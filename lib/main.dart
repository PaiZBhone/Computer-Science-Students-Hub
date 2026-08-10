import 'package:flutter/material.dart';
import 'package:flutter_helloworld/myhome.dart';
import 'package:flutter_helloworld/login_screen.dart';
import 'package:flutter_helloworld/splash_screen.dart';
import 'add_post.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'College of DIT\n Computer Science',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            backgroundColor: Colors.blue,
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.home)),
                Tab(icon: Icon(Icons.add_box_rounded)),
                Tab(icon: Icon(Icons.notifications)),
                Tab(icon: Icon(Icons.account_box_rounded)),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              //Icon(Icons.home),
              //Icon(Icons.add_box_rounded),
              //Icon(Icons.notifications),
              //Icon(Icons.account_box_rounded),

              //Text('Home'),
              Myhome(),
              AddPostScreen(),
              Text('Notification'),
              LoginScreen(),
            ],
          ),
        ),
      ),
    );
  }
}
