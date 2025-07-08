import 'package:feedz/domain/repositories/postrepository/post_repository.dart';

class AddComment {
  final PostRepository repository;

  AddComment(this.repository);

  Future<void> call({required int postId, required String commentContent}) {
    return repository.addComment(postId: postId, comment: commentContent);
  }
}
