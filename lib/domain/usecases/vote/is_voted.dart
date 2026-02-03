import 'package:radio_player/domain/repositories/vote_repository.dart';

class IsVoted {
  IsVoted(this._repository);

  final VoteRepository _repository;

  bool call(String stationId) => _repository.isVoted(stationId);
}
