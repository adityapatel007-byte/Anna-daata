import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'user_storage.dart';
import 'donor_home_screen.dart';
import 'ngo_home_screen.dart';

class AuthScreen extends StatefulWidget {
  final String role;
  const AuthScreen({super.key, required this.role});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isSignIn = true;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  String? nameErrorText;
  String? phoneErrorText;
  String? emailErrorText;
  String? passwordErrorText;
  String? confirmPasswordErrorText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.role} Authentication'),
        backgroundColor: const Color(0xFF43A047),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF6FFF2), Color(0xFFB2FF59)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isSignIn ? 'Sign In' : 'Create Account',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF388E3C)),
                    ),
                    const SizedBox(height: 24),
                    if (!isSignIn) ...[
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          prefixIcon: Icon(Icons.person, color: Color(0xFF43A047)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.white,
                          errorText: nameErrorText,
                        ),
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: phoneController,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          prefixIcon: Icon(Icons.phone, color: Color(0xFF43A047)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.white,
                          errorText: phoneErrorText,
                        ),
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email, color: Color(0xFF43A047)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.white,
                        errorText: emailErrorText,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      textCapitalization: TextCapitalization.none,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock, color: Color(0xFF43A047)),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        filled: true,
                        fillColor: Colors.white,
                        errorText: passwordErrorText,
                      ),
                      obscureText: true,
                    ),
                    if (!isSignIn) ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF43A047)),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          filled: true,
                          fillColor: Colors.white,
                          errorText: confirmPasswordErrorText,
                        ),
                        obscureText: true,
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: Icon(isSignIn ? Icons.login : Icons.person_add),
                        label: Text(isSignIn ? 'Sign In' : 'Create Account', style: const TextStyle(fontSize: 18)),
                        onPressed: () {
                          setState(() {
                            nameErrorText = null;
                            phoneErrorText = null;
                            emailErrorText = null;
                            passwordErrorText = null;
                            confirmPasswordErrorText = null;
                          });
                          
                          String email = emailController.text.trim();
                          String password = passwordController.text;
                          
                          // Validate email
                          bool validEmail = RegExp(r'^[a-z0-9._%+-]+@[a-z0-9.-]+\.[a-z]{2,4}$').hasMatch(email);
                          if (!validEmail) {
                            setState(() {
                              emailErrorText = 'Enter a valid email (lowercase only)';
                            });
                            return;
                          }
                          
                          // Validate password
                          bool validPassword = password.length >= 8 &&
                            RegExp(r'[A-Z]').hasMatch(password) &&
                            RegExp(r'[a-z]').hasMatch(password);
                          if (!validPassword) {
                            setState(() {
                              passwordErrorText = 'Password must be 8+ chars, include uppercase & lowercase';
                            });
                            return;
                          }
                          
                          if (!isSignIn) {
                            // Create Account validation
                            String name = nameController.text.trim();
                            String phone = phoneController.text.trim();
                            String confirmPassword = confirmPasswordController.text;
                            
                            if (name.isEmpty) {
                              setState(() {
                                nameErrorText = 'Name is required';
                              });
                              return;
                            }
                            
                            if (phone.length != 10) {
                              setState(() {
                                phoneErrorText = 'Phone number must be exactly 10 digits';
                              });
                              return;
                            }
                            
                            if (password != confirmPassword) {
                              setState(() {
                                confirmPasswordErrorText = 'Passwords do not match';
                              });
                              return;
                            }
                            
                            // Store account credentials
                            UserStorage.storeAccount(email, name, phone, password);
                            
                            // Navigate to home screen after account creation
                            if (widget.role == 'Volunteer') {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const DonorHomeScreen()),
                              );
                            } else {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (context) => const NGOHomeScreen()),
                              );
                            }
                            return;
                          }
                          
                          // Sign In validation
                          if (!UserStorage.accountExists(email)) {
                            setState(() {
                              emailErrorText = 'No account found. Please create an account first.';
                            });
                            return;
                          }
                          
                          if (!UserStorage.validatePassword(email, password)) {
                            setState(() {
                              passwordErrorText = 'Incorrect password';
                            });
                            return;
                          }
                          
                          // Navigate after successful sign in
                          if (widget.role == 'Volunteer') {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const DonorHomeScreen()),
                            );
                          } else {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const NGOHomeScreen()),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF43A047),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          isSignIn = !isSignIn;
                          // Clear all text fields when switching modes
                          nameController.clear();
                          phoneController.clear();
                          emailController.clear();
                          passwordController.clear();
                          confirmPasswordController.clear();
                          // Clear all error messages
                          nameErrorText = null;
                          phoneErrorText = null;
                          emailErrorText = null;
                          passwordErrorText = null;
                          confirmPasswordErrorText = null;
                        });
                      },
                      child: Text(
                        isSignIn ? 'Don\'t have an account? Create Account' : 'Already have an account? Sign In',
                        style: const TextStyle(color: Color(0xFF388E3C)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
