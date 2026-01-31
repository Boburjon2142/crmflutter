import '../entities/category.dart';
import '../repositories/catalog_repository.dart';

class GetCategories {
  GetCategories(this._repository);

  final CatalogRepository _repository;

  Future<List<Category>> call() => _repository.getCategories();
}
