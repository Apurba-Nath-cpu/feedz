import 'package:feedz/presentation/blocs/postfeedbloc/post_feed_bloc.dart';
import 'package:feedz/presentation/blocs/themecubit/theme_cubit.dart';
import 'package:feedz/presentation/widgets/animatedwidgets/animatedslidein/animated_slide_in.dart';
import 'package:feedz/presentation/widgets/common/shimmers/postshimmer/post_shimmer.dart';
import 'package:feedz/presentation/widgets/postcard/post_card.dart';
import 'package:feedz/utils/toasts/toasts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PostFeedScreen extends StatelessWidget {
  const PostFeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedz'),
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
              ? Icons.light_mode
              : Icons.dark_mode,
            ),
            onPressed: () => context.read<ThemeCubit>().toggleTheme(),
          ),
          IconButton(
            icon: Icon(
              Icons.restore_rounded,
            ),
            onPressed: () {
              HapticFeedback.heavyImpact();
              context.read<PostFeedBloc>().add(ClearCacheEvent());
            },
          ),
        ],
      ),
      body: BlocConsumer<PostFeedBloc, PostFeedState>(
        listenWhen: (previous, current) =>
            current is PostFeedActionSuccess || current is PostFeedError,
        listener: (context, state) {
          if (state is PostFeedActionSuccess) {
            showToast(ToastType.success, state.message);
          } else if (state is PostFeedError) {
            showToast(ToastType.error, state.message);
          }
        },
        buildWhen: (previous, current) => current is! PostFeedActionSuccess,
        builder: (context, state) {
          if (state is PostFeedLoading) {
            return const PostShimmer(count: 5);
          } else if (state is PostFeedError) {
            String errorMessage = 'Something went wrong';
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(errorMessage),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      HapticFeedback.heavyImpact();
                      context.read<PostFeedBloc>().add(FetchPostsEvent(1));
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state is PostFeedLoaded) {
            final posts = state.posts;
            return RefreshIndicator(
              onRefresh: () async {
                context.read<PostFeedBloc>().add(FetchPostsEvent(1));
              },
              backgroundColor: Colors.white,
              color: Theme.of(context).primaryColor,
              strokeWidth: 3.0,
              displacement: 60.0,
              child: posts.isEmpty
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox,
                      size: 64,
                    ),
                    Text(
                      'No posts yet. Pull down to refresh!',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              )
              : NotificationListener<ScrollNotification>(
                  onNotification: (scrollInfo) {
                    if (
                      scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 100 &&
                      !state.isLoadingMore &&
                      state.hasMore
                    ) {
                      context.read<PostFeedBloc>().add(LoadMorePostsEvent());
                    }
                    return false;
                  },
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            // Render actual posts
                            if (index < posts.length) {
                              final post = posts[index];
                              return AnimatedSlideIn(
                                delay: Duration(milliseconds: index * 50),
                                isRight: index.isEven,
                                child: PostCard(post: post),
                              );
                            }
                            // Render shimmer immediately after the last post when loading more
                            else if (index == posts.length && state.isLoadingMore) {
                              return const PostShimmer(count: 3);
                            }
                            return null;
                          },
                          childCount: posts.length + (state.isLoadingMore ? 1 : 0),
                        ),
                      ),
                    ],
                  ),
                ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
