import 'package:radio_player/domain/repositories/stations_repository.dart';

class GetStationsNextPage {
  GetStationsNextPage(this._repository);

  final StationsRepository _repository;

  Future<StationsResult> call() => _repository.loadNextPage();
}
