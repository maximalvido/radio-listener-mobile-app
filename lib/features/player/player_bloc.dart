import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:radio_player/domain/entities/station.dart';
import 'package:radio_player/domain/repositories/playback_repository.dart';
import 'package:radio_player/domain/usecases/playback/pause.dart';
import 'package:radio_player/domain/usecases/playback/play.dart';
import 'package:radio_player/domain/usecases/playback/set_station_and_play.dart';
import 'package:radio_player/domain/usecases/playback/set_volume.dart';
import 'package:radio_player/domain/usecases/playback/stop.dart';

part 'player_event.dart';
part 'player_state.dart';

class PlayerBloc extends Bloc<PlayerEvent, PlayerState> {
  PlayerBloc(
    this._playback,
    this._setStationAndPlay,
    this._play,
    this._pause,
    this._setVolume,
    this._stop,
  ) : super(PlayerState.initial()) {
    on<PlayerStationSelected>(_onStationSelected);
    on<PlayerPlayPauseToggled>(_onPlayPauseToggled);
    on<PlayerVolumeChanged>(_onVolumeChanged);
    on<PlayerDismissRequested>(_onDismissRequested);
    on<PlayerPositionUpdated>(_onPositionUpdated);
    on<PlayerPlayingStateChanged>(_onPlayingStateChanged);
    on<PlayerSyncPlayingState>(_onSyncPlayingState);
    _listenToPlayback();
    _playback.stop();
  }

  final PlaybackRepository _playback;
  final SetStationAndPlay _setStationAndPlay;
  final Play _play;
  final Pause _pause;
  final SetVolume _setVolume;
  final Stop _stop;

  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<void>? _completedSub;
  StreamSubscription<bool>? _playingSub;

  void _listenToPlayback() {
    _positionSub = _playback.positionStream.listen((position) {
      add(PlayerPositionUpdated(position: position));
    });
    _completedSub = _playback.completedStream.listen((_) {
      add(const PlayerDismissRequested());
    });
    _playingSub = _playback.playingStream.listen((isPlaying) {
      add(PlayerPlayingStateChanged(isPlaying));
    });
  }

  Future<void> _onStationSelected(
    PlayerStationSelected event,
    Emitter<PlayerState> emit,
  ) async {
    if (state.currentStation?.id == event.station.id) {
      return;
    }
    emit(
      PlayerState(
        currentStation: event.station,
        isPlaying: false,
        isStreamReady: false,
        volume: state.volume,
        position: Duration.zero,
        showMiniPlayer: true,
        stations: event.stations ?? state.stations,
        listTitle: event.listTitle ?? state.listTitle,
      ),
    );
    try {
      await _setStationAndPlay(event.station, volume: state.volume);
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!isClosed) add(const PlayerSyncPlayingState());
      });
    } catch (_) {
      emit(state.copyWith(showMiniPlayer: true));
    }
  }

  Future<void> _onPlayPauseToggled(
    PlayerPlayPauseToggled event,
    Emitter<PlayerState> emit,
  ) async {
    if (state.currentStation == null) return;
    if (state.isPlaying) {
      await _pause();
      emit(state.copyWith(isPlaying: false));
    } else {
      await _play();
      emit(state.copyWith(isPlaying: true));
    }
  }

  Future<void> _onVolumeChanged(
    PlayerVolumeChanged event,
    Emitter<PlayerState> emit,
  ) async {
    final v = (event.volume.clamp(0.0, 1.0) * 100).round() / 100.0;
    await _setVolume(v);
    emit(state.copyWith(volume: v));
  }

  void _onDismissRequested(
    PlayerDismissRequested event,
    Emitter<PlayerState> emit,
  ) async {
    await _stop();
    emit(PlayerState.initial());
  }

  void _onPositionUpdated(
    PlayerPositionUpdated event,
    Emitter<PlayerState> emit,
  ) {
    if (state.currentStation != null) {
      emit(state.copyWith(position: event.position));
    }
  }

  void _onPlayingStateChanged(
    PlayerPlayingStateChanged event,
    Emitter<PlayerState> emit,
  ) {
    if (state.currentStation == null) return;
    if (state.isPlaying != event.isPlaying) {
      emit(
        state.copyWith(
          isPlaying: event.isPlaying,
          isStreamReady: state.isStreamReady || event.isPlaying,
        ),
      );
    }
  }

  void _onSyncPlayingState(
    PlayerSyncPlayingState event,
    Emitter<PlayerState> emit,
  ) {
    if (state.currentStation == null) return;
    final playing = _playback.isPlayingNow;
    if (state.isPlaying != playing || (!state.isStreamReady && playing)) {
      emit(
        state.copyWith(
          isPlaying: playing,
          isStreamReady: state.isStreamReady || playing,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _positionSub?.cancel();
    _completedSub?.cancel();
    _playingSub?.cancel();
    _playback.dispose();
    return super.close();
  }
}
