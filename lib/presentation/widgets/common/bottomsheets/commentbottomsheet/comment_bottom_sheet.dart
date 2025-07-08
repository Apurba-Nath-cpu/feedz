import 'package:feedz/domain/entities/postentity/post_entity.dart';
import 'package:feedz/presentation/blocs/postfeedbloc/post_feed_bloc.dart';
import 'package:feedz/presentation/widgets/commentslist/comments_list.dart';
import 'package:feedz/utils/toasts/toasts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void showCommentBottomSheet(BuildContext context, PostEntity post) {
  final controller = TextEditingController();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Allows the sheet to take up more screen space
    builder: (ctx) {
      // Use a padding to handle the keyboard overlapping the text field
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: SizedBox(
          height: MediaQuery.of(ctx).size.height * 0.75, // 75% of screen height
          child: Column(
            children: [
              // Header with back arrow and title
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Text(
                      'Comments',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
              // Comment input field
              Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: const InputDecoration(
                          hintText: "Write a comment...",
                          border: OutlineInputBorder(),
                        ),
                        autofocus: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {
                        final commentText = controller.text;
                        if (commentText.isNotEmpty) {
                          HapticFeedback.heavyImpact();
                          context
                          .read<PostFeedBloc>()
                          .add(AddCommentEvent(post.id, commentText));
                          controller.clear();

                          // Hide keyboard using the bottom sheet's context
                          FocusScope.of(ctx).unfocus();
                          
                          // Show success toast
                          showToast(ToastType.success, 'Comment posted!');
                        } else {
                          showToast(ToastType.info, 'Comment cannot be empty');
                        }
                      },
                      child: Icon(
                        Icons.send,
                      ),
                    ),
                  ],
                ),
              ),
              // List of comments
              Expanded(
                child: CommentsList(post: post),
              ),
            ],
          ),
        ),
      );
    },
  );
}
