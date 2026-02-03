import 'package:radio_player/data/datasources/local/favorites_local_datasource.dart';
import 'package:radio_player/data/models/station_model.dart';
import 'package:radio_player/domain/entities/station.dart';
import 'package:radio_player/domain/repositories/favorites_repository.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  FavoritesRepositoryImpl(this._local);

  final FavoritesLocalDataSource _local;

  List<StationModel> _stations = [];
  bool _loaded = false;

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    _stations = await _local.getFavorites();
    _loaded = true;
  }

  @override
  Future<List<Station>> getFavorites() async {
    await _ensureLoaded();
    return _stations.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<Station>> toggleFavorite(Station station) async {
    await _ensureLoaded();
    final model = StationModel.fromEntity(station);
    final idx = _stations.indexWhere((s) => s.id == station.id);
    if (idx >= 0) {
      _stations.removeAt(idx);
    } else {
      _stations.insert(0, model);
    }
    await _local.saveFavorites(_stations);
    return _stations.map((m) => m.toEntity()).toList();
  }

  @override
  bool isFavorite(String stationId) {
    return _stations.any((s) => s.id == stationId);
  }
}
