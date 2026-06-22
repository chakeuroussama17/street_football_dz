import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/providers/auth_providers.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/team_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_input.dart';
import '../../../core/widgets/onboarding_scaffold.dart';
import '../../../core/widgets/wilaya_dropdown.dart';
import '../../../l10n/app_localizations.dart';

class CreateTeamScreen extends ConsumerStatefulWidget {
  const CreateTeamScreen({super.key});

  @override
  ConsumerState<CreateTeamScreen> createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends ConsumerState<CreateTeamScreen> {
  final _name = TextEditingController();
  final _details = TextEditingController();
  final _minAge = TextEditingController();
  final _maxAge = TextEditingController();
  String? _city;
  Uint8List? _logoBytes;
  String _logoExt = 'jpg';
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _details.dispose();
    _minAge.dispose();
    _maxAge.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final x = await ImagePicker().pickImage(
        source: ImageSource.gallery, maxWidth: 800, imageQuality: 80);
    if (x == null) return;
    final bytes = await x.readAsBytes();
    setState(() {
      _logoBytes = bytes;
      _logoExt = x.path.split('.').last.toLowerCase();
      if (_logoExt == 'jpeg') _logoExt = 'jpg';
    });
  }

  Future<void> _create() async {
    final t = AppLocalizations.of(context);
    final draft = ref.read(onboardingDraftProvider);
    if (draft == null) {
      context.goNamed('welcome');
      return;
    }
    if (_name.text.trim().isEmpty || _city == null) {
      _snack(t.fieldRequired);
      return;
    }
    setState(() => _loading = true);
    try {
      // 1. Ensure the users row exists (FK target for the team).
      await AuthService.upsertProfile(
        fullName: draft.fullName,
        dateOfBirth: draft.dateOfBirth,
        city: draft.city,
        phone: draft.phone,
        role: 'captain',
      );
      // 2. Optional logo upload.
      String? logoUrl;
      if (_logoBytes != null) {
        logoUrl = await TeamService.uploadLogo(_logoBytes!, _logoExt);
      }
      // 3. Create the team.
      final team = await TeamService.createTeam(
        name: _name.text.trim(),
        city: _city!,
        ageMin: int.tryParse(_minAge.text),
        ageMax: int.tryParse(_maxAge.text),
        details: _details.text.trim().isEmpty ? null : _details.text.trim(),
        logoUrl: logoUrl,
      );
      // 4. Link the captain to the team.
      await AuthService.setTeam(team.id, role: 'captain');
      final me = await AuthService.currentAppUser();
      if (!mounted) return;
      applySessionStateW(ref, me);
      ref.read(onboardingDraftProvider.notifier).state = null;
      await _showCodeDialog(team.teamCode);
    } on AuthFailure catch (e) {
      _snack(e.message);
    } on TeamFailure catch (e) {
      _snack(e.message);
    } catch (_) {
      _snack(t.fieldRequired);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _showCodeDialog(String code) async {
    final t = AppLocalizations.of(context);
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: Text(t.teamCreatedTitle,
            style: AppTextStyles.headline(AppColors.darkTextPrimary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(t.teamCreatedBody,
                style: AppTextStyles.body(AppColors.darkTextSecondary)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              decoration: BoxDecoration(
                gradient: AppColors.brandGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                code,
                style: AppTextStyles.display(Colors.white)
                    .copyWith(letterSpacing: 8, fontSize: 30),
              ),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: code));
                ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text(t.codeCopied)));
              },
              icon: const Icon(Icons.copy_rounded,
                  size: 18, color: AppColors.green),
              label: Text(t.copyCode,
                  style: const TextStyle(color: AppColors.green)),
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              label: t.letsGo,
              onPressed: () {
                Navigator.of(ctx).pop();
                context.goNamed('home');
              },
            ),
          ),
        ],
      ),
    );
  }

  void _snack(String m) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(m), backgroundColor: AppColors.red));

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return OnboardingScaffold(
      title: t.createTeamTitle,
      subtitle: t.createTeamSubtitle,
      bottom: CustomButton(
        label: t.createTeamBtn,
        icon: Icons.add_rounded,
        isLoading: _loading,
        onPressed: _loading ? null : _create,
      ),
      children: [
        Center(child: _logoPicker(t)),
        const SizedBox(height: 24),
        CustomInput(label: t.teamName, controller: _name),
        const SizedBox(height: 16),
        WilayaDropdown(
          label: t.cityWilaya,
          hint: t.selectCity,
          value: _city,
          onChanged: (v) => setState(() => _city = v),
        ),
        const SizedBox(height: 16),
        Text(t.ageRangeOptional,
            style: AppTextStyles.label(AppColors.darkTextSecondary)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: CustomInput(
                label: t.minAge,
                controller: _minAge,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 2,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomInput(
                label: t.maxAge,
                controller: _maxAge,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CustomInput(
          label: t.teamDetailsOptional,
          controller: _details,
          maxLines: 3,
          maxLength: 200,
        ),
      ],
    );
  }

  Widget _logoPicker(AppLocalizations t) {
    return GestureDetector(
      onTap: _pickLogo,
      child: Column(
        children: [
          Container(
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.darkCard,
              border: Border.all(color: AppColors.darkBorder),
              image: _logoBytes != null
                  ? DecorationImage(
                      image: MemoryImage(_logoBytes!), fit: BoxFit.cover)
                  : null,
            ),
            child: _logoBytes == null
                ? const Icon(Icons.add_a_photo_rounded,
                    color: AppColors.darkTextMuted, size: 30)
                : null,
          ),
          const SizedBox(height: 8),
          Text(t.teamLogoOptional,
              style: AppTextStyles.label(AppColors.darkTextMuted)),
        ],
      ),
    );
  }
}
