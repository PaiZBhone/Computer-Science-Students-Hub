import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'post_detail.dart';
import 'package:provider/provider.dart';
import 'post_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

class PostCard extends StatelessWidget {
  final String id;
  final String uploaderName;
  final String category;
  final String role;
  final String timeAgo;
  final String content;
  final int upvotes;
  final int comments;
  final int share;

  const PostCard({
    super.key,
    required this.id,
    required this.uploaderName,
    required this.category,
    required this.role,
    required this.timeAgo,
    required this.content,
    required this.upvotes,
    required this.comments,
    required this.share,
  });

  @override
  Widget build(BuildContext context) {
    final isUpvoted = Provider.of<PostProvider>(context).hasUpvoted(id);
    return InkWell(
      onTap: () {
        //This is the navigation logic when the post is tapped
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailScreen(
              id: id,
              uploaderName: uploaderName,
              role: role,
              category: category,
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
              // Header: Avatar, Name, Role, Category(added new), Options
              Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: const Color.fromARGB(
                      255,
                      41,
                      99,
                      165,
                    ),
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
                        const SizedBox(height: 2), // Tiny spacing
                        Text(
                          category,
                          style: TextStyle(
                            color:
                                Colors.blue[700], // Makes the category pop
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(PhosphorIconsFill.dotsThreeOutline),
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
                    onPressed: () {
                      Provider.of<PostProvider>(
                        context,
                        listen: false,
                      ).upvotePost(id);
                    },
                    icon: Icon(
                      // If liked, use solid icon. If not, use outline icon.
                      isUpvoted
                          ? PhosphorIconsFill.heart
                          : PhosphorIconsRegular.heart,
                      size: 20,
                      color: isUpvoted ? Colors.blue : Colors.grey[700],
                    ),
                    label: Text(
                      '$upvotes',
                      style: TextStyle(
                        color: isUpvoted ? Colors.blue : Colors.grey[700],
                        fontWeight: isUpvoted
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(
                      PhosphorIconsFill.chatCircleDots,
                      size: 20,
                      color: Color.fromARGB(255, 97, 97, 97),
                    ),
                    label: Text(
                      '$comments',
                      style: TextStyle(
                        color: Color.fromARGB(255, 97, 97, 97),
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {},
                    icon: const Icon(
                      PhosphorIconsFill.arrowBendUpRight,
                      size: 20,
                      color: Color.fromARGB(255, 97, 97, 97),
                    ),
                    label: Text(
                      '$share',
                      style: TextStyle(
                        color: Color.fromARGB(255, 97, 97, 97),
                      ),
                    ),
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
