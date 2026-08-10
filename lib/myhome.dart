import 'package:flutter/material.dart';

void main() => runApp(const Myhome());

class Myhome extends StatelessWidget {
  const Myhome({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.all(10),
        child: Column(
          children: [
            const Text(
              'College of Digital Innovation Technology',
              style: TextStyle(fontSize: 30),
            ),
            const Text('Computer Science', style: TextStyle(fontSize: 20)),
            Image.asset('assets/images/cm.jpg'),
          ],
        ),
      ),
    );
  }
}
