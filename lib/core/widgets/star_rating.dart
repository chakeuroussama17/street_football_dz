import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Read-only star display for a 0–5 average rating.
class StarRating extends StatelessWidget {
  final double value;
  final double size;
  const StarRating({super.key, required this.value, this.size = 16});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          Icon(
            value >= i
                ? Icons.star_rounded
                : (value >= i - 0.5
                    ? Icons.star_half_rounded
                    : Icons.star_outline_rounded),
            size: size,
            color: AppColors.gold,
          ),
      ],
    );
  }
}

/// Interactive 1–5 star picker (used by the rate-host dialog in Phase 5).
class StarPicker extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  final double size;
  const StarPicker({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          IconButton(
            onPressed: () => onChanged(i),
            iconSize: size,
            padding: const EdgeInsets.symmetric(horizontal: 2),
            constraints: const BoxConstraints(),
            icon: Icon(
              value >= i ? Icons.star_rounded : Icons.star_outline_rounded,
              color: AppColors.gold,
            ),
          ),
      ],
    );
  }
}
