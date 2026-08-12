import 'package:flutter/material.dart';
import 'post_provider.dart';
import 'package:provider/provider.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final TextEditingController _contentController = TextEditingController();
  String? _selectedCategory;

  // The exact same categories we used in the Home feed filter
  final List<String> _categories = [
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

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _publishPost() {
    if (_selectedCategory == null || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category and write something.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    Provider.of<PostProvider>(
      context,
      listen: false,
    ).addPost(_selectedCategory!, _contentController.text);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Post published successfully!'),
        backgroundColor: Colors.green,
      ),
    );

    // Clear the form after posted
    _contentController.clear();
    setState(() {
      _selectedCategory = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check if the app is currently in Dark Mode
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create post'),
        elevation: 0, // Flat design
        actions: [
          Padding(
            padding: const EdgeInsets.only(
              right: 12.0,
              top: 10.0,
              bottom: 10.0,
            ),
            child: ElevatedButton(
              onPressed: _publishPost,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 41, 99, 165),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Post',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. User Header with Avatar, Name, and Category Selector
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color.fromARGB(255, 41, 99, 165),
                  child: const Icon(Icons.person, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CS BANANA',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Sleek Category Dropdown Pill
                      Container(
                        height: 30,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? const Color(0xFF1E1E1E)
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: isDarkMode
                                ? Colors.grey[800]!
                                : Colors.grey[300]!,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCategory,
                            hint: Text(
                              'Select Category',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDarkMode
                                    ? Colors.grey[400]
                                    : Colors.grey[700],
                              ),
                            ),
                            icon: Icon(
                              Icons.arrow_drop_down,
                              size: 18,
                              color: isDarkMode
                                  ? Colors.grey[400]
                                  : Colors.grey[700],
                            ),
                            style: TextStyle(
                              fontSize: 13,
                              color: isDarkMode
                                  ? Colors.white
                                  : Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                            dropdownColor: isDarkMode
                                ? const Color(0xFF1E1E1E)
                                : Colors.white,
                            items: _categories.map((String category) {
                              return DropdownMenuItem<String>(
                                value: category,
                                child: Text(category),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedCategory = newValue;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // 2. Seamless Multi-line Text Input Canvas
            Expanded(
              child: TextField(
                controller: _contentController,
                maxLines: null, // Allows the text to grow infinitely
                keyboardType: TextInputType.multiline,
                style: const TextStyle(
                  fontSize: 18,
                ), // Larger font for social media feel
                decoration: InputDecoration(
                  hintText: 'What do you want to share with the Club?',
                  hintStyle: TextStyle(
                    fontSize: 18,
                    color: isDarkMode
                        ? Colors.grey[500]
                        : Colors.grey[500],
                  ),
                  border: InputBorder.none, // Removes the ugly box!
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
