import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/api_service.dart';

import 'login_screen.dart';
import 'provider_services_screen.dart';
import 'provider_bookings_screen.dart';

class ProviderDashboard extends StatefulWidget {
  const ProviderDashboard({
    super.key,
  });

  @override
  State<ProviderDashboard> createState() =>
      _ProviderDashboardState();
}

class _ProviderDashboardState
    extends State<ProviderDashboard> {

  String providerName = 'Provider';
  int? providerId;

  bool isLoading = true;

  List<Map<String, dynamic>> bookings = [];
  int serviceCount = 0;

  @override
  void initState() {
    super.initState();
    loadProvider();
  }

  // ============================================================
  // LOAD PROVIDER
  // ============================================================

  Future<void> loadProvider() async {
    try {
      final user =
          await AuthService.getSavedUser();

      if (!mounted) return;

      if (user == null) {
        _goToLogin();
        return;
      }

      final id = user['id'];

      setState(() {
        providerId = id is int
            ? id
            : int.tryParse(
                id?.toString() ?? '',
              );

        providerName =
            user['name']?.toString() ??
                'Provider';

        isLoading = false;
      });

      await loadProviderData();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  // ============================================================
  // LOAD PROVIDER DATA
  // ============================================================

  Future<void> loadProviderData() async {
    if (providerId == null) return;

    try {
      final result =
          await ApiService.getProviderBookings(
        providerId: providerId!,
      );

      if (!mounted) return;

      setState(() {
        bookings = result;
      });
    } catch (_) {
      // Keep dashboard usable even if booking API fails.
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
    await AuthService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  void _goToLogin() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF3F5F9),
        body: Center(
          child: CircularProgressIndicator(
            color: Color(0xFF5B4FE9),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor:
          const Color(0xFFF3F5F9),

      body: SafeArea(
        child: Center(
          child: Container(
            width: double.infinity,
            constraints:
                const BoxConstraints(
              maxWidth: 430,
            ),
            child: Column(
              children: [
                _buildHeader(),

                Expanded(
                  child:
                      RefreshIndicator(
                    onRefresh:
                        loadProviderData,
                    color:
                        const Color(
                      0xFF5B4FE9,
                    ),
                    child:
                        SingleChildScrollView(
                      physics:
                          const AlwaysScrollableScrollPhysics(),
                      padding:
                          const EdgeInsets.fromLTRB(
                        20,
                        20,
                        20,
                        30,
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          _buildWelcome(),

                          const SizedBox(
                            height: 22,
                          ),

                          _buildStats(),

                          const SizedBox(
                            height: 28,
                          ),

                          _buildSectionTitle(
                            'Provider Tools',
                            'Manage your SkillLink business',
                          ),

                          const SizedBox(
                            height: 14,
                          ),

                          _buildTools(),

                          const SizedBox(
                            height: 28,
                          ),

                          _buildPerformanceCard(),

                          const SizedBox(
                            height: 25,
                          ),

                          _buildQuickTip(),
                        ],
                      ),
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
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    final firstLetter =
        providerName.isNotEmpty
            ? providerName[0].toUpperCase()
            : 'P';

    return Container(
      padding:
          const EdgeInsets.fromLTRB(
        20,
        15,
        20,
        15,
      ),
      decoration:
          const BoxDecoration(
        color: Color(0xFF171A35),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration:
                BoxDecoration(
              color:
                  const Color(0xFF5B4FE9),
              borderRadius:
                  BorderRadius.circular(
                14,
              ),
            ),
            child: const Icon(
              Icons.handyman_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),

          const SizedBox(
            width: 12,
          ),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'SkillLink',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Provider Dashboard',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          // Notifications
          Container(
            width: 42,
            height: 42,
            decoration:
                BoxDecoration(
              color:
                  Colors.white.withOpacity(
                0.08,
              ),
              borderRadius:
                  BorderRadius.circular(
                13,
              ),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed:
                  _showNotifications,
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),

          const SizedBox(
            width: 8,
          ),

          // PROFILE MENU
          PopupMenuButton<String>(
            tooltip: 'Account',

            onSelected:
                (value) {
              if (value == 'logout') {
                logout();
              } else if (value ==
                  'profile') {
                _showProfile();
              }
            },

            itemBuilder:
                (context) => [
              PopupMenuItem(
                value: 'profile',
                child: Row(
                  children: [
                    const Icon(
                      Icons.person_outline_rounded,
                      color:
                          Color(0xFF5B4FE9),
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    Text(
                      providerName,
                    ),
                  ],
                ),
              ),

              const PopupMenuDivider(),

              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(
                      Icons.logout_rounded,
                      color:
                          Color(0xFFDC2626),
                    ),
                    SizedBox(
                      width: 12,
                    ),
                    Text(
                      'Log Out',
                    ),
                  ],
                ),
              ),
            ],

            child: CircleAvatar(
              radius: 21,
              backgroundColor:
                  const Color(0xFFEEEAFE),
              child: Text(
                firstLetter,
                style:
                    const TextStyle(
                  color:
                      Color(0xFF5B4FE9),
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // WELCOME
  // ============================================================

  Widget _buildWelcome() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Welcome back,',
          style: TextStyle(
            color:
                Color(0xFF8A8F9F),
            fontSize: 13,
          ),
        ),

        const SizedBox(
          height: 3,
        ),

        Text(
          providerName,
          maxLines: 1,
          overflow:
              TextOverflow.ellipsis,
          style: const TextStyle(
            color:
                Color(0xFF171A35),
            fontSize: 27,
            fontWeight:
                FontWeight.bold,
          ),
        ),

        const SizedBox(
          height: 7,
        ),

        const Text(
          'Here is what is happening with your services today.',
          style: TextStyle(
            color:
                Color(0xFF777D8E),
            fontSize: 12,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STATISTICS
  // ============================================================

  Widget _buildStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon:
                Icons.design_services_rounded,
            value:
                serviceCount.toString(),
            label: 'Services',
          ),
        ),

        const SizedBox(
          width: 10,
        ),

        Expanded(
          child: _buildStatCard(
            icon:
                Icons.calendar_month_rounded,
            value:
                bookings.length.toString(),
            label: 'Bookings',
          ),
        ),

        const SizedBox(
          width: 10,
        ),

        Expanded(
          child: _buildStatCard(
            icon:
                Icons.star_rounded,
            value: '4.8',
            label: 'Rating',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        vertical: 17,
        horizontal: 8,
      ),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          18,
        ),
        border: Border.all(
          color:
              const Color(0xFFE6E8EF),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration:
                BoxDecoration(
              color:
                  const Color(0xFFEEEAFE),
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),
            child: Icon(
              icon,
              color:
                  const Color(0xFF5B4FE9),
              size: 20,
            ),
          ),

          const SizedBox(
            height: 9,
          ),

          Text(
            value,
            style:
                const TextStyle(
              color:
                  Color(0xFF171A35),
              fontSize: 20,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 2,
          ),

          Text(
            label,
            style:
                const TextStyle(
              color:
                  Color(0xFF8A8F9F),
              fontSize: 10,
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
    String subtitle,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style:
              const TextStyle(
            color:
                Color(0xFF171A35),
            fontSize: 19,
            fontWeight:
                FontWeight.bold,
          ),
        ),

        const SizedBox(
          height: 4,
        ),

        Text(
          subtitle,
          style:
              const TextStyle(
            color:
                Color(0xFF8A8F9F),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PROVIDER TOOLS
  // ============================================================

  Widget _buildTools() {
    return Column(
      children: [
        _buildToolCard(
          icon:
              Icons.design_services_rounded,
          title: 'My Services',
          subtitle:
              'Manage the services you provide',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const ProviderServicesScreen(),
              ),
            );
          },
        ),

        const SizedBox(
          height: 12,
        ),

        _buildToolCard(
          icon:
              Icons.calendar_month_rounded,
          title: 'Customer Bookings',
          subtitle:
              'View and manage customer requests',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const ProviderBookingsScreen(),
              ),
            );
          },
        ),

        const SizedBox(
          height: 12,
        ),

        _buildToolCard(
          icon:
              Icons.account_balance_wallet_rounded,
          title: 'Earnings',
          subtitle:
              'Track your service earnings',
          onTap: () {
            _showEarnings();
          },
        ),

        const SizedBox(
          height: 12,
        ),

        _buildToolCard(
          icon:
              Icons.star_rounded,
          title: 'Reviews',
          subtitle:
              'See feedback from your customers',
          onTap: () {
            _showReviews();
          },
        ),
      ],
    );
  }

  Widget _buildToolCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(
          18,
        ),
        child: Container(
          padding:
              const EdgeInsets.all(16),
          decoration:
              BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(
              18,
            ),
            border: Border.all(
              color:
                  const Color(0xFFE6E8EF),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration:
                    BoxDecoration(
                  color:
                      const Color(0xFFEEEAFE),
                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                ),
                child: Icon(
                  icon,
                  color:
                      const Color(0xFF5B4FE9),
                  size: 23,
                ),
              ),

              const SizedBox(
                width: 14,
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      title,
                      style:
                          const TextStyle(
                        color:
                            Color(0xFF202337),
                        fontSize: 14,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height: 5,
                    ),

                    Text(
                      subtitle,
                      style:
                          const TextStyle(
                        color:
                            Color(0xFF8A8F9F),
                        fontSize: 10.5,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right_rounded,
                color:
                    Color(0xFFB0B4C0),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PERFORMANCE
  // ============================================================

  Widget _buildPerformanceCard() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(19),
      decoration:
          BoxDecoration(
        gradient:
            const LinearGradient(
          colors: [
            Color(0xFF171A35),
            Color(0xFF292D55),
          ],
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,
        ),
        borderRadius:
            BorderRadius.circular(
          21,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Your Performance',
                  style:
                      TextStyle(
                    color:
                        Colors.white,
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),

              Container(
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFF3A3E67,
                  ),
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                ),
                child:
                    const Text(
                  'This month',
                  style:
                      TextStyle(
                    color:
                        Color(
                      0xFFC7C9D9,
                    ),
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 20,
          ),

          Row(
            children: [
              Expanded(
                child:
                    _performanceItem(
                  value: '4.8',
                  label:
                      'Average Rating',
                  icon:
                      Icons.star_rounded,
                ),
              ),

              Expanded(
                child:
                    _performanceItem(
                  value: '100%',
                  label:
                      'Completion',
                  icon:
                      Icons
                          .check_circle_rounded,
                ),
              ),

              Expanded(
                child:
                    _performanceItem(
                  value: '\$15',
                  label: 'Earned',
                  icon:
                      Icons
                          .attach_money_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _performanceItem({
    required String value,
    required String label,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color:
              const Color(0xFF8F86FF),
          size: 20,
        ),

        const SizedBox(
          height: 8,
        ),

        Text(
          value,
          style:
              const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight:
                FontWeight.bold,
          ),
        ),

        const SizedBox(
          height: 3,
        ),

        Text(
          label,
          textAlign:
              TextAlign.center,
          style:
              const TextStyle(
            color:
                Color(0xFFB8BBD0),
            fontSize: 8.5,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // QUICK TIP
  // ============================================================

  Widget _buildQuickTip() {
    return Container(
      padding:
          const EdgeInsets.all(16),
      decoration:
          BoxDecoration(
        color:
            const Color(0xFFFFFBEB),
        borderRadius:
            BorderRadius.circular(
          17,
        ),
        border: Border.all(
          color:
              const Color(0xFFF5E6A8),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lightbulb_rounded,
            color:
                Color(0xFFD99A00),
            size: 22,
          ),

          const SizedBox(
            width: 12,
          ),

          const Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Provider Tip',
                  style:
                      TextStyle(
                    color:
                        Color(0xFF5E4A00),
                    fontSize: 12,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                SizedBox(
                  height: 5,
                ),

                Text(
                  'Keep your service information clear and updated to help customers choose your service.',
                  style:
                      TextStyle(
                    color:
                        Color(0xFF796A32),
                    fontSize: 10.5,
                    height: 1.4,
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
  // NOTIFICATIONS
  // ============================================================

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      backgroundColor:
          Colors.white,
      isScrollControlled: true,
      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.all(22),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notifications',
                  style:
                      TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        Color(0xFF171A35),
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                ListTile(
                  contentPadding:
                      EdgeInsets.zero,
                  leading:
                      const CircleAvatar(
                    backgroundColor:
                        Color(0xFFEEEAFE),
                    child: Icon(
                      Icons
                          .calendar_today_rounded,
                      color:
                          Color(0xFF5B4FE9),
                    ),
                  ),
                  title:
                      const Text(
                    'Booking requests',
                    style:
                        TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  subtitle:
                      Text(
                    bookings.isEmpty
                        ? 'No new booking requests.'
                        : '${bookings.length} booking(s) available.',
                  ),
                ),

                const SizedBox(
                  height: 15,
                ),

                SizedBox(
                  width:
                      double.infinity,
                  child:
                      ElevatedButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const ProviderBookingsScreen(),
                        ),
                      );
                    },
                    style:
                        ElevatedButton
                            .styleFrom(
                      backgroundColor:
                          const Color(
                        0xFF5B4FE9,
                      ),
                      foregroundColor:
                          Colors.white,
                    ),
                    child:
                        const Text(
                      'View Bookings',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // PROFILE
  // ============================================================

  void _showProfile() {
    showModalBottomSheet(
      context: context,
      backgroundColor:
          Colors.white,
      isScrollControlled: true,
      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding:
                  const EdgeInsets.all(22),
              child: Column(
                mainAxisSize:
                    MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.person_rounded,
                    size: 45,
                    color:
                        Color(0xFF5B4FE9),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  Text(
                    providerName,
                    style:
                        const TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                      color:
                          Color(0xFF171A35),
                    ),
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  const Text(
                    'Service Provider',
                    style:
                        TextStyle(
                      color:
                          Color(0xFF8A8F9F),
                      fontSize: 12,
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  ListTile(
                    leading:
                        const Icon(
                      Icons.person_outline_rounded,
                      color:
                          Color(0xFF5B4FE9),
                    ),
                    title:
                        const Text(
                      'My Profile',
                    ),
                    onTap: () {
                      Navigator.pop(
                        context,
                      );

                      ScaffoldMessenger.of(
                        this.context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Profile editing will be added later.',
                          ),
                        ),
                      );
                    },
                  ),

                  ListTile(
                    leading:
                        const Icon(
                      Icons.logout_rounded,
                      color:
                          Color(0xFFDC2626),
                    ),
                    title:
                        const Text(
                      'Log Out',
                    ),
                    onTap: () {
                      Navigator.pop(
                        context,
                      );
                      logout();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // EARNINGS
  // ============================================================

  void _showEarnings() {
    showModalBottomSheet(
      context: context,
      backgroundColor:
          Colors.white,
      isScrollControlled: true,
      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.all(22),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Earnings',
                  style:
                      TextStyle(
                    fontSize: 22,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        Color(0xFF171A35),
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                Container(
                  width:
                      double.infinity,
                  padding:
                      const EdgeInsets.all(
                    20,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xFFEEEAFE,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      18,
                    ),
                  ),
                  child: const Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        'Total Earnings',
                        style:
                            TextStyle(
                          color:
                              Color(
                            0xFF686E80,
                          ),
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        '\$15.00',
                        style:
                            TextStyle(
                          color:
                              Color(
                            0xFF5B4FE9,
                          ),
                          fontSize: 28,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 15,
                ),

                const Text(
                  'Your earnings will be updated when customers complete and pay for your services.',
                  style:
                      TextStyle(
                    color:
                        Color(0xFF8A8F9F),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // REVIEWS
  // ============================================================

  void _showReviews() {
    showModalBottomSheet(
      context: context,
      backgroundColor:
          Colors.white,
      isScrollControlled: true,
      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(25),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding:
                const EdgeInsets.all(22),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                const Icon(
                  Icons.star_rounded,
                  color:
                      Color(0xFFFFB800),
                  size: 45,
                ),

                const SizedBox(
                  height: 10,
                ),

                const Text(
                  'Customer Reviews',
                  style:
                      TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        Color(0xFF171A35),
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                const Text(
                  'Your current rating is 4.8 based on customer feedback.',
                  textAlign:
                      TextAlign.center,
                  style:
                      TextStyle(
                    color:
                        Color(0xFF8A8F9F),
                    fontSize: 12,
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}