import 'package:feedz/domain/entities/postentity/post_entity.dart';
import 'package:feedz/domain/usecases/clearcache/clear_cache.dart';
import 'package:feedz/utils/exceptions/exceptions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:feedz/domain/usecases/fetchposts/fetch_posts.dart';
import 'package:feedz/domain/usecases/deletecomment/delete_comment.dart';
import 'package:feedz/domain/usecases/addcomment/add_comment.dart';
import 'package:feedz/domain/usecases/updatelike/update_like.dart';

part 'post_feed_event.dart';
part 'post_feed_state.dart';

class PostFeedBloc extends Bloc<PostFeedEvent, PostFeedState> {
  final FetchPosts fetchPosts;
  final ToggleLike toggleLike;
  final AddComment addComment;
  final DeleteComment deleteComment;
  final ClearCache clearCache;

  int _currentPage = 1;
  final int _limit = 10;

  PostFeedBloc({
    required this.fetchPosts,
    required this.toggleLike,
    required this.addComment,
    required this.deleteComment,
    required this.clearCache,
  }) : super(PostFeedInitial()) {
    on<FetchPostsEvent>(_onFetchPosts);
    on<LoadMorePostsEvent>(_onLoadMorePosts);
    on<ToggleLikeEvent>(_onToggleLike);
    on<AddCommentEvent>(_onAddComment);
    on<DeleteCommentEvent>(_onDeleteComment);
    on<ClearCacheEvent>(_onClearCache);
  }

  Future<void> _onFetchPosts(FetchPostsEvent event, Emitter<PostFeedState> emit) async {
    emit(PostFeedLoading());
    try {
      final posts = await fetchPosts(page: event.page, limit: _limit);
      _currentPage = event.page;
      emit(PostFeedLoaded(
        posts: posts,
        hasMore: posts.length == _limit,
        isLoadingMore: false,
      ));
    } on NetworkException {
      emit(PostFeedError('No internet connection. Please check your network.'));
    } catch (e) {
      emit(PostFeedError('Failed to fetch posts: ${e.toString()}'));
    }
  }

  Future<void> _onLoadMorePosts(LoadMorePostsEvent event, Emitter<PostFeedState> emit) async {
    if (state is! PostFeedLoaded) return;
    final currentState = state as PostFeedLoaded;

    if (currentState.isLoadingMore || !currentState.hasMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final newPage = _currentPage + 1;
      final newPosts = await fetchPosts(page: newPage, limit: _limit);
      _currentPage = newPage;

      final updatedPosts = [...currentState.posts, ...newPosts];
      emit(currentState.copyWith(
        posts: updatedPosts,
        hasMore: newPosts.length == _limit,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(PostFeedError('Failed to load more posts: ${e.toString()}'));
    }
  }

  Future<void> _onToggleLike(ToggleLikeEvent event, Emitter<PostFeedState> emit) async {
    if (state is! PostFeedLoaded) return;
    final currentState = state as PostFeedLoaded;

    await toggleLike(postId: event.postId);

    // Refresh only the updated post
    final updatedPosts = currentState.posts.map(
      (post) {
        if (post.id == event.postId) {
          return PostEntity(
            userId: post.userId,
            id: post.id,
            title: post.title,
            description: post.description,
            likesCount: post.likesCount + 1,
            comments: post.comments,
          );
        }
        return post;
      }
    ).toList();

    emit(currentState.copyWith(posts: updatedPosts));
  }

  Future<void> _onAddComment(AddCommentEvent event, Emitter<PostFeedState> emit) async {
    if (state is! PostFeedLoaded) return;
    final currentState = state as PostFeedLoaded;

    await addComment(postId: event.postId, commentContent: event.commentContent);

    final updatedPosts = currentState.posts.map((post) {
      if (post.id == event.postId) {
        final newComments = List<String>.from(post.comments)..insert(0, event.commentContent);
        return PostEntity(
          userId: post.userId,
          id: post.id,
          title: post.title,
          description: post.description,
          likesCount: post.likesCount,
          comments: newComments,
        );
      }
      return post;
    }).toList();

    emit(currentState.copyWith(posts: updatedPosts));
  }

  Future<void> _onDeleteComment(
      DeleteCommentEvent event, Emitter<PostFeedState> emit) async {
    if (state is! PostFeedLoaded) return;
    final currentState = state as PostFeedLoaded;

    await deleteComment(postId: event.postId, commentIndex: event.commentIndex);

    final updatedPosts = currentState.posts.map((post) {
      if (post.id == event.postId) {
        final newComments = List<String>.from(post.comments)
          ..removeAt(event.commentIndex);
        return PostEntity(
          userId: post.userId,
          id: post.id,
          title: post.title,
          description: post.description,
          likesCount: post.likesCount,
          comments: newComments,
        );
      }
      return post;
    }).toList();

    emit(currentState.copyWith(posts: updatedPosts));
  }

  Future<void> _onClearCache(
    ClearCacheEvent event,
    Emitter<PostFeedState> emit,
  ) async {
    try {
      await clearCache();
      emit(PostFeedActionSuccess(message: 'Cache cleared successfully!'));
      add(FetchPostsEvent(1));
    } catch (e) {
      emit(PostFeedError('Failed to clear cache: ${e.toString()}'));
    }
  }
}
