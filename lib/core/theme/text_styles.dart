import 'package:flutter/material.dart';
import 'package:radio_player/core/theme/colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle splashTitle = TextStyle(
    color: AppColors.onSurface,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.2,
  );
  static const TextStyle splashSubtitle = TextStyle(
    color: AppColors.onSurfaceMuted,
    fontSize: 16,
  );

  static const TextStyle appBarTitle = TextStyle(
    color: AppColors.onSurface,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle nowPlayingHeader = TextStyle(
    color: AppColors.onSurface,
    fontSize: 14,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.2,
  );

  static const TextStyle searchInput = TextStyle(
    color: AppColors.onSurface,
    fontSize: 16,
  );

  static const TextStyle genreChip = TextStyle(
    color: AppColors.onSurfaceSecondary,
    fontSize: 10,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle stationTitle = TextStyle(
    color: AppColors.onSurface,
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle stationThumbPlaceholder = TextStyle(
    color: AppColors.accentPurple,
    fontSize: 22,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle miniPlayerTitle = TextStyle(
    color: AppColors.onSurface,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle miniPlayerSubtitle = TextStyle(
    color: AppColors.onSurfaceMuted,
    fontSize: 12,
  );
  static const TextStyle miniPlayerThumbPlaceholder = TextStyle(
    color: AppColors.accentPurple,
    fontSize: 18,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle playerStationName = TextStyle(
    color: AppColors.onSurface,
    fontSize: 22,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle playerGenre = TextStyle(
    color: AppColors.primaryPurple,
    fontSize: 14,
  );
  static const TextStyle playerLive = TextStyle(
    color: AppColors.onSurfaceSecondary,
    fontSize: 12,
  );
  static const TextStyle playerArtworkPlaceholder = TextStyle(
    color: AppColors.accentPurple,
    fontSize: 64,
    fontWeight: FontWeight.bold,
  );
  static const TextStyle playerProgressLabel = TextStyle(
    color: AppColors.onSurfaceSecondary,
    fontSize: 12,
  );
  static const TextStyle playerVolumeLabel = TextStyle(
    color: AppColors.onSurfaceSecondary,
    fontSize: 12,
  );

  static const TextStyle bodyMuted = TextStyle(
    color: AppColors.onSurfaceMuted,
    fontSize: 16,
  );
  static const TextStyle bodySecondary = TextStyle(
    color: AppColors.onSurfaceSecondary,
    fontSize: 16,
  );
}
