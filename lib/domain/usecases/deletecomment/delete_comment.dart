import 'package:feedz/domain/repositories/postrepository/post_repository.dart';

class DeleteComment {
  final PostRepository repository;

  DeleteComment(this.repository);

  Future<void> call({required int postId, required int commentIndex}) =>
      repository.deleteComment(postId: postId, commentIndex: commentIndex);
}