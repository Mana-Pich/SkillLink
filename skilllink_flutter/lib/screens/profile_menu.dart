import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'booking_history_screen.dart';
import 'wallet_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color primaryColor =
      Color(0xFF5B4FE9);

  static const Color darkColor =
      Color(0xFF171A35);

  static const Color backgroundColor =
      Color(0xFFF3F5F9);

  String userName = 'User';
  String userEmail = 'No email available';

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  // ============================================================
  // LOAD PROFILE
  // ============================================================

  Future<void> loadProfile() async {
    try {
      final name = await _getName();
      final email = await _getEmail();

      if (!mounted) return;

      setState(() {
        userName = name;
        userEmail = email;
        isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  // ============================================================
  // SAFE AUTH SERVICE HELPERS
  // ============================================================

  Future<String> _getName() async {
    try {
      final dynamic result =
          await AuthService.getUserName();

      if (result != null &&
          result.toString().trim().isNotEmpty) {
        return result.toString();
      }
    } catch (_) {}

    return 'User';
  }

  Future<String> _getEmail() async {
    try {
      final dynamic result =
          await AuthService.getUserEmail();

      if (result != null &&
          result.toString().trim().isNotEmpty) {
        return result.toString();
      }
    } catch (_) {}

    return 'No email available';
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
    final shouldLogout =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Logout',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Are you sure you want to logout?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFFDC2626),
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) {
      return;
    }

    try {
      await AuthService.logout();
    } catch (_) {}

    if (!mounted) return;

    Navigator.of(context).popUntil(
      (route) => route.isFirst,
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: darkColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Center(
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(
            maxWidth: 430,
          ),
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: primaryColor,
                  ),
                )
              : RefreshIndicator(
                  color: primaryColor,
                  onRefresh: loadProfile,
                  child: ListView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    children: [
                      _buildProfileHeader(),

                      const SizedBox(height: 20),

                      _buildSectionTitle(
                        'Account',
                      ),

                      const SizedBox(height: 10),

                      _buildMenuCard(
                        icon: Icons.receipt_long_rounded,
                        title: 'Booking History',
                        subtitle:
                            'View your bookings',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const BookingHistoryScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 10),

                      _buildMenuCard(
                        icon:
                            Icons.account_balance_wallet_rounded,
                        title: 'My Wallet',
                        subtitle:
                            'View your wallet balance',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const WalletScreen(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 25),

                      _buildSectionTitle(
                        'Settings',
                      ),

                      const SizedBox(height: 10),

                      _buildMenuCard(
                        icon: Icons.person_outline_rounded,
                        title: 'Account Information',
                        subtitle:
                            'Manage your account',
                        onTap: () {
                          _showComingSoon(
                            'Account editing',
                          );
                        },
                      ),

                      const SizedBox(height: 10),

                      _buildMenuCard(
                        icon:
                            Icons.notifications_none_rounded,
                        title: 'Notifications',
                        subtitle:
                            'Manage notifications',
                        onTap: () {
                          _showComingSoon(
                            'Notifications',
                          );
                        },
                      ),

                      const SizedBox(height: 10),

                      _buildMenuCard(
                        icon:
                            Icons.help_outline_rounded,
                        title: 'Help & Support',
                        subtitle:
                            'Get help with SkillLink',
                        onTap: () {
                          _showComingSoon(
                            'Help & Support',
                          );
                        },
                      ),

                      const SizedBox(height: 25),

                      _buildLogoutButton(),

                      const SizedBox(height: 30),

                      const Center(
                        child: Text(
                          'SkillLink',
                          style: TextStyle(
                            color:
                                Color(0xFF9CA3AF),
                            fontSize: 12,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 5),

                      const Center(
                        child: Text(
                          'Connect. Book. Get Skilled.',
                          style: TextStyle(
                            color:
                                Color(0xFFB0B4BF),
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  // ============================================================
  // PROFILE HEADER
  // ============================================================

  Widget _buildProfileHeader() {
    final firstLetter =
        userName.trim().isEmpty
            ? 'U'
            : userName.trim()[0].toUpperCase();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE6E8EF),
        ),
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color:
                  const Color(0xFFEEEAFE),
              borderRadius:
                  BorderRadius.circular(22),
            ),
            child: Center(
              child: Text(
                firstLetter,
                style: const TextStyle(
                  color: primaryColor,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  maxLines: 1,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: darkColor,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  userEmail,
                  maxLines: 2,
                  overflow:
                      TextOverflow.ellipsis,
                  style: const TextStyle(
                    color:
                        Color(0xFF8A8F9F),
                    fontSize: 11,
                  ),
                ),

                const SizedBox(height: 8),

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color:
                        const Color(0xFFEEEAFE),
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'SkillLink Member',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 9,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle(
    String title,
  ) {
    return Text(
      title,
      style: const TextStyle(
        color: darkColor,
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // ============================================================
  // MENU CARD
  // ============================================================

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius:
          BorderRadius.circular(17),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(17),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius:
                BorderRadius.circular(17),
            border: Border.all(
              color:
                  const Color(0xFFE6E8EF),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color:
                      const Color(0xFFEEEAFE),
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: primaryColor,
                  size: 22,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style:
                          const TextStyle(
                        color: darkColor,
                        fontSize: 13,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,
                      style:
                          const TextStyle(
                        color:
                            Color(0xFF8A8F9F),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF9CA3AF),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LOGOUT BUTTON
  // ============================================================

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: logout,
        icon: const Icon(
          Icons.logout_rounded,
          size: 19,
        ),
        label: const Text(
          'Logout',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor:
              const Color(0xFFDC2626),
          side: const BorderSide(
            color: Color(0xFFDC2626),
          ),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // COMING SOON
  // ============================================================

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(
          '$feature will be available soon.',
        ),
        behavior:
            SnackBarBehavior.floating,
      ),
    );
  }
}