// import 'package:equatable/equatable.dart';
part of 'post_feed_bloc.dart';
abstract class PostFeedEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchPostsEvent extends PostFeedEvent {
  final int page;
  FetchPostsEvent(this.page);

  @override
  List<Object> get props => [page];
}

class LoadMorePostsEvent extends PostFeedEvent {}

class ToggleLikeEvent extends PostFeedEvent {
  final int postId;
  ToggleLikeEvent(this.postId);

  @override
  List<Object> get props => [postId];
}


class AddCommentEvent extends PostFeedEvent {
  final int postId;
  final String commentContent;
  AddCommentEvent(this.postId, this.commentContent);

  @override
  List<Object> get props => [postId, commentContent];
}

class DeleteCommentEvent extends PostFeedEvent {
  final int postId;
  final int commentIndex;
  DeleteCommentEvent(this.postId, this.commentIndex);

  @override
  List<Object> get props => [postId, commentIndex];
}

class ClearCacheEvent extends PostFeedEvent {}
