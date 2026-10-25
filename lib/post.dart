import 'package:flutter/material.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'post_detail.dart';
import 'package:provider/provider.dart';
import 'post_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Needed for checking current user

class PostCard extends StatelessWidget {
  final String id;
  final String authorId; // Added authorId parameter
  final String uploaderName;
  final String? uploaderAvatar;
  final String category;
  final String role;
  final String timeAgo;
  final String content;
  final String? imageUrl;
  final int upvotes;
  final int comments;
  final int share;

  const PostCard({
    super.key,
    required this.id,
    required this.authorId, // Added to constructor
    required this.uploaderName,
    this.uploaderAvatar,
    required this.category,
    required this.role,
    required this.timeAgo,
    required this.content,
    this.imageUrl,
    required this.upvotes,
    required this.comments,
    required this.share,
  });

  Widget _buildRoleBadge(String role, bool isDarkMode) {
    Color bgColor;
    Color textColor;

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
        borderRadius: BorderRadius.circular(12),
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

    // Check if the current user is the author of this specific post
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;
    final isAuthor = currentUserId == authorId;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PostDetailScreen(
              id: id,
              uploaderName: uploaderName,
              uploaderAvatar: uploaderAvatar,
              role: role,
              category: category,
              timeAgo: timeAgo,
              content: content,
              imageUrl: imageUrl,
            ),
          ),
        );
      },
      child: Card(
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
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: const Color.fromARGB(
                      255,
                      41,
                      99,
                      165,
                    ),
                    backgroundImage:
                        uploaderAvatar != null &&
                            uploaderAvatar!.isNotEmpty
                        ? NetworkImage(uploaderAvatar!)
                        : null,
                    child:
                        (uploaderAvatar == null || uploaderAvatar!.isEmpty)
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
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

                  // Only show delete menu if logged-in user is the author
                  if (isAuthor)
                    PopupMenuButton<String>(
                      icon: const Icon(
                        PhosphorIconsFill.dotsThreeOutline,
                        color: Color.fromARGB(255, 97, 97, 97),
                      ),
                      onSelected: (value) {
                        if (value == 'delete') {
                          showDialog(
                            context: context,
                            builder: (BuildContext dialogContext) {
                              return AlertDialog(
                                title: const Text('Delete Post'),
                                content: const Text(
                                  'Are you sure you want to permanently delete this post?',
                                ),
                                actions: [
                                  TextButton(
                                    child: const Text('Cancel'),
                                    onPressed: () =>
                                        Navigator.of(dialogContext).pop(),
                                  ),
                                  TextButton(
                                    child: const Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                    onPressed: () {
                                      Navigator.of(dialogContext).pop();
                                      Provider.of<PostProvider>(
                                        context,
                                        listen: false,
                                      ).deletePost(id);
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<String>>[
                            const PopupMenuItem<String>(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete_outline,
                                    color: Colors.redAccent,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Delete Post',
                                    style: TextStyle(
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                    ),
                ],
              ),
              const SizedBox(height: 12),

              Text(
                content,
                style: const TextStyle(fontSize: 15, height: 1.4),
              ),

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
