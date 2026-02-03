import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:radio_player/components/animated_list_item.dart';
import 'package:radio_player/components/station_card.dart';
import 'package:radio_player/core/theme/app_theme.dart';
import 'package:radio_player/core/theme/colors.dart';
import 'package:radio_player/core/theme/text_styles.dart';
import 'package:radio_player/domain/entities/station_list_filter.dart';
import 'package:radio_player/features/favorites/favorites_bloc.dart';
import 'package:radio_player/features/player/player_bloc.dart';
import 'package:radio_player/features/player/player_view.dart';
import 'package:radio_player/features/stations/stations_bloc.dart';

class AllStationsView extends StatefulWidget {
  const AllStationsView({super.key});

  @override
  State<AllStationsView> createState() => _AllStationsViewState();
}

class _AllStationsViewState extends State<AllStationsView> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  bool _showSearchBar = false;
  Timer? _searchDebounce;

  final Set<String> _animatedStationIds = {};

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      _animatedStationIds.clear();
      context.read<StationsBloc>().add(StationsSearchSubmitted(value));
    });
  }

  void _onFilterTap(StationListFilter filter) {
    _animatedStationIds.clear();
    context.read<StationsBloc>().add(StationsFilterChanged(filter));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            title: _showSearchBar
                ? TextField(
                    controller: _searchController,
                    focusNode: _searchFocusNode,
                    autofocus: true,
                    style: AppTextStyles.searchInput,
                    decoration: InputDecoration(
                      hintText: 'Search stations...',
                      hintStyle: AppTextStyles.searchInput.copyWith(
                        color: AppColors.onSurfaceFaded,
                      ),
                      border: InputBorder.none,
                    ),
                    onChanged: _onSearchChanged,
                  )
                : const Text('Radio Stations'),
            actions: [
              IconButton(
                icon: Icon(_showSearchBar ? Icons.close : Icons.search),
                onPressed: () {
                  setState(() {
                    _showSearchBar = !_showSearchBar;
                    if (!_showSearchBar) {
                      _searchController.clear();
                      _searchDebounce?.cancel();
                      _animatedStationIds.clear();
                      context.read<StationsBloc>().add(
                        const StationsSearchSubmitted(''),
                      );
                    } else {
                      _searchFocusNode.requestFocus();
                      final state = context.read<StationsBloc>().state;
                      final q = state is StationsLoaded
                          ? state.searchQuery
                          : (state is StationsLoadMoreInProgress
                                ? state.searchQuery
                                : '');
                      if (q.isNotEmpty) _searchController.text = q;
                    }
                  });
                },
              ),
            ],
          ),
          BlocBuilder<StationsBloc, StationsState>(
            builder: (context, state) {
              if (state is StationsInitial) {
                context.read<StationsBloc>().add(const StationsLoadRequested());
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryPurple,
                    ),
                  ),
                );
              }
              if (state is StationsLoading) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryPurple,
                    ),
                  ),
                );
              }
              if (state is StationsError) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Could not load stations',
                          style: AppTextStyles.bodySecondary,
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => context.read<StationsBloc>().add(
                            const StationsLoadRequested(),
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                );
              }
              final stations = state is StationsLoaded
                  ? state.stations
                  : (state as StationsLoadMoreInProgress).stations;
              final hasMore = state is StationsLoaded
                  ? state.hasMore
                  : (state as StationsLoadMoreInProgress).hasMore;
              final filter = state is StationsLoaded
                  ? state.filter
                  : (state as StationsLoadMoreInProgress).filter;

              return SliverMainAxisGroup(
                slivers: [
                  SliverToBoxAdapter(
                    child: _FilterChips(
                      currentFilter: filter,
                      onFilterTap: _onFilterTap,
                    ),
                  ),
                  if (stations.isEmpty)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Text(
                            'No stations found',
                            style: AppTextStyles.bodySecondary,
                          ),
                        ),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        if (index == stations.length) {
                          if (hasMore) {
                            context.read<StationsBloc>().add(
                              const StationsLoadMoreRequested(),
                            );
                            return const Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppTheme.primaryPurple,
                                  ),
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        }
                        final station = stations[index];
                        return BlocBuilder<FavoritesBloc, FavoritesState>(
                          buildWhen: (prev, next) {
                            if (next is FavoritesLoaded) return true;
                            return prev != next;
                          },
                          builder: (context, favState) {
                            final isFavorite = context
                                .read<FavoritesBloc>()
                                .isFavorite(station.id);
                            return AnimatedListItem(
                              key: ValueKey(station.id),
                              index: index,
                              alreadyAnimated: _animatedStationIds.contains(
                                station.id,
                              ),
                              onAnimated: () => setState(
                                () => _animatedStationIds.add(station.id),
                              ),
                              child: StationCard(
                                station: station,
                                isFavorite: isFavorite,
                                onTap: () {
                                  context.read<PlayerBloc>().add(
                                    PlayerStationSelected(
                                      station,
                                      stations: stations,
                                      listTitle: 'All Stations',
                                    ),
                                  );
                                  Navigator.of(context).push(
                                    PlayerView.route(
                                      initialStation: station,
                                      stations: stations,
                                      listTitle: 'All Stations',
                                    ),
                                  );
                                },
                                onFavoriteToggle: () => context
                                    .read<FavoritesBloc>()
                                    .add(FavoritesToggleRequested(station)),
                              ),
                            );
                          },
                        );
                      }, childCount: stations.length + (hasMore ? 1 : 0)),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.currentFilter, required this.onFilterTap});

  final StationListFilter currentFilter;
  final ValueChanged<StationListFilter> onFilterTap;

  static const _filters = [
    (StationListFilter.topVotes, 'Top Votes'),
    (StationListFilter.topClicks, 'Top Clicks'),
    (StationListFilter.recentClicks, 'Recent Clicks'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _filters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (filter, label) = _filters[index];
          return IntrinsicWidth(
            child: _Chip(
              label: label,
              selected: currentFilter == filter,
              onTap: () => onFilterTap(filter),
            ),
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppTheme.primaryPurple : AppTheme.cardBackground,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            overflow: TextOverflow.visible,
            softWrap: false,
            style: AppTextStyles.bodySecondary.copyWith(
              color: selected
                  ? AppColors.onSurface
                  : AppColors.onSurfaceSecondary,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
