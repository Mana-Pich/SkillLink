import 'package:flutter/material.dart';

import '../models/service.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

import 'booking_history_screen.dart';
import 'category_services_screen.dart';
import 'login_screen.dart';
import 'service_details_screen.dart';
import 'wallet_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Service> services = [];
  List<Service> filteredServices = [];

  bool isLoading = true;
  String? errorMessage;

  String userName = 'User';
  String userEmail = '';

  String selectedCategory = 'All';

  final TextEditingController _searchController =
      TextEditingController();

  // ============================================================
  // SIX SKILLINK CATEGORIES
  // ============================================================

  final List<Map<String, dynamic>> categories = [
    {
      'name': 'Technology',
      'icon': Icons.computer_rounded,
    },
    {
      'name': 'Design',
      'icon': Icons.brush_rounded,
    },
    {
      'name': 'Education',
      'icon': Icons.school_rounded,
    },
    {
      'name': 'Photography',
      'icon': Icons.camera_alt_rounded,
    },
    {
      'name': 'Beauty',
      'icon': Icons.spa_rounded,
    },
    {
      'name': 'Home Services',
      'icon': Icons.home_repair_service_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();

    _loadUser();
    loadServices();

    _searchController.addListener(_filterServices);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterServices);
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD USER
  // ============================================================

  Future<void> _loadUser() async {
    final user = await AuthService.getSavedUser();

    if (!mounted || user == null) return;

    setState(() {
      userName =
          user['name']?.toString().trim().isNotEmpty == true
              ? user['name'].toString()
              : 'User';

      userEmail = user['email']?.toString() ?? '';
    });
  }

  // ============================================================
  // LOAD SERVICES
  // ============================================================

  Future<void> loadServices() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      final result = await ApiService.getServices();

      if (!mounted) return;

      setState(() {
        services = result;
        isLoading = false;
      });

      _filterServices();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Unable to load services.';
      });
    }
  }

  // ============================================================
  // SEARCH + FILTER
  // ============================================================

  void _filterServices() {
    final search =
        _searchController.text.trim().toLowerCase();

    List<Service> result = List.from(services);

    // CATEGORY
    if (selectedCategory != 'All') {
      result = result.where((service) {
        return service.categoryName
                .toLowerCase() ==
            selectedCategory.toLowerCase();
      }).toList();
    }

    // SEARCH
    if (search.isNotEmpty) {
      result = result.where((service) {
        final title =
            service.title.toLowerCase();

        final category =
            service.categoryName.toLowerCase();

        final provider =
            service.providerName.toLowerCase();

        return title.contains(search) ||
            category.contains(search) ||
            provider.contains(search);
      }).toList();
    }

    if (!mounted) return;

    setState(() {
      filteredServices = result;
    });
  }

  // ============================================================
  // SELECT CATEGORY
  // ============================================================

  Future<void> _selectCategory(
    String category,
  ) async {
    // ALL
    if (category == 'All') {
      setState(() {
        selectedCategory = 'All';
      });

      _searchController.clear();
      _filterServices();
      return;
    }

    // OPEN CATEGORY PAGE
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            CategoryServicesScreen(
          categoryName: category,
          services: services,
        ),
      ),
    );
  }

  // ============================================================
  // OPEN BOOKINGS
  // ============================================================

  Future<void> openBookings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const BookingHistoryScreen(),
      ),
    );
  }

  // ============================================================
  // OPEN WALLET
  // ============================================================

  Future<void> openWallet() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const WalletScreen(),
      ),
    );
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> logout() async {
    final shouldLogout =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(18),
          ),
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
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFFDC2626),
                foregroundColor:
                    Colors.white,
              ),
              child:
                  const Text('Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) return;

    await AuthService.logout();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const LoginScreen(),
      ),
      (route) => false,
    );
  }

  // ============================================================
  // PROFILE MENU
  // ============================================================

  void showProfileMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor:
          Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            constraints:
                BoxConstraints(
              maxHeight:
                  MediaQuery.of(
                    sheetContext,
                  ).size.height *
                  0.85,
            ),
            decoration:
                const BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child:
                SingleChildScrollView(
              padding:
                  const EdgeInsets.fromLTRB(
                20,
                12,
                20,
                20,
              ),
              child: Column(
                children: [
                  Container(
                    width: 45,
                    height: 5,
                    decoration:
                        BoxDecoration(
                      color: const Color(
                        0xFFD9DCE5,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        10,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  // USER
                  Row(
                    children: [
                      Container(
                        width: 54,
                        height: 54,
                        decoration:
                            BoxDecoration(
                          color: const Color(
                            0xFFEEEAFE,
                          ),
                          borderRadius:
                              BorderRadius.circular(
                            17,
                          ),
                        ),
                        child:
                            const Icon(
                          Icons.person_rounded,
                          color:
                              Color(0xFF5B4FE9),
                          size: 28,
                        ),
                      ),

                      const SizedBox(
                        width: 13,
                      ),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              userName,
                              maxLines: 1,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                              style:
                                  const TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    FontWeight.bold,
                                color:
                                    Color(
                                  0xFF171A35,
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: 3,
                            ),

                            Text(
                              userEmail.isEmpty
                                  ? 'SkillLink Account'
                                  : userEmail,
                              maxLines: 1,
                              overflow:
                                  TextOverflow
                                      .ellipsis,
                              style:
                                  const TextStyle(
                                fontSize: 11,
                                color:
                                    Color(
                                  0xFF8A8F9F,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  // PROFILE
                  _menuItem(
                    icon:
                        Icons.person_outline_rounded,
                    title: 'My Profile',
                    subtitle:
                        'View your account',
                    onTap: () {
                      Navigator.pop(
                        sheetContext,
                      );

                      _showMessage(
                        'Profile page is not available yet.',
                      );
                    },
                  ),

                  // WALLET
                  _menuItem(
                    icon: Icons
                        .account_balance_wallet_outlined,
                    title:
                        'SkillLink Wallet',
                    subtitle:
                        'Check your wallet balance',
                    onTap: () {
                      Navigator.pop(
                        sheetContext,
                      );

                      openWallet();
                    },
                  ),

                  // BOOKINGS
                  _menuItem(
                    icon: Icons
                        .receipt_long_outlined,
                    title: 'My Bookings',
                    subtitle:
                        'View your booking history',
                    onTap: () {
                      Navigator.pop(
                        sheetContext,
                      );

                      openBookings();
                    },
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  const Divider(),

                  const SizedBox(
                    height: 8,
                  ),

                  // LOGOUT
                  _menuItem(
                    icon:
                        Icons.logout_rounded,
                    title: 'Logout',
                    subtitle:
                        'Sign out of SkillLink',
                    iconColor:
                        const Color(0xFFDC2626),
                    titleColor:
                        const Color(0xFFDC2626),
                    onTap: () {
                      Navigator.pop(
                        sheetContext,
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
  // MENU ITEM
  // ============================================================

  Widget _menuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color iconColor =
        const Color(0xFF5B4FE9),
    Color titleColor =
        const Color(0xFF202337),
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(16),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(
          vertical: 10,
        ),
        child: Row(
          children: [
            Container(
              width: 45,
              height: 45,
              decoration:
                  BoxDecoration(
                color: iconColor
                    .withOpacity(0.10),
                borderRadius:
                    BorderRadius.circular(
                  14,
                ),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 22,
              ),
            ),

            const SizedBox(
              width: 13,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 14,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 3,
                  ),

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
              Icons
                  .chevron_right_rounded,
              color:
                  Color(0xFFB0B4BF),
            ),
          ],
        ),
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
          Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Container(
            constraints:
                BoxConstraints(
              maxHeight:
                  MediaQuery.of(
                    sheetContext,
                  ).size.height *
                  0.75,
            ),
            decoration:
                const BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child:
                SingleChildScrollView(
              padding:
                  const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Notifications',
                          style:
                              TextStyle(
                            fontSize: 21,
                            fontWeight:
                                FontWeight.bold,
                            color:
                                Color(
                              0xFF171A35,
                            ),
                          ),
                        ),
                      ),

                      IconButton(
                        onPressed: () {
                          Navigator.pop(
                            sheetContext,
                          );
                        },
                        icon: const Icon(
                          Icons.close_rounded,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  _notificationItem(
                    icon: Icons
                        .check_circle_rounded,
                    title:
                        'Welcome to SkillLink',
                    message:
                        'Find a service and book it easily.',
                  ),

                  _notificationItem(
                    icon: Icons
                        .local_offer_rounded,
                    title:
                        'Popular services',
                    message:
                        'Explore our available service categories.',
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  const Center(
                    child: Text(
                      'No new notifications',
                      style:
                          TextStyle(
                        color:
                            Color(0xFF8A8F9F),
                        fontSize: 12,
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
  }

  Widget _notificationItem({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),
      padding:
          const EdgeInsets.all(14),
      decoration:
          BoxDecoration(
        color:
            const Color(0xFFF7F7FB),
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration:
                BoxDecoration(
              color:
                  const Color(0xFFEEEAFE),
              borderRadius:
                  BorderRadius.circular(
                13,
              ),
            ),
            child: Icon(
              icon,
              color:
                  const Color(0xFF5B4FE9),
              size: 21,
            ),
          ),

          const SizedBox(
            width: 12,
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
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(
                  height: 4,
                ),

                Text(
                  message,
                  style:
                      const TextStyle(
                    color:
                        Color(0xFF8A8F9F),
                    fontSize: 11,
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
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message,
  ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        behavior:
            SnackBarBehavior.floating,
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
          const Color(0xFFF3F5F9),

      body: Center(
        child: Container(
          width: double.infinity,
          constraints:
              const BoxConstraints(
            maxWidth: 430,
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(),

                Expanded(
                  child:
                      RefreshIndicator(
                    onRefresh:
                        loadServices,
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
                            height: 24,
                          ),

                          _buildSearchBox(),

                          const SizedBox(
                            height: 25,
                          ),

                          _buildCategories(),

                          const SizedBox(
                            height: 28,
                          ),

                          _buildServicesHeader(),

                          const SizedBox(
                            height: 14,
                          ),

                          _buildServices(),
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
            child:
                const Icon(
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
                  CrossAxisAlignment
                      .start,
              children: [
                Text(
                  'SkillLink',
                  style:
                      TextStyle(
                    color:
                        Colors.white,
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                SizedBox(
                  height: 2,
                ),

                Text(
                  'Connect. Book. Get it done.',
                  style:
                      TextStyle(
                    color:
                        Colors.white60,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          GestureDetector(
            onTap:
                _showNotifications,
            child: Container(
              width: 42,
              height: 42,
              decoration:
                  BoxDecoration(
                color: Colors.white
                    .withOpacity(0.08),
                borderRadius:
                    BorderRadius.circular(
                  13,
                ),
              ),
              child:
                  const Icon(
                Icons
                    .notifications_none_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),

          const SizedBox(
            width: 8,
          ),

          GestureDetector(
            onTap:
                showProfileMenu,
            child: Container(
              width: 42,
              height: 42,
              decoration:
                  const BoxDecoration(
                color:
                    Color(0xFFEEEAFE),
                shape:
                    BoxShape.circle,
              ),
              child:
                  const Icon(
                Icons.person_rounded,
                color:
                    Color(0xFF5B4FE9),
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
        Text(
          'Good day, $userName 👋',
          maxLines: 1,
          overflow:
              TextOverflow.ellipsis,
          style:
              const TextStyle(
            color:
                Color(0xFF8A8F9F),
            fontSize: 13,
          ),
        ),

        const SizedBox(
          height: 5,
        ),

        const Text(
          'What service do you need?',
          style:
              TextStyle(
            color:
                Color(0xFF171A35),
            fontSize: 25,
            fontWeight:
                FontWeight.bold,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Widget _buildSearchBox() {
    return Container(
      height: 52,
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          16,
        ),
        border: Border.all(
          color:
              const Color(0xFFE6E8EF),
        ),
      ),
      child: TextField(
        controller:
            _searchController,
        textInputAction:
            TextInputAction.search,
        decoration:
            InputDecoration(
          hintText:
              'Search for services...',
          hintStyle:
              const TextStyle(
            color:
                Color(0xFF9CA3AF),
            fontSize: 13,
          ),
          prefixIcon:
              const Icon(
            Icons.search_rounded,
            color:
                Color(0xFF8A8F9F),
          ),
          suffixIcon:
              _searchController
                      .text
                      .isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController
                            .clear();
                      },
                      icon:
                          const Icon(
                        Icons.close_rounded,
                        size: 19,
                      ),
                    )
                  : null,
          border:
              InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(
            vertical: 15,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CATEGORIES
  // ============================================================

  Widget _buildCategories() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Popular Categories',
          style:
              TextStyle(
            color:
                Color(0xFF171A35),
            fontSize: 18,
            fontWeight:
                FontWeight.bold,
          ),
        ),

        const SizedBox(
          height: 14,
        ),

        SizedBox(
          height: 100,
          child: ListView(
            scrollDirection:
                Axis.horizontal,
            physics:
                const BouncingScrollPhysics(),
            children: [
              // ALL
              _CategoryItem(
                icon:
                    Icons.apps_rounded,
                title: 'All',
                selected:
                    selectedCategory ==
                        'All',
                onTap: () =>
                    _selectCategory(
                  'All',
                ),
              ),

              // SIX REAL CATEGORIES
              ...categories.map(
                (category) {
                  return _CategoryItem(
                    icon:
                        category['icon']
                            as IconData,
                    title:
                        category['name']
                            as String,
                    onTap: () =>
                        _selectCategory(
                      category['name']
                          as String,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SERVICES HEADER
  // ============================================================

  Widget _buildServicesHeader() {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Recommended Services',
            style:
                TextStyle(
              color:
                  Color(0xFF171A35),
              fontSize: 18,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ),

        Text(
          '${filteredServices.length} available',
          style:
              const TextStyle(
            color:
                Color(0xFF5B4FE9),
            fontSize: 12,
            fontWeight:
                FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SERVICES
  // ============================================================

  Widget _buildServices() {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding:
              EdgeInsets.all(40),
          child:
              CircularProgressIndicator(
            color:
                Color(0xFF5B4FE9),
          ),
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding:
              const EdgeInsets.all(30),
          child: Column(
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                size: 45,
                color:
                    Color(0xFF8A8F9F),
              ),

              const SizedBox(
                height: 12,
              ),

              Text(
                errorMessage!,
                style:
                    const TextStyle(
                  color:
                      Color(0xFF686E80),
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              ElevatedButton(
                onPressed:
                    loadServices,
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
                  'Try Again',
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (filteredServices.isEmpty) {
      return Center(
        child: Padding(
          padding:
              const EdgeInsets.all(35),
          child: Column(
            children: [
              const Icon(
                Icons.search_off_rounded,
                size: 48,
                color:
                    Color(0xFF9CA3AF),
              ),

              const SizedBox(
                height: 12,
              ),

              const Text(
                'No services found.',
                style:
                    TextStyle(
                  color:
                      Color(0xFF686E80),
                  fontSize: 14,
                  fontWeight:
                      FontWeight.w600,
                ),
              ),

              const SizedBox(
                height: 6,
              ),

              const Text(
                'Try another search or category.',
                textAlign:
                    TextAlign.center,
                style:
                    TextStyle(
                  color:
                      Color(0xFF9CA3AF),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children:
          filteredServices.map(
        (service) {
          return Padding(
            padding:
                const EdgeInsets.only(
              bottom: 14,
            ),
            child:
                GestureDetector(
              onTap: () async {
                final result =
                    await Navigator.push<
                        bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ServiceDetailsScreen(
                      service:
                          service,
                    ),
                  ),
                );

                if (result == true) {
                  loadServices();
                }
              },
              child:
                  _ServiceCard(
                service:
                    service,
              ),
            ),
          );
        },
      ).toList(),
    );
  }
}

// ============================================================
// CATEGORY ITEM
// ============================================================

class _CategoryItem
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return GestureDetector(
      behavior:
          HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: 90,
        margin:
            const EdgeInsets.only(
          right: 12,
        ),
        child: Column(
          children: [
            AnimatedContainer(
              duration:
                  const Duration(
                milliseconds: 180,
              ),
              width: 56,
              height: 56,
              decoration:
                  BoxDecoration(
                color: selected
                    ? const Color(
                        0xFF5B4FE9,
                      )
                    : const Color(
                        0xFFEEEAFE,
                      ),
                borderRadius:
                    BorderRadius.circular(
                  17,
                ),
                boxShadow:
                    selected
                        ? [
                            BoxShadow(
                              color:
                                  const Color(
                                0xFF5B4FE9,
                              ).withOpacity(
                                0.25,
                              ),
                              blurRadius:
                                  10,
                              offset:
                                  const Offset(
                                0,
                                4,
                              ),
                            ),
                          ]
                        : null,
              ),
              child: Icon(
                icon,
                color: selected
                    ? Colors.white
                    : const Color(
                        0xFF5B4FE9,
                      ),
                size: 25,
              ),
            ),

            const SizedBox(
              height: 7,
            ),

            Text(
              title,
              maxLines: 1,
              overflow:
                  TextOverflow.ellipsis,
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color: selected
                    ? const Color(
                        0xFF5B4FE9,
                      )
                    : const Color(
                        0xFF686E80,
                      ),
                fontSize: 10,
                fontWeight: selected
                    ? FontWeight.bold
                    : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// SERVICE CARD
// ============================================================

class _ServiceCard
    extends StatelessWidget {
  final Service service;

  const _ServiceCard({
    required this.service,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      padding:
          const EdgeInsets.all(14),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(19),
        border: Border.all(
          color:
              const Color(0xFFE6E8EF),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(0.03),
            blurRadius: 10,
            offset:
                const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 82,
            height: 82,
            decoration:
                BoxDecoration(
              gradient:
                  const LinearGradient(
                colors: [
                  Color(0xFF29245C),
                  Color(0xFF5B4FE9),
                ],
                begin:
                    Alignment.topLeft,
                end:
                    Alignment.bottomRight,
              ),
              borderRadius:
                  BorderRadius.circular(
                17,
              ),
            ),
            child:
                const Icon(
              Icons
                  .design_services_rounded,
              color: Colors.white,
              size: 34,
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
                  service.categoryName,
                  maxLines: 1,
                  overflow:
                      TextOverflow
                          .ellipsis,
                  style:
                      const TextStyle(
                    color:
                        Color(0xFF5B4FE9),
                    fontSize: 10,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 5,
                ),

                Text(
                  service.title,
                  maxLines: 2,
                  overflow:
                      TextOverflow
                          .ellipsis,
                  style:
                      const TextStyle(
                    color:
                        Color(0xFF202337),
                    fontSize: 15,
                    fontWeight:
                        FontWeight.bold,
                    height: 1.2,
                  ),
                ),

                const SizedBox(
                  height: 7,
                ),

                Text(
                  service.providerName,
                  maxLines: 1,
                  overflow:
                      TextOverflow
                          .ellipsis,
                  style:
                      const TextStyle(
                    color:
                        Color(0xFF8A8F9F),
                    fontSize: 11,
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color:
                          Color(0xFFFFB800),
                      size: 16,
                    ),

                    const SizedBox(
                      width: 3,
                    ),

                    Text(
                      service.rating
                          .toStringAsFixed(
                        1,
                      ),
                      style:
                          const TextStyle(
                        color:
                            Color(0xFF686E80),
                        fontSize: 11,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),

                    const SizedBox(
                      width: 10,
                    ),

                    const Icon(
                      Icons
                          .access_time_rounded,
                      color:
                          Color(0xFF8A8F9F),
                      size: 15,
                    ),

                    const SizedBox(
                      width: 3,
                    ),

                    Text(
                      '${service.duration} min',
                      style:
                          const TextStyle(
                        color:
                            Color(0xFF686E80),
                        fontSize: 11,
                      ),
                    ),

                    const Spacer(),

                    Text(
                      '\$${service.price.toStringAsFixed(2)}',
                      style:
                          const TextStyle(
                        color:
                            Color(0xFF5B4FE9),
                        fontSize: 15,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}