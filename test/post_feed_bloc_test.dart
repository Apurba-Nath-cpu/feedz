import 'package:bloc_test/bloc_test.dart';
import 'package:feedz/domain/entities/postentity/post_entity.dart';
import 'package:feedz/domain/usecases/addcomment/add_comment.dart';
import 'package:feedz/domain/usecases/clearcache/clear_cache.dart';
import 'package:feedz/domain/usecases/deletecomment/delete_comment.dart';
import 'package:feedz/domain/usecases/fetchposts/fetch_posts.dart';
import 'package:feedz/domain/usecases/updatelike/update_like.dart';
import 'package:feedz/presentation/blocs/postfeedbloc/post_feed_bloc.dart';
import 'package:feedz/utils/exceptions/exceptions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'post_feed_bloc_test.mocks.dart';

@GenerateMocks([
  FetchPosts,
  ToggleLike,
  AddComment,
  DeleteComment,
  ClearCache,
])
void main() {
  late MockFetchPosts mockFetchPosts;
  late MockToggleLike mockToggleLike;
  late MockAddComment mockAddComment;
  late MockDeleteComment mockDeleteComment;
  late MockClearCache mockClearCache;
  late PostFeedBloc postFeedBloc;

  setUp(() {
    mockFetchPosts = MockFetchPosts();
    mockToggleLike = MockToggleLike();
    mockAddComment = MockAddComment();
    mockDeleteComment = MockDeleteComment();
    mockClearCache = MockClearCache();

    postFeedBloc = PostFeedBloc(
      fetchPosts: mockFetchPosts,
      toggleLike: mockToggleLike,
      addComment: mockAddComment,
      deleteComment: mockDeleteComment,
      clearCache: mockClearCache,
    );
  });

  tearDown(() {
    postFeedBloc.close();
  });

  final tPost1 = PostEntity(
    id: 1,
    userId: 1,
    title: 'Test Title 1',
    description: 'Test Body 1',
    likesCount: 0,
    comments: const [],
  );
  final tPost2 = PostEntity(
    id: 2,
    userId: 1,
    title: 'Test Title 2',
    description: 'Test Body 2',
    likesCount: 5,
    comments: const ['first comment'],
  );
  final tPosts = [tPost1, tPost2];
  const tLimit = 10;

  test('initial state should be PostFeedInitial', () {
    expect(postFeedBloc.state, equals(PostFeedInitial()));
  });

  group('FetchPostsEvent', () {
    blocTest<PostFeedBloc, PostFeedState>(
      'emits [PostFeedLoading, PostFeedLoaded] when fetchPosts is successful.',
      build: () {
        when(mockFetchPosts(page: 1, limit: tLimit))
            .thenAnswer((_) async => tPosts);
        return postFeedBloc;
      },
      act: (bloc) => bloc.add(FetchPostsEvent(1)),
      expect: () => [
        PostFeedLoading(),
        PostFeedLoaded(posts: tPosts, hasMore: false, isLoadingMore: false),
      ],
      verify: (_) {
        verify(mockFetchPosts(page: 1, limit: tLimit)).called(1);
      },
    );

    blocTest<PostFeedBloc, PostFeedState>(
      'emits [PostFeedLoading, PostFeedError] when fetchPosts throws NetworkException.',
      build: () {
        when(mockFetchPosts(page: 1, limit: tLimit))
            .thenThrow(NetworkException());
        return postFeedBloc;
      },
      act: (bloc) => bloc.add(FetchPostsEvent(1)),
      expect: () => [
        PostFeedLoading(),
        PostFeedError('No internet connection. Please check your network.'),
      ],
    );
  });

  group('LoadMorePostsEvent', () {
    blocTest<PostFeedBloc, PostFeedState>(
      'emits [isLoadingMore=true, then appends new posts] on success.',
      seed: () => PostFeedLoaded(posts: tPosts, hasMore: true),
      build: () {
        when(mockFetchPosts(page: 2, limit: tLimit))
            .thenAnswer((_) async => [tPost1.copyWith(id: 3)]);
        return postFeedBloc;
      },
      act: (bloc) => bloc.add(LoadMorePostsEvent()),
      expect: () => [
        PostFeedLoaded(posts: tPosts, hasMore: true, isLoadingMore: true),
        PostFeedLoaded(
          posts: [...tPosts, tPost1.copyWith(id: 3)],
          hasMore: false,
          isLoadingMore: false,
        ),
      ],
    );

    blocTest<PostFeedBloc, PostFeedState>(
      'does nothing if hasMore is false.',
      seed: () => PostFeedLoaded(posts: tPosts, hasMore: false),
      build: () => postFeedBloc,
      act: (bloc) => bloc.add(LoadMorePostsEvent()),
      expect: () => [],
      verify: (_) {
        verifyNever(
            mockFetchPosts(page: anyNamed('page'), limit: anyNamed('limit')));
      },
    );
  });

  group('ToggleLikeEvent', () {
    blocTest<PostFeedBloc, PostFeedState>(
      'optimistically updates likesCount and emits PostFeedLoaded.',
      seed: () => PostFeedLoaded(posts: [tPost1, tPost2], hasMore: true),
      build: () {
        when(mockToggleLike(postId: tPost1.id)).thenAnswer((_) async {});
        return postFeedBloc;
      },
      act: (bloc) => bloc.add(ToggleLikeEvent(tPost1.id)),
      expect: () => [
        PostFeedLoaded(
          posts: [tPost1.copyWith(likesCount: 1), tPost2],
          hasMore: true,
        ),
      ],
    );
  });

  group('AddCommentEvent', () {
    const newComment = 'This is a new comment!';
    blocTest<PostFeedBloc, PostFeedState>(
      'optimistically adds a comment and emits PostFeedLoaded.',
      seed: () => PostFeedLoaded(posts: [tPost1, tPost2], hasMore: true),
      build: () {
        when(mockAddComment(postId: tPost1.id, commentContent: newComment))
            .thenAnswer((_) async {});
        return postFeedBloc;
      },
      act: (bloc) => bloc.add(AddCommentEvent(tPost1.id, newComment)),
      expect: () => [
        PostFeedLoaded(
          posts: [tPost1.copyWith(comments: [newComment]), tPost2],
          hasMore: true,
        ),
      ],
    );
  });

  group('DeleteCommentEvent', () {
    blocTest<PostFeedBloc, PostFeedState>(
      'optimistically deletes a comment and emits PostFeedLoaded.',
      seed: () => PostFeedLoaded(posts: [tPost1, tPost2], hasMore: true),
      build: () {
        when(mockDeleteComment(postId: tPost2.id, commentIndex: 0))
            .thenAnswer((_) async {});
        return postFeedBloc;
      },
      act: (bloc) => bloc.add(DeleteCommentEvent(tPost2.id, 0)),
      expect: () => [
        PostFeedLoaded(posts: [tPost1, tPost2.copyWith(comments: [])], hasMore: true),
      ],
    );
  });

  group('ClearCacheEvent', () {
    blocTest<PostFeedBloc, PostFeedState>(
      'emits [ActionSuccess, Loading, Loaded] and re-fetches on success.',
      build: () {
        when(mockClearCache()).thenAnswer((_) async {});
        when(mockFetchPosts(page: 1, limit: tLimit))
            .thenAnswer((_) async => tPosts);
        return postFeedBloc;
      },
      act: (bloc) => bloc.add(ClearCacheEvent()),
      expect: () => [
        PostFeedActionSuccess(message: 'Cache cleared successfully!'),
        PostFeedLoading(),
        PostFeedLoaded(posts: tPosts, hasMore: false),
      ],
      verify: (_) {
        verify(mockClearCache()).called(1);
        verify(mockFetchPosts(page: 1, limit: tLimit)).called(1);
      },
    );
  });
}
