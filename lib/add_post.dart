import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
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

  // State variables for image uploading
  File? _selectedImage;
  bool _isUploading = false;
  final supabase = Supabase.instance.client;

  // Category
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

  // Function to open the phone gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70, // Compresses the image slightly for faster uploads
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Updated publish function to handle the image upload
  Future<void> _publishPost() async {
    if (_selectedCategory == null || _contentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category and write something.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      String? imageUrl;

      // 1. If an image is selected, upload it to Supabase first
      if (_selectedImage != null) {
        final fileExt = _selectedImage!.path.split('.').last;
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}.$fileExt'; // Unique filename

        await supabase.storage
            .from('post_images')
            .upload(fileName, _selectedImage!);

        // Grab the public URL of the uploaded image
        imageUrl = supabase.storage
            .from('post_images')
            .getPublicUrl(fileName);
      }

      // 2. Send the text, category, and image URL to the database
      if (mounted) {
        await Provider.of<PostProvider>(context, listen: false).addPost(
          _selectedCategory!,
          _contentController.text,
          imageUrl: imageUrl, // Pass the new image link
        );

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
          _selectedImage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if the app is currently in Dark Mode
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create post',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(
              right: 12.0,
              top: 10.0,
              bottom: 10.0,
            ),
            child: ElevatedButton(
              // Disable the button if it's currently uploading
              onPressed: _isUploading ? null : _publishPost,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 41, 99, 165),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: _isUploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Post',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. User Header with Avatar, Name, and Category Selector
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: Color.fromARGB(255, 41, 99, 165),
                    child: Icon(Icons.person, color: Colors.white),
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

              // 2. Seamless Multi-line Text Input Canvas & Image Preview
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        controller: _contentController,
                        maxLines:
                            null, // Allows the text to grow infinitely
                        keyboardType: TextInputType.multiline,
                        style: const TextStyle(fontSize: 18),
                        decoration: InputDecoration(
                          hintText:
                              'What do you want to share with the Club?',
                          hintStyle: TextStyle(
                            fontSize: 18,
                            color: isDarkMode
                                ? Colors.grey[500]
                                : Colors.grey[500],
                          ),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                        ),
                      ),

                      // 3. Image Preview Area
                      if (_selectedImage != null) ...[
                        const SizedBox(height: 16),
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Image.file(
                                _selectedImage!,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: IconButton(
                                onPressed: () =>
                                    setState(() => _selectedImage = null),
                                icon: const Icon(
                                  Icons.cancel,
                                  color: Colors.white,
                                  size: 30,
                                ),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // 4. Bottom Photo Toolbar
              Container(
                padding: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: isDarkMode
                          ? Colors.grey[800]!
                          : Colors.grey[200]!,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(LucideIcons.image),
                      color: const Color.fromARGB(255, 41, 99, 165),
                      onPressed: _pickImage,
                    ),
                    const Text(
                      'Add Photo',
                      style: TextStyle(
                        color: Color.fromARGB(255, 41, 99, 165),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
