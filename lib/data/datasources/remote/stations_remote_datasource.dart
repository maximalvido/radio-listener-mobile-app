import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:radio_player/data/models/station_model.dart';
import 'package:radio_player/domain/entities/station_list_filter.dart';

abstract class StationsRemoteDataSource {
  Future<bool> voteStation(String stationUuid);

  Future<List<StationModel>> fetchStations({
    required int offset,
    required int limit,
    String searchQuery = '',
    StationListFilter filter = StationListFilter.topVotes,
  });
}

class StationsRemoteDataSourceImpl implements StationsRemoteDataSource {
  StationsRemoteDataSourceImpl()
    : _baseUrl =
          dotenv.env['API_BASE_URL'] ?? 'https://de1.api.radio-browser.info';

  final String _baseUrl;
  static const String _userAgent = 'RadioPlayer/1.0';

  static (String order, String reverse) _orderAndReverseForFilter(
    StationListFilter filter,
  ) {
    return switch (filter) {
      StationListFilter.topVotes => ('votes', 'true'),
      StationListFilter.topClicks => ('clickcount', 'true'),
      StationListFilter.recentClicks => ('clicktimestamp', 'true'),
    };
  }

  @override
  Future<bool> voteStation(String stationUuid) async {
    final uri = Uri.parse('$_baseUrl/json/vote/$stationUuid');
    final response = await http
        .get(uri, headers: {'User-Agent': _userAgent})
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) return false;
    try {
      final map = json.decode(response.body) as Map<String, dynamic>;
      return map['ok'] == true;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<List<StationModel>> fetchStations({
    required int offset,
    required int limit,
    String searchQuery = '',
    StationListFilter filter = StationListFilter.topVotes,
  }) async {
    final Uri uri;
    if (searchQuery.trim().isNotEmpty) {
      final orderReverse = _orderAndReverseForFilter(filter);
      uri = Uri.parse('$_baseUrl/json/stations/search').replace(
        queryParameters: {
          'name': searchQuery.trim(),
          'offset': offset.toString(),
          'limit': limit.toString(),
          'hidebroken': 'true',
          'order': orderReverse.$1,
          'reverse': orderReverse.$2,
        },
      );
    } else {
      final path = switch (filter) {
        StationListFilter.topVotes => 'json/stations/topvote',
        StationListFilter.topClicks => 'json/stations/topclick',
        StationListFilter.recentClicks => 'json/stations/lastclick',
      };
      uri = Uri.parse('$_baseUrl/$path').replace(
        queryParameters: {
          'offset': offset.toString(),
          'limit': limit.toString(),
          'hidebroken': 'true',
        },
      );
    }

    final response = await http
        .get(uri, headers: {'User-Agent': _userAgent})
        .timeout(const Duration(seconds: 15));

    if (response.statusCode != 200) return [];

    final list = json.decode(response.body) as List<dynamic>;
    return list
        .map((e) => StationModel.fromJson(e as Map<String, dynamic>))
        .where((s) => s.streamUrl.isNotEmpty)
        .toList();
  }
}
