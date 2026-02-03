import 'dart:async';

import 'package:radio_player/domain/entities/station.dart';

abstract class PlaybackRepository {
  Future<void> setStationAndPlay(Station station, {required double volume});
  Future<void> pause();
  Future<void> play();
  Future<void> setVolume(double volume);
  Future<void> stop();
  Stream<Duration> get positionStream;
  Stream<bool> get playingStream;
  bool get isPlayingNow;
  Stream<void> get completedStream;
  void dispose();
}
