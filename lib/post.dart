import 'package:flutter/material.dart';
import 'post_detail.dart';
import 'package:provider/provider.dart';
import 'post_provider.dart';

class PostCard extends StatelessWidget {
  final String id;
  final String uploaderName;
  final String role;
  final String timeAgo;
  final String content;
  final int upvotes;
  final int comments;

  const PostCard({
    super.key,
    required this.id,
    required this.uploaderName,
    required this.role,
    required this.timeAgo,
    required this.content,
    required this.upvotes,
    required this.comments,
  });

  @override
  Widget build(BuildContext context) {
    // 1. We wrap the entire Card in an InkWell to make it clickable
    return InkWell(
      onTap: () {
        // 2. This is the navigation logic when the post is tapped
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailScreen(
              uploaderName: uploaderName,
              role: role,
              timeAgo: timeAgo,
              content: content,
            ),
          ),
        );
      },
      child: Card(
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
              // Header: Avatar, Name, Role, Options
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
                    onPressed: () {},
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Body: Post Content
              Text(
                content,
                style: const TextStyle(fontSize: 15, height: 1.4),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1, thickness: 1),

              // Action Bar: Upvote, Comment, Share
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    // Call the upvote function from the provider when pressed!
                    onPressed: () {
                      Provider.of<PostProvider>(
                        context,
                        listen: false,
                      ).upvotePost(id);
                    },
                    icon: const Icon(
                      Icons.thumb_up_alt_outlined,
                      size: 20,
                    ),
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
      ),
    );
  }
}
