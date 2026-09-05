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
import 'settting_screen.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

void main() {
  runApp(
    //testing command
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
        //feed color
        scaffoldBackgroundColor: const Color(0xFFF4F4F8),
        appBarTheme: const AppBarTheme(
          backgroundColor: const Color.fromARGB(255, 41, 99, 165),
          foregroundColor: Colors.white,
        ),
      ),

      // --- DARK THEME SETTINGS ---
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        //feed color
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody:
          true, // Allows the feed to scroll behind the floating bar
      body: _screens[_selectedIndex],
      //pill shape nevigation
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Container(
            height: 62,
            decoration: BoxDecoration(
              // Negv Color
              color: isDarkMode
                  ? const Color.fromARGB(255, 34, 34, 34)
                  : Colors.white,
              borderRadius: BorderRadius.circular(35),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode
                      ? Colors.black.withOpacity(0.3)
                      : Colors.black.withOpacity(0.15),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
              border: Border.all(
                color: isDarkMode ? Colors.white10 : Colors.grey[200]!,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildNavItem(
                  0,
                  LucideIcons.house,
                  LucideIcons.house500,
                  isDarkMode,
                ),
                _buildNavItem(
                  1,
                  LucideIcons.plus,
                  LucideIcons.plus500,
                  isDarkMode,
                ),
                _buildNavItem(
                  2,
                  LucideIcons.bell,
                  LucideIcons.bell500,
                  isDarkMode,
                ),
                _buildNavItem(
                  3,
                  LucideIcons.user,
                  LucideIcons.user500,
                  isDarkMode,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData unselectedIcon,
    IconData selectedIcon,
    bool isDarkMode,
  ) {
    final isSelected = _selectedIndex == index;

    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(25),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          // Set to transparent so the background highlight is completely removed
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Icon(
          isSelected ? selectedIcon : unselectedIcon,
          size: 24,

          color: isSelected
              ? const Color.fromARGB(255, 41, 99, 165)
              : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
        ),
      ),
    );
  }
}
