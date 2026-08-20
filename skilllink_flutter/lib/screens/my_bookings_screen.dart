import 'package:flutter/material.dart';

import '../services/api_service.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() =>
      _MyBookingsScreenState();
}

class _MyBookingsScreenState
    extends State<MyBookingsScreen> {
  static const int demoUserId = 2;

  List<Map<String, dynamic>> bookings = [];

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadBookings();
  }

  Future<void> loadBookings() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result =
          await ApiService.getBookings(
        userId: demoUserId,
      );

      if (!mounted) return;

      setState(() {
        bookings = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage =
            'Unable to load your bookings.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF3F5F9),
      appBar: AppBar(
        backgroundColor:
            const Color(0xFF171A35),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'My Bookings',
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
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF5B4FE9),
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
      color: const Color(0xFF5B4FE9),
      onRefresh: loadBookings,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [
          _buildHeader(),

          const SizedBox(height: 20),

          ...bookings.map(
            (booking) =>
                _buildBookingCard(booking),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Bookings',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Color(0xFF171A35),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '${bookings.length} booking${bookings.length == 1 ? '' : 's'}',
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF8A8F9F),
          ),
        ),
      ],
    );
  }

  Widget _buildBookingCard(
    Map<String, dynamic> booking,
  ) {
    final service =
        booking['service'] ?? {};

    final payment =
        booking['payment'];

    final String title =
        service['title'] ??
            'Unknown Service';

    final String provider =
        service['provider']?['name'] ??
            'Unknown Provider';

    final String date =
        _formatDate(
      booking['booking_date'],
    );

    final String time =
        booking['booking_time'] ??
            '--:--';

    final String status =
        booking['status'] ??
            'pending';

    final String amount =
        booking['total_amount'] ??
            '0.00';

    return Container(
      margin:
          const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
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
      child: Column(
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color:
                      const Color(0xFFEEEAFE),
                  borderRadius:
                      BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.design_services_rounded,
                  color:
                      Color(0xFF5B4FE9),
                  size: 28,
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
                      maxLines: 2,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight:
                            FontWeight.bold,
                        color:
                            Color(0xFF202337),
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      'Provider: $provider',
                      style: const TextStyle(
                        fontSize: 11,
                        color:
                            Color(0xFF8A8F9F),
                      ),
                    ),

                    const SizedBox(height: 8),

                    _statusBadge(status),
                  ],
                ),
              ),
            ],
          ),

          const Padding(
            padding:
                EdgeInsets.symmetric(
              vertical: 15,
            ),
            child: Divider(
              color: Color(0xFFECEEF3),
            ),
          ),

          _infoRow(
            Icons.calendar_today_rounded,
            'Date',
            date,
          ),

          const SizedBox(height: 10),

          _infoRow(
            Icons.access_time_rounded,
            'Time',
            time,
          ),

          const SizedBox(height: 10),

          _infoRow(
            Icons.payments_outlined,
            'Amount',
            '\$$amount',
          ),

          if (payment != null) ...[
            const SizedBox(height: 10),

            _infoRow(
              Icons.check_circle_outline,
              'Payment',
              payment['status'] ??
                  'unknown',
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color background;
    Color foreground;

    switch (status.toLowerCase()) {
      case 'confirmed':
        background =
            const Color(0xFFE8F8EE);
        foreground =
            const Color(0xFF16A34A);
        break;

      case 'completed':
        background =
            const Color(0xFFE8F8EE);
        foreground =
            const Color(0xFF15803D);
        break;

      case 'cancelled':
        background =
            const Color(0xFFFEECEC);
        foreground =
            const Color(0xFFDC2626);
        break;

      default:
        background =
            const Color(0xFFFFF6E5);
        foreground =
            const Color(0xFFD97706);
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
            BorderRadius.circular(20),
      ),
      child: Text(
        _capitalize(status),
        style: TextStyle(
          color: foreground,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 17,
          color: const Color(0xFF6B7280),
        ),

        const SizedBox(width: 9),

        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF8A8F9F),
          ),
        ),

        const Spacer(),

        Flexible(
          child: Text(
            value,
            textAlign:
                TextAlign.right,
            style: const TextStyle(
              fontSize: 12,
              fontWeight:
                  FontWeight.w600,
              color:
                  Color(0xFF202337),
            ),
          ),
        ),
      ],
    );
  }

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
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color:
                    const Color(0xFFEEEAFE),
                borderRadius:
                    BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.calendar_month_rounded,
                color:
                    Color(0xFF5B4FE9),
                size: 45,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'No Bookings Yet',
              style: TextStyle(
                fontSize: 21,
                fontWeight:
                    FontWeight.bold,
                color:
                    Color(0xFF171A35),
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Your service bookings will '
              'appear here.',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color:
                    Color(0xFF8A8F9F),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

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
              size: 60,
              color:
                  Color(0xFF9CA3AF),
            ),

            const SizedBox(height: 16),

            const Text(
              'Unable to Load Bookings',
              style: TextStyle(
                fontSize: 19,
                fontWeight:
                    FontWeight.bold,
                color:
                    Color(0xFF171A35),
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Please check your connection '
              'and try again.',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color:
                    Color(0xFF8A8F9F),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: loadBookings,
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(0xFF5B4FE9),
                foregroundColor:
                    Colors.white,
                elevation: 0,
              ),
              child:
                  const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic value) {
    if (value == null) {
      return '--';
    }

    try {
      final date =
          DateTime.parse(value.toString());

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

  String _capitalize(String value) {
    if (value.isEmpty) {
      return value;
    }

    return value[0].toUpperCase() +
        value.substring(1);
  }
}