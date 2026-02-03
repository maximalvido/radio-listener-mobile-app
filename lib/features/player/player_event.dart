part of 'player_bloc.dart';

sealed class PlayerEvent extends Equatable {
  const PlayerEvent();

  @override
  List<Object?> get props => [];
}

final class PlayerStationSelected extends PlayerEvent {
  const PlayerStationSelected(this.station, {this.stations, this.listTitle});

  final Station station;
  final List<Station>? stations;
  final String? listTitle;

  @override
  List<Object?> get props => [station, stations, listTitle];
}

final class PlayerPlayPauseToggled extends PlayerEvent {
  const PlayerPlayPauseToggled();
}

final class PlayerVolumeChanged extends PlayerEvent {
  const PlayerVolumeChanged(this.volume);

  final double volume;

  @override
  List<Object?> get props => [volume];
}

final class PlayerDismissRequested extends PlayerEvent {
  const PlayerDismissRequested();
}

final class PlayerPositionUpdated extends PlayerEvent {
  const PlayerPositionUpdated({required this.position});

  final Duration position;

  @override
  List<Object?> get props => [position];
}

final class PlayerPlayingStateChanged extends PlayerEvent {
  const PlayerPlayingStateChanged(this.isPlaying);

  final bool isPlaying;

  @override
  List<Object?> get props => [isPlaying];
}

final class PlayerSyncPlayingState extends PlayerEvent {
  const PlayerSyncPlayingState();
}
