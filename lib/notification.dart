import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // A dummy list of notifications
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color.fromARGB(255, 41, 99, 165),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark all as read',
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.separated(
        itemCount: notifications.length,
        separatorBuilder: (context, index) =>
            const Divider(height: 1, thickness: 1),
        itemBuilder: (context, index) {
          final notif = notifications[index];

          return ListTile(
            // Give a very light blue background to unread items
            tileColor: notif['isUnread']
                ? Colors.blue.withOpacity(0.05)
                : Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: CircleAvatar(
              backgroundColor: notif['iconColor'].withOpacity(0.15),
              child: Icon(notif['icon'], color: notif['iconColor']),
            ),
            title: Text(
              notif['title'],
              style: TextStyle(
                fontWeight: notif['isUnread']
                    ? FontWeight.bold
                    : FontWeight.normal,
                fontSize: 15,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                notif['time'],
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
              ),
            ),
            // Add a small blue dot indicator for unread notifications
            trailing: notif['isUnread']
                ? const CircleAvatar(
                    radius: 5,
                    backgroundColor: Colors.blue,
                  )
                : const SizedBox(width: 10), // Empty space if read
            onTap: () {
              // TODO: Navigate to the specific post or announcement
            },
          );
        },
      ),
    );
  }
}
