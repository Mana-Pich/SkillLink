import 'package:flutter/material.dart';

import '../models/service.dart';
import 'booking_screen.dart';

class ServiceDetailsScreen extends StatelessWidget {
  final Service service;

  const ServiceDetailsScreen({
    super.key,
    required this.service,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF171A35),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Service Details',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
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
                  physics:
                      const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      _buildServiceHeader(),

                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            _buildServiceInfo(),

                            const SizedBox(height: 25),

                            _buildProvider(),

                            const SizedBox(height: 25),

                            _buildDescription(),

                            const SizedBox(height: 25),

                            _buildServiceFeatures(),

                            const SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              _buildBottomBookingBar(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceHeader() {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF29245C),
            Color(0xFF5B4FE9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(30),
          ),
          child: const Icon(
            Icons.design_services_rounded,
            color: Colors.white,
            size: 60,
          ),
        ),
      ),
    );
  }

  Widget _buildServiceInfo() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          service.categoryName,
          style: const TextStyle(
            color: Color(0xFF5B4FE9),
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          service.title,
          style: const TextStyle(
            color: Color(0xFF171A35),
            fontSize: 24,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),

        const SizedBox(height: 14),

        Row(
          children: [
            const Icon(
              Icons.star_rounded,
              color: Color(0xFFFFB800),
              size: 20,
            ),

            const SizedBox(width: 5),

            Text(
              service.rating.toStringAsFixed(1),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),

            const SizedBox(width: 15),

            const Icon(
              Icons.access_time_rounded,
              color: Color(0xFF7B8194),
              size: 18,
            ),

            const SizedBox(width: 5),

            Text(
              '${service.duration} minutes',
              style: const TextStyle(
                color: Color(0xFF7B8194),
                fontSize: 13,
              ),
            ),
          ],
        ),

        const SizedBox(height: 18),

        Text(
          '\$${service.price.toStringAsFixed(2)}',
          style: const TextStyle(
            color: Color(0xFF5B4FE9),
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildProvider() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE6E8EF),
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: Color(0xFFEEEAFE),
            child: Icon(
              Icons.person_rounded,
              color: Color(0xFF5B4FE9),
              size: 30,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const Text(
                  'Service Provider',
                  style: TextStyle(
                    color: Color(0xFF8A8F9F),
                    fontSize: 11,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  service.providerName,
                  style: const TextStyle(
                    color: Color(0xFF202337),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 3),

                const Text(
                  'Verified SkillLink Provider',
                  style: TextStyle(
                    color: Color(0xFF5B4FE9),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.verified_rounded,
            color: Color(0xFF5B4FE9),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'About this service',
          style: TextStyle(
            color: Color(0xFF171A35),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          service.description,
          style: const TextStyle(
            color: Color(0xFF686E80),
            fontSize: 14,
            height: 1.6,
          ),
        ),
      ],
    );
  }

  Widget _buildServiceFeatures() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Service Information',
          style: TextStyle(
            color: Color(0xFF171A35),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(
              child: _InfoBox(
                icon: Icons.access_time_rounded,
                title: 'Duration',
                value: '${service.duration} min',
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: _InfoBox(
                icon: Icons.payments_rounded,
                title: 'Starting at',
                value:
                    '\$${service.price.toStringAsFixed(2)}',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomBookingBar(
    BuildContext context,
  ) {
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      BookingScreen(
                    service: service,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  const Color(0xFF5B4FE9),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(15),
              ),
            ),
            child: const Text(
              'Book Now',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoBox({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE6E8EF),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFEEEAFE),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF5B4FE9),
              size: 20,
            ),
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF8A8F9F),
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF202337),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}