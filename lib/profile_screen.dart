import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 1. Profile Header
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blueAccent,
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

                // 2.Badges
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
          const SizedBox(height: 8), // Small gap before the tabs
          // 3.Activity Tabs
          Expanded(
            child: Container(
              color: Colors.white,
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
                          // Content for 'My Posts'
                          ListView(
                            padding: const EdgeInsets.all(16),
                            children: const [
                              Center(
                                child: Text(
                                  'You haven\'t published any posts yet.',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ],
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

  // A helper method to quickly create aesthetic skill chips
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
