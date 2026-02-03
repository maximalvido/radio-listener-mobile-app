import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:radio_player/domain/entities/station.dart';
import 'package:radio_player/domain/entities/station_list_filter.dart';
import 'package:radio_player/domain/usecases/stations/get_stations_first_page.dart';
import 'package:radio_player/domain/usecases/stations/get_stations_next_page.dart';

part 'stations_event.dart';
part 'stations_state.dart';

class StationsBloc extends Bloc<StationsEvent, StationsState> {
  StationsBloc(this._getFirstPage, this._getNextPage)
    : super(StationsInitial()) {
    on<StationsLoadRequested>(_onLoadRequested);
    on<StationsSearchSubmitted>(_onSearchSubmitted);
    on<StationsFilterChanged>(_onFilterChanged);
    on<StationsLoadMoreRequested>(_onLoadMoreRequested);
  }

  final GetStationsFirstPage _getFirstPage;
  final GetStationsNextPage _getNextPage;

  StationListFilter _currentFilter(StationsState s) {
    if (s is StationsLoaded) return s.filter;
    if (s is StationsLoadMoreInProgress) return s.filter;
    return StationListFilter.topVotes;
  }

  String _currentSearchQuery(StationsState s) {
    if (s is StationsLoaded) return s.searchQuery;
    if (s is StationsLoadMoreInProgress) return s.searchQuery;
    return '';
  }

  Future<void> _onLoadRequested(
    StationsLoadRequested event,
    Emitter<StationsState> emit,
  ) async {
    emit(StationsLoading());
    final result = await _getFirstPage();
    if (result.stations.isEmpty) {
      emit(StationsError());
      return;
    }
    emit(StationsLoaded(
      stations: result.stations,
      hasMore: result.hasMore,
      searchQuery: '',
      filter: StationListFilter.topVotes,
    ));
  }

  Future<void> _onSearchSubmitted(
    StationsSearchSubmitted event,
    Emitter<StationsState> emit,
  ) async {
    emit(StationsLoading());
    final filter = _currentFilter(state);
    final result = await _getFirstPage(
      searchQuery: event.query,
      filter: filter,
    );
    emit(StationsLoaded(
      stations: result.stations,
      hasMore: result.hasMore,
      searchQuery: event.query,
      filter: filter,
    ));
  }

  Future<void> _onFilterChanged(
    StationsFilterChanged event,
    Emitter<StationsState> emit,
  ) async {
    emit(StationsLoading());
    final searchQuery = _currentSearchQuery(state);
    final result = await _getFirstPage(
      searchQuery: searchQuery,
      filter: event.filter,
    );
    emit(StationsLoaded(
      stations: result.stations,
      hasMore: result.hasMore,
      searchQuery: searchQuery,
      filter: event.filter,
    ));
  }

  Future<void> _onLoadMoreRequested(
    StationsLoadMoreRequested event,
    Emitter<StationsState> emit,
  ) async {
    final current = state;
    if (current is! StationsLoaded) return;
    emit(
      StationsLoadMoreInProgress(
        stations: current.stations,
        hasMore: current.hasMore,
        searchQuery: current.searchQuery,
        filter: current.filter,
      ),
    );
    final result = await _getNextPage();
    emit(StationsLoaded(
      stations: result.stations,
      hasMore: result.hasMore,
      searchQuery: current.searchQuery,
      filter: current.filter,
    ));
  }
}
