// lib/screens/sign_in_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth.service.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});
  
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  bool isLoading = false;
  String errorMessage = '';
  
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading 
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: Column(
                children: [
                  // Email Field
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) => val!.isEmpty ? 'Enter an email' : null,
                    onChanged: (val) {
                      setState(() => email = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Password Field
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    validator: (val) => val!.length < 6 ? 'Password too short' : null,
                    onChanged: (val) {
                      setState(() => password = val);
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Error Message
                  if (errorMessage.isNotEmpty)
                    Text(
                      errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // Sign In Button
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          isLoading = true;
                          errorMessage = '';
                        });
                        var user = await authService.signIn(email, password);
                        if (user != null) {
                          Navigator.pushReplacementNamed(context, '/home');
                        } else {
                          setState(() {
                            errorMessage = 'Failed to sign in. Please try again.';
                            isLoading = false;
                          });
                        }
                      }
                    },
                    child: const Text('Sign In'),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Navigate to Sign Up
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/signUp'); // Implement SignUpScreen similarly
                    },
                    child: const Text('Don\'t have an account? Sign Up'),
                  ),
                ],
              ),
            ),
      ),
    );
  }
}