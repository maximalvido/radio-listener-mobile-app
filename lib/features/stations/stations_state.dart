part of 'stations_bloc.dart';

sealed class StationsState extends Equatable {
  const StationsState();

  @override
  List<Object?> get props => [];
}

final class StationsInitial extends StationsState {}

final class StationsLoading extends StationsState {}

final class StationsLoadMoreInProgress extends StationsState {
  const StationsLoadMoreInProgress({
    required this.stations,
    required this.hasMore,
    this.searchQuery = '',
    this.filter = StationListFilter.topVotes,
  });

  final List<Station> stations;
  final bool hasMore;
  final String searchQuery;
  final StationListFilter filter;

  @override
  List<Object?> get props => [stations, hasMore, searchQuery, filter];
}

final class StationsLoaded extends StationsState {
  const StationsLoaded({
    required this.stations,
    required this.hasMore,
    this.searchQuery = '',
    this.filter = StationListFilter.topVotes,
  });

  final List<Station> stations;
  final bool hasMore;
  final String searchQuery;
  final StationListFilter filter;

  @override
  List<Object?> get props => [stations, hasMore, searchQuery, filter];
}

final class StationsError extends StationsState {}
