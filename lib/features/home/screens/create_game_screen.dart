import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/game_providers.dart';
import '../../../core/providers/session_provider.dart';
import '../../../core/providers/team_providers.dart';
import '../../../core/services/game_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_input.dart';
import '../../../core/widgets/wilaya_dropdown.dart';
import '../../../l10n/app_localizations.dart';

class CreateGameScreen extends ConsumerStatefulWidget {
  const CreateGameScreen({super.key});

  @override
  ConsumerState<CreateGameScreen> createState() => _CreateGameScreenState();
}

class _CreateGameScreenState extends ConsumerState<CreateGameScreen> {
  final _field = TextEditingController();
  final _details = TextEditingController();
  String _format = '5';
  String? _city;
  DateTime? _day;
  TimeOfDay? _time;
  int _duration = 90;
  Uint8List? _photoBytes;
  String _photoExt = 'jpg';
  bool _saving = false;
  bool _prefilled = false;

  @override
  void dispose() {
    _field.dispose();
    _details.dispose();
    super.dispose();
  }

  Future<void> _pickDay() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _day ?? now,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: now.add(const Duration(days: 90)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
              primary: AppColors.green, surface: AppColors.darkSurface),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _day = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time ?? const TimeOfDay(hour: 19, minute: 0),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.dark(
              primary: AppColors.green, surface: AppColors.darkSurface),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _pickPhoto() async {
    final x = await ImagePicker().pickImage(
        source: ImageSource.gallery, maxWidth: 1280, imageQuality: 80);
    if (x == null) return;
    final bytes = await x.readAsBytes();
    setState(() {
      _photoBytes = bytes;
      _photoExt = x.path.split('.').last.toLowerCase();
      if (_photoExt == 'jpeg') _photoExt = 'jpg';
    });
  }

  Future<void> _post() async {
    final t = AppLocalizations.of(context);
    final teamId = ref.read(myTeamIdProvider);
    if (teamId == null || ref.read(userRoleProvider) != UserRole.captain) {
      _snack(t.onlyCaptainsPost);
      return;
    }
    if (_city == null ||
        _field.text.trim().isEmpty ||
        _day == null ||
        _time == null) {
      _snack(t.fieldRequired);
      return;
    }
    final kickoff = DateTime(
        _day!.year, _day!.month, _day!.day, _time!.hour, _time!.minute);
    setState(() => _saving = true);
    try {
      String? photoUrl;
      if (_photoBytes != null) {
        photoUrl = await GameService.uploadPhoto(_photoBytes!, _photoExt);
      }
      await GameService.createGame(
        hostTeamId: teamId,
        format: _format,
        city: _city!,
        fieldAddress: _field.text.trim(),
        kickoff: kickoff,
        durationMinutes: _duration,
        photoUrl: photoUrl,
        details: _details.text.trim().isEmpty ? null : _details.text.trim(),
      );
      ref.invalidate(feedProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(t.gamePosted)));
      context.pop();
    } on GameFailure catch (e) {
      _snack(e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _snack(String m) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(m), backgroundColor: AppColors.red));

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final localeCode = Localizations.localeOf(context).languageCode;

    // Default the city to the captain's team city once loaded.
    final myTeam = ref.watch(myTeamProvider).valueOrNull;
    if (!_prefilled && myTeam?.city != null) {
      _city = myTeam!.city;
      _prefilled = true;
    }

    return Scaffold(
      appBar: AppBar(title: Text(t.createGameTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          Text(t.createGameSubtitle,
              style: AppTextStyles.body(AppColors.darkTextSecondary)),
          const SizedBox(height: 20),

          // Format chips.
          Text(t.gameFormat,
              style: AppTextStyles.label(AppColors.darkTextSecondary)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final f in ['5', '7', '9', '11'])
                ChoiceChip(
                  label: Text(t.asideLabel(f)),
                  selected: _format == f,
                  onSelected: (_) => setState(() => _format = f),
                  selectedColor: AppColors.green,
                  labelStyle: TextStyle(
                      color: _format == f
                          ? Colors.white
                          : AppColors.darkTextSecondary),
                  backgroundColor: AppColors.darkCard,
                ),
            ],
          ),
          const SizedBox(height: 16),

          WilayaDropdown(
            label: t.cityWilaya,
            hint: t.selectCity,
            value: _city,
            onChanged: (v) => setState(() => _city = v),
          ),
          const SizedBox(height: 16),
          CustomInput(
              label: t.fieldAddress,
              hint: t.fieldAddressHint,
              controller: _field),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _pickerField(
                  label: t.gameDay,
                  icon: Icons.event_rounded,
                  value: _day == null
                      ? t.selectDate
                      : DateFormat('EEE d MMM', localeCode).format(_day!),
                  placeholder: _day == null,
                  onTap: _pickDay,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _pickerField(
                  label: t.gameTime,
                  icon: Icons.schedule_rounded,
                  value: _time == null
                      ? t.selectTime
                      : _time!.format(context),
                  placeholder: _time == null,
                  onTap: _pickTime,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Duration stepper.
          Text('${t.durationLabel}: $_duration ${t.minutesShort}',
              style: AppTextStyles.label(AppColors.darkTextSecondary)),
          Slider(
            value: _duration.toDouble(),
            min: 30,
            max: 120,
            divisions: 6,
            activeColor: AppColors.green,
            label: '$_duration',
            onChanged: (v) => setState(() => _duration = v.round()),
          ),
          const SizedBox(height: 8),

          // Photo.
          _photoPicker(t),
          const SizedBox(height: 16),

          CustomInput(
            label: t.gameDetailsOptional,
            hint: t.gameDetailsHint,
            controller: _details,
            maxLines: 3,
            maxLength: 200,
          ),
          const SizedBox(height: 24),
          CustomButton(
            label: t.postGameBtn,
            icon: Icons.send_rounded,
            isLoading: _saving,
            onPressed: _saving ? null : _post,
          ),
        ],
      ),
    );
  }

  Widget _pickerField({
    required String label,
    required IconData icon,
    required String value,
    required bool placeholder,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label(AppColors.darkTextSecondary)),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.darkBorder),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppColors.darkTextMuted),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(value,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: placeholder
                              ? AppColors.darkTextMuted
                              : AppColors.darkTextPrimary)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _photoPicker(AppLocalizations t) {
    return InkWell(
      onTap: _pickPhoto,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.darkBorder),
          image: _photoBytes != null
              ? DecorationImage(
                  image: MemoryImage(_photoBytes!), fit: BoxFit.cover)
              : null,
        ),
        alignment: Alignment.center,
        child: _photoBytes == null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add_photo_alternate_rounded,
                      color: AppColors.darkTextMuted, size: 30),
                  const SizedBox(height: 6),
                  Text(t.addPhoto,
                      style: AppTextStyles.label(AppColors.darkTextMuted)),
                ],
              )
            : null,
      ),
    );
  }
}
