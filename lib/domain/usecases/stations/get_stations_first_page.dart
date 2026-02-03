import 'package:radio_player/domain/entities/station_list_filter.dart';
import 'package:radio_player/domain/repositories/stations_repository.dart';

class GetStationsFirstPage {
  GetStationsFirstPage(this._repository);

  final StationsRepository _repository;

  Future<StationsResult> call({
    String searchQuery = '',
    StationListFilter filter = StationListFilter.topVotes,
  }) => _repository.loadFirstPage(searchQuery: searchQuery, filter: filter);
}
