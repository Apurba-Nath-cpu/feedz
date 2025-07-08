# Feedz - Flutter Post Feed Application

A modern Flutter application that displays a social media-style post feed with offline capabilities, real-time connectivity monitoring, and clean architecture implementation.

## 🚀 Features

- **Post Feed Display**: Browse through posts with titles, descriptions, and user interactions
- **Like System**: Toggle likes on posts with local caching
- **Comment System**: Add and delete comments on posts
- **Offline Support**: Cached data available when offline
- **Connectivity Monitoring**: Real-time network status with visual indicators
- **Pull-to-Refresh**: Refresh posts by pulling down
- **Infinite Scrolling**: Load more posts as you scroll
- **Dark/Light Theme**: Toggle between theme modes
- **Shimmer Loading**: Elegant loading animations
- **Haptic Feedback**: Polished UX and better event recogniton
- **Clean Architecture**: Well-structured codebase following SOLID principles

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.8.0 or higher)
- [Dart SDK](https://dart.dev/get-dart) (included with Flutter)
- [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/)
- [Git](https://git-scm.com/)

## 🛠️ Project Setup Instructions

### 1. Clone the Repository

```
git clone https://github.com/Apurba-Nath-cpu/feedz.git
cd feedz
```

### 2. Install Dependencies

```
flutter pub get
```

### 3. Generate Code (if needed)

The project uses code generation for models and other boilerplate code:

```
flutter packages pub run build_runner build
```

### 4. Run the Application

```
flutter run
```

For specific platforms:

```
# Android
flutter run -d android

# iOS
flutter run -d ios

# Web
flutter run -d web
```

## 🏗️ Architecture & State Management

### Clean Architecture

The project follows Clean Architecture principles with clear separation of concerns:

```
lib/
├── data/
│   ├── datasources/
│   │   ├── local/          # Local data sources (cache)
│   │   └── remote/         # Remote data sources (API)
│   └── repositories/       # Repository implementations
├── domain/
│   ├── entities/           # Business entities
│   ├── repositories/       # Repository interfaces
│   └── usecases/          # Business logic use cases
├── presentation/
│   ├── blocs/             # State management (BLoC)
│   ├── pages/             # Screen widgets
│   └── widgets/           # Reusable UI components
└── utils/                 # Utilities and helpers
```

### State Management - BLoC Pattern

**Why BLoC was chosen:**

1. **Predictable State Management**: BLoC provides a clear, predictable way to manage application state
2. **Separation of Concerns**: Business logic is separated from UI components
3. **Testability**: Easy to unit test business logic independently
4. **Reactive Programming**: Built on streams and reactive programming principles
5. **Flutter Integration**: Excellent integration with Flutter through flutter_bloc package

**BLoC Implementation:**

- **PostFeedBloc**: Manages post feed state (loading, loaded, error)
- **ConnectivityCubit**: Handles network connectivity status
- **ThemeCubit**: Manages app theme (light/dark mode)

### Key State Management Features:

```
// Example BLoC usage
BlocProvider<PostFeedBloc>(
  create: (_) => PostFeedBloc(
    fetchPosts: fetchPosts,
    toggleLike: toggleLike,
    addComment: addComment,
    deleteComment: deleteComment,
    clearCache: clearCache,
  )..add(FetchPostsEvent(1)),
)
```

## 📦 Dependencies

### Core Dependencies

| Package              | Version  | Purpose                             |
|----------------------|----------|-------------------------------------|
| `flutter_bloc`       | ^9.1.1   | State management using BLoC pattern |
| `dio`                | ^5.8.0+1 | HTTP client for API requests        |
| `connectivity_plus`  | ^6.1.4   | Network connectivity monitoring     |
| `shared_preferences` | ^2.5.3   | Local data persistence              |
| `equatable`          | ^2.0.7   | Value equality for Dart objects     |

### UI & UX Dependencies

| Package           | Version | Purpose                    |
|-------------------|---------|----------------------------|
| `shimmer`         | ^3.0.0  | Loading shimmer animations |
| `fluttertoast`    | ^2.12   | Toast notifications        |
| `cupertino_icons` | ^1.0.8  | iOS-style icons            |

### Code Generation

| Package             | Version | Purpose                            |
|---------------------|---------|------------------------------------|
| `freezed`           | ^3.1.0  | Immutable classes and unions       |
| `json_annotation`   | ^4.9.0  | JSON serialization annotations     |
| `json_serializable` | ^6.9.5  | JSON serialization code generation |
| `build_runner`      | ^2.5.4  | Code generation runner             |

### Development & Testing

| Package             | Version | Purpose                   |
|---------------------|---------|---------------------------|
| `flutter_test`      | SDK     | Flutter testing framework |
| `bloc_test`         | ^10.0.0 | BLoC testing utilities    |
| `mocktail`          | ^1.0.4  | Mocking framework         |
| `mockito`           | ^5.4.6  | Mock object generation    |
| `http_mock_adapter` | ^0.6.1  | HTTP request mocking      |

## 🧪 Testing

### Running Tests

Execute all tests:

```
flutter test
```

Run tests with coverage:

```
flutter test --coverage
```

View coverage report:

```
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Test Structure

The project includes comprehensive unit and widget tests:

```
// Example unit test
test('should create Post from JSON correctly', () {
    // Arrange
    final json = {
    'id': 1,
    'title': 'Test Post',
    'body': 'This is a test post body',
    'userId': 1,
    };

    // Act
    final post = PostModel.fromJson(json);

    // Assert
    expect(post.id, 1);
    expect(post.title, 'Test Post');
    expect(post.description, 'This is a test post body');
    expect(post.userId, 1);
});
```


```
// Example widget test
testWidgets('renders list of PostCards when state is PostFeedLoaded',
    (WidgetTester tester) async {
  // Arrange
  when(() => mockPostFeedBloc.state).thenReturn(
      PostFeedLoaded(posts: tPosts, hasMore: true, isLoadingMore: false));
  
  // Act
  await tester.pumpWidget(createWidgetUnderTest());
  await tester.pumpAndSettle();

  // Assert
  expect(find.byType(PostCard), findsNWidgets(tPosts.length));
});
```


### Testing Features Covered

- ✅ Widget rendering based on different states
- ✅ User interactions (tap, scroll, pull-to-refresh)
- ✅ BLoC event dispatching
- ✅ Error state handling
- ✅ Loading state animations
- ✅ Mock data and API responses

## 🌐 API Integration

The app integrates with JSONPlaceholder API:

- **Base URL**: `https://jsonplaceholder.typicode.com/`
- **Endpoints**: Posts, Comments, Users
- **Timeout**: 5 seconds for all requests
- **Error Handling**: Comprehensive error handling with user feedback

### Network Configuration

```
final dio = Dio(BaseOptions(
  baseUrl: 'https://jsonplaceholder.typicode.com/',
  connectTimeout: const Duration(seconds: 5),
  receiveTimeout: const Duration(seconds: 5),
  sendTimeout: const Duration(seconds: 5),
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  },
));
```

## 🔧 Configuration

### Debug Mode Features

- HTTP request/response logging
- Detailed error messages
- Development-specific debugging tools

### Production Optimizations

- Disabled debug logging
- Optimized network timeouts
- Error handling without sensitive information

## 📱 Platform Support

- ✅ Android
- ✅ iOS  
- ✅ Web
- ✅ Desktop (Windows, macOS, Linux)

## 🐛 Troubleshooting

### Common Issues

**1. Build Runner Issues**
```
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

**2. Dependency Conflicts**
```
flutter clean
flutter pub get
```

**3. Network Issues**
- Check internet connectivity
- Verify API endpoint accessibility
- Review firewall/proxy settings

**Built with ❤️ using Flutter and BLoC**
