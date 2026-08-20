import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController =
      TextEditingController();

  final _emailController =
      TextEditingController();

  final _passwordController =
      TextEditingController();

  final _confirmPasswordController =
      TextEditingController();

  String _selectedRole = 'user';

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user =
          await AuthService.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        role: _selectedRole,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Account created successfully!',
          ),
        ),
      );

      // For now we show the registered user.
      // We will connect this to the actual
      // login/navigation flow next.
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              'Registration Successful',
            ),
            content: Text(
              'Welcome, ${user['name']}!\n\n'
              'Email: ${user['email']}\n'
              'Role: ${user['role']}',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);

                  Navigator.pop(context);
                },
                child: const Text('Continue'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor:
            const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Create Account',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints:
                  const BoxConstraints(
                maxWidth: 430,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons
                          .person_add_alt_1_rounded,
                      color:
                          Color(0xFF60A5FA),
                      size: 60,
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    const Text(
                      'Join SkillLink',
                      textAlign:
                          TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    const Text(
                      'Create an account to get started',
                      textAlign:
                          TextAlign.center,
                      style: TextStyle(
                        color:
                            Color(0xFF94A3B8),
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(
                      height: 32,
                    ),

                    // NAME
                    TextFormField(
                      controller:
                          _nameController,
                      style:
                          const TextStyle(
                        color: Colors.white,
                      ),
                      decoration:
                          _inputDecoration(
                        label: 'Full Name',
                        icon: Icons
                            .person_outline,
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Please enter your name';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    // EMAIL
                    TextFormField(
                      controller:
                          _emailController,
                      keyboardType:
                          TextInputType
                              .emailAddress,
                      style:
                          const TextStyle(
                        color: Colors.white,
                      ),
                      decoration:
                          _inputDecoration(
                        label: 'Email',
                        icon: Icons
                            .email_outlined,
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Please enter your email';
                        }

                        if (!value.contains('@')) {
                          return 'Please enter a valid email';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    // PASSWORD
                    TextFormField(
                      controller:
                          _passwordController,
                      obscureText:
                          _obscurePassword,
                      style:
                          const TextStyle(
                        color: Colors.white,
                      ),
                      decoration:
                          _inputDecoration(
                        label: 'Password',
                        icon:
                            Icons.lock_outline,
                      ).copyWith(
                        suffixIcon:
                            IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword =
                                  !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons
                                    .visibility_outlined
                                : Icons
                                    .visibility_off_outlined,
                            color:
                                const Color(
                              0xFF94A3B8,
                            ),
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty) {
                          return 'Please enter a password';
                        }

                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    // CONFIRM PASSWORD
                    TextFormField(
                      controller:
                          _confirmPasswordController,
                      obscureText:
                          _obscureConfirmPassword,
                      style:
                          const TextStyle(
                        color: Colors.white,
                      ),
                      decoration:
                          _inputDecoration(
                        label:
                            'Confirm Password',
                        icon:
                            Icons.lock_reset,
                      ).copyWith(
                        suffixIcon:
                            IconButton(
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons
                                    .visibility_outlined
                                : Icons
                                    .visibility_off_outlined,
                            color:
                                const Color(
                              0xFF94A3B8,
                            ),
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty) {
                          return 'Please confirm your password';
                        }

                        if (value !=
                            _passwordController
                                .text) {
                          return 'Passwords do not match';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    // ROLE
                    const Text(
                      'Account Type',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    Row(
                      children: [
                        Expanded(
                          child:
                              _roleCard(
                            role: 'user',
                            title:
                                'Customer',
                            subtitle:
                                'Book services',
                            icon: Icons
                                .person_rounded,
                          ),
                        ),

                        const SizedBox(
                          width: 12,
                        ),

                        Expanded(
                          child:
                              _roleCard(
                            role:
                                'provider',
                            title:
                                'Provider',
                            subtitle:
                                'Offer services',
                            icon: Icons
                                .business_center_rounded,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 28,
                    ),

                    // REGISTER BUTTON
                    SizedBox(
                      height: 54,
                      child:
                          ElevatedButton(
                        onPressed:
                            _isLoading
                                ? null
                                : _register,
                        style:
                            ElevatedButton
                                .styleFrom(
                          backgroundColor:
                              const Color(
                            0xFF2563EB,
                          ),
                          foregroundColor:
                              Colors.white,
                          disabledBackgroundColor:
                              const Color(
                            0xFF334155,
                          ),
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              14,
                            ),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child:
                                    CircularProgressIndicator(
                                  strokeWidth:
                                      2.5,
                                  color:
                                      Colors.white,
                                ),
                              )
                            : const Text(
                                'Create Account',
                                style:
                                    TextStyle(
                                  fontSize:
                                      16,
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    // LOGIN
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .center,
                      children: [
                        const Text(
                          'Already have an account? ',
                          style: TextStyle(
                            color:
                                Color(
                              0xFF94A3B8,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(
                              context,
                            );
                          },
                          child: const Text(
                            'Sign In',
                            style:
                                TextStyle(
                              color:
                                  Color(
                                0xFF60A5FA,
                              ),
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                        ),
                      ],
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

  // ============================================================
  // ROLE CARD
  // ============================================================

  Widget _roleCard({
    required String role,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final selected =
        _selectedRole == role;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      child: AnimatedContainer(
        duration:
            const Duration(
          milliseconds: 200,
        ),
        padding:
            const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected
              ? const Color(
                  0xFF1D4ED8,
                )
              : const Color(
                  0xFF1E293B,
                ),
          borderRadius:
              BorderRadius.circular(
            14,
          ),
          border: Border.all(
            color: selected
                ? const Color(
                    0xFF60A5FA,
                  )
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: selected
                  ? Colors.white
                  : const Color(
                      0xFF94A3B8,
                    ),
              size: 30,
            ),

            const SizedBox(
              height: 8,
            ),

            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 4,
            ),

            Text(
              subtitle,
              textAlign:
                  TextAlign.center,
              style: const TextStyle(
                color:
                    Color(0xFF94A3B8),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle:
          const TextStyle(
        color:
            Color(0xFF94A3B8),
      ),
      prefixIcon: Icon(
        icon,
        color:
            const Color(0xFF64748B),
      ),
      filled: true,
      fillColor:
          const Color(0xFF1E293B),
      border:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(
          14,
        ),
        borderSide:
            BorderSide.none,
      ),
      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(
          14,
        ),
        borderSide:
            BorderSide.none,
      ),
      focusedBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(
          14,
        ),
        borderSide:
            const BorderSide(
          color:
              Color(0xFF2563EB),
          width: 1.5,
        ),
      ),
      errorBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(
          14,
        ),
        borderSide:
            const BorderSide(
          color: Colors.redAccent,
        ),
      ),
      focusedErrorBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(
          14,
        ),
        borderSide:
            const BorderSide(
          color: Colors.redAccent,
        ),
      ),
    );
  }
}