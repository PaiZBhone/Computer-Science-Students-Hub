import 'package:flutter/material.dart';

// ChangeNotifier gives this class the ability to alert the UI when data changes
class PostProvider extends ChangeNotifier {
  //added 'id' to easily find exactly which post gets upvoted
  final List<Map<String, dynamic>> _posts = [
    {
      'id': '1',
      'uploaderName': 'Dr. S John',
      'role': 'Lecturer',
      'timeAgo': '1 hour ago',
      'category': '📌 Announcements',
      'content':
          'Attention Students: The Object-Oriented Programming midterm grades have been posted. Please check the portal. We will review the Java practical questions in tomorrow\'s lecture.',
      'upvotes': 45,
      'comments': 12,
    },
    {
      'id': '2',
      'uploaderName': 'Larry',
      'role': 'Student',
      'timeAgo': '3 hours ago',
      'category': '📚 Academic',
      'content':
          'Does anyone have a good visual guide for how the Buddy System memory allocation works? Struggling with this Computer Architecture concept.',
      'upvotes': 8,
      'comments': 3,
    },
    {
      'id': '3',
      'uploaderName': 'Hein Htet',
      'role': 'Student',
      'timeAgo': '3 hours ago',
      'category': '📚 Academic',
      'content':
          'Does anyone have a good visual guide for how the Buddy System memory allocation works? Struggling with this Computer Architecture concept.',
      'upvotes': 8,
      'comments': 3,
    },
    {
      'id': '4',
      'uploaderName': 'Wathan Oo',
      'role': 'Student',
      'timeAgo': '3 hours ago',
      'category': '🎮 Social',
      'content':
          'Need a break from coding! Anyone want to queue up for some Counter-Strike 2 competitive matches tonight around 8 PM?',
      'upvotes': 15,
      'comments': 7,
    },
    {
      'id': '5',
      'uploaderName': 'Htoo Aung Lin',
      'role': 'Student',
      'timeAgo': '3 hours ago',
      'category': '📚 Academic',
      'content':
          'Does anyone have a good visual guide for how the Buddy System memory allocation works? Struggling with this Computer Architecture concept.',
      'upvotes': 8,
      'comments': 3,
    },
    {
      'id': '6',
      'uploaderName': 'Alex',
      'role': 'Student',
      'timeAgo': '5 hours ago',
      'category': '🎮 Social',
      'content':
          'Need a break from coding! Anyone want to queue up for some Counter-Strike 2 competitive matches tonight around 8 PM?',
      'upvotes': 15,
      'comments': 7,
    },
  ];

  List<Map<String, dynamic>> get posts => _posts;

  // 1. Logic to upvote a post
  void upvotePost(String postId) {
    final index = _posts.indexWhere((post) => post['id'] == postId);
    if (index != -1) {
      _posts[index]['upvotes'] += 1; // Increase the count
      notifyListeners();
    }
  }

  // 2. Logic to publish a brand new post
  void addPost(String category, String content) {
    _posts.insert(0, {
      'id': DateTime.now().toString(), // Generates a unique ID
      'uploaderName': 'CS BANANA',
      'role': 'Student',
      'timeAgo': 'Just now',
      'category': category,
      'content': content,
      'upvotes': 0,
      'comments': 0,
    });
    notifyListeners(); // Tells the Home tab feed to update and show the new post
  }
}
