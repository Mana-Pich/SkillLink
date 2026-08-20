import 'package:flutter/material.dart';

import '../models/service.dart';
import 'service_details_screen.dart';

class CategoryServicesScreen
    extends StatelessWidget {
  final String categoryName;
  final List<Service> services;

  const CategoryServicesScreen({
    super.key,
    required this.categoryName,
    required this.services,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    // ==========================================================
    // FILTER SERVICES BY CATEGORY
    // ==========================================================

    final categoryServices =
        services.where((service) {
      return service.categoryName
              .trim()
              .toLowerCase() ==
          categoryName
              .trim()
              .toLowerCase();
    }).toList();

    return Scaffold(
      backgroundColor:
          const Color(0xFFF3F5F9),

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor:
            const Color(0xFF171A35),
        foregroundColor:
            Colors.white,
        elevation: 0,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
          ),
        ),

        title: Text(
          categoryName,
          style:
              const TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: Center(
        child: Container(
          width: double.infinity,
          constraints:
              const BoxConstraints(
            maxWidth: 430,
          ),
          child:
              categoryServices.isEmpty
                  ? _emptyState()
                  : _buildServices(
                      context,
                      categoryServices,
                    ),
        ),
      ),
    );
  }

  // ============================================================
  // SERVICES
  // ============================================================

  Widget _buildServices(
    BuildContext context,
    List<Service> categoryServices,
  ) {
    return ListView.builder(
      padding:
          const EdgeInsets.fromLTRB(
        20,
        20,
        20,
        30,
      ),
      itemCount:
          categoryServices.length,
      itemBuilder:
          (context, index) {
        final service =
            categoryServices[index];

        return Padding(
          padding:
              const EdgeInsets.only(
            bottom: 14,
          ),
          child:
              GestureDetector(
            behavior:
                HitTestBehavior.opaque,
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ServiceDetailsScreen(
                    service: service,
                  ),
                ),
              );
            },
            child:
                _CategoryServiceCard(
              service: service,
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _emptyState() {
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
              child:
                  const Icon(
                Icons
                    .inventory_2_outlined,
                size: 40,
                color:
                    Color(0xFF5B4FE9),
              ),
            ),

            const SizedBox(
              height: 18,
            ),

            Text(
              'No $categoryName Services',
              textAlign:
                  TextAlign.center,
              style:
                  const TextStyle(
                color:
                    Color(0xFF202337),
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            const Text(
              'There are currently no services available in this category.',
              textAlign:
                  TextAlign.center,
              style:
                  TextStyle(
                color:
                    Color(0xFF8A8F9F),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// CATEGORY SERVICE CARD
// ============================================================

class _CategoryServiceCard
    extends StatelessWidget {
  final Service service;

  const _CategoryServiceCard({
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
          // ====================================================
          // IMAGE
          // ====================================================

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

          // ====================================================
          // SERVICE INFORMATION
          // ====================================================

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                // CATEGORY
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

                // TITLE
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
                  height: 6,
                ),

                // PROVIDER
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

                // BOTTOM INFORMATION
                Row(
                  children: [
                    const Icon(
                      Icons
                          .star_rounded,
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