import 'package:flutter/material.dart';
import 'package:flutter_helloworld/post.dart';

void main() => runApp(const Myhome());

class Myhome extends StatelessWidget {
  const Myhome({super.key});

  @override
  Widget build(BuildContext context) {
    //example posts on the feed
    final List<Map<String, dynamic>> feedPosts = [
      {
        'Name': 'Dr. S. Lecturer',
        'role': 'Lecturer',
        'timeAgo': '1 hour ago',
        'content':
            'Attention Students: The Object-Oriented Programming midterm grades have been posted. Please check the portal. We will review the Java practical questions in tomorrow\'s lecture.',
        'upvotes': 45,
        'comments': 12,
      },
      {
        'Name': 'Pai Zaw Bhone',
        'role': 'Student',
        'timeAgo': '3 hours ago',
        'content':
            'Does anyone have a good visual guide for how the Buddy System memory allocation works? Struggling with this Computer Architecture concept.',
        'upvotes': 8,
        'comments': 3,
      },
      {
        'Name': 'Alex Developer',
        'role': 'Student',
        'timeAgo': '5 hours ago',
        'content':
            'Need a break from coding! Anyone want to queue up for some Counter-Strike 2 competitive matches tonight around 8 PM?',
        'upvotes': 15,
        'comments': 7,
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          //Header
          const SliverAppBar(
            backgroundColor: Colors.blue,
            expandedHeight: 120,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Department Feed',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),

              background: Padding(
                padding: EdgeInsets.only(top: 40, left: 16),
                child: Text(
                  'College of DIT\n Computer Science',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
            ),
          ),
          //For scrolling
          SliverList(
            delegate: SliverChildBuilderDelegate((
              BuildContext context,
              int index,
            ) {
              final post = feedPosts[index];
              return PostCard(
                uploaderName: post['Uploader Name'],
                role: post['role'],
                timeAgo: post['timeAgo'],
                content: post['content'],
                upvotes: post['upvotes'],
                comments: post['comments'],
              );
              //only appear the size of post on screen
            }, childCount: feedPosts.length),
          ),
        ],
      ),
    );
  }
}
