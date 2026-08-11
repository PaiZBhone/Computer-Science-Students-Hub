import 'package:flutter/material.dart';
import 'package:flutter_helloworld/post.dart';
import 'package:provider/provider.dart';
import 'post_provider.dart';

class Myhome extends StatefulWidget {
  const Myhome({super.key});

  @override
  State<Myhome> createState() => _MyhomeState();
}

class _MyhomeState extends State<Myhome> {
  // 1. State variable to track the currently selected filter
  String selectedFilter = 'All';

  // 2. The available filter categories
  final List<String> filters = [
    'All',
    '📌 Announcements',
    '📚 Academic',
    '🎮 Social',
    '🍔 Food',
    '🏫 Campus',
    '🎵 Music',
    '😂 Fun',
    '💻 Tech',
    '👽 Random',
    '🌧️ Weather',
  ];

  // 3. Virtual dummy posts
  // final List<Map<String, dynamic>> allPosts = [
  //   {
  //     'uploaderName': 'Dr. S John',
  //     'role': 'Lecturer',
  //     'timeAgo': '1 hour ago',
  //     'category': '📌 Announcements',
  //     'content':
  //         'Attention Students: The Object-Oriented Programming midterm grades have been posted. Please check the portal. We will review the Java practical questions in tomorrow\'s lecture.',
  //     'upvotes': 45,
  //     'comments': 12,
  //   },
  //   {
  //     'uploaderName': 'Larry',
  //     'role': 'Student',
  //     'timeAgo': '3 hours ago',
  //     'category': '📚 Academic',
  //     'content':
  //         'Does anyone have a good visual guide for how the Buddy System memory allocation works? Struggling with this Computer Architecture concept.',
  //     'upvotes': 8,
  //     'comments': 3,
  //   },
  //   {
  //     'uploaderName': 'Hein Htet',
  //     'role': 'Student',
  //     'timeAgo': '3 hours ago',
  //     'category': '📚 Academic',
  //     'content':
  //         'Does anyone have a good visual guide for how the Buddy System memory allocation works? Struggling with this Computer Architecture concept.',
  //     'upvotes': 8,
  //     'comments': 3,
  //   },
  //   {
  //     'uploaderName': 'Wathan Oo',
  //     'role': 'Student',
  //     'timeAgo': '3 hours ago',
  //     'category': '📚 Academic',
  //     'content':
  //         'Does anyone have a good visual guide for how the Buddy System memory allocation works? Struggling with this Computer Architecture concept.',
  //     'upvotes': 8,
  //     'comments': 3,
  //   },
  //   {
  //     'uploaderName': 'Htoo Aung Lwin',
  //     'role': 'Student',
  //     'timeAgo': '3 hours ago',
  //     'category': '📚 Academic',
  //     'content':
  //         'Does anyone have a good visual guide for how the Buddy System memory allocation works? Struggling with this Computer Architecture concept.',
  //     'upvotes': 8,
  //     'comments': 3,
  //   },
  //   {
  //     'uploaderName': 'Alex',
  //     'role': 'Student',
  //     'timeAgo': '5 hours ago',
  //     'category': '🎮 Social',
  //     'content':
  //         'Need a break from coding! Anyone want to queue up for some Counter-Strike 2 competitive matches tonight around 8 PM?',
  //     'upvotes': 15,
  //     'comments': 7,
  //   },
  // ];

  @override
  Widget build(BuildContext context) {
    // 4. Filter the posts before displaying them
    final allPosts = Provider.of<PostProvider>(context).posts;

    // Filter the posts exactly like we did before
    final displayedPosts = selectedFilter == 'All'
        ? allPosts
        : allPosts
              .where((post) => post['category'] == selectedFilter)
              .toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Provider.of<PostProvider>(context).isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            ) // Shows a spinner while fetching
          : CustomScrollView(
              slivers: [
                // const SliverAppBar(
                //   backgroundColor: Colors.blue,
                //   expandedHeight: 120.0,
                //   floating: true,
                //   pinned: true,
                //   flexibleSpace: FlexibleSpaceBar(
                //     title: Text(
                //       'Department Feed',
                //       style: TextStyle(
                //         color: Colors.white,
                //         fontWeight: FontWeight.bold,
                //         fontSize: 18,
                //       ),
                //     ),
                //     background: Padding(
                //       padding: EdgeInsets.only(top: 40.0, left: 16.0),
                //       child: Text(
                //         'College of Digital\nInnovation Technology',
                //         style: TextStyle(color: Colors.white70, fontSize: 16),
                //       ),
                //     ),
                //   ),
                // ),

                // 5. The new Filter Chips Section
                SliverToBoxAdapter(
                  child: Container(
                    height: 60,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: filters.length,
                      itemBuilder: (context, index) {
                        final filter = filters[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(filter),
                            selected: selectedFilter == filter,
                            onSelected: (bool selected) {
                              // setState tells Flutter to rebuild the screen with the new filter
                              setState(() {
                                selectedFilter = filter;
                              });
                            },
                            selectedColor: Colors.blue.withOpacity(0.2),
                            labelStyle: TextStyle(
                              color: selectedFilter == filter
                                  ? Colors.blue[800]
                                  : Colors.black87,
                              fontWeight: selectedFilter == filter
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // 6. The Scrolling List of Filtered Posts
                SliverList(
                  delegate: SliverChildBuilderDelegate((
                    BuildContext context,
                    int index,
                  ) {
                    final post = displayedPosts[index];
                    return PostCard(
                      id: post['id'],
                      uploaderName: post['uploaderName'],
                      role: post['role'],
                      category: post['category'],
                      timeAgo: post['timeAgo'],
                      content: post['content'],
                      upvotes: post['upvotes'],
                      comments: post['comments'],
                    );
                  }, childCount: displayedPosts.length),
                ),
              ],
            ),
    );
  }
}
