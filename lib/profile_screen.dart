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
      debugPrint('Error fetching profile: $e');
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
      final rawExt = filePath.contains('.')
          ? filePath.split('.').last.toLowerCase()
          : 'jpg';
      final fileExt =
          (rawExt == 'png' || rawExt == 'webp' || rawExt == 'gif')
          ? rawExt
          : 'jpg';
      final mimeType = fileExt == 'jpg' ? 'image/jpeg' : 'image/$fileExt';

      final fileName =
          '${user.id}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      await supabase.storage
          .from('avatars')
          .upload(
            fileName,
            file,
            fileOptions: FileOptions(contentType: mimeType, upsert: true),
          );

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

        // Refresh feed posts so the new avatar appears on past posts immediately
        Provider.of<PostProvider>(context, listen: false).fetchPosts();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error uploading avatar: $e');
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
                        if (val != null) {
                          setModalState(() => selectedRole = val);
                        }
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

  // Modal Sheet allowing user to change their password safely
  // Modal Sheet allowing user to change their password with inline validation
  void _showChangePasswordDialog() {
    final formKey = GlobalKey<FormState>();
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;
    bool isUpdating = false;
    String? errorMessage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(modalContext).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Change Password',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Inline Error Banner (visible right inside the modal)
                      if (errorMessage != null) ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.redAccent),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.error_outline,
                                color: Colors.redAccent,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  errorMessage!,
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // 1. Current Password
                      TextFormField(
                        controller: currentPasswordController,
                        obscureText: obscureCurrent,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your current password';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Current Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureCurrent
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () => setModalState(
                              () => obscureCurrent = !obscureCurrent,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 2. New Password
                      TextFormField(
                        controller: newPasswordController,
                        obscureText: obscureNew,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a new password';
                          }
                          if (value.trim().length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          if (value.trim() ==
                              currentPasswordController.text.trim()) {
                            return 'New password must be different from current';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'New Password (min. 6 characters)',
                          prefixIcon: const Icon(Icons.vpn_key_outlined),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureNew
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () => setModalState(
                              () => obscureNew = !obscureNew,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 3. Confirm New Password
                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: obscureConfirm,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please confirm your new password';
                          }
                          if (value.trim() !=
                              newPasswordController.text.trim()) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Confirm New Password',
                          prefixIcon: const Icon(
                            Icons.check_circle_outline,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureConfirm
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () => setModalState(
                              () => obscureConfirm = !obscureConfirm,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Update Password Button
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
                          onPressed: isUpdating
                              ? null
                              : () async {
                                  // Clear previous server errors
                                  setModalState(() => errorMessage = null);

                                  // Run all field validators
                                  if (!formKey.currentState!.validate()) {
                                    return;
                                  }

                                  final currentPwd =
                                      currentPasswordController.text
                                          .trim();
                                  final newPwd = newPasswordController.text
                                      .trim();

                                  setModalState(() => isUpdating = true);

                                  try {
                                    final email =
                                        supabase.auth.currentUser?.email;
                                    if (email == null) {
                                      throw 'User email not found.';
                                    }

                                    // 1. Verify current password
                                    await supabase.auth.signInWithPassword(
                                      email: email,
                                      password: currentPwd,
                                    );

                                    // 2. Update to new password
                                    await supabase.auth.updateUser(
                                      UserAttributes(password: newPwd),
                                    );

                                    if (mounted) {
                                      Navigator.pop(modalContext);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Password updated successfully!',
                                          ),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  } on AuthException catch (e) {
                                    setModalState(() {
                                      errorMessage =
                                          e.message.toLowerCase().contains(
                                            'invalid',
                                          )
                                          ? 'Current password is incorrect.'
                                          : e.message;
                                    });
                                  } catch (e) {
                                    setModalState(() {
                                      errorMessage = 'Error: $e';
                                    });
                                  } finally {
                                    if (modalContext.mounted) {
                                      setModalState(
                                        () => isUpdating = false,
                                      );
                                    }
                                  }
                                },
                          child: isUpdating
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Update Password',
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
                            onBackgroundImageError:
                                (_avatarUrl != null &&
                                    _avatarUrl!.isNotEmpty)
                                ? (exception, stackTrace) {
                                    debugPrint(
                                      'Avatar load error: $exception',
                                    );
                                    if (mounted) {
                                      setState(() => _avatarUrl = null);
                                    }
                                  }
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
                    // TAB 1: ABOUT (Info Tiles + Security Action)
                    SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
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
                          const SizedBox(height: 20),

                          // Change Password Action Card
                          InkWell(
                            onTap: _showChangePasswordDialog,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? const Color(0xFF1E1E1E)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isDarkMode
                                      ? Colors.grey[800]!
                                      : Colors.grey[200]!,
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.lock_reset,
                                    color: Color.fromARGB(
                                      255,
                                      41,
                                      99,
                                      165,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  const Expanded(
                                    child: Text(
                                      'Change Password',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right,
                                    color: isDarkMode
                                        ? Colors.grey[400]
                                        : Colors.grey[600],
                                  ),
                                ],
                              ),
                            ),
                          ),
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

  Widget _buildSavedPostsTab(BuildContext context, bool isDarkMode) {
    final provider = context.watch<PostProvider>();

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
      padding: const EdgeInsets.only(top: 8, bottom: 100),
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
