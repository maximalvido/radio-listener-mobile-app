import 'package:radio_player/data/datasources/local/user_stations_local_datasource.dart';
import 'package:radio_player/data/datasources/remote/stations_remote_datasource.dart';
import 'package:radio_player/domain/entities/station.dart';
import 'package:radio_player/domain/repositories/vote_repository.dart';

class VoteRepositoryImpl implements VoteRepository {
  VoteRepositoryImpl(this._remote, this._local);

  final StationsRemoteDataSource _remote;
  final UserStationsLocalDataSource _local;

  final Set<String> _votedIds = {};
  bool _loaded = false;

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    _loaded = true;
    _votedIds.addAll(await _local.getVotedStationIds());
  }

  @override
  Future<bool> vote(Station station) async {
    if (station.id.isEmpty) return false;
    final ok = await _remote.voteStation(station.id);
    if (!ok) return false;
    await _ensureLoaded();
    _votedIds.add(station.id);
    await _local.addVotedStationId(station.id);
    return true;
  }

  @override
  bool isVoted(String stationId) {
    return _votedIds.contains(stationId);
  }

  Future<void> loadVotedIds() async {
    await _ensureLoaded();
  }
}
