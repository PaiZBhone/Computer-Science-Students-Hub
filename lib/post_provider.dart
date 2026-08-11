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
    if (_posts.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }

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

  //upvote a post permanently
  Future<void> upvotePost(String postId) async {
    // 1. Find  post in local list
    final index = _posts.indexWhere((post) => post['id'] == postId);

    if (index != -1) {
      // 2. Optimistic UI update: increase the count instantly for a snappy feel
      _posts[index]['upvotes'] += 1;
      notifyListeners();

      // 3. Save the new count
      try {
        final url = Uri.parse(
          'https://api.jsonbin.io/v3/b/6a7ae6bbf5f4af5e29065838',
        );

        final response = await http.put(
          url,
          headers: {
            'Content-Type': 'application/json',
            'X-Master-Key':
                r'$2a$10$X2KX8JcpVTj3Fiuh89RuNu3XquTFjlQPrdqbYL6DBd7cFLuFkgZZW',
          },
          body: json.encode({
            'posts':
                _posts, // Send the newly updated list back to the server
          }),
        );

        if (response.statusCode != 200) {
          print('Failed to sync upvote. Status: ${response.statusCode}');
        } else {
          print('Upvote permanently saved!');
        }
      } catch (error) {
        print('Error saving upvote: $error');
      }
    }
  }

  // Logic to publish a brand new post
  // Logic to publish a brand new post permanently
  Future<void> addPost(String category, String content) async {
    // 1. Create the new post object
    final newPost = {
      'id': DateTime.now().toString(),
      'timestamp': DateTime.now().toIso8601String(),
      'uploaderName': 'Pai Zaw Bhone',
      'role': 'Student',
      'timeAgo': 'Just now',
      'category': category,
      'content': content,
      'upvotes': 0,
      'comments': 0,
    };

    // 2. Add it to the local list instantly so the UI feels incredibly fast (Optimistic UI updating)
    _posts.insert(0, newPost);
    notifyListeners();

    // 3. Save it to the cloud permanently
    try {
      final url = Uri.parse(
        'https://api.jsonbin.io/v3/b/6a7ae6bbf5f4af5e29065838',
      );

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'X-Master-Key':
              r'$2a$10$X2KX8JcpVTj3Fiuh89RuNu3XquTFjlQPrdqbYL6DBd7cFLuFkgZZW', // Paste your key here!
        },
        body: json.encode({
          'posts':
              _posts, // We send the entire updated list back to the server
        }),
      );

      if (response.statusCode != 200) {
        print('Failed to save to cloud. Status: ${response.statusCode}');
        print('Error details: ${response.body}');
      } else {
        print('Post successfully saved to the cloud!');
      }
    } catch (error) {
      print('Error saving data: $error');
    }
  }
}
