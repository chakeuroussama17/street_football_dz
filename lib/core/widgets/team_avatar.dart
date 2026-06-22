import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// Circular team logo. Falls back to the team's initials on a brand gradient
/// when there's no image. Also reused for user avatars.
class TeamAvatar extends StatelessWidget {
  final String? imageUrl;
  final String name;
  final double size;

  const TeamAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = 48,
  });

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.take(2).toString().toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: hasImage ? null : AppColors.brandGradientHot,
        border: Border.all(color: AppColors.darkBorder),
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: hasImage
          ? CachedNetworkImage(
              imageUrl: imageUrl!,
              fit: BoxFit.cover,
              width: size,
              height: size,
              placeholder: (_, _) => const ColoredBox(color: AppColors.darkCard),
              errorWidget: (_, _, _) => _initialsLabel(),
            )
          : _initialsLabel(),
    );
  }

  Widget _initialsLabel() => Text(
        _initials,
        style: GoogleFonts.spaceGrotesk(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.36,
        ),
      );
}
