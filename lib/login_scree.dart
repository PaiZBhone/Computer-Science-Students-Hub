import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return LoginScreenState();
  }
}

class LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              //email
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                //email condition
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  } else if (!value.contains('@')) {
                    return 'Please Enter valid email address';
                  } else {
                    return null;
                  }
                },
              ),
              //password
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                //password condition
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Plese enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  if (!value.contains('#') &&
                      !value.contains('@') &&
                      !value.contains('%') &&
                      !value.contains('*')) {
                    return 'Password must contain a special character (# @ % *)';
                  } else {
                    return null;
                  }
                },
              ),
              //button
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      final email = _emailController.text;
                      final password = _passwordController.text;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Email: $email\nPassword:$password',
                          ),
                        ),
                      );
                    }
                  },
                  child: Text('Login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
