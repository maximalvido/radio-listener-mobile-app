import 'package:radio_player/domain/entities/station.dart';
import 'package:radio_player/domain/repositories/favorites_repository.dart';

class ToggleFavorite {
  ToggleFavorite(this._repository);

  final FavoritesRepository _repository;

  Future<List<Station>> call(Station station) =>
      _repository.toggleFavorite(station);
}
