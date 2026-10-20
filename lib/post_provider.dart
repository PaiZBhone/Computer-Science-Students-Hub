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

  // --- 1. FETCH POSTS, UPVOTE COUNTS, AND USER UPVOTES FROM SUPABASE ---
  Future<void> fetchPosts() async {
    if (_posts.isEmpty) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final userId = supabase.auth.currentUser?.id;

      if (userId != null) {
        final upvotesResponse = await supabase
            .from('upvotes')
            .select('post_id')
            .eq('user_id', userId);

        _upvotedPostIds.clear();
        for (var row in upvotesResponse) {
          _upvotedPostIds.add(row['post_id'].toString());
        }
      }

      // Explicitly select display_name from joined profiles
      final response = await supabase
          .from('posts')
          .select(
            '*, profiles!posts_author_id_fkey(display_name, role), upvotes(count)',
          )
          .order('created_at', ascending: false);

      final List<dynamic> data = response;

      _posts = data.map((item) {
        final profile = item['profiles'] ?? {};
        final postId = item['id'].toString();

        int realUpvoteCount = 0;
        final upvotesData = item['upvotes'];
        if (upvotesData is List && upvotesData.isNotEmpty) {
          realUpvoteCount = upvotesData[0]['count'] ?? 0;
        }

        return {
          'id': postId,
          // CRITICAL: Must map to display_name from profiles table
          'uploaderName': profile['display_name'] ?? 'Unknown User',
          'role': profile['role'] ?? 'Student',
          'category': item['category'] ?? 'General',
          'content': item['content'] ?? '',
          'imageUrl': item['image_url'],
          'timeAgo': _calculateTimeAgo(item['created_at']),
          'upvotes': realUpvoteCount,
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
    if (userId == null) {
      print('User must be logged in to upvote');
      return;
    }

    try {
      if (_upvotedPostIds.contains(postId)) {
        // REMOVE UPVOTE LOCALLY & FROM SUPABASE
        _posts[index]['upvotes'] -= 1;
        _upvotedPostIds.remove(postId);
        notifyListeners();

        await supabase.from('upvotes').delete().match({
          'post_id': postId,
          'user_id': userId,
        });
      } else {
        // ADD UPVOTE LOCALLY & TO SUPABASE
        _posts[index]['upvotes'] += 1;
        _upvotedPostIds.add(postId);
        notifyListeners();

        await supabase.from('upvotes').insert({
          'post_id': postId,
          'user_id': userId,
        });
      }
    } catch (error) {
      print('Error syncing upvote to database: $error');
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
    if (user == null) return;

    try {
      final response = await supabase
          .from('posts')
          .insert({
            'author_id': user.id,
            'content': content,
            'category': category,
            'image_url': imageUrl,
          })
          .select('*, profiles!posts_author_id_fkey(display_name, role)')
          .single();

      final profile = response['profiles'] ?? {};
      final newPost = {
        'id': response['id'].toString(),
        'uploaderName':
            profile['display_name'] ??
            'Unknown User', // Maps display_name!
        'role': profile['role'] ?? 'Student',
        'category': response['category'] ?? 'General',
        'content': response['content'] ?? '',
        'imageUrl': response['image_url'],
        'timeAgo': 'Just now',
        'upvotes': 0,
        'comments': 0,
        'share': 0,
      };

      _posts.insert(0, newPost);
      notifyListeners();
    } catch (error) {
      print('Error saving post: $error');
    }
  }
}
