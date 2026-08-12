import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Check if Dark Mode is active
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final List<Map<String, dynamic>> notifications = [
      {
        'icon': Icons.campaign,
        'iconColor': Colors.orange,
        'title': 'New Department Announcement posted.',
        'time': '10 mins ago',
        'isUnread': true,
      },
      {
        'icon': Icons.thumb_up,
        'iconColor': Colors.blue,
        'title':
            'Alex Developer upvoted your post about memory allocation.',
        'time': '2 hours ago',
        'isUnread': true,
      },
      {
        'icon': Icons.comment,
        'iconColor': Colors.green,
        'title': 'Dr. S. Lecturer commented on your question.',
        'time': '1 day ago',
        'isUnread': false,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0, // Flat design
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark all as read',
            onPressed: () {},
          ),
        ],
      ),
      // 2. Switched from ListView.separated to ListView.builder for a borderless, cleaner look
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notif = notifications[index];

          return Container(
            // 3. Dynamic background highlight for unread items
            color: notif['isUnread']
                ? (isDarkMode
                      ? Colors.blue.withOpacity(0.1)
                      : Colors.blue.withOpacity(0.05))
                : Colors.transparent,
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12, // Extra breathing room feels more premium
              ),
              leading: CircleAvatar(
                radius: 26, // Slightly larger avatar
                backgroundColor: notif['iconColor'].withOpacity(
                  isDarkMode ? 0.2 : 0.15,
                ),
                child: Icon(
                  notif['icon'],
                  color: notif['iconColor'],
                  size: 26,
                ),
              ),
              title: Text(
                notif['title'],
                style: TextStyle(
                  fontWeight: notif['isUnread']
                      ? FontWeight.bold
                      : FontWeight.w500,
                  fontSize: 15,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text(
                  notif['time'],
                  style: TextStyle(
                    color: isDarkMode
                        ? Colors.grey[400]
                        : Colors.grey[600],
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              // Modern Unread Dot Indicator
              trailing: notif['isUnread']
                  ? Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    )
                  : const SizedBox(width: 10),
              onTap: () {
                // Navigate to the specific post or announcement
              },
            ),
          );
        },
      ),
    );
  }
}
