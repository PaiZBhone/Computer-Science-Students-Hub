import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:phosphor_icons/phosphor_icons.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool _obscurePassword = true;

  // ---State variables for splitting user types ---
  bool _isStudent = true;
  String _staffRole = 'Lecturer'; // Default for non-students
  final List<String> _staffRoles = ['Lecturer', 'Official Department'];

  @override
  Widget build(BuildContext context) {
    // isDarkMode variable has been completely removed

    return Scaffold(
      backgroundColor: Colors.white, // Locked to white background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.black, // Locked back button to black
        ),
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
                  color: Colors.black, // Locked text to black
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Join Computer Science Club',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 30),

              // --- Account Type Toggle ---
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
                            : Colors.grey,
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
                            : Colors.grey,
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

              // Display name
              _buildTextField(
                hint: 'Display Name',
                icon: PhosphorIconsRegular.user,
              ),
              const SizedBox(height: 16),

              // Name Field
              _buildTextField(
                hint: 'Full Name',
                icon: PhosphorIconsRegular.user,
              ),
              const SizedBox(height: 16),

              // Email
              _buildTextField(
                hint: 'Email',
                icon: PhosphorIconsRegular.envelope,
              ),
              const SizedBox(height: 16),

              // --- Dynamic ID & Role Fields ---
              if (_isStudent)
                _buildTextField(
                  hint: 'Student ID',
                  icon: LucideIcons.badgeInfo,
                )
              else ...[
                // Staff Role Dropdown
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(
                      255,
                      235,
                      232,
                      232,
                    ), // Locked to grey
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
                // Staff ID Field
                _buildTextField(
                  hint: 'Employee / Department ID',
                  icon: LucideIcons.briefcase,
                ),
              ],

              const SizedBox(height: 16),

              // Password Field
              _buildTextField(
                hint: 'Password',
                icon: PhosphorIconsRegular.lockSimple,
                isPassword: true,
              ),
              const SizedBox(height: 32),

              // Sign Up Button
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    final finalRole = _isStudent ? 'Student' : _staffRole;
                    print("User is signing up with role: $finalRole");

                    Navigator.pop(context);
                  },
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
                  child: const Text(
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

  // Removed isDarkMode parameter from the helper method
  Widget _buildTextField({
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      obscureText: isPassword ? _obscurePassword : false,
      style: const TextStyle(color: Colors.black), // Locked to black text
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
        filled: true,
        //box color
        fillColor: const Color.fromARGB(
          255,
          242,
          242,
          243,
        ), // Locked to light grey fill
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(
            //border color
            color: Colors.grey[300]!, // Locked to grey border
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(
            //active color
            color: Color.fromARGB(255, 41, 99, 165),
            width: 2,
          ),
        ),
      ),
    );
  }
}
