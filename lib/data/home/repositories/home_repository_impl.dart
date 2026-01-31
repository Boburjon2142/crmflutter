import '../../../domain/home/entities/home_data.dart';
import '../../../domain/home/repositories/home_repository.dart';
import '../datasources/home_remote_data_source.dart';

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl(this._remote);

  final HomeRemoteDataSource _remote;

  @override
  Future<HomeData> getHome() async {
    final response = await _remote.getHome();
    return response.toEntity();
  }
}
