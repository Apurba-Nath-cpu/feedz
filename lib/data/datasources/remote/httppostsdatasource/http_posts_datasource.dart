import 'package:dio/dio.dart';
import 'package:feedz/data/models/postmodel/post_model.dart';

abstract class PostsRemoteDataSource {
  Future<List<PostModel>> fetchPosts({required int page, int limit = 10});
}

class HttpPostsDataSource implements PostsRemoteDataSource {
  final Dio dio;

  HttpPostsDataSource({required this.dio});

  @override
  Future<List<PostModel>> fetchPosts({required int page, int limit = 10}) async {
    try {
      final response = await dio.get(
        'posts',
        queryParameters: {
          '_limit': limit,
          '_page': page,
        },
      );
      // Dio throws a DioException for non-2xx status codes by default,
      // so we don't need to check for response.statusCode == 200 explicitly.
      final List<dynamic> data = response.data;
      return data.map((json) => PostModel.fromJson(json)).toList();
    } on DioException catch (e) {
      // Re-throw the DioException to be handled by the repository/bloc.
      // This preserves valuable error information like status codes.
      rethrow;
    }
  }
}
