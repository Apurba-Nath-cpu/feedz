import 'package:feedz/domain/entities/postentity/post_entity.dart';
import 'package:feedz/domain/repositories/postrepository/post_repository.dart';

class FetchPosts {
  final PostRepository repository;

  FetchPosts(this.repository);

  Future<List<PostEntity>> call({required int page, int limit = 10}) {
    return repository.fetchPosts(page: page, limit: limit);
  }
}
