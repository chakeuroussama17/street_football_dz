import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/algeria.dart';
import '../theme/app_colors.dart';

/// A dropdown of the 58 Algerian wilayas. Stores the canonical Latin name and
/// displays the Arabic or Latin label based on the current locale.
class WilayaDropdown extends StatelessWidget {
  final String label;
  final String? value; // stored Latin name
  final ValueChanged<String?> onChanged;
  final String? hint;
  final bool includeAllOption; // for filters: an "All wilayas" entry (null)
  final String? allLabel;

  const WilayaDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.hint,
    this.includeAllOption = false,
    this.allLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localeCode = Localizations.localeOf(context).languageCode;
    final labelColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.inter(
                fontSize: 13, fontWeight: FontWeight.w500, color: labelColor)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String?>(
          initialValue: value,
          isExpanded: true,
          hint: hint == null ? null : Text(hint!),
          dropdownColor:
              isDark ? AppColors.darkSurface : AppColors.lightSurface,
          items: [
            if (includeAllOption)
              DropdownMenuItem<String?>(
                value: null,
                child: Text(allLabel ?? '—'),
              ),
            for (final w in Algeria.wilayas)
              DropdownMenuItem<String?>(
                value: w.fr,
                child: Text('${w.code.toString().padLeft(2, '0')} · '
                    '${w.label(localeCode)}'),
              ),
          ],
          onChanged: onChanged,
        ),
      ],
    );
  }
}
