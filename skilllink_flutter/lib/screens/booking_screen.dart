import 'package:flutter/material.dart';

import '../models/service.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'payment_screen.dart';

class BookingScreen extends StatefulWidget {
  final Service service;

  const BookingScreen({
    super.key,
    required this.service,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  bool isLoading = false;

  // ============================================================
  // SELECT DATE
  // ============================================================

  Future<void> selectDate() async {
    final now = DateTime.now();

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now.add(
        const Duration(days: 1),
      ),
      firstDate: now,
      lastDate: now.add(
        const Duration(days: 90),
      ),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // ============================================================
  // SELECT TIME
  // ============================================================

  Future<void> selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(
        hour: 10,
        minute: 0,
      ),
    );

    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  // ============================================================
  // CREATE BOOKING
  // ============================================================

  Future<void> createBooking() async {
    if (selectedDate == null) {
      _showMessage(
        'Please select a booking date.',
      );
      return;
    }

    if (selectedTime == null) {
      _showMessage(
        'Please select a booking time.',
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Get actual logged-in user
      final userId = await AuthService.getUserId();

      if (userId == null) {
        throw Exception(
          'User is not logged in.',
        );
      }

      final booking =
          await ApiService.createBooking(
        userId: userId,
        serviceId: widget.service.id,
        bookingDate: selectedDate!,
        bookingTime: selectedTime!,
        totalAmount: widget.service.price,
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      final int bookingId =
          int.parse(
        booking['id'].toString(),
      );

      // Go to payment
      final paymentCompleted =
          await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) =>
              PaymentScreen(
            bookingId: bookingId,
            service: widget.service,
            amount: widget.service.price,
            bookingDate: selectedDate!,
            bookingTime: selectedTime!,
          ),
        ),
      );

      if (!mounted) return;

      // Payment completed
      if (paymentCompleted == true) {
        Navigator.pop(
          context,
          true,
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      _showMessage(
        e.toString().contains(
              'not logged in',
            )
            ? 'Please log in first.'
            : 'Unable to create booking. '
                'Please make sure Laravel is running.',
      );
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
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
      appBar: AppBar(
        backgroundColor:
            const Color(0xFF171A35),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Book Service',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Container(
          width: double.infinity,
          constraints:
              const BoxConstraints(
            maxWidth: 430,
          ),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics:
                      const BouncingScrollPhysics(),
                  padding:
                      const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      _buildServiceSummary(),

                      const SizedBox(height: 28),

                      const Text(
                        'Choose Date',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                          color:
                              Color(0xFF171A35),
                        ),
                      ),

                      const SizedBox(height: 12),

                      _buildDateSelector(),

                      const SizedBox(height: 25),

                      const Text(
                        'Choose Time',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.bold,
                          color:
                              Color(0xFF171A35),
                        ),
                      ),

                      const SizedBox(height: 12),

                      _buildTimeSelector(),

                      const SizedBox(height: 28),

                      _buildBookingSummary(),

                      const SizedBox(height: 25),
                    ],
                  ),
                ),
              ),

              _buildBottomButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SERVICE SUMMARY
  // ============================================================

  Widget _buildServiceSummary() {
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
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
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
              size: 30,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  widget.service.title,
                  maxLines: 2,
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
                  widget.service.providerName,
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  '\$${widget.service.price.toStringAsFixed(2)}',
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
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DATE
  // ============================================================

  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: selectDate,
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(16),
          border: Border.all(
            color: selectedDate != null
                ? const Color(0xFF5B4FE9)
                : const Color(0xFFE6E8EF),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color:
                    const Color(0xFFEEEAFE),
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.calendar_month_rounded,
                color:
                    Color(0xFF5B4FE9),
              ),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Booking Date',
                    style: TextStyle(
                      fontSize: 11,
                      color:
                          Color(0xFF8A8F9F),
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    selectedDate == null
                        ? 'Select a date'
                        : _formatDate(
                            selectedDate!,
                          ),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          FontWeight.w600,
                      color:
                          selectedDate == null
                              ? const Color(
                                  0xFF8A8F9F,
                                )
                              : const Color(
                                  0xFF202337,
                                ),
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right_rounded,
              color:
                  Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TIME
  // ============================================================

  Widget _buildTimeSelector() {
    return GestureDetector(
      onTap: selectTime,
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(16),
          border: Border.all(
            color: selectedTime != null
                ? const Color(0xFF5B4FE9)
                : const Color(0xFFE6E8EF),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color:
                    const Color(0xFFEEEAFE),
                borderRadius:
                    BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.access_time_rounded,
                color:
                    Color(0xFF5B4FE9),
              ),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Booking Time',
                    style: TextStyle(
                      fontSize: 11,
                      color:
                          Color(0xFF8A8F9F),
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    selectedTime == null
                        ? 'Select a time'
                        : selectedTime!
                            .format(context),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight:
                          FontWeight.w600,
                      color:
                          selectedTime == null
                              ? const Color(
                                  0xFF8A8F9F,
                                )
                              : const Color(
                                  0xFF202337,
                                ),
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.chevron_right_rounded,
              color:
                  Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _buildBookingSummary() {
    return Container(
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color:
            const Color(0xFF171A35),
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Align(
            alignment:
                Alignment.centerLeft,
            child: Text(
              'Booking Summary',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 16),

          _summaryRow(
            'Service',
            widget.service.title,
          ),

          const SizedBox(height: 10),

          _summaryRow(
            'Duration',
            '${widget.service.duration} minutes',
          ),

          const SizedBox(height: 10),

          _summaryRow(
            'Date',
            selectedDate == null
                ? 'Not selected'
                : _formatDate(
                    selectedDate!,
                  ),
          ),

          const SizedBox(height: 10),

          _summaryRow(
            'Time',
            selectedTime == null
                ? 'Not selected'
                : selectedTime!
                    .format(context),
          ),

          const Padding(
            padding:
                EdgeInsets.symmetric(
              vertical: 14,
            ),
            child: Divider(
              color: Colors.white24,
            ),
          ),

          Row(
            mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              Text(
                '\$${widget.service.price.toStringAsFixed(2)}',
                style:
                    const TextStyle(
                  color:
                      Color(0xFF9F95FF),
                  fontSize: 21,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String title,
    String value,
  ) {
    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style:
              const TextStyle(
            color: Colors.white60,
            fontSize: 12,
          ),
        ),

        const Spacer(),

        Flexible(
          child: Text(
            value,
            textAlign:
                TextAlign.right,
            style:
                const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BUTTON
  // ============================================================

  Widget _buildBottomButton() {
    return Container(
      padding:
          const EdgeInsets.fromLTRB(
        20,
        14,
        20,
        14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color:
                Colors.black.withOpacity(
              0.08,
            ),
            blurRadius: 15,
            offset:
                const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed:
                isLoading
                    ? null
                    : createBooking,
            style:
                ElevatedButton.styleFrom(
              backgroundColor:
                  const Color(0xFF5B4FE9),
              foregroundColor:
                  Colors.white,
              disabledBackgroundColor:
                  const Color(
                0xFFB8B4E8,
              ),
              elevation: 0,
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  15,
                ),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child:
                        CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color:
                          Colors.white,
                    ),
                  )
                : const Text(
                    'Continue to Payment',
                    style:
                        TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String _formatDate(
    DateTime date,
  ) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[date.month - 1]} '
        '${date.day}, ${date.year}';
  }
}