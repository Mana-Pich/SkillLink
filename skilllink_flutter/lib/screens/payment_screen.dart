import 'package:flutter/material.dart';

import '../models/service.dart';
import '../models/wallet.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

import 'booking_history_screen.dart';

class PaymentScreen extends StatefulWidget {
  final int bookingId;
  final Service service;
  final double amount;
  final DateTime bookingDate;
  final TimeOfDay bookingTime;

  const PaymentScreen({
    super.key,
    required this.bookingId,
    required this.service,
    required this.amount,
    required this.bookingDate,
    required this.bookingTime,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String selectedMethod = 'khqr';

  bool isLoading = false;
  bool isWalletLoading = false;

  Wallet? wallet;

  @override
  void initState() {
    super.initState();
    loadWallet();
  }

  // ============================================================
  // LOAD SKILLINK WALLET
  // ============================================================

  Future<void> loadWallet() async {
    try {
      final userId = await AuthService.getUserId();

      if (userId == null) return;

      if (mounted) {
        setState(() {
          isWalletLoading = true;
        });
      }

      final result = await ApiService.getWallet(
        userId: userId,
      );

      if (!mounted) return;

      setState(() {
        wallet = result;
        isWalletLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isWalletLoading = false;
      });
    }
  }

  // ============================================================
  // PROCESS PAYMENT
  // ============================================================

  Future<void> processPayment() async {
    // Check SkillLink Wallet balance.
    if (selectedMethod == 'skilllink_wallet') {
      if (wallet == null) {
        _showMessage(
          'Unable to load your SkillLink Wallet.',
        );
        return;
      }

      if (wallet!.balance < widget.amount) {
        _showMessage(
          'Insufficient SkillLink Wallet balance.',
        );
        return;
      }
    }

    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      // Backend accepts:
      // khqr
      // card
      // wallet
      //
      // SkillLink Wallet is temporarily sent as wallet.
      final backendMethod =
          selectedMethod == 'skilllink_wallet'
              ? 'wallet'
              : selectedMethod;

      final payment = await ApiService.createPayment(
        bookingId: widget.bookingId,
        paymentMethod: backendMethod,
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      await _showPaymentSuccess(payment);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      _showMessage(
        'Payment failed. Please try again.',
      );
    }
  }

  // ============================================================
  // PAYMENT SUCCESS
  // ============================================================

  Future<void> _showPaymentSuccess(
    Map<String, dynamic> payment,
  ) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 75,
                height: 75,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F8EE),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Color(0xFF22C55E),
                  size: 48,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Payment Successful!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF171A35),
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Your booking has been confirmed.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF686E80),
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 18),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F5F9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    _successRow(
                      'Amount',
                      '\$${widget.amount.toStringAsFixed(2)}',
                    ),

                    const SizedBox(height: 8),

                    _successRow(
                      'Payment',
                      _methodName(selectedMethod),
                    ),

                    const SizedBox(height: 8),

                    _successRow(
                      'Transaction',
                      payment['transaction_id']
                              ?.toString() ??
                          'N/A',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B4FE9),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    // ==========================================================
    // IMPORTANT:
    //
    // After the user presses OK, go directly to Booking History.
    //
    // pushAndRemoveUntil removes:
    // Payment Screen
    // Booking Screen
    // Service Details
    //
    // so the user does NOT return to the old booking screen.
    // ==========================================================

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const BookingHistoryScreen(),
      ),
      (route) => false,
    );
  }

  // ============================================================
  // PAYMENT METHOD NAME
  // ============================================================

  String _methodName(String method) {
    switch (method) {
      case 'card':
        return 'Credit / Debit Card';

      case 'wallet':
        return 'Digital Wallet';

      case 'skilllink_wallet':
        return 'SkillLink Wallet';

      default:
        return 'KHQR';
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
      backgroundColor: const Color(0xFFF3F5F9),

      appBar: AppBar(
        backgroundColor: const Color(0xFF171A35),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Payment',
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
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),

                      const SizedBox(height: 25),

                      _buildBookingCard(),

                      const SizedBox(height: 25),

                      const Text(
                        'Choose Payment Method',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF171A35),
                        ),
                      ),

                      const SizedBox(height: 14),

                      _paymentMethod(
                        method: 'khqr',
                        icon: Icons.qr_code_rounded,
                        title: 'KHQR',
                        subtitle: 'Pay using KHQR',
                      ),

                      const SizedBox(height: 12),

                      _paymentMethod(
                        method: 'card',
                        icon: Icons.credit_card_rounded,
                        title: 'Credit / Debit Card',
                        subtitle: 'Visa, Mastercard',
                      ),

                      const SizedBox(height: 12),

                      _paymentMethod(
                        method: 'wallet',
                        icon: Icons.account_balance_wallet_rounded,
                        title: 'Digital Wallet',
                        subtitle:
                            'Pay from your digital wallet',
                      ),

                      const SizedBox(height: 12),

                      _skillLinkWallet(),

                      const SizedBox(height: 25),

                      _buildSecurityNote(),
                    ],
                  ),
                ),
              ),

              _buildPayButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Secure Checkout',
          style: TextStyle(
            color: Color(0xFF171A35),
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 6),

        const Text(
          'Choose how you want to pay for your booking.',
          style: TextStyle(
            color: Color(0xFF8A8F9F),
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BOOKING CARD
  // ============================================================

  Widget _buildBookingCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF171A35),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFF5B4FE9),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.design_services_rounded,
                  color: Colors.white,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Booking',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 10,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      widget.service.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(
              vertical: 16,
            ),
            child: Divider(
              color: Colors.white24,
            ),
          ),

          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                ),
              ),

              Text(
                '\$${widget.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Color(0xFF9F95FF),
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NORMAL PAYMENT METHOD
  // ============================================================

  Widget _paymentMethod({
    required String method,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final selected = selectedMethod == method;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMethod = method;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 200,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: selected
                ? const Color(0xFF5B4FE9)
                : const Color(0xFFE6E8EF),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFEEEAFE)
                    : const Color(0xFFF3F5F9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: selected
                    ? const Color(0xFF5B4FE9)
                    : const Color(0xFF686E80),
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
                    style: const TextStyle(
                      color: Color(0xFF202337),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF8A8F9F),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: selected
                  ? const Color(0xFF5B4FE9)
                  : const Color(0xFFB0B4BF),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SKILLINK WALLET
  // ============================================================

  Widget _skillLinkWallet() {
    final selected =
        selectedMethod == 'skilllink_wallet';

    final balance = wallet?.balance ?? 0;

    final enoughBalance =
        balance >= widget.amount;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMethod = 'skilllink_wallet';
        });
      },
      child: AnimatedContainer(
        duration: const Duration(
          milliseconds: 200,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: selected
                ? const Color(0xFF5B4FE9)
                : const Color(0xFFE6E8EF),
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFEEEAFE),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                color: Color(0xFF5B4FE9),
              ),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'SkillLink Wallet',
                    style: TextStyle(
                      color: Color(0xFF202337),
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  if (isWalletLoading)
                    const Text(
                      'Loading balance...',
                      style: TextStyle(
                        color: Color(0xFF8A8F9F),
                        fontSize: 11,
                      ),
                    )
                  else
                    Text(
                      'Balance: \$${balance.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: enoughBalance
                            ? const Color(0xFF16A34A)
                            : const Color(0xFFDC2626),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),

            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: selected
                  ? const Color(0xFF5B4FE9)
                  : const Color(0xFFB0B4BF),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SECURITY
  // ============================================================

  Widget _buildSecurityNote() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lock_outline_rounded,
            color: Color(0xFF3B82F6),
            size: 20,
          ),

          SizedBox(width: 10),

          Expanded(
            child: Text(
              'This is a demo payment. No real money '
              'will be charged. The payment will be '
              'recorded as successful for demonstration.',
              style: TextStyle(
                color: Color(0xFF3B5F91),
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PAY BUTTON
  // ============================================================

  Widget _buildPayButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        20,
        14,
        20,
        14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, -4),
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
                isLoading ? null : processPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  const Color(0xFF5B4FE9),
              foregroundColor: Colors.white,
              disabledBackgroundColor:
                  const Color(0xFFB8B4E8),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(15),
              ),
            ),
            child: isLoading
                ? const Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 21,
                        height: 21,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      ),

                      SizedBox(width: 12),

                      Text(
                        'Processing Payment...',
                        style: TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                : Text(
                    'Pay \$${widget.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SUCCESS ROW
  // ============================================================

  Widget _successRow(
    String label,
    String value,
  ) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8A8F9F),
            fontSize: 11,
          ),
        ),

        const Spacer(),

        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Color(0xFF202337),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}