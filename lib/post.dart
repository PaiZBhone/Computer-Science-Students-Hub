import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  final String uploaderName;
  final String role;
  final String timeAgo;
  final String content;
  final int upvotes;
  final int comments;

  const PostCard({
    super.key,
    required this.uploaderName,
    required this.role,
    required this.timeAgo,
    required this.content,
    required this.upvotes,
    required this.comments,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header: Avatar, Name, Role, Options
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        uploaderName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '$role • $timeAgo',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: () {
                    // TODO: Add bottom sheet for edit/delete
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 2. Body: Post Content
            Text(
              content,
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, thickness: 1),

            // 3. Action Bar: Upvote, Comment, Share
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.thumb_up_alt_outlined, size: 20),
                  label: Text('$upvotes'),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.comment_outlined, size: 20),
                  label: Text('$comments'),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.share, size: 20),
                  label: const Text('Share'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
