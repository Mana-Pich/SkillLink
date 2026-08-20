import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/auth_service.dart';

import 'home_screen.dart';

class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() =>
      _BookingHistoryScreenState();
}

class _BookingHistoryScreenState
    extends State<BookingHistoryScreen> {
  static const Color primaryColor =
      Color(0xFF5B4FE9);

  static const Color darkColor =
      Color(0xFF171A35);

  static const Color backgroundColor =
      Color(0xFFF3F5F9);

  List<Map<String, dynamic>> bookings = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadBookings();
  }

  // ============================================================
  // LOAD BOOKING HISTORY
  // ============================================================

  Future<void> loadBookings() async {
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      final userId = await AuthService.getUserId();

      if (userId == null) {
        throw Exception('User is not logged in.');
      }

      final result = await ApiService.getBookings(
        userId: userId,
      );

      // ========================================================
      // SHOW ALL CUSTOMER BOOKINGS
      // pending, confirmed, completed, cancelled
      // ========================================================

      final historyBookings =
          List<Map<String, dynamic>>.from(result);

      // ========================================================
      // NEWEST BOOKING FIRST
      // ========================================================

      historyBookings.sort((a, b) {
        final aDate =
            DateTime.tryParse(
              a['booking_date']?.toString() ?? '',
            ) ??
            DateTime(2000);

        final bDate =
            DateTime.tryParse(
              b['booking_date']?.toString() ?? '',
            ) ??
            DateTime(2000);

        return bDate.compareTo(aDate);
      });

      if (!mounted) return;

      setState(() {
        bookings = historyBookings;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage =
            'Unable to load booking history.';
      });
    }
  }

  // ============================================================
  // GO HOME
  // ============================================================

  void goToHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const HomeScreen(),
      ),
      (route) => false,
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
          'Booking History',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            tooltip: 'Home',
            onPressed: goToHome,
            icon: const Icon(
              Icons.home_rounded,
            ),
          ),

          IconButton(
            tooltip: 'Refresh',
            onPressed: loadBookings,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
        ],
      ),

      body: Center(
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(
            maxWidth: 430,
          ),
          child: _buildBody(),
        ),
      ),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: primaryColor,
        ),
      );
    }

    if (errorMessage != null) {
      return _buildError();
    }

    if (bookings.isEmpty) {
      return _buildEmpty();
    }

    return RefreshIndicator(
      onRefresh: loadBookings,
      color: primaryColor,

      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),

        padding: const EdgeInsets.all(20),

        children: [
          _buildHeader(),

          const SizedBox(height: 20),

          ...bookings.map(
            (booking) => Padding(
              padding:
                  const EdgeInsets.only(
                bottom: 14,
              ),
              child:
                  _buildBookingCard(booking),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        const Text(
          'Booking History',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: darkColor,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          '${bookings.length} booking'
          '${bookings.length == 1 ? '' : 's'}',

          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF8A8F9F),
          ),
        ),

        const SizedBox(height: 8),

        const Text(
          'All your bookings and their current status.',
          style: TextStyle(
            fontSize: 11,
            color: Color(0xFF9CA3AF),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BOOKING CARD
  // ============================================================

  Widget _buildBookingCard(
    Map<String, dynamic> booking,
  ) {
    final service =
        booking['service'];

    final serviceTitle =
        service is Map
            ? service['title']
                    ?.toString() ??
                'Service'
            : 'Service';

    final provider =
        service is Map
            ? service['provider']
            : null;

    final providerName =
        provider is Map
            ? provider['name']
                    ?.toString() ??
                'Provider'
            : 'Provider';

    final date =
        _formatDate(
      booking['booking_date'],
    );

    final time =
        booking['booking_time']
                ?.toString() ??
            'Unknown time';

    final amount =
        _parseAmount(
      booking['total_amount'],
    );

    final status =
        booking['status']
                ?.toString()
                .toLowerCase() ??
            'unknown';

    final payment =
        booking['payment'];

    return Container(
      padding:
          const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
            BorderRadius.circular(18),

        border: Border.all(
          color:
              const Color(0xFFE6E8EF),
        ),

        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(
              0.03,
            ),
            blurRadius: 10,
            offset:
                const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        children: [
          // ==================================================
          // TOP
          // ==================================================

          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              Container(
                width: 54,
                height: 54,

                decoration:
                    BoxDecoration(
                  color:
                      const Color(
                    0xFFEEEAFE,
                  ),

                  borderRadius:
                      BorderRadius.circular(
                    15,
                  ),
                ),

                child: const Icon(
                  Icons
                      .design_services_rounded,
                  color:
                      primaryColor,
                  size: 27,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      serviceTitle,

                      maxLines: 2,

                      overflow:
                          TextOverflow.ellipsis,

                      style:
                          const TextStyle(
                        color:
                            Color(
                          0xFF202337,
                        ),
                        fontSize: 14,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      'by $providerName',

                      maxLines: 1,

                      overflow:
                          TextOverflow.ellipsis,

                      style:
                          const TextStyle(
                        color:
                            Color(
                          0xFF8A8F9F,
                        ),
                        fontSize: 11,
                      ),
                    ),

                    const SizedBox(height: 8),

                    _statusBadge(status),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          const Divider(
            color:
                Color(0xFFE6E8EF),
          ),

          const SizedBox(height: 12),

          // ==================================================
          // DATE
          // ==================================================

          _infoRow(
            Icons.calendar_month_rounded,
            'Date',
            date,
          ),

          const SizedBox(height: 10),

          // ==================================================
          // TIME
          // ==================================================

          _infoRow(
            Icons.access_time_rounded,
            'Time',
            time,
          ),

          const SizedBox(height: 10),

          // ==================================================
          // AMOUNT
          // ==================================================

          _infoRow(
            Icons.payments_rounded,
            'Total',
            '\$${amount.toStringAsFixed(2)}',
            valueColor:
                primaryColor,
          ),

          // ==================================================
          // PAYMENT
          // ==================================================

          if (payment is Map) ...[
            const SizedBox(height: 10),

            _infoRow(
              Icons
                  .check_circle_outline_rounded,
              'Payment',
              payment['status']
                      ?.toString() ??
                  'Unknown',
              valueColor:
                  _paymentColor(
                payment['status']
                    ?.toString(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget _infoRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color:
              const Color(0xFF8A8F9F),
        ),

        const SizedBox(width: 10),

        Text(
          label,

          style: const TextStyle(
            color:
                Color(0xFF8A8F9F),
            fontSize: 11,
          ),
        ),

        const Spacer(),

        Flexible(
          child: Text(
            value,

            textAlign:
                TextAlign.right,

            maxLines: 2,

            overflow:
                TextOverflow.ellipsis,

            style: TextStyle(
              color:
                  valueColor ??
                      const Color(
                    0xFF202337,
                  ),
              fontSize: 12,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // STATUS BADGE
  // ============================================================

  Widget _statusBadge(
    String status,
  ) {
    Color background;
    Color foreground;

    switch (status) {
      case 'pending':
        background =
            const Color(0xFFFFF7E6);

        foreground =
            const Color(0xFFD97706);

        break;

      case 'confirmed':
        background =
            const Color(0xFFE8F8EE);

        foreground =
            const Color(0xFF16A34A);

        break;

      case 'completed':
        background =
            const Color(0xFFEFF6FF);

        foreground =
            const Color(0xFF2563EB);

        break;

      case 'cancelled':
        background =
            const Color(0xFFFEECEC);

        foreground =
            const Color(0xFFDC2626);

        break;

      default:
        background =
            const Color(0xFFF3F4F6);

        foreground =
            const Color(0xFF6B7280);
    }

    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),

      decoration: BoxDecoration(
        color: background,

        borderRadius:
            BorderRadius.circular(8),
      ),

      child: Text(
        _capitalize(status),

        style: TextStyle(
          color: foreground,
          fontSize: 8,
          fontWeight:
              FontWeight.bold,
        ),
      ),
    );
  }

  // ============================================================
  // PAYMENT COLOR
  // ============================================================

  Color _paymentColor(
    String? status,
  ) {
    switch (
        status?.toLowerCase()) {
      case 'paid':
        return const Color(
          0xFF16A34A,
        );

      case 'failed':
        return const Color(
          0xFFDC2626,
        );

      default:
        return const Color(
          0xFFD97706,
        );
    }
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Container(
              width: 80,
              height: 80,

              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0xFFEEEAFE,
                ),

                borderRadius:
                    BorderRadius.circular(
                  25,
                ),
              ),

              child: const Icon(
                Icons
                    .receipt_long_rounded,
                color:
                    primaryColor,
                size: 40,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'No Booking History',
              style: TextStyle(
                color: darkColor,
                fontSize: 20,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Your bookings will appear here.',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color:
                    Color(0xFF8A8F9F),
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: 180,
              height: 45,

              child:
                  ElevatedButton.icon(
                onPressed:
                    goToHome,

                icon: const Icon(
                  Icons.home_rounded,
                  size: 19,
                ),

                label: const Text(
                  'Go to Home',
                  style: TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      primaryColor,

                  foregroundColor:
                      Colors.white,

                  elevation: 0,

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      13,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(30),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 50,
              color:
                  Color(0xFF8A8F9F),
            ),

            const SizedBox(height: 15),

            Text(
              errorMessage ??
                  'Something went wrong.',

              textAlign:
                  TextAlign.center,

              style:
                  const TextStyle(
                color:
                    Color(0xFF686E80),
                fontSize: 13,
              ),
            ),

            const SizedBox(height: 15),

            ElevatedButton(
              onPressed:
                  loadBookings,

              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    primaryColor,

                foregroundColor:
                    Colors.white,
              ),

              child:
                  const Text(
                'Try Again',
              ),
            ),

            const SizedBox(height: 10),

            OutlinedButton.icon(
              onPressed:
                  goToHome,

              icon: const Icon(
                Icons.home_rounded,
              ),

              label: const Text(
                'Go to Home',
              ),

              style:
                  OutlinedButton.styleFrom(
                foregroundColor:
                    primaryColor,

                side:
                    const BorderSide(
                  color:
                      primaryColor,
                ),

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDate(dynamic value) {
    if (value == null) {
      return '--';
    }

    try {
      final date =
          DateTime.parse(
        value.toString(),
      );

      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];

      return '${months[date.month - 1]} '
          '${date.day}, ${date.year}';
    } catch (_) {
      return value.toString();
    }
  }

  // ============================================================
  // AMOUNT PARSER
  // ============================================================

  double _parseAmount(
    dynamic value,
  ) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0.0;
  }

  // ============================================================
  // CAPITALIZE
  // ============================================================

  String _capitalize(
    String value,
  ) {
    if (value.isEmpty) {
      return value;
    }

    return value[0].toUpperCase() +
        value.substring(1);
  }
}