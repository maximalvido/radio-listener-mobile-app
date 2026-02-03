import 'package:radio_player/data/datasources/remote/stations_remote_datasource.dart';
import 'package:radio_player/domain/entities/station.dart';
import 'package:radio_player/domain/entities/station_list_filter.dart';
import 'package:radio_player/domain/repositories/stations_repository.dart';

class StationsRepositoryImpl implements StationsRepository {
  StationsRepositoryImpl(this._remote);

  final StationsRemoteDataSource _remote;

  final List<Station> _cache = [];
  int _cachedOffset = 0;
  bool _hasMore = true;
  bool _isLoading = false;
  String _searchQuery = '';
  StationListFilter _filter = StationListFilter.topVotes;

  static const int _pageSize = 20;

  @override
  List<Station> get cachedStations => List.unmodifiable(_cache);

  @override
  bool get hasMore => _hasMore;

  @override
  bool get isLoading => _isLoading;

  @override
  Future<StationsResult> loadFirstPage({
    String searchQuery = '',
    StationListFilter filter = StationListFilter.topVotes,
  }) async {
    _searchQuery = searchQuery;
    _filter = filter;
    _cachedOffset = 0;
    _hasMore = true;
    _cache.clear();
    return _fetchPage(offset: 0);
  }

  @override
  Future<StationsResult> loadNextPage() async {
    if (!_hasMore || _isLoading) {
      return StationsResult(stations: List.from(_cache), hasMore: _hasMore);
    }
    return _fetchPage(offset: _cachedOffset);
  }

  Future<StationsResult> _fetchPage({required int offset}) async {
    if (_isLoading) {
      return StationsResult(stations: List.from(_cache), hasMore: _hasMore);
    }
    _isLoading = true;
    try {
      final list = await _remote.fetchStations(
        offset: offset,
        limit: _pageSize,
        searchQuery: _searchQuery,
        filter: _filter,
      );
      if (list.length < _pageSize) _hasMore = false;
      if (offset == 0) _cache.clear();
      _cache.addAll(list.map((m) => m.toEntity()));
      _cachedOffset = _cache.length;
      return StationsResult(stations: List.from(_cache), hasMore: _hasMore);
    } catch (_) {
      _hasMore = false;
      return StationsResult(stations: List.from(_cache), hasMore: false);
    } finally {
      _isLoading = false;
    }
  }
}
