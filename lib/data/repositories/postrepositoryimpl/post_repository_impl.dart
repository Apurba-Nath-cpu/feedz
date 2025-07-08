import 'package:feedz/data/datasources/local/likescomentscache/likes_comments_cache.dart';
import 'package:feedz/data/datasources/remote/httppostsdatasource/http_posts_datasource.dart';
import 'package:feedz/domain/entities/postentity/post_entity.dart';
import 'package:feedz/domain/repositories/postrepository/post_repository.dart';
import 'package:feedz/utils/exceptions/exceptions.dart';
import 'package:feedz/utils/networkinfo/network_info.dart';

class PostRepositoryImpl implements PostRepository {
  final HttpPostsDataSource remoteDataSource;
  final LikesCommentsCache localCache;
  final NetworkInfo networkInfo;

  PostRepositoryImpl({
    required this.remoteDataSource,
    required this.localCache,
    required this.networkInfo,
  });

  @override
  Future<List<PostEntity>> fetchPosts({required int page, int limit = 10}) async {
    if (!await networkInfo.isConnected) {
      throw NetworkException();
    }
    final models = await remoteDataSource.fetchPosts(page: page, limit: limit);

    final List<PostEntity> enriched = [];
    for (var model in models) {
      final likesCount = await localCache.getLikesCount(model.id);
      final comments = await localCache.getComments(model.id);

      enriched.add(PostEntity(
        userId: model.userId,
        id: model.id,
        title: model.title,
        description: model.description,
        likesCount: likesCount,
        comments: comments,
      ));
    }

    return enriched;
  }

  @override
  Future<void> updateLike(int postId) async {
    await localCache.updateLikes(postId);
  }

  @override
  Future<void> addComment({required int postId, required String comment}) async {
    await localCache.addComment(postId, comment);
  }

  @override
  Future<void> deleteComment(
      {required int postId, required int commentIndex}) async {
    await localCache.deleteComment(postId: postId, commentIndex: commentIndex);
  }

  @override
  Future<void> clearCache() async {
    await localCache.clearCache();
  }
}
