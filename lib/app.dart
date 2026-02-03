import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:radio_player/components/mini_player.dart';
import 'package:radio_player/core/theme/app_theme.dart';
import 'package:radio_player/features/favorites/favorites_view.dart';
import 'package:radio_player/features/player/player_bloc.dart';
import 'package:radio_player/features/player/player_view.dart';
import 'package:radio_player/features/stations/all_stations_view.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RadioWave',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const _AppShell(),
    );
  }
}

class _AppShell extends StatefulWidget {
  const _AppShell();

  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> {
  int _currentIndex = 0;

  static const _tabs = [
    (icon: Icons.sensors, label: 'Stations'),
    (icon: Icons.favorite_border, label: 'Favorites'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: IndexedStack(
        index: _currentIndex,
        children: const [AllStationsView(), FavoritesView()],
      ),
      bottomNavigationBar: BlocBuilder<PlayerBloc, PlayerState>(
        buildWhen: (prev, next) =>
            prev.showMiniPlayer != next.showMiniPlayer ||
            prev.currentStation != next.currentStation ||
            prev.isPlaying != next.isPlaying,
        builder: (context, state) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (state.showMiniPlayer && state.currentStation != null)
                MiniPlayer(
                  station: state.currentStation!,
                  isPlaying: state.isPlaying,
                  onTap: () => Navigator.of(context).push(
                    PlayerView.route(
                      initialStation: state.currentStation,
                      stations: state.stations,
                      listTitle: state.listTitle,
                    ),
                  ),
                  onPlayPause: () => context.read<PlayerBloc>().add(
                    const PlayerPlayPauseToggled(),
                  ),
                  onDismiss: () => context.read<PlayerBloc>().add(
                    const PlayerDismissRequested(),
                  ),
                ),
              BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (i) => setState(() => _currentIndex = i),
                items: _tabs
                    .asMap()
                    .entries
                    .map(
                      (e) => BottomNavigationBarItem(
                        icon: Icon(e.value.icon),
                        label: e.value.label,
                      ),
                    )
                    .toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}
