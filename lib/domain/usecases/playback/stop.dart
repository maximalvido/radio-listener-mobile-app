import 'package:radio_player/domain/repositories/playback_repository.dart';

class Stop {
  Stop(this._repository);

  final PlaybackRepository _repository;

  Future<void> call() => _repository.stop();
}
