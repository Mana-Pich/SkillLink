import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../services/auth_service.dart';

class ProviderBookingsScreen extends StatefulWidget {
  const ProviderBookingsScreen({super.key});

  @override
  State<ProviderBookingsScreen> createState() =>
      _ProviderBookingsScreenState();
}

class _ProviderBookingsScreenState
    extends State<ProviderBookingsScreen> {
  List<Map<String, dynamic>> bookings = [];

  bool isLoading = true;
  String? errorMessage;

  int? providerId;

  @override
  void initState() {
    super.initState();
    loadBookings();
  }

  // ============================================================
  // LOAD BOOKINGS
  // ============================================================

  Future<void> loadBookings() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final userId = await AuthService.getUserId();

      if (userId == null) {
        throw Exception('Provider is not logged in.');
      }

      providerId = userId;

      final result =
          await ApiService.getProviderBookings(
        providerId: userId,
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
            'Unable to load provider bookings.';
      });
    }
  }

  // ============================================================
  // UPDATE STATUS
  // ============================================================

  Future<void> updateStatus(
    Map<String, dynamic> booking,
    String newStatus,
  ) async {
    final bookingId = booking['id'];

    if (bookingId == null) {
      return;
    }

    try {
      await ApiService.updateBookingStatus(
        bookingId: int.parse(
          bookingId.toString(),
        ),
        status: newStatus,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Booking ${_capitalize(newStatus)} successfully.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      await loadBookings();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update booking.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // CONFIRM DIALOG
  // ============================================================

  Future<void> confirmStatusChange(
    Map<String, dynamic> booking,
    String status,
  ) async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            '${_capitalize(status)} Booking?',
          ),
          content: Text(
            'Are you sure you want to mark this booking as $status?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text(
                'No',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(
                  0xFF5B4FE9,
                ),
                foregroundColor:
                    Colors.white,
              ),
              child: const Text(
                'Yes',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await updateStatus(
        booking,
        status,
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF3F5F9),

      appBar: AppBar(
        backgroundColor:
            const Color(0xFF171A35),
        foregroundColor:
            Colors.white,
        elevation: 0,

        title: const Text(
          'Provider Bookings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            onPressed: loadBookings,
            tooltip: 'Refresh',
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
      onRefresh: loadBookings,
      color: const Color(0xFF5B4FE9),

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
                bottom: 16,
              ),
              child:
                  _buildBookingCard(
                booking,
              ),
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
          'Customer Bookings',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Color(0xFF171A35),
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
      ],
    );
  }

  // ============================================================
  // BOOKING CARD
  // ============================================================

  Widget _buildBookingCard(
    Map<String, dynamic> booking,
  ) {
    final customer =
        booking['user'];

    final service =
        booking['service'];

    final customerName =
        customer is Map
            ? customer['name']
                    ?.toString() ??
                'Customer'
            : 'Customer';

    final serviceTitle =
        service is Map
            ? service['title']
                    ?.toString() ??
                'Service'
            : 'Service';

    final date =
        _formatDate(
      booking['booking_date'],
    );

    final time =
        booking['booking_time']
                ?.toString() ??
            '--:--';

    final amount =
        _parseAmount(
      booking['total_amount'],
    );

    final status =
        booking['status']
                ?.toString()
                .toLowerCase() ??
            'pending';

    return Container(
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
                Colors.black.withOpacity(
              0.04,
            ),
            blurRadius: 12,
            offset:
                const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          // ==================================================
          // CUSTOMER
          // ==================================================

          Row(
            children: [
              Container(
                width: 52,
                height: 52,

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
                  Icons.person_rounded,
                  color:
                      Color(0xFF5B4FE9),
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
                      customerName,

                      maxLines: 1,

                      overflow:
                          TextOverflow.ellipsis,

                      style:
                          const TextStyle(
                        fontSize: 15,
                        fontWeight:
                            FontWeight.bold,
                        color:
                            Color(0xFF202337),
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      'Customer',
                      style:
                          const TextStyle(
                        fontSize: 11,
                        color:
                            Color(0xFF8A8F9F),
                      ),
                    ),
                  ],
                ),
              ),

              _statusBadge(status),
            ],
          ),

          const SizedBox(height: 16),

          const Divider(
            color: Color(0xFFE6E8EF),
          ),

          const SizedBox(height: 14),

          // ==================================================
          // SERVICE
          // ==================================================

          _infoRow(
            Icons.design_services_rounded,
            'Service',
            serviceTitle,
          ),

          const SizedBox(height: 11),

          // ==================================================
          // DATE
          // ==================================================

          _infoRow(
            Icons.calendar_month_rounded,
            'Date',
            date,
          ),

          const SizedBox(height: 11),

          // ==================================================
          // TIME
          // ==================================================

          _infoRow(
            Icons.access_time_rounded,
            'Time',
            time,
          ),

          const SizedBox(height: 11),

          // ==================================================
          // AMOUNT
          // ==================================================

          _infoRow(
            Icons.payments_rounded,
            'Total',
            '\$${amount.toStringAsFixed(2)}',
            valueColor:
                const Color(0xFF5B4FE9),
          ),

          const SizedBox(height: 18),

          // ==================================================
          // ACTIONS
          // ==================================================

          _buildActions(
            booking,
            status,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACTION BUTTONS
  // ============================================================

  Widget _buildActions(
    Map<String, dynamic> booking,
    String status,
  ) {
    if (status == 'pending') {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () =>
                  confirmStatusChange(
                booking,
                'cancelled',
              ),
              style:
                  OutlinedButton.styleFrom(
                foregroundColor:
                    const Color(
                  0xFFDC2626,
                ),
                side:
                    const BorderSide(
                  color:
                      Color(0xFFDC2626),
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
              ),
              child: const Text(
                'Cancel',
              ),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: ElevatedButton(
              onPressed: () =>
                  confirmStatusChange(
                booking,
                'confirmed',
              ),
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(
                  0xFF16A34A,
                ),
                foregroundColor:
                    Colors.white,
                elevation: 0,
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),
              ),
              child: const Text(
                'Confirm',
              ),
            ),
          ),
        ],
      );
    }

    if (status == 'confirmed') {
      return SizedBox(
        width: double.infinity,
        height: 46,
        child: ElevatedButton.icon(
          onPressed: () =>
              confirmStatusChange(
            booking,
            'completed',
          ),
          icon: const Icon(
            Icons.check_circle_outline,
          ),
          label: const Text(
            'Mark as Completed',
          ),
          style:
              ElevatedButton.styleFrom(
            backgroundColor:
                const Color(
              0xFF2563EB,
            ),
            foregroundColor:
                Colors.white,
            elevation: 0,
            shape:
                RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(
                12,
              ),
            ),
          ),
        ),
      );
    }

    if (status == 'completed') {
      return _completedMessage();
    }

    if (status == 'cancelled') {
      return _cancelledMessage();
    }

    return const SizedBox.shrink();
  }

  // ============================================================
  // COMPLETED MESSAGE
  // ============================================================

  Widget _completedMessage() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(
        vertical: 12,
      ),

      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius:
            BorderRadius.circular(12),
      ),

      child: const Row(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_rounded,
            color:
                Color(0xFF2563EB),
            size: 18,
          ),

          SizedBox(width: 7),

          Text(
            'Booking Completed',
            style: TextStyle(
              color:
                  Color(0xFF2563EB),
              fontSize: 12,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CANCELLED MESSAGE
  // ============================================================

  Widget _cancelledMessage() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(
        vertical: 12,
      ),

      decoration: BoxDecoration(
        color: const Color(0xFFFEECEC),
        borderRadius:
            BorderRadius.circular(12),
      ),

      child: const Row(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cancel_rounded,
            color:
                Color(0xFFDC2626),
            size: 18,
          ),

          SizedBox(width: 7),

          Text(
            'Booking Cancelled',
            style: TextStyle(
              color:
                  Color(0xFFDC2626),
              fontSize: 12,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
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
          size: 17,
          color:
              const Color(0xFF8A8F9F),
        ),

        const SizedBox(width: 9),

        Text(
          label,
          style:
              const TextStyle(
            fontSize: 11,
            color:
                Color(0xFF8A8F9F),
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
              fontSize: 12,
              fontWeight:
                  FontWeight.bold,
              color:
                  valueColor ??
                      const Color(
                    0xFF202337,
                  ),
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
          fontSize: 9,
          fontWeight:
              FontWeight.bold,
        ),
      ),
    );
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
              width: 90,
              height: 90,

              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0xFFEEEAFE,
                ),
                borderRadius:
                    BorderRadius.circular(
                  30,
                ),
              ),

              child: const Icon(
                Icons.event_note_rounded,
                color:
                    Color(0xFF5B4FE9),
                size: 45,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'No Customer Bookings',
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
              'New bookings from customers '
              'will appear here.',
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
              size: 55,
              color:
                  Color(0xFF8A8F9F),
            ),

            const SizedBox(height: 16),

            Text(
              errorMessage ??
                  'Something went wrong.',

              textAlign:
                  TextAlign.center,

              style:
                  const TextStyle(
                fontSize: 14,
                color:
                    Color(0xFF686E80),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: loadBookings,

              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    const Color(
                  0xFF5B4FE9,
                ),
                foregroundColor:
                    Colors.white,
                elevation: 0,
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

  String _capitalize(String value) {
    if (value.isEmpty) {
      return value;
    }

    return value[0].toUpperCase() +
        value.substring(1);
  }
}