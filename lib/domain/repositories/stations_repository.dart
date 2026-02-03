import 'package:radio_player/domain/entities/station.dart';
import 'package:radio_player/domain/entities/station_list_filter.dart';

class StationsResult {
  const StationsResult({required this.stations, required this.hasMore});

  final List<Station> stations;
  final bool hasMore;
}

abstract class StationsRepository {
  Future<StationsResult> loadFirstPage({
    String searchQuery = '',
    StationListFilter filter = StationListFilter.topVotes,
  });
  Future<StationsResult> loadNextPage();
  List<Station> get cachedStations;
  bool get hasMore;
  bool get isLoading;
}
