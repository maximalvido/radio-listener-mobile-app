import 'package:radio_player/domain/entities/station.dart';
import 'package:radio_player/domain/repositories/playback_repository.dart';

class SetStationAndPlay {
  SetStationAndPlay(this._repository);

  final PlaybackRepository _repository;

  Future<void> call(Station station, {required double volume}) =>
      _repository.setStationAndPlay(station, volume: volume);
}
