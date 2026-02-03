import 'package:equatable/equatable.dart';

class Station extends Equatable {
  const Station({
    required this.id,
    required this.name,
    required this.streamUrl,
    this.faviconUrl,
    this.homepage,
    this.tags = const [],
    this.countryCode,
    this.country,
    this.state,
    this.bitrate,
  });

  final String id;
  final String name;
  final String streamUrl;
  final String? faviconUrl;
  final String? homepage;
  final List<String> tags;
  final String? countryCode;
  final String? country;
  final String? state;
  final int? bitrate;

  String get genreSubtitle =>
      tags.isNotEmpty ? tags.take(2).join(' & ') : 'Radio';

  @override
  List<Object?> get props => [
    id,
    name,
    streamUrl,
    faviconUrl,
    tags,
    country,
    bitrate,
  ];
}
