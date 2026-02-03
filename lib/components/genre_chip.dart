import 'package:flutter/material.dart';
import 'package:radio_player/core/theme/app_theme.dart';
import 'package:radio_player/core/theme/border_radius.dart';
import 'package:radio_player/core/theme/text_styles.dart';

class GenreChip extends StatelessWidget {
  const GenreChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: AppBorderRadius.radiusSm,
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.genreChip,
      ),
    );
  }
}
