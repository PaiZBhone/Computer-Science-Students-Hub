import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'post_provider.dart';
import 'post.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      //backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        //backgroundColor: const Color.fromARGB(255, 41, 99, 165),
        foregroundColor: Colors.white,
        elevation: 0,
        // actions: [
        //   IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
        // ],
      ),
      body: Column(
        children: [
          // 1. Profile Header Section
          Container(
            width: double.infinity,
            //color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color.fromARGB(255, 41, 99, 165),
                  child: Icon(Icons.person, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 16),
                const Text(
                  'CS BANANA',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Computer Science Student',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),

                // Interactive Skill Badges
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildSkillBadge('Flutter'),
                    _buildSkillBadge('Java'),
                    _buildSkillBadge('SQL'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // 2. User Activity Tabs (My Posts & Saved)
          Expanded(
            child: Container(
              //color: Colors.white,
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    const TabBar(
                      labelColor: Colors.blue,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.blue,
                      tabs: [
                        Tab(text: 'My Posts'),
                        Tab(text: 'Saved Resources'),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          // Content for 'My Posts' using Provider
                          Consumer<PostProvider>(
                            builder: (context, provider, child) {
                              // Filter the global posts to only show yours
                              final myPosts = provider.posts
                                  .where(
                                    (post) =>
                                        post['uploaderName'] ==
                                        'Pai Zaw Bhone',
                                  )
                                  .toList();

                              if (myPosts.isEmpty) {
                                return ListView(
                                  padding: const EdgeInsets.all(16),
                                  children: const [
                                    Center(
                                      child: Text(
                                        'You haven\'t published any posts yet.',
                                        style: TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }

                              // Display your posts using the PostCard widget
                              return ListView.builder(
                                padding: const EdgeInsets.only(top: 8),
                                itemCount: myPosts.length,
                                itemBuilder: (context, index) {
                                  final post = myPosts[index];
                                  return PostCard(
                                    id: post['id'],
                                    uploaderName: post['uploaderName'],
                                    role: post['role'],
                                    timeAgo: post['timeAgo'] ?? 'Just now',
                                    category: post['category'],
                                    content: post['content'],
                                    upvotes: post['upvotes'],
                                    comments: post['comments'],
                                    share: post['share'],
                                  );
                                },
                              );
                            },
                          ),
                          // Content for 'Saved Resources'
                          ListView(
                            padding: const EdgeInsets.all(16),
                            children: const [
                              Center(
                                child: Text(
                                  'No resources saved.',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillBadge(String text) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.blue[800],
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}
