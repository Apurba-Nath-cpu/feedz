part of 'post_feed_bloc.dart';

abstract class PostFeedState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PostFeedInitial extends PostFeedState {}

class PostFeedLoading extends PostFeedState {}

class PostFeedLoaded extends PostFeedState {
  final List<PostEntity> posts;
  final bool hasMore;
  final bool isLoadingMore;

  PostFeedLoaded({
    required this.posts,
    required this.hasMore,
    this.isLoadingMore = false,
  });

  PostFeedLoaded copyWith({
    List<PostEntity>? posts,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return PostFeedLoaded(
      posts: posts ?? this.posts,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [posts, hasMore, isLoadingMore];
}

class PostFeedError extends PostFeedState {
  final String message;
  PostFeedError(this.message);

  @override
  List<Object?> get props => [message];
}

class PostFeedActionSuccess extends PostFeedState {
  final String message;

  PostFeedActionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}
