import 'package:flutter/material.dart';

import '../models/wallet.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({
    super.key,
  });

  @override
  State<WalletScreen> createState() =>
      _WalletScreenState();
}

class _WalletScreenState
    extends State<WalletScreen> {
  Wallet? wallet;

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadWallet();
  }

  Future<void> loadWallet() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final userId =
          await AuthService.getUserId();

      if (userId == null) {
        throw Exception(
          'User is not logged in.',
        );
      }

      final result =
          await ApiService.getWallet(
        userId: userId,
      );

      if (!mounted) return;

      setState(() {
        wallet = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage =
            'Unable to load your SkillLink Wallet.';
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
          'SkillLink Wallet',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            onPressed: loadWallet,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
        ],
      ),

      body: Center(
        child: Container(
          width: double.infinity,
          constraints:
              const BoxConstraints(
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
      return Center(
        child: Padding(
          padding:
              const EdgeInsets.all(30),

          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [
              const Icon(
                Icons.account_balance_wallet_outlined,
                size: 50,
                color: Color(0xFF8A8F9F),
              ),

              const SizedBox(height: 15),

              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF686E80),
                ),
              ),

              const SizedBox(height: 15),

              ElevatedButton(
                onPressed: loadWallet,
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(0xFF5B4FE9),
                  foregroundColor:
                      Colors.white,
                ),
                child:
                    const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    if (wallet == null) {
      return const Center(
        child: Text(
          'Wallet not available.',
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadWallet,
      color: const Color(0xFF5B4FE9),

      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),

        padding:
            const EdgeInsets.all(20),

        children: [
          _buildWalletCard(),

          const SizedBox(height: 25),

          _buildInfoCard(),
        ],
      ),
    );
  }

  Widget _buildWalletCard() {
    return Container(
      padding:
          const EdgeInsets.all(22),

      decoration: BoxDecoration(
        gradient:
            const LinearGradient(
          colors: [
            Color(0xFF171A35),
            Color(0xFF29245C),
            Color(0xFF5B4FE9),
          ],
          begin:
              Alignment.topLeft,
          end:
              Alignment.bottomRight,
        ),

        borderRadius:
            BorderRadius.circular(24),

        boxShadow: [
          BoxShadow(
            color: const Color(
              0xFF5B4FE9,
            ).withOpacity(0.25),
            blurRadius: 20,
            offset:
                const Offset(0, 8),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,

                decoration:
                    BoxDecoration(
                  color: Colors.white
                      .withOpacity(0.12),
                  borderRadius:
                      BorderRadius.circular(
                    15,
                  ),
                ),

                child: const Icon(
                  Icons
                      .account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 25,
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              const Text(
                'SkillLink Wallet',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          const Text(
            'Available Balance',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            '\$${wallet!.balance.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Use your SkillLink Wallet to pay for services.',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding:
          const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),

        border: Border.all(
          color:
              const Color(0xFFE6E8EF),
        ),
      ),

      child: Column(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color:
                Color(0xFF5B4FE9),
            size: 28,
          ),

          const SizedBox(height: 12),

          const Text(
            'About SkillLink Wallet',
            style: TextStyle(
              color:
                  Color(0xFF171A35),
              fontSize: 16,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Your SkillLink Wallet stores your available '
            'balance for paying for services inside the app.',
            textAlign:
                TextAlign.center,
            style: TextStyle(
              color:
                  Color(0xFF8A8F9F),
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}