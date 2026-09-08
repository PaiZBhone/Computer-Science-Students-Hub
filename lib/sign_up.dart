import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:phosphor_icons/phosphor_icons.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Add Supabase import

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Controllers to grab the text from the input boxes
  final _displayNameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();

  //  Supabase client and loading state
  final supabase = Supabase.instance.client;
  bool _isLoading = false;

  bool _obscurePassword = true;
  bool _isStudent = true;
  String _staffRole = 'Lecturer';
  final List<String> _staffRoles = ['Lecturer', 'Official Department'];

  // Connection to the database
  Future<void> _signUp() async {
    // 1. Check if fields are empty
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 2. Create the secure login account in Auth
      final AuthResponse res = await supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final User? user = res.user;

      if (user != null) {
        final finalRole = _isStudent ? 'Student' : _staffRole;

        // 3. Save the extra profile details into our public.profiles table
        await supabase.from('profiles').insert({
          'id': user.id, // Links this profile to the secure auth account
          'display_name': _displayNameController.text.trim(),
          'full_name': _fullNameController.text.trim(),
          'email': _emailController.text.trim(),
          'role': finalRole,
          'institutional_id': _idController.text.trim(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account created successfully!')),
          );
          Navigator.pop(context); // Go back to login screen
        }
      }
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
      }
    } catch (e) {
      // Catch any other errors
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Join Computer Science Club',
                style: TextStyle(
                  fontSize: 16,
                  color: const Color.fromARGB(255, 134, 134, 134),
                ),
              ),
              const SizedBox(height: 30),

              //Choice Box
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Student')),
                      selected: _isStudent,
                      onSelected: (bool selected) {
                        setState(() {
                          _isStudent = true;
                        });
                      },
                      selectedColor: const Color.fromARGB(
                        255,
                        41,
                        99,
                        165,
                      ).withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: _isStudent
                            ? const Color.fromARGB(255, 41, 99, 165)
                            : const Color.fromARGB(255, 134, 134, 134),
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(
                        child: Text('Faculty & Official'),
                      ),
                      selected: !_isStudent,
                      onSelected: (bool selected) {
                        setState(() {
                          _isStudent = false;
                        });
                      },
                      selectedColor: const Color.fromARGB(
                        255,
                        41,
                        99,
                        165,
                      ).withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: !_isStudent
                            ? const Color.fromARGB(255, 41, 99, 165)
                            : const Color.fromARGB(255, 134, 134, 134),
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              //User
              // Pass the specific controller to each field
              _buildTextField(
                controller: _displayNameController,
                hint: 'Display Name',
                icon: PhosphorIconsRegular.user,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _fullNameController,
                hint: 'Full Name',
                icon: PhosphorIconsRegular.user,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _emailController,
                hint: 'Email',
                icon: PhosphorIconsRegular.envelope,
              ),
              const SizedBox(height: 16),

              if (_isStudent)
                _buildTextField(
                  controller: _idController,
                  hint: 'Student ID',
                  icon: LucideIcons.badgeInfo,
                )
              else ...[
                Container(
                  //lecturebox
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 226, 225, 225),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _staffRole,
                      isExpanded: true,
                      dropdownColor: Colors.white,
                      icon: Icon(
                        PhosphorIconsRegular.caretDown,
                        color: Colors.grey[500],
                      ),
                      items: _staffRoles.map((String role) {
                        return DropdownMenuItem<String>(
                          value: role,
                          child: Text(
                            role,
                            style: const TextStyle(color: Colors.black),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          if (newValue != null) _staffRole = newValue;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _idController,
                  hint: 'Employee / Department ID',
                  icon: LucideIcons.briefcase,
                ),
              ],

              const SizedBox(height: 16),
              _buildTextField(
                controller: _passwordController,
                hint: 'Password',
                icon: PhosphorIconsRegular.lockSimple,
                isPassword: true,
              ),
              const SizedBox(height: 32),
              //Signup
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  // Call the _signUp function or show loading indicator
                  onPressed: _isLoading ? null : _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(
                      255,
                      41,
                      99,
                      165,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          'Sign Up',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // UPDATED** Added the TextEditingController parameter
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller, // Connect the text field to its controller
      obscureText: isPassword ? _obscurePassword : false,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[500]),
        prefixIcon: Icon(icon, color: Colors.grey[500], size: 22),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                  color: Colors.grey[500],
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              )
            : null,

        //Fillbox
        filled: true,
        fillColor: const Color.fromARGB(255, 241, 241, 241),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 41, 99, 165),
            width: 2,
          ),
        ),
      ),
    );
  }
}
