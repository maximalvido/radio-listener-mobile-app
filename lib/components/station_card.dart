import 'package:flutter/material.dart';
import 'package:radio_player/domain/entities/station.dart';
import 'package:radio_player/core/theme/app_theme.dart';
import 'package:radio_player/core/theme/border_radius.dart';
import 'package:radio_player/core/theme/colors.dart';
import 'package:radio_player/core/theme/text_styles.dart';
import 'package:radio_player/components/genre_chip.dart';

class StationCard extends StatelessWidget {
  const StationCard({
    super.key,
    required this.station,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  final Station station;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppBorderRadius.radiusCard,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              _StationThumb(faviconUrl: station.faviconUrl, name: station.name),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      station.name,
                      style: AppTextStyles.stationTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (station.tags.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: station.tags
                            .take(3)
                            .map((t) => GenreChip(label: t))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite
                      ? AppTheme.primaryPurple
                      : AppColors.onSurfaceMuted,
                  size: 24,
                ),
                onPressed: onFavoriteToggle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StationThumb extends StatelessWidget {
  const _StationThumb({this.faviconUrl, required this.name});

  final String? faviconUrl;
  final String name;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppBorderRadius.radiusMd,
      child: SizedBox(
        width: 56,
        height: 56,
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
        style: AppTextStyles.stationThumbPlaceholder,
      ),
    );
  }
}
