import 'dart:async';

import 'package:just_audio/just_audio.dart' as ja;
import 'package:radio_player/domain/entities/station.dart';
import 'package:radio_player/domain/repositories/playback_repository.dart';

class PlaybackRepositoryImpl implements PlaybackRepository {
  PlaybackRepositoryImpl(this._player);

  final ja.AudioPlayer _player;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<ja.PlayerState>? _stateSub;
  final _completedController = StreamController<void>.broadcast();

  Stream<void>? _completedStream;

  Stream<void> get _completed =>
      _completedStream ??= _completedController.stream;

  @override
  Future<void> setStationAndPlay(
    Station station, {
    required double volume,
  }) async {
    await _player.setVolume(volume);
    await _player.setUrl(station.streamUrl);
    await _player.play();
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> setVolume(double volume) => _player.setVolume(volume);

  @override
  Future<void> stop() => _player.stop();

  @override
  Stream<Duration> get positionStream => _player.positionStream;

  @override
  Stream<bool> get playingStream =>
      _player.playerStateStream.map((s) => s.playing).distinct();

  @override
  bool get isPlayingNow => _player.playerState.playing;

  @override
  Stream<void> get completedStream => _completed;

  void _listen() {
    _stateSub?.cancel();
    _stateSub = _player.playerStateStream.listen((s) {
      if (s.processingState == ja.ProcessingState.completed) {
        _completedController.add(null);
      }
    });
  }

  static Future<PlaybackRepositoryImpl> create() async {
    final player = ja.AudioPlayer();
    final repo = PlaybackRepositoryImpl(player);
    repo._listen();
    return repo;
  }

  @override
  void dispose() {
    _positionSub?.cancel();
    _stateSub?.cancel();
    _completedController.close();
    _player.dispose();
  }
}
