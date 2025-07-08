import 'package:feedz/domain/entities/postentity/post_entity.dart';
import 'package:feedz/presentation/blocs/postfeedbloc/post_feed_bloc.dart';
import 'package:feedz/presentation/widgets/common/dialogs/commentdeletionconfirmationdialog/comment_deletion_confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CommentsList extends StatelessWidget {
  final PostEntity post;
  const CommentsList({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostFeedBloc, PostFeedState>(
    builder: (context, state) {
      if (state is PostFeedLoaded) {
        final currentPost = state.posts.firstWhere(
          (p) => p.id == post.id,
          orElse: () => post,
        );
        if (currentPost.comments.isEmpty) {
          return const Center(
            child: Text("No comments yet. Be the first!"),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          itemCount: currentPost.comments.length,
          itemBuilder: (BuildContext context, int index) {
            final comment = currentPost.comments[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          child: Text('You')
                        ),
                        SizedBox(width: 8.0),
                        Text(
                          comment,
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        // Show confirmation dialog
                        showCommentDeletionConfirmationPopup(context, post.id, index);
                      },
                      child: Icon(
                        Icons.delete_outline,
                        color: Colors.red
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }
      return const Center(child: Text("Loading comments..."));
    },
  );
  }
}