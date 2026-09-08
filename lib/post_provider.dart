import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PostProvider extends ChangeNotifier {
  final Set<String> _upvotedPostIds = {};
  bool hasUpvoted(String postId) => _upvotedPostIds.contains(postId);

  List<Map<String, dynamic>> _posts = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get posts => _posts;
  bool get isLoading => _isLoading;

  // Create the Supabase client
  final supabase = Supabase.instance.client;

  PostProvider() {
    fetchPosts();
  }

  // --- 1. FETCH POSTS FROM SUPABASE ---
  Future<void> fetchPosts() async {
    if (_posts.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      // Query the posts table and JOIN the profiles table using the explicit foreign key hint
      final response = await supabase
          .from('posts')
          .select('*, profiles!posts_author_id_fkey(full_name, role)')
          .order(
            'created_at',
            ascending: false,
          ); // Sort newest first automatically

      final List<dynamic> data = response;

      _posts = data.map((item) {
        final profile = item['profiles'] ?? {};

        return {
          'id': item['id'].toString(),
          'uploaderName': profile['full_name'] ?? 'Unknown User',
          'role': profile['role'] ?? 'Student',
          'category': item['category'] ?? 'General',
          'content': item['content'] ?? '',
          'imageUrl': item['image_url'], // Optional image support
          'timeAgo': _calculateTimeAgo(item['created_at']),
          'upvotes': 0, // We will calculate true upvotes in a later step
          'comments': 0,
          'share': 0,
        };
      }).toList();
    } catch (error) {
      print('Error fetching data from Supabase: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- CUSTOM TIME PARSER ---
  String _calculateTimeAgo(String? timestamp) {
    if (timestamp == null) return 'Just now';

    final postDate = DateTime.parse(timestamp).toLocal();
    final now = DateTime.now();
    final difference = now.difference(postDate);

    if (difference.inDays > 7) {
      return '${postDate.day}/${postDate.month}/${postDate.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  // --- 2. UPVOTE POST ---
  Future<void> upvotePost(String postId) async {
    final index = _posts.indexWhere((post) => post['id'] == postId);
    if (index == -1) return;

    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return; // Must be logged in

    try {
      if (_upvotedPostIds.contains(postId)) {
        // REMOVE UPVOTE
        _posts[index]['upvotes'] -= 1;
        _upvotedPostIds.remove(postId);
        notifyListeners(); // Optimistic UI update

        await supabase.from('upvotes').delete().match({
          'post_id': postId,
          'user_id': userId,
        });
      } else {
        // ADD UPVOTE
        _posts[index]['upvotes'] += 1;
        _upvotedPostIds.add(postId);
        notifyListeners(); // Optimistic UI update

        await supabase.from('upvotes').insert({
          'post_id': postId,
          'user_id': userId,
        });
      }
    } catch (error) {
      print('Error toggling upvote: $error');
      // Ideally, revert the UI change here if the database fails
    }
  }

  // --- 3. DELETE POST ---
  Future<void> deletePost(String postId) async {
    // 1. Remove instantly from UI
    _posts.removeWhere((post) => post['id'] == postId);
    notifyListeners();

    // 2. Delete permanently from Supabase
    try {
      await supabase.from('posts').delete().eq('id', postId);
      print('Post deleted successfully');
    } catch (error) {
      print('Error deleting post: $error');
    }
  }

  // --- 4. ADD BRAND NEW POST ---
  Future<void> addPost(
    String category,
    String content, {
    String? imageUrl,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      print('Must be logged in to post');
      return;
    }

    try {
      // Insert into Supabase
      final response = await supabase
          .from('posts')
          .insert({
            'author_id': user.id, // Links directly to the logged-in user
            'content': content,
            'category': category,
            'image_url': imageUrl, // Will be null if no image is provided
          })
          .select('*, profiles!posts_author_id_fkey(full_name, role)')
          .single();

      // Format the returned data to instantly match the UI
      final profile = response['profiles'] ?? {};
      final newPost = {
        'id': response['id'].toString(),
        'uploaderName': profile['full_name'] ?? 'Unknown User',
        'role': profile['role'] ?? 'Student',
        'category': response['category'] ?? 'General',
        'content': response['content'] ?? '',
        'imageUrl': response['image_url'],
        'timeAgo': 'Just now',
        'upvotes': 0,
        'comments': 0,
        'share': 0,
      };

      // Insert at the top of the feed and update UI
      _posts.insert(0, newPost);
      notifyListeners();
      print('Post successfully saved to Supabase!');
    } catch (error) {
      print('Error saving post: $error');
    }
  }
}
