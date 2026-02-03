import 'package:radio_player/domain/entities/station.dart';
import 'package:radio_player/domain/repositories/vote_repository.dart';

class VoteStation {
  VoteStation(this._repository);

  final VoteRepository _repository;

  Future<bool> call(Station station) => _repository.vote(station);
}
