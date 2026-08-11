import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PostProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get posts => _posts;
  bool get isLoading => _isLoading;

  PostProvider() {
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse(
        'https://api.jsonbin.io/v3/b/6a7ae6bbf5f4af5e29065838',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> loadedPosts = data['record']['posts'];

        _posts = loadedPosts
            .map((post) => post as Map<String, dynamic>)
            .toList();

        // Sorting the post with custom time parser
        _posts.sort((a, b) {
          DateTime timeA = _parseTimeAgo(a['timeAgo'] ?? '');
          DateTime timeB = _parseTimeAgo(b['timeAgo'] ?? '');
          return timeB.compareTo(timeA);
        });
      } else {
        print('Failed to load posts. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching data: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- CUSTOM PARSER ---
  // Converts strings like "3 hours ago" into real mathematical time
  DateTime _parseTimeAgo(String timeAgo) {
    final now = DateTime.now();
    final parts = timeAgo.split(' ');

    if (parts.isEmpty) return now;
    final int value = int.tryParse(parts[0]) ?? 0;

    if (timeAgo.contains('minute')) {
      return now.subtract(Duration(minutes: value));
    } else if (timeAgo.contains('hour')) {
      return now.subtract(Duration(hours: value));
    } else if (timeAgo.contains('day')) {
      return now.subtract(Duration(days: value));
    }

    return now;
  }

  // Logic to upvote a post
  void upvotePost(String postId) {
    final index = _posts.indexWhere((post) => post['id'] == postId);
    if (index != -1) {
      _posts[index]['upvotes'] += 1;
      notifyListeners();
    }
  }

  // Logic to publish a brand new post
  void addPost(String category, String content) {
    _posts.insert(0, {
      'id': DateTime.now().toString(),
      'uploaderName': 'Pai Zaw Bhone',
      'role': 'Student',
      'timeAgo': 'Just now', // Displays instantly
      'category': category,
      'content': content,
      'upvotes': 0,
      'comments': 0,
    });
    notifyListeners();
  }
}
