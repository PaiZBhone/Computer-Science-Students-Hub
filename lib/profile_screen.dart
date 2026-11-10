import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'login_screen.dart';
import 'settting_screen.dart';
import 'post_provider.dart';
import 'post.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final supabase = Supabase.instance.client;

  String _displayName = 'Loading...';
  String _fullName = '';
  String _role = 'Student';
  String _email = '';
  String _institutionalId = '';
  String _faculty = '';
  String _department = '';
  String? _avatarUrl;

  bool _isLoading = true;
  bool _isUploadingAvatar = false;

  final List<String> _roles = [
    'Student',
    'Lecturer',
    'Staff',
    'Official Account',
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final user = supabase.auth.currentUser;
      if (user != null) {
        final data = await supabase
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();

        if (mounted) {
          setState(() {
            _displayName = data['display_name'] ?? 'Unknown User';
            _fullName = data['full_name'] ?? '';
            _role = data['role'] ?? 'Student';
            _email = data['email'] ?? user.email ?? '';
            _institutionalId = data['institutional_id'] ?? '';
            _faculty = data['faculty'] ?? '';
            _department = data['department'] ?? '';
            _avatarUrl = data['avatar_url'];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error fetching profile: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Upload or Change Profile Picture
  Future<void> _pickAndUploadAvatar() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;

      final filePath = result.files.single.path;
      if (filePath == null) return;

      setState(() => _isUploadingAvatar = true);

      final user = supabase.auth.currentUser;
      if (user == null) return;

      final file = File(filePath);
      final fileExt = filePath.split('.').last;
      final fileName =
          '${user.id}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      await supabase.storage.from('avatars').upload(fileName, file);

      final publicUrl = supabase.storage
          .from('avatars')
          .getPublicUrl(fileName);

      await supabase
          .from('profiles')
          .update({'avatar_url': publicUrl})
          .eq('id', user.id);

      if (mounted) {
        setState(() {
          _avatarUrl = publicUrl;
          _isUploadingAvatar = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error uploading avatar: $e');
      if (mounted) {
        setState(() => _isUploadingAvatar = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload picture: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    await supabase.auth.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  // Modal Sheet allowing editing of profile information
  void _showEditProfileDialog() {
    final displayNameController = TextEditingController(
      text: _displayName,
    );
    final fullNameController = TextEditingController(text: _fullName);
    final idController = TextEditingController(text: _institutionalId);
    final facultyController = TextEditingController(text: _faculty);
    final departmentController = TextEditingController(text: _department);
    String selectedRole = _roles.contains(_role) ? _role : _roles.first;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isStudent = selectedRole.toLowerCase() == 'student';

            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Edit Profile Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: displayNameController,
                      decoration: InputDecoration(
                        labelText: 'Display Name',
                        prefixIcon: const Icon(Icons.badge_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: fullNameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedRole,
                      decoration: InputDecoration(
                        labelText: 'Role',
                        prefixIcon: const Icon(Icons.work_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: _roles.map((roleOption) {
                        return DropdownMenuItem(
                          value: roleOption,
                          child: Text(roleOption),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null)
                          setModalState(() => selectedRole = val);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: idController,
                      decoration: InputDecoration(
                        labelText: isStudent ? 'Student ID' : 'Staff ID',
                        prefixIcon: const Icon(
                          Icons.card_membership_outlined,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: facultyController,
                      decoration: InputDecoration(
                        labelText: 'Faculty',
                        prefixIcon: const Icon(
                          Icons.account_balance_outlined,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    if (!isStudent) ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: departmentController,
                        decoration: InputDecoration(
                          labelText: 'Department',
                          prefixIcon: const Icon(Icons.business_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            41,
                            99,
                            165,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: isSaving
                            ? null
                            : () async {
                                setModalState(() => isSaving = true);
                                try {
                                  final user = supabase.auth.currentUser;
                                  if (user != null) {
                                    final Map<String, dynamic> updateData =
                                        {
                                          'display_name':
                                              displayNameController.text
                                                  .trim(),
                                          'full_name': fullNameController
                                              .text
                                              .trim(),
                                          'role': selectedRole,
                                          'institutional_id': idController
                                              .text
                                              .trim(),
                                          'faculty': facultyController.text
                                              .trim(),
                                          'department': isStudent
                                              ? ''
                                              : departmentController.text
                                                    .trim(),
                                        };

                                    await supabase
                                        .from('profiles')
                                        .update(updateData)
                                        .eq('id', user.id);

                                    await _fetchUserProfile();
                                    if (context.mounted) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Profile updated successfully!',
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(
                                      context,
                                    ).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Error updating profile: $e',
                                        ),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                  }
                                } finally {
                                  if (context.mounted) {
                                    setModalState(() => isSaving = false);
                                  }
                                }
                              },
                        child: isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Save Changes',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final isStudent = _role.toLowerCase() == 'student';

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Wrap the Scaffold in a DefaultTabController
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'My Profile',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // --- FIXED PROFILE HEADER SECTION ---
              Padding(
                padding: const EdgeInsets.only(
                  left: 24.0,
                  right: 24.0,
                  top: 24.0,
                  bottom: 12.0,
                ),
                child: Column(
                  children: [
                    // Interactive Avatar
                    GestureDetector(
                      onTap: _isUploadingAvatar
                          ? null
                          : _pickAndUploadAvatar,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: const Color.fromARGB(
                              255,
                              41,
                              99,
                              165,
                            ),
                            backgroundImage:
                                _avatarUrl != null &&
                                    _avatarUrl!.isNotEmpty
                                ? NetworkImage(_avatarUrl!)
                                : null,
                            child: _isUploadingAvatar
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : (_avatarUrl == null ||
                                      _avatarUrl!.isEmpty)
                                ? Text(
                                    _displayName.isNotEmpty
                                        ? _displayName[0].toUpperCase()
                                        : 'U',
                                    style: const TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Color.fromARGB(255, 41, 99, 165),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _displayName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(
                          255,
                          41,
                          99,
                          165,
                        ).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _role,
                        style: const TextStyle(
                          color: Color.fromARGB(255, 41, 99, 165),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: ElevatedButton.icon(
                        onPressed: _showEditProfileDialog,
                        icon: const Icon(
                          Icons.edit,
                          size: 18,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Edit Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            41,
                            99,
                            165,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // --- TAB BAR ---
              TabBar(
                labelColor: isDarkMode ? Colors.white : Colors.black,
                unselectedLabelColor: Colors.grey,
                indicatorColor: const Color.fromARGB(255, 41, 99, 165),
                indicatorWeight: 3,
                tabs: const [
                  Tab(text: 'About'),
                  Tab(text: 'Saved Posts'),
                ],
              ),

              // --- TAB BAR VIEWS ---
              Expanded(
                child: TabBarView(
                  children: [
                    // TAB 1: ABOUT (Info Tiles)
                    SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        24,
                        24,
                        24,
                        100,
                      ), // Bottom padding for nav bar
                      child: Column(
                        children: [
                          _buildInfoTile(
                            'Display Name',
                            _displayName,
                            Icons.badge_outlined,
                            isDarkMode,
                          ),
                          const SizedBox(height: 12),
                          _buildInfoTile(
                            'Full Name',
                            _fullName,
                            Icons.person_outline,
                            isDarkMode,
                          ),
                          const SizedBox(height: 12),
                          _buildInfoTile(
                            'Email',
                            _email,
                            Icons.email_outlined,
                            isDarkMode,
                          ),
                          const SizedBox(height: 12),
                          _buildInfoTile(
                            isStudent ? 'Student ID' : 'Staff ID',
                            _institutionalId,
                            Icons.card_membership_outlined,
                            isDarkMode,
                          ),
                          const SizedBox(height: 12),
                          _buildInfoTile(
                            'Faculty',
                            _faculty,
                            Icons.account_balance_outlined,
                            isDarkMode,
                          ),
                          if (!isStudent) ...[
                            const SizedBox(height: 12),
                            _buildInfoTile(
                              'Department',
                              _department,
                              Icons.business_outlined,
                              isDarkMode,
                            ),
                          ],
                        ],
                      ),
                    ),

                    // TAB 2: SAVED POSTS
                    _buildSavedPostsTab(context, isDarkMode),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build the saved posts tab
  Widget _buildSavedPostsTab(BuildContext context, bool isDarkMode) {
    // Watch the provider to get real-time updates when a user saves/unsaves a post
    final provider = context.watch<PostProvider>();

    // Filter out only the posts where the ID is in the saved list
    final savedPosts = provider.posts
        .where((post) => provider.isSaved(post['id']))
        .toList();

    if (savedPosts.isEmpty) {
      return Center(
        child: Text(
          'No saved posts yet.',
          style: TextStyle(
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(
        top: 8,
        bottom: 100,
      ), // Bottom padding for the floating navigation bar
      itemCount: savedPosts.length,
      itemBuilder: (context, index) {
        final post = savedPosts[index];
        return PostCard(
          id: post['id'],
          authorId: post['authorId'],
          uploaderName: post['uploaderName'],
          uploaderAvatar: post['uploaderAvatar'],
          role: post['role'],
          category: post['category'],
          timeAgo: post['timeAgo'],
          content: post['content'],
          imageUrl: post['imageUrl'],
          upvotes: post['upvotes'],
          comments: post['comments'],
          share: post['share'],
        );
      },
    );
  }

  Widget _buildInfoTile(
    String label,
    String value,
    IconData icon,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color.fromARGB(255, 41, 99, 165)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value.isNotEmpty ? value : 'N/A',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
