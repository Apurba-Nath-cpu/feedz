import 'package:dio/dio.dart';
import 'package:feedz/data/datasources/remote/httppostsdatasource/http_posts_datasource.dart';
import 'package:feedz/data/models/postmodel/post_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late PostsRemoteDataSource dataSource;

  const baseUrl = 'https://jsonplaceholder.typicode.com/';

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: baseUrl));
    dioAdapter = DioAdapter(dio: dio);
    // We test the implementation, but declare the variable as the abstraction.
    dataSource = HttpPostsDataSource(dio: dio);
  });

  group('fetchPosts', () {
    const page = 1;
    const limit = 10;

    // Mock data based on your PostModel.
    // Since you're using freezed, the generated `fromJson` will handle this.
    final tPostModelsJson = [
      {'userId': 1, 'id': 1, 'title': 'title 1', 'body': 'body 1'},
      {'userId': 1, 'id': 2, 'title': 'title 2', 'body': 'body 2'},
    ];

    final tPostModels =
        tPostModelsJson.map((json) => PostModel.fromJson(json)).toList();

    test(
        'should return a list of PostModel when the response code is 200 (success)',
        () async {
      // arrange
      dioAdapter.onGet(
        'posts',
        (server) => server.reply(200, tPostModelsJson),
        queryParameters: {
          '_limit': limit,
          '_page': page,
        },
      );

      // act
      final result = await dataSource.fetchPosts(page: page, limit: limit);

      // assert
      expect(result, equals(tPostModels));
    });

    test('should throw a DioException when the response code is not 200',
        () async {
      // arrange
      dioAdapter.onGet(
        'posts',
        (server) => server.reply(404, {'message': 'Not Found'}),
        queryParameters: {'_limit': limit, '_page': page},
      );

      // act
      final call = dataSource.fetchPosts;

      // assert
      expect(() => call(page: page, limit: limit), throwsA(isA<DioException>()));
    });
  });
}