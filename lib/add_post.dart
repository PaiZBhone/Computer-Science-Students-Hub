import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'post_provider.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final TextEditingController _contentController = TextEditingController();
  String? _selectedCategory;

  // State variables for image uploading and dynamic user details
  File? _selectedImage;
  bool _isUploading = false;
  String _uploaderName = 'Loading...';
  final supabase = Supabase.instance.client;

  // Category list
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
  void initState() {
    super.initState();
    _fetchUploaderProfile();
  }

  // Fetch the logged-in user's display_name dynamically from the profiles table
  Future<void> _fetchUploaderProfile() async {
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        final response = await supabase
            .from('profiles')
            .select(
              'display_name',
            ) // Changed from full_name to display_name
            .eq('id', user.id)
            .single();

        if (mounted) {
          setState(() {
            _uploaderName = response['display_name'] ?? 'Unknown User';
          });
        }
      }
    } catch (e) {
      print('Error fetching uploader name: $e');
      if (mounted) {
        setState(() {
          _uploaderName = 'CS Student';
        });
      }
    }
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  // Uses FilePicker.platform to fix the undefined getter error
  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final filePath = result.files.single.path;
        if (filePath != null) {
          setState(() {
            _selectedImage = File(filePath);
          });
        }
      }
    } catch (e) {
      print('Error picking file: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to open file picker: $e')),
        );
      }
    }
  }

  // Publish function
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

      if (_selectedImage != null) {
        final fileExt = _selectedImage!.path.split('.').last;
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}.$fileExt';

        await supabase.storage
            .from('post_images')
            .upload(fileName, _selectedImage!);

        imageUrl = supabase.storage
            .from('post_images')
            .getPublicUrl(fileName);
      }

      if (mounted) {
        await Provider.of<PostProvider>(context, listen: false).addPost(
          _selectedCategory!,
          _contentController.text,
          imageUrl: imageUrl,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post published successfully!'),
            backgroundColor: Colors.green,
          ),
        );

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
              // User Header
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
                        Text(
                          _uploaderName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
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

              // Multi-line Text Input Canvas & Image Preview
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        controller: _contentController,
                        maxLines: null,
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

              // Bottom Photo Toolbar
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
