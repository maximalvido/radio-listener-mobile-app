import 'package:radio_player/domain/repositories/favorites_repository.dart';

class IsFavorite {
  IsFavorite(this._repository);

  final FavoritesRepository _repository;

  bool call(String stationId) => _repository.isFavorite(stationId);
}
