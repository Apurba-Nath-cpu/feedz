import 'package:feedz/domain/repositories/postrepository/post_repository.dart';

class ClearCache {
  final PostRepository repository;

  ClearCache(this.repository);

  Future<void> call() => repository.clearCache();
}
