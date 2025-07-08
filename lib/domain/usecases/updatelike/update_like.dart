import 'package:feedz/domain/repositories/postrepository/post_repository.dart';

class ToggleLike {
  final PostRepository repository;

  ToggleLike(this.repository);

  Future<void> call({required int postId}) {
    return repository.updateLike(postId);
  }
}
