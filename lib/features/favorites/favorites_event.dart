part of 'favorites_bloc.dart';

sealed class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object?> get props => [];
}

final class FavoritesLoadRequested extends FavoritesEvent {
  const FavoritesLoadRequested();
}

final class FavoritesToggleRequested extends FavoritesEvent {
  const FavoritesToggleRequested(this.station);

  final Station station;

  @override
  List<Object?> get props => [station];
}
