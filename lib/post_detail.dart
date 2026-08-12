import 'package:flutter/material.dart';
import 'post_provider.dart';
import 'package:provider/provider.dart';

class PostDetailScreen extends StatelessWidget {
  final String id;
  final String uploaderName;
  final String role;
  final String category;
  final String timeAgo;
  final String content;

  const PostDetailScreen({
    super.key,
    required this.id,
    required this.uploaderName,
    required this.role,
    required this.category,
    required this.timeAgo,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Post Details'),
        //backgroundColor: const Color.fromARGB(255, 41, 99, 165),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Only show the delete button if it is your post!
          if (uploaderName == 'Pai Zaw Bhone')
            IconButton(
              icon: const Icon(Icons.delete_outline),
              color: const Color.fromARGB(255, 184, 59, 50),
              onPressed: () {
                // Show a confirmation dialog before deleting
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
                          child: const Text('Cancel', style: TextStyle()),
                          onPressed: () =>
                              Navigator.of(dialogContext).pop(),
                        ),
                        TextButton(
                          child: const Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                          onPressed: () {
                            // 1. Close the dialog
                            Navigator.of(dialogContext).pop();

                            // 2. Tell the provider to delete it
                            Provider.of<PostProvider>(
                              context,
                              listen: false,
                            ).deletePost(id);

                            // 3. Go back to the main feed
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // 1.Post
          Container(
            //color: Colors.white,
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  content,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1),

          // 2.Comments Section
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                const Text(
                  'Comments',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildComment(
                  'Hein Htet',
                  'Student',
                  'This is really helpful, thanks for sharing!',
                ),
                _buildComment('Larry', 'Student', 'G bro!!. Im in'),
              ],
            ),
          ),

          // 3.Comment Field
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Write a comment...',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.grey[200]!),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: const Color.fromARGB(
                      255,
                      41,
                      99,
                      165,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget to generate comment UI
  Widget _buildComment(String name, String role, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$name • $role',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(text, style: const TextStyle(fontSize: 14)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
