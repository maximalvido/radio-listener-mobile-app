import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

abstract class UserStationsLocalDataSource {
  Future<Set<String>> getVotedStationIds();
  Future<void> addVotedStationId(String stationId);
}

class UserStationsLocalDataSourceImpl implements UserStationsLocalDataSource {
  static const String _fileName = 'user_stations.json';
  static const String _keyVotedIds = 'votedStationIds';

  Set<String> _votedIds = {};
  bool _loaded = false;

  Future<File> get _file async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<void> _load() async {
    if (_loaded) return;
    _loaded = true;
    try {
      final f = await _file;
      if (!await f.exists()) return;
      final raw = await f.readAsString();
      final map = json.decode(raw) as Map<String, dynamic>;
      final list = map[_keyVotedIds];
      if (list is List<dynamic>) {
        _votedIds = list
            .map((e) => e.toString())
            .where((id) => id.isNotEmpty)
            .toSet();
      }
    } catch (_) {
      _votedIds = {};
    }
  }

  Future<void> _save() async {
    final f = await _file;
    await f.writeAsString(
      json.encode({_keyVotedIds: _votedIds.toList()}),
      flush: true,
    );
  }

  @override
  Future<Set<String>> getVotedStationIds() async {
    await _load();
    return Set.from(_votedIds);
  }

  @override
  Future<void> addVotedStationId(String stationId) async {
    await _load();
    if (stationId.isEmpty) return;
    _votedIds.add(stationId);
    await _save();
  }

  Future<bool> isVoted(String stationId) async {
    await _load();
    return _votedIds.contains(stationId);
  }
}
