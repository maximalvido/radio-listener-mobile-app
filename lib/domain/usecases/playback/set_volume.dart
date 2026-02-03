import 'package:radio_player/domain/repositories/playback_repository.dart';

class SetVolume {
  SetVolume(this._repository);

  final PlaybackRepository _repository;

  Future<void> call(double volume) => _repository.setVolume(volume);
}
