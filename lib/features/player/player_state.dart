part of 'player_bloc.dart';

class PlayerState extends Equatable {
  const PlayerState({
    this.currentStation,
    this.isPlaying = false,
    this.isStreamReady = false,
    this.volume = 1.0,
    this.position = Duration.zero,
    this.showMiniPlayer = false,
    this.stations,
    this.listTitle,
  });

  factory PlayerState.initial() => const PlayerState();

  final Station? currentStation;
  final bool isPlaying;
  final bool isStreamReady;
  final double volume;
  final Duration position;
  final bool showMiniPlayer;
  final List<Station>? stations;
  final String? listTitle;

  PlayerState copyWith({
    Station? currentStation,
    bool? isPlaying,
    bool? isStreamReady,
    double? volume,
    Duration? position,
    bool? showMiniPlayer,
    List<Station>? stations,
    String? listTitle,
  }) {
    return PlayerState(
      currentStation: currentStation ?? this.currentStation,
      isPlaying: isPlaying ?? this.isPlaying,
      isStreamReady: isStreamReady ?? this.isStreamReady,
      volume: volume ?? this.volume,
      position: position ?? this.position,
      showMiniPlayer: showMiniPlayer ?? this.showMiniPlayer,
      stations: stations ?? this.stations,
      listTitle: listTitle ?? this.listTitle,
    );
  }

  @override
  List<Object?> get props => [
    currentStation,
    isPlaying,
    isStreamReady,
    volume,
    position,
    showMiniPlayer,
    stations,
    listTitle,
  ];
}
