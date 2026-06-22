import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/providers/team_providers.dart';
import '../../../core/services/team_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_input.dart';
import '../../../core/widgets/team_avatar.dart';
import '../../../core/widgets/wilaya_dropdown.dart';
import '../../../l10n/app_localizations.dart';

class EditTeamScreen extends ConsumerStatefulWidget {
  final String id;
  const EditTeamScreen({super.key, required this.id});

  @override
  ConsumerState<EditTeamScreen> createState() => _EditTeamScreenState();
}

class _EditTeamScreenState extends ConsumerState<EditTeamScreen> {
  final _name = TextEditingController();
  final _details = TextEditingController();
  final _minAge = TextEditingController();
  final _maxAge = TextEditingController();
  String? _city;
  String? _logoUrl;
  Uint8List? _logoBytes;
  String _logoExt = 'jpg';
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final team = await TeamService.fetchTeam(widget.id);
    if (!mounted) return;
    if (team != null) {
      _name.text = team.name;
      _details.text = team.details ?? '';
      _minAge.text = team.ageMin?.toString() ?? '';
      _maxAge.text = team.ageMax?.toString() ?? '';
      _city = team.city;
      _logoUrl = team.logoUrl;
    }
    setState(() => _loading = false);
  }

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

  Future<void> _save() async {
    final t = AppLocalizations.of(context);
    if (_name.text.trim().isEmpty || _city == null) {
      _snack(t.fieldRequired);
      return;
    }
    setState(() => _saving = true);
    try {
      String? logoUrl;
      if (_logoBytes != null) {
        logoUrl = await TeamService.uploadLogo(_logoBytes!, _logoExt);
      }
      await TeamService.updateTeam(
        widget.id,
        name: _name.text.trim(),
        city: _city,
        ageMin: int.tryParse(_minAge.text),
        ageMax: int.tryParse(_maxAge.text),
        details: _details.text.trim(),
        logoUrl: logoUrl,
      );
      ref.invalidate(myTeamProvider);
      ref.invalidate(teamProvider(widget.id));
      ref.invalidate(rosterProvider(widget.id));
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t.teamSaved)));
      context.pop();
    } catch (_) {
      _snack(t.retry);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _snack(String m) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(m), backgroundColor: AppColors.red));

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(t.editTeam)),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.green))
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _pickLogo,
                    child: _logoBytes != null
                        ? CircleAvatar(
                            radius: 52,
                            backgroundImage: MemoryImage(_logoBytes!))
                        : TeamAvatar(
                            name: _name.text.isEmpty ? '?' : _name.text,
                            imageUrl: _logoUrl,
                            size: 104),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                    child: Text(t.addLogo,
                        style: AppTextStyles.label(AppColors.darkTextMuted))),
                const SizedBox(height: 20),
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
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        maxLength: 2,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomInput(
                        label: t.maxAge,
                        controller: _maxAge,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
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
                const SizedBox(height: 24),
                CustomButton(
                  label: t.save,
                  icon: Icons.check_rounded,
                  isLoading: _saving,
                  onPressed: _saving ? null : _save,
                ),
              ],
            ),
    );
  }
}
