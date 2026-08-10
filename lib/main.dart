import 'package:flutter/material.dart';
import 'package:flutter_helloworld/myhome.dart';
import 'package:flutter_helloworld/login_scree.dart';
import 'package:flutter_helloworld/splash_scree.dart';

void main() => runApp(const MaterialApp(home: SplashScreen()));

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
              'Testing APP',
              style: TextStyle(fontSize: 25, color: Colors.white),
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
              Text('Add Post'),
              Text('Notification'),
              LoginScreen(),
            ],
          ),
        ),
      ),
    );
  }
}
