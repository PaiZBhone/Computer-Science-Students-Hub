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
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://xvqukjmxicwxmqjyzkoz.supabase.co',
    anonKey: 'sb_publishable_NS7sWRbh_R1DFJxFxsDAQg_y_C0YI_N',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => PostProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF4F4F8),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(255, 41, 99, 165),
          foregroundColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

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
    final hasUnread = context.watch<PostProvider>().hasUnreadNotifications;

    return Scaffold(
      extendBody: true,
      body: _screens[_selectedIndex],
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Container(
            height: 62,
            decoration: BoxDecoration(
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
                  showBadge: hasUnread,
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
    bool isDarkMode, {
    bool showBadge = false,
  }) {
    final isSelected = _selectedIndex == index;

    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(25),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              isSelected ? selectedIcon : unselectedIcon,
              size: 24,
              color: isSelected
                  ? const Color.fromARGB(255, 41, 99, 165)
                  : (isDarkMode ? Colors.grey[400] : Colors.grey[600]),
            ),
            if (showBadge)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDarkMode
                          ? const Color.fromARGB(255, 34, 34, 34)
                          : Colors.white,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
