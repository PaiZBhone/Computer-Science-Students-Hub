import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PostProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get posts => _posts;
  bool get isLoading => _isLoading;

  //fetches data when the app starts
  PostProvider() {
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    // 1. Set loading to true and update the UI
    _isLoading = true;
    notifyListeners();

    try {
      // 2. HTTP request
      final url = Uri.parse(
        'https://api.jsonbin.io/v3/b/6a7ae6bbf5f4af5e29065838',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // 3. Decode the JSON response
        final data = json.decode(response.body);

        final List<dynamic> loadedPosts = data['record']['posts'];

        // 4. Convert the dynamic list back into our required Map format
        _posts = loadedPosts
            .map((post) => post as Map<String, dynamic>)
            .toList();
      } else {
        print('Failed to load posts. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching data: $error');
    } finally {
      // 5. Turn off the loading state and rebuild the feed
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logic to upvote a post
  void upvotePost(String postId) {
    final index = _posts.indexWhere((post) => post['id'] == postId);
    if (index != -1) {
      _posts[index]['upvotes'] += 1;
      notifyListeners();
    }
  }

  // publish a brand new post
  void addPost(String category, String content) {
    _posts.insert(0, {
      'id': DateTime.now().toString(),
      'uploaderName': 'CS BANANA',
      'role': 'Student',
      'timeAgo': 'Just now',
      'category': category,
      'content': content,
      'upvotes': 0,
      'comments': 0,
    });
    notifyListeners();
  }
}
