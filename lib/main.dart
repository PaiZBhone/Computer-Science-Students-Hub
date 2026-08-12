import 'package:flutter/material.dart';
import 'package:flutter_helloworld/myhome.dart';
import 'package:flutter_helloworld/login_screen.dart';
import 'package:flutter_helloworld/splash_screen.dart';
import 'add_post.dart';
import 'profile_screen.dart';
import 'notification.dart';
import 'package:provider/provider.dart';
import 'post_provider.dart';
import 'theme.dart';
import 'settting_screen.dart'; // Make sure this points to your ThemeProvider file!

void main() {
  runApp(
    // 1. MultiProvider allows us to inject both Post data and Theme data globally
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => PostProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: const MainApp(),
    ),
  );
}

// 2. A new top-level widget to handle the global theme and initial route
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to the ThemeProvider to know if we are in Light, Dark, or System mode
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode, // Instantly switches themes
      // --- LIGHT THEME SETTINGS ---
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF4F4F8),
        appBarTheme: const AppBarTheme(
          backgroundColor: const Color.fromARGB(255, 41, 99, 165),
          foregroundColor: Colors.white,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Color.fromARGB(
            255,
            41,
            99,
            165,
          ), // Your custom blue
          unselectedItemColor: Colors.grey,
        ),
      ),

      // --- DARK THEME SETTINGS ---
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1E1E1E),
          selectedItemColor: const Color.fromARGB(
            255,
            41,
            99,
            165,
          ), // Neon cyan for dark mode
          unselectedItemColor: Colors.grey,
        ),
      ),

      // Keep your splash screen as the starting point!
      home: const SplashScreen(),
    );
  }
}

// 3. Your main navigation screen (now strictly a Scaffold, no longer a nested MaterialApp)
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    Myhome(),
    AddPostScreen(),
    NotificationsScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],

      // The modern Bottom Navigation Bar (Colors are now controlled by the ThemeData above!)
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        elevation: 8,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            activeIcon: Icon(Icons.add_box_rounded),
            label: 'Post',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_none),
            activeIcon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.account_box_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
