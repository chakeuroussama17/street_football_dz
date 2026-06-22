import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../../l10n/app_localizations.dart';

/// Coloured chip for a game's status.
class StatusChip extends StatelessWidget {
  final String status; // open | matched | completed | cancelled
  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final (label, color) = switch (status) {
      'open' => (t.statusOpen, AppColors.gold),
      'matched' => (t.statusMatched, AppColors.green),
      'completed' => (t.statusCompleted, AppColors.info),
      _ => (t.statusCancelled, AppColors.darkTextMuted),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: AppTextStyles.label(color)),
    );
  }
}
