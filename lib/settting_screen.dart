import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';
import 'theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Appearance',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.brightness_6),
                    title: const Text('Dark mode '),
                    trailing: DropdownButton<ThemeMode>(
                      value: themeProvider.themeMode,
                      underline: const SizedBox(),
                      onChanged: (ThemeMode? newValue) {
                        if (newValue != null) {
                          themeProvider.setThemeMode(newValue);
                        }
                      },
                      items: const [
                        DropdownMenuItem(
                          value: ThemeMode.system,
                          child: Text('System Default'),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.dark,
                          child: Text('On'),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.light,
                          child: Text('Off'),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: const Text('About CS Hub'),
                    onTap: () {
                      // Action for About section
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(
                      Icons.logout,
                      color: Colors.redAccent,
                    ),
                    title: const Text(
                      'Log Out',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext dialogContext) {
                          return AlertDialog(
                            title: const Text('Log Out'),
                            content: const Text(
                              'Are you sure you want to log out?',
                            ),
                            actions: [
                              TextButton(
                                child: const Text('Cancel'),
                                onPressed: () =>
                                    Navigator.of(dialogContext).pop(),
                              ),
                              TextButton(
                                child: const Text(
                                  'Log Out',
                                  style: TextStyle(color: Colors.red),
                                ),
                                onPressed: () async {
                                  Navigator.of(dialogContext).pop();

                                  await Supabase.instance.client.auth
                                      .signOut();

                                  if (context.mounted) {
                                    Navigator.of(
                                      context,
                                    ).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const LoginScreen(),
                                      ),
                                      (route) => false,
                                    );
                                  }
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            // --- FOOTER WATERMARK ---
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.school_rounded,
                    size: 28,
                    color: isDarkMode
                        ? Colors.grey[700]
                        : Colors.grey[400],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'CS Hub • DIT College',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: isDarkMode
                          ? Colors.grey[600]
                          : Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Developed by matriX • v1.0.0',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDarkMode
                          ? Colors.grey[700]
                          : Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
