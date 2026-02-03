import 'dart:convert';

import 'package:radio_player/data/models/station_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class FavoritesLocalDataSource {
  Future<List<StationModel>> getFavorites();
  Future<void> saveFavorites(List<StationModel> stations);
}

class FavoritesLocalDataSourceImpl implements FavoritesLocalDataSource {
  FavoritesLocalDataSourceImpl(this._prefs);

  final SharedPreferences _prefs;
  static const String _key = 'favorite_stations_json';

  @override
  Future<List<StationModel>> getFavorites() async {
    final raw = _prefs.getString(_key);
    if (raw == null) return [];
    try {
      final list = json.decode(raw) as List<dynamic>;
      return list
          .map((e) => StationModel.fromJson(e as Map<String, dynamic>))
          .where((s) => s.id.isNotEmpty && s.streamUrl.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveFavorites(List<StationModel> stations) async {
    await _prefs.setString(
      _key,
      json.encode(stations.map((s) => s.toJson()).toList()),
    );
  }
}
