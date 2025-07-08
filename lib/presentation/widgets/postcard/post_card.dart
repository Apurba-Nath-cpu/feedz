import 'package:feedz/domain/entities/postentity/post_entity.dart';
import 'package:feedz/presentation/blocs/postfeedbloc/post_feed_bloc.dart';
import 'package:feedz/presentation/widgets/common/bottomsheets/commentbottomsheet/comment_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PostCard extends StatelessWidget {
  final PostEntity post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).highlightColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  post.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  )
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              post.description,
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    post.likesCount > 0 ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                    color: post.likesCount > 0 ? Colors.blue : null,
                  ),
                  onPressed: () {
                    HapticFeedback.heavyImpact();
                    context.read<PostFeedBloc>().add(ToggleLikeEvent(post.id));
                  },
                ),
                Text('${post.likesCount}'),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.comment_outlined),
                  onPressed: () {
                    showCommentBottomSheet(context, post);
                  },
                ),
                Text('${post.comments.length}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}