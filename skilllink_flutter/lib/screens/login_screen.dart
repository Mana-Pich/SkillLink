import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'home_screen.dart';
import 'provider_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailController =
      TextEditingController();

  final _passwordController =
      TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await AuthService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      final role =
          user['role']?.toString().toLowerCase();

      // ========================================================
      // CUSTOMER / USER
      // ========================================================

      if (role == 'user') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const HomeScreen(),
          ),
          (route) => false,
        );

        return;
      }

      // ========================================================
      // SERVICE PROVIDER
      // ========================================================

      if (role == 'provider') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const ProviderDashboard(),
          ),
          (route) => false,
        );

        return;
      }

      // ========================================================
      // UNKNOWN ROLE
      // ========================================================

      await AuthService.logout();

      if (!mounted) return;

      _showMessage(
        'This account has an invalid role.',
        isError: true,
      );
    } catch (e) {
      if (!mounted) return;

      String message =
          e.toString();

      if (message.startsWith(
        'Exception: ',
      )) {
        message =
            message.substring(11);
      }

      _showMessage(
        message,
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Colors.redAccent
            : const Color(0xFF16A34A),
        behavior:
            SnackBarBehavior.floating,
        margin:
            const EdgeInsets.all(16),
        shape:
            RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(12),
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF0F172A),

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
                      CrossAxisAlignment
                          .stretch,

                  children: [

                    // ==================================================
                    // LOGO
                    // ==================================================

                    Center(
                      child: Container(
                        width: 76,
                        height: 76,

                        decoration:
                            BoxDecoration(
                          color:
                              const Color(
                            0xFF5B4FE9,
                          ),

                          borderRadius:
                              BorderRadius
                                  .circular(
                            22,
                          ),

                          boxShadow: [
                            BoxShadow(
                              color:
                                  const Color(
                                0xFF5B4FE9,
                              ).withOpacity(
                                0.25,
                              ),
                              blurRadius: 20,
                              offset:
                                  const Offset(
                                0,
                                8,
                              ),
                            ),
                          ],
                        ),

                        child:
                            const Icon(
                          Icons
                              .handshake_rounded,
                          color:
                              Colors.white,
                          size: 40,
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 28,
                    ),

                    // ==================================================
                    // TITLE
                    // ==================================================

                    const Text(
                      'Welcome Back',
                      style: TextStyle(
                        color:
                            Colors.white,
                        fontSize: 30,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    const Text(
                      'Sign in to continue to SkillLink',
                      style: TextStyle(
                        color:
                            Color(
                          0xFF94A3B8,
                        ),
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(
                      height: 32,
                    ),

                    // ==================================================
                    // EMAIL
                    // ==================================================

                    TextFormField(
                      controller:
                          _emailController,

                      keyboardType:
                          TextInputType
                              .emailAddress,

                      textInputAction:
                          TextInputAction
                              .next,

                      style:
                          const TextStyle(
                        color:
                            Colors.white,
                      ),

                      decoration:
                          _inputDecoration(
                        label: 'Email',
                        icon:
                            Icons
                                .email_outlined,
                      ),

                      validator:
                          (value) {
                        if (value ==
                                null ||
                            value
                                .trim()
                                .isEmpty) {
                          return 'Please enter your email';
                        }

                        if (!value
                            .trim()
                            .contains(
                              '@',
                            )) {
                          return 'Please enter a valid email';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    // ==================================================
                    // PASSWORD
                    // ==================================================

                    TextFormField(
                      controller:
                          _passwordController,

                      obscureText:
                          _obscurePassword,

                      textInputAction:
                          TextInputAction
                              .done,

                      onFieldSubmitted:
                          (_) {
                        if (!_isLoading) {
                          _login();
                        }
                      },

                      style:
                          const TextStyle(
                        color:
                            Colors.white,
                      ),

                      decoration:
                          _inputDecoration(
                        label: 'Password',
                        icon:
                            Icons
                                .lock_outline,
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

                      validator:
                          (value) {
                        if (value ==
                                null ||
                            value
                                .isEmpty) {
                          return 'Please enter your password';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(
                      height: 28,
                    ),

                    // ==================================================
                    // LOGIN BUTTON
                    // ==================================================

                    SizedBox(
                      height: 54,

                      child:
                          ElevatedButton(
                        onPressed:
                            _isLoading
                                ? null
                                : _login,

                        style:
                            ElevatedButton
                                .styleFrom(
                          backgroundColor:
                              const Color(
                            0xFF5B4FE9,
                          ),

                          foregroundColor:
                              Colors.white,

                          disabledBackgroundColor:
                              const Color(
                            0xFF334155,
                          ),

                          elevation: 0,

                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                              14,
                            ),
                          ),
                        ),

                        child:
                            _isLoading
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
                                    'Sign In',
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
                      height: 24,
                    ),

                    // ==================================================
                    // REGISTER
                    // ==================================================

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .center,

                      children: [
                        const Text(
                          "Don't have an account? ",
                          style:
                              TextStyle(
                            color:
                                Color(
                              0xFF94A3B8,
                            ),
                          ),
                        ),

                        TextButton(
                          onPressed:
                              _isLoading
                                  ? null
                                  : () {
                                      Navigator
                                          .pushNamed(
                                        context,
                                        '/register',
                                      );
                                    },

                          child:
                              const Text(
                            'Register',
                            style:
                                TextStyle(
                              color:
                                  Color(
                                0xFF8F86FF,
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

      prefixIcon:
          Icon(
        icon,
        color:
            const Color(
          0xFF64748B,
        ),
      ),

      filled: true,

      fillColor:
          const Color(
        0xFF1E293B,
      ),

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
              Color(0xFF5B4FE9),
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
          color:
              Colors.redAccent,
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
          color:
              Colors.redAccent,
        ),
      ),
    );
  }
}