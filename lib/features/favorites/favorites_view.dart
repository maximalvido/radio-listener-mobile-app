import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:radio_player/components/station_card.dart';
import 'package:radio_player/domain/entities/station.dart';
import 'package:radio_player/core/theme/app_theme.dart';
import 'package:radio_player/core/theme/text_styles.dart';
import 'package:radio_player/features/favorites/favorites_bloc.dart';
import 'package:radio_player/features/player/player_bloc.dart';
import 'package:radio_player/features/player/player_view.dart';

class FavoritesView extends StatelessWidget {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      appBar: AppBar(title: const Text('Favorites')),
      body: BlocBuilder<FavoritesBloc, FavoritesState>(
        builder: (context, state) {
          if (state is FavoritesInitial) {
            context.read<FavoritesBloc>().add(const FavoritesLoadRequested());
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryPurple),
            );
          }
          final stations = state is FavoritesLoaded
              ? state.stations
              : <Station>[];
          if (stations.isEmpty) {
            return const Center(
              child: Text(
                'No favorites yet.\nTap the heart on a station to add it.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMuted,
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: stations.length,
            itemBuilder: (context, index) {
              final station = stations[index];
              return StationCard(
                station: station,
                isFavorite: true,
                onTap: () {
                  context.read<PlayerBloc>().add(
                    PlayerStationSelected(
                      station,
                      stations: stations,
                      listTitle: 'Favorites',
                    ),
                  );
                  Navigator.of(context).push(
                    PlayerView.route(
                      initialStation: station,
                      stations: stations,
                      listTitle: 'Favorites',
                    ),
                  );
                },
                onFavoriteToggle: () => context.read<FavoritesBloc>().add(
                  FavoritesToggleRequested(station),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
