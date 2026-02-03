import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:radio_player/domain/entities/station.dart';
import 'package:radio_player/domain/repositories/vote_repository.dart';
import 'package:radio_player/components/animated_wave_chart.dart';
import 'package:radio_player/core/theme/app_theme.dart';
import 'package:radio_player/core/theme/border_radius.dart';
import 'package:radio_player/core/theme/colors.dart';
import 'package:radio_player/core/theme/text_styles.dart';
import 'package:radio_player/features/player/player_bloc.dart';

class PlayerView extends StatelessWidget {
  const PlayerView({
    super.key,
    this.initialStation,
    this.stations,
    this.listTitle,
  });

  final Station? initialStation;
  final List<Station>? stations;
  final String? listTitle;

  static PageRoute<void> route({
    Station? initialStation,
    List<Station>? stations,
    String? listTitle,
  }) {
    return PageRouteBuilder<void>(
      opaque: false,
      barrierColor: Colors.transparent,
      pageBuilder: (context, animation, secondaryAnimation) => PlayerView(
        initialStation: initialStation,
        stations: stations,
        listTitle: listTitle,
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeOut;
        final tween = Tween<Offset>(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.transparent,
      body: _DragToDismissDetector(
        onDismiss: () => Navigator.of(context).pop(),
        child: BlocBuilder<PlayerBloc, PlayerState>(
          builder: (context, state) {
            if (initialStation != null && state.currentStation == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  context.read<PlayerBloc>().add(
                    PlayerStationSelected(initialStation!),
                  );
                }
              });
            }
            final station = state.currentStation ?? initialStation;
            if (station == null) {
              return const Center(
                child: Text(
                  'No station selected',
                  style: AppTextStyles.bodySecondary,
                ),
              );
            }
            return Container(
              color: AppTheme.backgroundDark,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _header(context, station),
                      if (listTitle != null && listTitle!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          listTitle!,
                          style: AppTextStyles.playerGenre.copyWith(
                            color: AppColors.onSurfaceMuted,
                          ),
                        ),
                      ],
                      const Spacer(),
                      _artwork(station),
                      const Spacer(),
                      _stationInfo(station, state),
                      const Spacer(),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) => AnimatedWaveChart(
                            height: constraints.maxHeight,
                            isPlaying: state.isPlaying,
                            isLoading:
                                state.currentStation != null &&
                                !state.isStreamReady,
                            bitrate: station.bitrate,
                          ),
                        ),
                      ),
                      const Spacer(),
                      _volumeAndControls(context, state, station),
                      const Spacer(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _header(BuildContext context, Station station) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.onSurface,
              size: 28,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Expanded(
            child: Text(
              'NOW PLAYING',
              textAlign: TextAlign.center,
              style: AppTextStyles.nowPlayingHeader,
            ),
          ),
          _VoteButton(station: station),
          IconButton(
            icon: const Icon(Icons.share, color: AppColors.onSurface),
            onPressed: () {
              SharePlus.instance.share(
                ShareParams(
                  text:
                      'Listening to ${station.name} on RadioWave\n${station.streamUrl}',
                  subject: station.name,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _artwork(Station station) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final size = constraints.maxWidth * 0.65;
            return SizedBox(
              width: size,
              height: size,
              child: ClipRRect(
                borderRadius: AppBorderRadius.radiusCard,
                child:
                    station.faviconUrl != null && station.faviconUrl!.isNotEmpty
                    ? Image.network(
                        station.faviconUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _placeholderArt(station),
                      )
                    : _placeholderArt(station),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _placeholderArt(Station station) {
    return Container(
      color: AppTheme.cardBackground,
      alignment: Alignment.center,
      child: Text(
        station.name.isNotEmpty ? station.name[0].toUpperCase() : '?',
        style: AppTextStyles.playerArtworkPlaceholder,
      ),
    );
  }

  Widget _stationInfo(Station station, PlayerState state) {
    final liveDotColor = state.isPlaying
        ? AppTheme.liveRed
        : AppColors.liveInactive;
    final countryOrBitrate = <String>[
      if (station.country != null && station.country!.trim().isNotEmpty)
        station.country!.trim(),
      if (station.bitrate != null && station.bitrate! > 0)
        station.bitrate! >= 1000
            ? '${station.bitrate! ~/ 1000} kbps'
            : '${station.bitrate} bps',
    ].join(' • ');
    return Column(
      children: [
        Text(
          station.name,
          style: AppTextStyles.playerStationName,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(station.genreSubtitle, style: AppTextStyles.playerGenre),
        if (countryOrBitrate.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            countryOrBitrate,
            style: AppTextStyles.playerGenre.copyWith(
              color: AppColors.onSurfaceMuted,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: liveDotColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            const Text('Live', style: AppTextStyles.playerLive),
          ],
        ),
      ],
    );
  }

  Widget _volumeAndControls(
    BuildContext context,
    PlayerState state,
    Station currentStation,
  ) {
    final ready = state.isStreamReady;
    final inactiveColor = AppColors.primaryPurple.withValues(alpha: 0.3);
    final list = stations ?? <Station>[];
    final index = list.indexWhere((s) => s.id == currentStation.id);
    final hasPrev = index > 0;
    final hasNext = index >= 0 && index < list.length - 1;
    final prevStation = hasPrev ? list[index - 1] : null;
    final nextStation = hasNext ? list[index + 1] : null;
    final volumeIconColor = AppColors.primaryPurple.withValues(alpha: 0.7);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          const Text('Volume', style: AppTextStyles.playerVolumeLabel),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  state.volume <= 0 ? Icons.volume_off : Icons.volume_down,
                  color: volumeIconColor,
                  size: 24,
                ),
                onPressed: () => context.read<PlayerBloc>().add(
                  const PlayerVolumeChanged(0.0),
                ),
              ),
              SizedBox(
                width: 200,
                child: Slider(
                  activeColor: AppColors.primaryPurple,
                  inactiveColor: inactiveColor,
                  value: state.volume,
                  onChanged: (v) =>
                      context.read<PlayerBloc>().add(PlayerVolumeChanged(v)),
                ),
              ),
              IconButton(
                icon: Icon(Icons.volume_up, color: volumeIconColor, size: 24),
                onPressed: () => context.read<PlayerBloc>().add(
                  const PlayerVolumeChanged(1.0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(
                  Icons.skip_previous,
                  color: prevStation != null ? volumeIconColor : inactiveColor,
                  size: 40,
                ),
                onPressed: prevStation != null
                    ? () => context.read<PlayerBloc>().add(
                        PlayerStationSelected(prevStation),
                      )
                    : null,
              ),
              IconButton(
                icon: Icon(
                  state.isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_filled,
                  color: ready ? AppTheme.primaryPurple : inactiveColor,
                  size: 64,
                ),
                onPressed: ready
                    ? () => context.read<PlayerBloc>().add(
                        const PlayerPlayPauseToggled(),
                      )
                    : null,
              ),
              IconButton(
                icon: Icon(
                  Icons.skip_next,
                  color: nextStation != null ? volumeIconColor : inactiveColor,
                  size: 40,
                ),
                onPressed: nextStation != null
                    ? () => context.read<PlayerBloc>().add(
                        PlayerStationSelected(nextStation),
                      )
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DragToDismissDetector extends StatefulWidget {
  const _DragToDismissDetector({required this.child, required this.onDismiss});

  final Widget child;
  final VoidCallback onDismiss;

  @override
  State<_DragToDismissDetector> createState() => _DragToDismissDetectorState();
}

class _DragToDismissDetectorState extends State<_DragToDismissDetector>
    with SingleTickerProviderStateMixin {
  double _translateY = 0;
  late AnimationController _snapController;
  late Animation<double> _snapAnimation;

  static const double _dismissThreshold = 120;
  static const double _dragExtent = 0.6;

  @override
  void initState() {
    super.initState();
    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _snapAnimation = Tween<double>(
      begin: 0,
      end: 0,
    ).animate(CurvedAnimation(parent: _snapController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _snapController.dispose();
    super.dispose();
  }

  void _onDragEnd() {
    if (_translateY >= _dismissThreshold) {
      widget.onDismiss();
      return;
    }
    final start = _translateY;
    setState(() => _translateY = 0);
    _snapAnimation = Tween<double>(
      begin: start,
      end: 0,
    ).animate(CurvedAnimation(parent: _snapController, curve: Curves.easeOut));
    _snapController
      ..reset()
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    final maxDrag = MediaQuery.sizeOf(context).height * _dragExtent;
    return AnimatedBuilder(
      animation: _snapController,
      builder: (context, child) {
        final y = _snapController.isAnimating
            ? _snapAnimation.value
            : _translateY;
        return GestureDetector(
          onVerticalDragStart: (_) {
            if (_snapController.isAnimating) _snapController.stop();
          },
          onVerticalDragUpdate: (details) {
            if (_snapController.isAnimating) return;
            setState(() {
              _translateY = (_translateY + details.delta.dy).clamp(
                0.0,
                maxDrag,
              );
            });
          },
          onVerticalDragEnd: (_) => _onDragEnd(),
          child: Transform.translate(offset: Offset(0, y), child: child),
        );
      },
      child: widget.child,
    );
  }
}

class _VoteButton extends StatefulWidget {
  const _VoteButton({required this.station});

  final Station station;

  @override
  State<_VoteButton> createState() => _VoteButtonState();
}

class _VoteButtonState extends State<_VoteButton> {
  late bool _voted;

  @override
  void initState() {
    super.initState();
    _voted = context.read<VoteRepository>().isVoted(widget.station.id);
  }

  @override
  void didUpdateWidget(_VoteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.station.id != widget.station.id) {
      _voted = context.read<VoteRepository>().isVoted(widget.station.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        _voted ? Icons.thumb_up : Icons.thumb_up_outlined,
        color: _voted ? AppTheme.primaryPurple : AppColors.onSurface,
        size: 24,
      ),
      tooltip: _voted ? 'Voted' : 'Vote up',
      onPressed: _voted
          ? null
          : () async {
              final messenger = ScaffoldMessenger.of(context);
              messenger.showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text('Voting...'),
                    ],
                  ),
                  duration: const Duration(days: 1),
                ),
              );
              final ok = await context.read<VoteRepository>().vote(
                widget.station,
              );
              if (!context.mounted) return;
              messenger.hideCurrentSnackBar();
              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    ok
                        ? 'Vote recorded! Thanks for supporting this station.'
                        : 'Could not record vote. Try again later.',
                  ),
                  backgroundColor: ok ? null : AppColors.error,
                ),
              );
              if (ok) setState(() => _voted = true);
            },
    );
  }
}
