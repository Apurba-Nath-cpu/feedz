import 'package:feedz/domain/entities/postentity/post_entity.dart';

abstract class PostRepository {
  Future<List<PostEntity>> fetchPosts({required int page, int limit});
  Future<void> updateLike(int postId);
  Future<void> addComment({required int postId, required String comment});
  Future<void> deleteComment({required int postId, required int commentIndex});
  Future<void> clearCache();
}
