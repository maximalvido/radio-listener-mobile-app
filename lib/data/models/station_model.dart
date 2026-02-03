import 'package:radio_player/domain/entities/station.dart';

class StationModel extends Station {
  const StationModel({
    required super.id,
    required super.name,
    required super.streamUrl,
    super.faviconUrl,
    super.homepage,
    super.tags,
    super.countryCode,
    super.country,
    super.state,
    super.bitrate,
  });

  factory StationModel.fromJson(Map<String, dynamic> json) {
    final tagsRaw = json['tags'];
    final tagsList = tagsRaw is String
        ? (tagsRaw
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList())
        : <String>[];
    final bitrateRaw = json['bitrate'];
    final bitrate = bitrateRaw is int
        ? bitrateRaw
        : (bitrateRaw is num ? bitrateRaw.toInt() : null);
    return StationModel(
      id: json['stationuuid'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      streamUrl: (json['url_resolved'] ?? json['url']) as String? ?? '',
      faviconUrl: json['favicon'] as String?,
      homepage: json['homepage'] as String?,
      tags: tagsList,
      countryCode: json['countrycode'] as String?,
      country: json['country'] as String?,
      state: json['state'] as String?,
      bitrate: bitrate,
    );
  }

  Map<String, dynamic> toJson() => {
    'stationuuid': id,
    'name': name,
    'url_resolved': streamUrl,
    'favicon': faviconUrl,
    'homepage': homepage,
    'tags': tags.join(','),
    'countrycode': countryCode,
    'country': country,
    'state': state,
    'bitrate': bitrate,
  };

  Station toEntity() => Station(
    id: id,
    name: name,
    streamUrl: streamUrl,
    faviconUrl: faviconUrl,
    homepage: homepage,
    tags: tags,
    countryCode: countryCode,
    country: country,
    state: state,
    bitrate: bitrate,
  );

  static StationModel fromEntity(Station entity) => StationModel(
    id: entity.id,
    name: entity.name,
    streamUrl: entity.streamUrl,
    faviconUrl: entity.faviconUrl,
    homepage: entity.homepage,
    tags: entity.tags,
    countryCode: entity.countryCode,
    country: entity.country,
    state: entity.state,
    bitrate: entity.bitrate,
  );
}
