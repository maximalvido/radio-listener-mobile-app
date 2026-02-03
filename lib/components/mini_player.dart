import 'package:flutter/material.dart';
import 'package:radio_player/domain/entities/station.dart';
import 'package:radio_player/components/animated_wave_chart.dart';
import 'package:radio_player/core/theme/app_theme.dart';
import 'package:radio_player/core/theme/border_radius.dart';
import 'package:radio_player/core/theme/colors.dart';
import 'package:radio_player/core/theme/text_styles.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({
    super.key,
    required this.station,
    required this.isPlaying,
    required this.onTap,
    required this.onPlayPause,
    required this.onDismiss,
  });

  final Station station;
  final bool isPlaying;
  final VoidCallback onTap;
  final VoidCallback onPlayPause;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.surfaceDark,
      elevation: 8,
      child: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final height = constraints.maxHeight.isFinite
                ? constraints.maxHeight
                : 70.0;
            return Stack(
              children: [
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.35,
                    child: AnimatedWaveChart(
                      height: height,
                      isPlaying: isPlaying,
                      isLoading: false,
                      particleCount: 32,
                      color: AppTheme.primaryPurple,
                    ),
                  ),
                ),
                InkWell(
                  onTap: onTap,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        _MiniThumb(
                          faviconUrl: station.faviconUrl,
                          name: station.name,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                station.name,
                                style: AppTextStyles.miniPlayerTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                station.genreSubtitle,
                                style: AppTextStyles.miniPlayerSubtitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            color: AppColors.onSurface,
                            size: 28,
                          ),
                          onPressed: onPlayPause,
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: AppColors.onSurfaceMuted,
                            size: 22,
                          ),
                          onPressed: onDismiss,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MiniThumb extends StatelessWidget {
  const _MiniThumb({this.faviconUrl, required this.name});

  final String? faviconUrl;
  final String name;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppBorderRadius.radiusXs,
      child: SizedBox(
        width: 44,
        height: 44,
        child: faviconUrl != null && faviconUrl!.isNotEmpty
            ? Image.network(
                faviconUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _placeholder(),
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppTheme.cardBackground,
      alignment: Alignment.center,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: AppTextStyles.miniPlayerThumbPlaceholder,
      ),
    );
  }
}
