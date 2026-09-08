import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'post_detail.dart';
import 'package:provider/provider.dart';
import 'post_provider.dart';

class PostCard extends StatelessWidget {
  final String id;
  final String uploaderName;
  final String category;
  final String role;
  final String timeAgo;
  final String content;
  final String? imageUrl; // NEW: Optional image link property
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
    this.imageUrl, // Added to constructor
    required this.upvotes,
    required this.comments,
    required this.share,
  });

  // 1. Helper method
  Widget _buildRoleBadge(String role, bool isDarkMode) {
    Color bgColor;
    Color textColor;

    // Determine colors based on the role
    if (role.toLowerCase() == 'student') {
      bgColor = const Color.fromARGB(255, 41, 99, 165).withOpacity(0.15);
      textColor = isDarkMode
          ? Colors.blue[300]!
          : const Color.fromARGB(255, 41, 99, 165);
    } else if (role.toLowerCase() == 'lecturer') {
      bgColor = Colors.teal.withOpacity(0.15);
      textColor = isDarkMode ? Colors.teal[300]! : Colors.teal[700]!;
    } else if (role.toLowerCase() == 'official department') {
      bgColor = Colors.deepPurple.withOpacity(0.15);
      textColor = isDarkMode
          ? Colors.deepPurple[300]!
          : Colors.deepPurple[700]!;
    } else {
      bgColor = Colors.grey.withOpacity(0.15);
      textColor = isDarkMode ? Colors.grey[400]! : Colors.grey[700]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12), // Pill shape
      ),
      child: Text(
        role,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isUpvoted = Provider.of<PostProvider>(context).hasUpvoted(id);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        //navigation logic when the post is tapped
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
        //post color
        color: isDarkMode
            ? const Color.fromARGB(255, 30, 30, 30)
            : Colors.white,
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
              // Header: Avatar, Name, Role, Category, Options
              Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color.fromARGB(255, 41, 99, 165),
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
                        const SizedBox(height: 4),

                        //Badge & Time
                        Row(
                          children: [
                            _buildRoleBadge(role, isDarkMode),
                            const SizedBox(width: 6),
                            Text(
                              '• $timeAgo',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),
                        Text(
                          category,
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      PhosphorIconsFill.dotsThreeOutline,
                      color: Color.fromARGB(255, 97, 97, 97),
                    ),
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

              // --- NEW: Render Image if available ---
              if (imageUrl != null && imageUrl!.isNotEmpty) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl!,
                    width: double.infinity,
                    height: 220,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 220,
                        color: Colors.grey[200],
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox.shrink(),
                  ),
                ),
              ],

              const SizedBox(height: 16),
              const Divider(height: 1, thickness: 1),

              // Upvote, Comment, Share
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
                    style: TextButton.styleFrom(
                      foregroundColor: const Color.fromARGB(
                        255,
                        97,
                        97,
                        97,
                      ),
                    ),
                    icon: const Icon(
                      PhosphorIconsFill.chatCircleDots,
                      size: 20,
                    ),
                    label: Text('$comments', style: const TextStyle()),
                  ),
                  TextButton.icon(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      foregroundColor: const Color.fromARGB(
                        255,
                        97,
                        97,
                        97,
                      ),
                    ),
                    icon: const Icon(
                      PhosphorIconsFill.arrowBendUpRight,
                      size: 20,
                    ),
                    label: Text('$share', style: const TextStyle()),
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
