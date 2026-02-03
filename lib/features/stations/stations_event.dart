part of 'stations_bloc.dart';

sealed class StationsEvent extends Equatable {
  const StationsEvent();

  @override
  List<Object?> get props => [];
}

final class StationsLoadRequested extends StationsEvent {
  const StationsLoadRequested();
}

final class StationsSearchSubmitted extends StationsEvent {
  const StationsSearchSubmitted(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

final class StationsFilterChanged extends StationsEvent {
  const StationsFilterChanged(this.filter);

  final StationListFilter filter;

  @override
  List<Object?> get props => [filter];
}

final class StationsLoadMoreRequested extends StationsEvent {
  const StationsLoadMoreRequested();
}
