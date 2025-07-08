import 'package:bloc_test/bloc_test.dart';
import 'package:feedz/domain/entities/postentity/post_entity.dart';
import 'package:feedz/presentation/blocs/postfeedbloc/post_feed_bloc.dart';
import 'package:feedz/presentation/blocs/themecubit/theme_cubit.dart';
import 'package:feedz/presentation/pages/postfeedscreen/post_feed_screen.dart';
import 'package:feedz/presentation/widgets/common/shimmers/postshimmer/post_shimmer.dart';
import 'package:feedz/presentation/widgets/postcard/post_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes using mocktail, which is used by bloc_test
class MockPostFeedBloc extends MockBloc<PostFeedEvent, PostFeedState>
    implements PostFeedBloc {}

class MockThemeCubit extends MockCubit<ThemeMode> implements ThemeCubit {}

void main() {
  late MockPostFeedBloc mockPostFeedBloc;
  late MockThemeCubit mockThemeCubit;

  setUpAll(() {
    // Register fallback values for events to avoid mocktail errors
    registerFallbackValue(FetchPostsEvent(1));
    registerFallbackValue(LoadMorePostsEvent());
    registerFallbackValue(ClearCacheEvent());
  });

  setUp(() {
    mockPostFeedBloc = MockPostFeedBloc();
    mockThemeCubit = MockThemeCubit();
  });

  // Helper to pump the widget tree with necessary providers
  Widget createWidgetUnderTest() {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PostFeedBloc>.value(value: mockPostFeedBloc),
        BlocProvider<ThemeCubit>.value(value: mockThemeCubit),
      ],
      child: const MaterialApp(
        home: PostFeedScreen(),
      ),
    );
  }

  // Test data
  final tPosts = [
    PostEntity(
      id: 1,
      userId: 1,
      title: 'Title 1',
      description: 'Body 1',
      likesCount: 0,
      comments: const [],
    ),
    PostEntity(
      id: 2,
      userId: 1,
      title: 'Title 2',
      description: 'Body 2',
      likesCount: 5,
      comments: const ['first comment'],
    ),
  ];

  group('PostFeedScreen', () {
    testWidgets('renders PostShimmer when state is PostFeedLoading',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockPostFeedBloc.state).thenReturn(PostFeedLoading());
      when(() => mockThemeCubit.state).thenReturn(ThemeMode.light);

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(PostShimmer), findsOneWidget);
    });

    testWidgets('renders list of PostCards when state is PostFeedLoaded',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockPostFeedBloc.state).thenReturn(
          PostFeedLoaded(posts: tPosts, hasMore: true, isLoadingMore: false));
      when(() => mockThemeCubit.state).thenReturn(ThemeMode.light);

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      // pumpAndSettle is needed to let the slide-in animations finish
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(PostCard), findsNWidgets(tPosts.length));
      expect(find.text('Title 1'), findsOneWidget);
      expect(find.text('Title 2'), findsOneWidget);
    });

    testWidgets('renders empty message when loaded list is empty',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockPostFeedBloc.state).thenReturn(
          PostFeedLoaded(posts: const [], hasMore: false, isLoadingMore: false));
      when(() => mockThemeCubit.state).thenReturn(ThemeMode.light);

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('No posts yet. Pull down to refresh!'), findsOneWidget);
    });

    testWidgets('renders error message and retry button when state is PostFeedError',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockPostFeedBloc.state)
          .thenReturn(PostFeedError('Something went wrong'));
      when(() => mockThemeCubit.state).thenReturn(ThemeMode.light);

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Retry'), findsOneWidget);

      // Act again: tap the retry button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert again: verify event was added
      verify(() => mockPostFeedBloc.add(any(that: isA<FetchPostsEvent>())))
          .called(1);
    });

    testWidgets('scrolling to the bottom triggers loading more posts',
        (WidgetTester tester) async {
      // Arrange - Create enough posts to make the list scrollable
      final longPostList = List.generate(10, (i) => PostEntity(
        id: i,
        userId: 1,
        title: 'Title $i',
        description: 'Body $i with some longer content to make the posts take up more space and ensure scrolling is needed',
        likesCount: 0,
        comments: const [],
      ));
      
      when(() => mockPostFeedBloc.state).thenReturn(
          PostFeedLoaded(posts: longPostList, hasMore: true, isLoadingMore: false));
      when(() => mockThemeCubit.state).thenReturn(ThemeMode.light);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Act - Scroll to near the bottom to trigger load more
      final scrollable = find.byType(Scrollable);
      expect(scrollable, findsOneWidget);
      
      // Scroll down significantly to trigger the load more condition
      await tester.drag(scrollable, const Offset(0, -2000));
      await tester.pumpAndSettle();

      // Assert - Verify that LoadMorePostsEvent was called at least once
      // Multiple calls can happen due to multiple scroll notifications
      verify(() => mockPostFeedBloc.add(any(that: isA<LoadMorePostsEvent>())))
          .called(greaterThan(0));
    });

    testWidgets('pull to refresh dispatches FetchPostsEvent',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockPostFeedBloc.state).thenReturn(PostFeedLoaded(posts: tPosts, hasMore: false, isLoadingMore: false));
      when(() => mockThemeCubit.state).thenReturn(ThemeMode.light);

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Act
      await tester.fling(find.byType(PostCard).first, const Offset(0.0, 300.0), 1000.0);
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockPostFeedBloc.add(any(that: isA<FetchPostsEvent>())))
          .called(1);
    });
  });
}
