import 'package:radio_player/domain/entities/station.dart';

abstract class FavoritesRepository {
  Future<List<Station>> getFavorites();
  Future<List<Station>> toggleFavorite(Station station);
  bool isFavorite(String stationId);
}
