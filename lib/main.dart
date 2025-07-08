import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:feedz/data/datasources/local/likescomentscache/likes_comments_cache.dart';
import 'package:feedz/data/datasources/remote/httppostsdatasource/http_posts_datasource.dart';
import 'package:feedz/data/repositories/connectivityrepositoryimpl/connectivity_repository_impl.dart';
import 'package:feedz/data/repositories/postrepositoryimpl/post_repository_impl.dart';
import 'package:feedz/domain/entities/connectivitystatusentity/conectivity_status_entity.dart';
import 'package:feedz/domain/repositories/connectivityrepository/connectivity_repository.dart';
import 'package:feedz/domain/repositories/postrepository/post_repository.dart';
import 'package:feedz/domain/usecases/clearcache/clear_cache.dart';
import 'package:feedz/domain/usecases/deletecomment/delete_comment.dart';
import 'package:feedz/domain/usecases/addcomment/add_comment.dart';
import 'package:feedz/domain/usecases/fetchposts/fetch_posts.dart';
import 'package:feedz/domain/usecases/updatelike/update_like.dart';
import 'package:feedz/presentation/blocs/connectivitycubit/connectivity_cubit.dart';
import 'package:feedz/presentation/blocs/postfeedbloc/post_feed_bloc.dart';
import 'package:feedz/presentation/blocs/themecubit/theme_cubit.dart';
import 'package:feedz/presentation/pages/postfeedscreen/post_feed_screen.dart';
import 'package:feedz/presentation/widgets/connectivitybanner/connectivity_banner.dart';
import 'package:feedz/utils/networkinfo/network_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


void main() async {

  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  // Set up Dio
  final dio = Dio(BaseOptions(
    baseUrl: dotenv.env['BASE_URL'] ?? '',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
    sendTimeout: const Duration(seconds: 5),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
    followRedirects: true,
    validateStatus: (status) {
      // Accept status codes from 200 to 299
      return status != null && status >= 200 && status < 300;
    },
  ));

  if(kDebugMode) {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: true,
      )
    );
  }

  // Set up data sources
  final remoteDataSource = HttpPostsDataSource(dio: dio);
  final localCache = LikesCommentsCache();
  final networkInfo = NetworkInfoImpl(Connectivity());

  // Create repositories
  final PostRepository postRepository = PostRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localCache: localCache,
    networkInfo: networkInfo,
  );
  final ConnectivityRepository connectivityRepository =
      ConnectivityRepositoryImpl(networkInfo: networkInfo);

  // Create use cases
  final fetchPosts = FetchPosts(postRepository);
  final toggleLike = ToggleLike(postRepository);
  final addComment = AddComment(postRepository);
  final deleteComment = DeleteComment(postRepository);
  final clearCache = ClearCache(postRepository);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (_) => ThemeCubit()),
        BlocProvider<PostFeedBloc>(
          create: (_) => PostFeedBloc(
            fetchPosts: fetchPosts,
            toggleLike: toggleLike,
            addComment: addComment,
            deleteComment: deleteComment,
            clearCache: clearCache,
          )..add(FetchPostsEvent(1)),
        ),
        BlocProvider<ConnectivityCubit>(
          create: (_) => ConnectivityCubit(
            connectivityRepository: connectivityRepository,
          )..monitorConnectivity(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return MaterialApp(
          title: 'Post Feed',
          theme: ThemeData(
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
          ),
          themeMode: themeMode,
          debugShowCheckedModeBanner: false,
          home: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              const PostFeedScreen(),
              BlocBuilder<ConnectivityCubit, ConnectivityState>(
                builder: (context, state) {
                  bool isVisible = false;
                  bool isRestored = false;

                  if (state is ConnectivityStatusState) {
                    isVisible = state.status == ConnectivityStatus.disconnected ||
                        state.isRestored;
                    isRestored = state.status == ConnectivityStatus.connected &&
                        state.isRestored;
                  }

                  return ConnectivityBanner(
                    isVisible: isVisible,
                    isRestored: isRestored,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
