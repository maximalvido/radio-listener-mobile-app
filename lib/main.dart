import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:radio_player/app.dart';
import 'package:radio_player/data/datasources/local/favorites_local_datasource.dart';
import 'package:radio_player/data/datasources/local/user_stations_local_datasource.dart';
import 'package:radio_player/data/datasources/remote/stations_remote_datasource.dart';
import 'package:radio_player/data/repositories/favorites_repository_impl.dart';
import 'package:radio_player/data/repositories/vote_repository_impl.dart';
import 'package:radio_player/data/repositories/playback_repository_impl.dart';
import 'package:radio_player/data/repositories/stations_repository_impl.dart';
import 'package:radio_player/domain/repositories/favorites_repository.dart';
import 'package:radio_player/domain/repositories/vote_repository.dart';
import 'package:radio_player/domain/usecases/favorites/get_favorites.dart';
import 'package:radio_player/domain/usecases/favorites/is_favorite.dart';
import 'package:radio_player/domain/usecases/favorites/toggle_favorite.dart';
import 'package:radio_player/domain/usecases/playback/pause.dart';
import 'package:radio_player/domain/usecases/playback/play.dart';
import 'package:radio_player/domain/usecases/playback/set_station_and_play.dart';
import 'package:radio_player/domain/usecases/playback/set_volume.dart';
import 'package:radio_player/domain/usecases/playback/stop.dart';
import 'package:radio_player/domain/usecases/stations/get_stations_first_page.dart';
import 'package:radio_player/domain/usecases/stations/get_stations_next_page.dart';
import 'package:radio_player/features/favorites/favorites_bloc.dart';
import 'package:radio_player/features/player/player_bloc.dart';
import 'package:radio_player/features/splash/splash_screen.dart';
import 'package:radio_player/features/stations/stations_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  final prefs = await SharedPreferences.getInstance();
  final stationsRemote = StationsRemoteDataSourceImpl();
  final favoritesLocal = FavoritesLocalDataSourceImpl(prefs);

  final stationsRepo = StationsRepositoryImpl(stationsRemote);
  final favoritesRepo = FavoritesRepositoryImpl(favoritesLocal);
  await favoritesRepo.getFavorites();

  final userStationsLocal = UserStationsLocalDataSourceImpl();
  final voteRepo = VoteRepositoryImpl(stationsRemote, userStationsLocal);
  await voteRepo.loadVotedIds();

  final playbackRepo = await PlaybackRepositoryImpl.create();

  final getStationsFirstPage = GetStationsFirstPage(stationsRepo);
  final getStationsNextPage = GetStationsNextPage(stationsRepo);
  final getFavorites = GetFavorites(favoritesRepo);
  final toggleFavorite = ToggleFavorite(favoritesRepo);
  final isFavorite = IsFavorite(favoritesRepo);
  final setStationAndPlay = SetStationAndPlay(playbackRepo);
  final play = Play(playbackRepo);
  final pause = Pause(playbackRepo);
  final setVolume = SetVolume(playbackRepo);
  final stop = Stop(playbackRepo);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<FavoritesRepository>.value(value: favoritesRepo),
        RepositoryProvider<VoteRepository>.value(value: voteRepo),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) =>
                StationsBloc(getStationsFirstPage, getStationsNextPage),
          ),
          BlocProvider(
            create: (_) =>
                FavoritesBloc(getFavorites, toggleFavorite, isFavorite),
          ),
          BlocProvider(
            create: (_) => PlayerBloc(
              playbackRepo,
              setStationAndPlay,
              play,
              pause,
              setVolume,
              stop,
            ),
          ),
        ],
        child: const _SplashThenApp(),
      ),
    ),
  );
}

class _SplashThenApp extends StatefulWidget {
  const _SplashThenApp();

  @override
  State<_SplashThenApp> createState() => _SplashThenAppState();
}

class _SplashThenAppState extends State<_SplashThenApp> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _showSplash = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return MaterialApp(
        theme: ThemeData.dark(),
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(),
      );
    }
    return const App();
  }
}
