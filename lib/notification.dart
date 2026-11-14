import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'post_detail.dart';
import 'post_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await supabase
          .from('notifications')
          .select('''
            *,
            actor:profiles!notifications_actor_id_fkey (
              display_name
            ),
            posts (
              id,
              content,
              category,
              image_url,
              created_at,
              profiles!posts_author_id_fkey (
                display_name,
                role,
                avatar_url
              )
            )
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _notifications = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _markAllAsRead() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    setState(() {
      for (var notif in _notifications) {
        notif['is_read'] = true;
      }
    });

    try {
      await supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);

      if (mounted) {
        Provider.of<PostProvider>(
          context,
          listen: false,
        ).fetchUnreadNotificationCount();
      }
    } catch (e) {
      debugPrint('Error marking all as read: $e');
    }
  }

  Future<void> _handleNotificationTap(
    Map<String, dynamic> notif,
    int index,
  ) async {
    if (notif['is_read'] == false) {
      setState(() {
        _notifications[index]['is_read'] = true;
      });

      try {
        await supabase
            .from('notifications')
            .update({'is_read': true})
            .eq('id', notif['id']);

        if (mounted) {
          Provider.of<PostProvider>(
            context,
            listen: false,
          ).fetchUnreadNotificationCount();
        }
      } catch (e) {
        debugPrint('Error updating notification status: $e');
      }
    }

    final post = notif['posts'];
    if (post != null && mounted) {
      final profile = post['profiles'] ?? {};
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PostDetailScreen(
            id: post['id'].toString(),
            uploaderName: profile['display_name'] ?? 'Unknown User',
            uploaderAvatar: profile['avatar_url'],
            role: profile['role'] ?? 'Student',
            category: post['category'] ?? 'General',
            timeAgo: _calculateTimeAgo(post['created_at']),
            content: post['content'] ?? '',
            imageUrl: post['image_url'],
          ),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This post is no longer available.')),
      );
    }
  }

  String _buildLiveTitle(Map<String, dynamic> notif) {
    final actor = notif['actor'];
    final String liveName =
        (actor != null && actor['display_name'] != null)
        ? actor['display_name']
        : 'Someone';

    final String type = notif['type'] ?? '';
    final String rawTitle = notif['title'] ?? '';

    if (type == 'upvote') {
      return '$liveName upvoted your post.';
    } else if (type == 'comment') {
      if (rawTitle.contains('replied to a post')) {
        return '$liveName replied to a post you commented on.';
      } else if (rawTitle.contains('also commented')) {
        return '$liveName also commented on a post you follow.';
      }
      return '$liveName commented on your post.';
    } else if (type.isNotEmpty) {
      return 'New $type post from $liveName';
    }

    return rawTitle;
  }

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

  IconData _getIconForType(String? type) {
    if (type == 'upvote') return Icons.favorite;
    if (type == 'comment') return Icons.chat_bubble;
    if (type == null) return Icons.notifications;

    if (type.contains('Announcements')) return Icons.campaign;
    if (type.contains('Academic')) return Icons.school;
    if (type.contains('Social')) return Icons.groups;
    if (type.contains('Food')) return Icons.restaurant;
    if (type.contains('Campus')) return Icons.account_balance;
    if (type.contains('Music')) return Icons.music_note;
    if (type.contains('Fun')) return Icons.sentiment_very_satisfied;
    if (type.contains('Tech')) return Icons.computer;
    if (type.contains('Weather')) return Icons.cloud;
    return Icons.article;
  }

  Color _getColorForType(String? type) {
    if (type == 'upvote') return Colors.blue;
    if (type == 'comment') return Colors.green;
    if (type == null) return const Color.fromARGB(255, 41, 99, 165);

    if (type.contains('Announcements')) return Colors.orange;
    if (type.contains('Academic')) return Colors.indigo;
    if (type.contains('Social')) return Colors.purple;
    if (type.contains('Food')) return Colors.redAccent;
    if (type.contains('Tech')) return Colors.teal;
    return const Color.fromARGB(255, 41, 99, 165);
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          if (_notifications.any((n) => n['is_read'] == false))
            IconButton(
              icon: const Icon(Icons.done_all),
              tooltip: 'Mark all as read',
              onPressed: _markAllAsRead,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchNotifications,
              child: _notifications.isEmpty
                  ? ListView(
                      children: [
                        SizedBox(
                          height:
                              MediaQuery.of(context).size.height * 0.65,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.notifications_none,
                                  size: 64,
                                  color: Colors.grey[500],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No notifications yet',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: isDarkMode
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 100),
                      itemCount: _notifications.length,
                      itemBuilder: (context, index) {
                        final notif = _notifications[index];
                        final bool isUnread = notif['is_read'] == false;
                        final IconData icon = _getIconForType(
                          notif['type'],
                        );
                        final Color iconColor = _getColorForType(
                          notif['type'],
                        );

                        return Container(
                          color: isUnread
                              ? (isDarkMode
                                    ? Colors.blue.withOpacity(0.1)
                                    : Colors.blue.withOpacity(0.05))
                              : Colors.transparent,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            leading: CircleAvatar(
                              radius: 26,
                              backgroundColor: iconColor.withOpacity(
                                isDarkMode ? 0.2 : 0.15,
                              ),
                              child: Icon(
                                icon,
                                color: iconColor,
                                size: 26,
                              ),
                            ),
                            title: Text(
                              _buildLiveTitle(notif),
                              style: TextStyle(
                                fontWeight: isUnread
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                fontSize: 15,
                                color: isDarkMode
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: Text(
                                _calculateTimeAgo(notif['created_at']),
                                style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.grey[400]
                                      : Colors.grey[600],
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            trailing: isUnread
                                ? Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: Colors.blue,
                                      shape: BoxShape.circle,
                                    ),
                                  )
                                : const SizedBox(width: 10),
                            onTap: () =>
                                _handleNotificationTap(notif, index),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
