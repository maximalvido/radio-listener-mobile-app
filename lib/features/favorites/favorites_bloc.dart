import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:radio_player/domain/entities/station.dart';
import 'package:radio_player/domain/usecases/favorites/get_favorites.dart';
import 'package:radio_player/domain/usecases/favorites/is_favorite.dart';
import 'package:radio_player/domain/usecases/favorites/toggle_favorite.dart';

part 'favorites_event.dart';
part 'favorites_state.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  FavoritesBloc(this._getFavorites, this._toggleFavorite, this._isFavorite)
    : super(FavoritesInitial()) {
    on<FavoritesLoadRequested>(_onLoadRequested);
    on<FavoritesToggleRequested>(_onToggleRequested);
  }

  final GetFavorites _getFavorites;
  final ToggleFavorite _toggleFavorite;
  final IsFavorite _isFavorite;

  Future<void> _onLoadRequested(
    FavoritesLoadRequested event,
    Emitter<FavoritesState> emit,
  ) async {
    final stations = await _getFavorites();
    emit(FavoritesLoaded(stations: stations));
  }

  Future<void> _onToggleRequested(
    FavoritesToggleRequested event,
    Emitter<FavoritesState> emit,
  ) async {
    final stations = await _toggleFavorite(event.station);
    emit(FavoritesLoaded(stations: stations));
  }

  bool isFavorite(String stationId) => _isFavorite(stationId);
}
