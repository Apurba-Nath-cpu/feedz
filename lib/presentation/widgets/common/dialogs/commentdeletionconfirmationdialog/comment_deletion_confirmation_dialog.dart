import 'package:feedz/presentation/blocs/postfeedbloc/post_feed_bloc.dart';
import 'package:feedz/utils/toasts/toasts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> showCommentDeletionConfirmationPopup(BuildContext context, int postId, int commentIndex) {
  return showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Delete Comment'),
      content: const Text(
        'Are you sure you want to delete this comment?',
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(dialogContext).pop(),
        ),
        TextButton(
          child: const Text('Delete',
              style: TextStyle(color: Colors.red)),
          onPressed: () {
            context.read<PostFeedBloc>().add(
              DeleteCommentEvent(postId, commentIndex),
            );
            
            Navigator.of(dialogContext).pop();

            showToast(ToastType.success, 'Comment deleted!');
          },
        ),
      ],
    ),
  );
}
