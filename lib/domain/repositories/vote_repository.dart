import 'package:radio_player/domain/entities/station.dart';

abstract class VoteRepository {
  Future<bool> vote(Station station);
  bool isVoted(String stationId);
}
