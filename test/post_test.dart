import 'package:feedz/data/models/postmodel/post_model.dart';
import 'package:flutter_test/flutter_test.dart';
void main() {
  group('Post Model Tests', () {
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

    test('should convert Post to JSON correctly', () {
      // Arrange
      final post = PostModel(
        id: 1,
        title: 'Test Post',
        description: 'This is a test post body',
        userId: 1,
      );

      // Act
      final json = post.toJson();

      // Assert
      expect(json['id'], 1);
      expect(json['title'], 'Test Post');
      expect(json['body'], 'This is a test post body');
      expect(json['userId'], 1);
    });
  });
}
