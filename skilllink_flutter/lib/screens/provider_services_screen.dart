import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/service.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class ProviderServicesScreen extends StatefulWidget {
  const ProviderServicesScreen({
    super.key,
  });

  @override
  State<ProviderServicesScreen> createState() =>
      _ProviderServicesScreenState();
}

class _ProviderServicesScreenState
    extends State<ProviderServicesScreen> {
  // ============================================================
  // COLORS
  // ============================================================

  static const Color primaryColor =
      Color(0xFF5B4FE9);

  static const Color darkColor =
      Color(0xFF171A35);

  static const Color backgroundColor =
      Color(0xFFF3F5F9);

  // ============================================================
  // DATA
  // ============================================================

  List<Service> services = [];

  bool isLoading = true;
  String? errorMessage;

  int? providerId;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();
    loadServices();
  }

  // ============================================================
  // LOAD SERVICES
  // ============================================================

  Future<void> loadServices() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final userId =
          await AuthService.getUserId();

      if (userId == null) {
        throw Exception(
          'Provider is not logged in.',
        );
      }

      providerId = userId;

      final allServices =
          await ApiService.getServices();

      if (!mounted) return;

      setState(() {
        services = allServices
            .where(
              (service) =>
                  service.providerId == userId,
            )
            .toList();

        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage =
            'Unable to load your services.';
      });
    }
  }

  // ============================================================
  // ADD SERVICE
  // ============================================================

  Future<void> addService() async {
    if (providerId == null) {
      final userId =
          await AuthService.getUserId();

      if (userId == null) {
        _showMessage(
          'Please login again.',
        );
        return;
      }

      providerId = userId;
    }

    await _showServiceForm();
  }

  // ============================================================
  // EDIT SERVICE
  // ============================================================

  Future<void> editService(
    Service service,
  ) async {
    await _showServiceForm(
      service: service,
    );
  }

  // ============================================================
  // SERVICE FORM
  // ============================================================

  Future<void> _showServiceForm({
    Service? service,
  }) async {
    final isEditing = service != null;

    final titleController =
        TextEditingController(
      text: service?.title ?? '',
    );

    final descriptionController =
        TextEditingController(
      text: service?.description ?? '',
    );

    final priceController =
        TextEditingController(
      text: service != null
          ? service.price.toString()
          : '',
    );

    final durationController =
        TextEditingController(
      text: service != null
          ? service.duration.toString()
          : '',
    );

    // Category ID is required by your API.
    //
    // If your existing database uses another category,
    // change this value.
    final categoryController =
        TextEditingController(
      text: '1',
    );

    XFile? selectedImage;

    bool isSaving = false;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (
            context,
            setSheetState,
          ) {
            return Container(
              constraints:
                  BoxConstraints(
                maxHeight:
                    MediaQuery.of(context)
                            .size
                            .height *
                        0.92,
              ),
              decoration:
                  const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // ==================================================
                    // TOP BAR
                    // ==================================================

                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(
                        20,
                        16,
                        12,
                        10,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              isEditing
                                  ? 'Edit Service'
                                  : 'Add Service',
                              style:
                                  const TextStyle(
                                color:
                                    darkColor,
                                fontSize: 21,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),

                          IconButton(
                            onPressed:
                                isSaving
                                    ? null
                                    : () {
                                        Navigator.pop(
                                          sheetContext,
                                        );
                                      },
                            icon:
                                const Icon(
                              Icons
                                  .close_rounded,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Divider(
                      height: 1,
                      color:
                          Color(0xFFE6E8EF),
                    ),

                    // ==================================================
                    // FORM
                    // ==================================================

                    Expanded(
                      child:
                          SingleChildScrollView(
                        padding:
                            const EdgeInsets
                                .fromLTRB(
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
                            // ==================================================
                            // IMAGE
                            // ==================================================

                            const Text(
                              'Service Image',
                              style:
                                  TextStyle(
                                color:
                                    darkColor,
                                fontSize: 13,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(
                              height: 10,
                            ),

                            GestureDetector(
                              onTap:
                                  isSaving
                                      ? null
                                      : () async {
                                          final picker =
                                              ImagePicker();

                                          final image =
                                              await picker.pickImage(
                                            source:
                                                ImageSource
                                                    .gallery,
                                            imageQuality:
                                                80,
                                          );

                                          if (image !=
                                              null) {
                                            setSheetState(
                                              () {
                                                selectedImage =
                                                    image;
                                              },
                                            );
                                          }
                                        },
                              child:
                                  _buildImagePicker(
                                service,
                                selectedImage,
                              ),
                            ),

                            const SizedBox(
                              height: 20,
                            ),

                            // ==================================================
                            // TITLE
                            // ==================================================

                            _buildTextField(
                              controller:
                                  titleController,
                              label:
                                  'Service Title',
                              hint:
                                  'e.g. Web Design',
                              icon:
                                  Icons.title_rounded,
                            ),

                            const SizedBox(
                              height: 15,
                            ),

                            // ==================================================
                            // DESCRIPTION
                            // ==================================================

                            _buildTextField(
                              controller:
                                  descriptionController,
                              label:
                                  'Description',
                              hint:
                                  'Describe your service...',
                              icon:
                                  Icons
                                      .description_outlined,
                              maxLines: 4,
                            ),

                            const SizedBox(
                              height: 15,
                            ),

                            // ==================================================
                            // CATEGORY
                            // ==================================================

                            _buildTextField(
                              controller:
                                  categoryController,
                              label:
                                  'Category ID',
                              hint:
                                  'e.g. 1',
                              icon:
                                  Icons
                                      .category_outlined,
                              keyboardType:
                                  TextInputType
                                      .number,
                            ),

                            const SizedBox(
                              height: 15,
                            ),

                            // ==================================================
                            // PRICE + DURATION
                            // ==================================================

                            Row(
                              children: [
                                Expanded(
                                  child:
                                      _buildTextField(
                                    controller:
                                        priceController,
                                    label:
                                        'Price',
                                    hint:
                                        '0.00',
                                    icon:
                                        Icons
                                            .attach_money_rounded,
                                    keyboardType:
                                        const TextInputType
                                            .numberWithOptions(
                                      decimal:
                                          true,
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                  width: 12,
                                ),

                                Expanded(
                                  child:
                                      _buildTextField(
                                    controller:
                                        durationController,
                                    label:
                                        'Duration',
                                    hint:
                                        '60',
                                    icon:
                                        Icons
                                            .access_time_rounded,
                                    keyboardType:
                                        TextInputType
                                            .number,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(
                              height: 25,
                            ),

                            // ==================================================
                            // SAVE BUTTON
                            // ==================================================

                            SizedBox(
                              width:
                                  double.infinity,
                              height: 52,
                              child:
                                  ElevatedButton(
                                onPressed:
                                    isSaving
                                        ? null
                                        : () async {
                                            // --------------------------------
                                            // VALIDATE
                                            // --------------------------------

                                            final title =
                                                titleController
                                                    .text
                                                    .trim();

                                            final description =
                                                descriptionController
                                                    .text
                                                    .trim();

                                            final categoryId =
                                                int.tryParse(
                                              categoryController
                                                  .text
                                                  .trim(),
                                            );

                                            final price =
                                                double.tryParse(
                                              priceController
                                                  .text
                                                  .trim(),
                                            );

                                            final duration =
                                                int.tryParse(
                                              durationController
                                                  .text
                                                  .trim(),
                                            );

                                            if (title
                                                    .isEmpty ||
                                                description
                                                    .isEmpty ||
                                                categoryId ==
                                                    null ||
                                                price ==
                                                    null ||
                                                duration ==
                                                    null) {
                                              ScaffoldMessenger
                                                  .of(
                                                sheetContext,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content:
                                                      Text(
                                                    'Please fill in all fields correctly.',
                                                  ),
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                ),
                                              );

                                              return;
                                            }

                                            if (providerId ==
                                                null) {
                                              ScaffoldMessenger
                                                  .of(
                                                sheetContext,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content:
                                                      Text(
                                                    'Provider account not found.',
                                                  ),
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                ),
                                              );

                                              return;
                                            }

                                            // --------------------------------
                                            // START SAVING
                                            // --------------------------------

                                            setSheetState(
                                              () {
                                                isSaving =
                                                    true;
                                              },
                                            );

                                            try {
                                              if (isEditing) {
                                                await ApiService
                                                    .updateService(
                                                  serviceId:
                                                      service!
                                                          .id,
                                                  providerId:
                                                      providerId!,
                                                  categoryId:
                                                      categoryId,
                                                  title:
                                                      title,
                                                  description:
                                                      description,
                                                  price:
                                                      price,
                                                  duration:
                                                      duration,
                                                  image:
                                                      selectedImage,
                                                );
                                              } else {
                                                await ApiService
                                                    .createService(
                                                  providerId:
                                                      providerId!,
                                                  categoryId:
                                                      categoryId,
                                                  title:
                                                      title,
                                                  description:
                                                      description,
                                                  price:
                                                      price,
                                                  duration:
                                                      duration,
                                                  image:
                                                      selectedImage,
                                                );
                                              }

                                              if (!mounted) {
                                                return;
                                              }

                                              Navigator.pop(
                                                sheetContext,
                                              );

                                              _showMessage(
                                                isEditing
                                                    ? 'Service updated successfully.'
                                                    : 'Service created successfully.',
                                              );

                                              await loadServices();
                                            } catch (e) {
                                              if (!mounted) {
                                                return;
                                              }

                                              setSheetState(
                                                () {
                                                  isSaving =
                                                      false;
                                                },
                                              );

                                              ScaffoldMessenger
                                                  .of(
                                                sheetContext,
                                              ).showSnackBar(
                                                SnackBar(
                                                  content:
                                                      Text(
                                                    'Failed to save service: $e',
                                                  ),
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                ),
                                              );
                                            }
                                          },
                                style:
                                    ElevatedButton
                                        .styleFrom(
                                  backgroundColor:
                                      primaryColor,
                                  foregroundColor:
                                      Colors.white,
                                  elevation: 0,
                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      14,
                                    ),
                                  ),
                                ),
                                child: isSaving
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child:
                                            CircularProgressIndicator(
                                          strokeWidth:
                                              2.5,
                                          color:
                                              Colors.white,
                                        ),
                                      )
                                    : Text(
                                        isEditing
                                            ? 'Update Service'
                                            : 'Create Service',
                                        style:
                                            const TextStyle(
                                          fontWeight:
                                              FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    titleController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    durationController.dispose();
    categoryController.dispose();
  }

  // ============================================================
  // IMAGE PICKER
  // ============================================================

  Widget _buildImagePicker(
    Service? service,
    XFile? selectedImage,
  ) {
    if (selectedImage != null) {
      return ClipRRect(
        borderRadius:
            BorderRadius.circular(18),
        child: Image.network(
          selectedImage.path,
          width: double.infinity,
          height: 160,
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) {
            return _imagePlaceholder(
              selectedImage.name,
            );
          },
        ),
      );
    }

    if (service != null &&
        service.image != null &&
        service.image!.isNotEmpty) {
      String imageUrl =
          service.image!;

      if (!imageUrl.startsWith('http')) {
        imageUrl =
            'http://127.0.0.1:8000/storage/$imageUrl';
      }

      return ClipRRect(
        borderRadius:
            BorderRadius.circular(18),
        child: Image.network(
          imageUrl,
          width: double.infinity,
          height: 160,
          fit: BoxFit.cover,
          errorBuilder:
              (context, error, stackTrace) {
            return _imagePlaceholder(
              'Current image',
            );
          },
        ),
      );
    }

    return _imagePlaceholder(
      'Tap to select an image',
    );
  }

  Widget _imagePlaceholder(
    String text,
  ) {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        color: const Color(0xFFEEEAFE),
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFDCD8FA),
        ),
      ),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          const Icon(
            Icons
                .add_photo_alternate_outlined,
            color: primaryColor,
            size: 42,
          ),
          const SizedBox(height: 10),
          Text(
            text,
            style: const TextStyle(
              color: primaryColor,
              fontSize: 12,
              fontWeight:
                  FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _buildTextField({
    required TextEditingController
        controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: darkColor,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration:
              InputDecoration(
            hintText: hint,
            prefixIcon: Icon(
              icon,
              color: primaryColor,
              size: 20,
            ),
            filled: true,
            fillColor:
                const Color(0xFFF7F8FB),
            border:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                13,
              ),
              borderSide:
                  const BorderSide(
                color: Color(0xFFE6E8EF),
              ),
            ),
            enabledBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                13,
              ),
              borderSide:
                  const BorderSide(
                color: Color(0xFFE6E8EF),
              ),
            ),
            focusedBorder:
                OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(
                13,
              ),
              borderSide:
                  const BorderSide(
                color: primaryColor,
                width: 1.5,
              ),
            ),
            hintStyle:
                const TextStyle(
              color: Color(0xFFB0B4BF),
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DELETE SERVICE
  // ============================================================

  Future<void> deleteService(
    Service service,
  ) async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete Service',
            style: TextStyle(
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          content: Text(
            'Are you sure you want to delete "${service.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child:
                  const Text('Cancel'),
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
                  0xFFDC2626,
                ),
                foregroundColor:
                    Colors.white,
              ),
              child:
                  const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await ApiService.deleteService(
        serviceId: service.id,
      );

      if (!mounted) return;

      _showMessage(
        'Service deleted successfully.',
      );

      await loadServices();
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'Failed to delete service.',
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          backgroundColor,

      appBar: AppBar(
        backgroundColor:
            darkColor,
        foregroundColor:
            Colors.white,
        elevation: 0,

        title: const Text(
          'My Services',
          style: TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            onPressed:
                loadServices,
            tooltip: 'Refresh',
            icon: const Icon(
              Icons
                  .refresh_rounded,
            ),
          ),
        ],
      ),

      floatingActionButton:
          FloatingActionButton(
        onPressed:
            isLoading
                ? null
                : addService,
        backgroundColor:
            primaryColor,
        child: const Icon(
          Icons.add_rounded,
          color: Colors.white,
        ),
      ),

      body: Center(
        child: Container(
          width:
              double.infinity,
          constraints:
              const BoxConstraints(
            maxWidth: 430,
          ),
          child:
              _buildBody(),
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
        child:
            CircularProgressIndicator(
          color:
              primaryColor,
        ),
      );
    }

    if (errorMessage != null) {
      return _buildError();
    }

    if (services.isEmpty) {
      return _buildEmpty();
    }

    return RefreshIndicator(
      color: primaryColor,
      onRefresh:
          loadServices,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        padding:
            const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              const Expanded(
                child:
                    Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Services',
                      style:
                          TextStyle(
                        fontSize: 24,
                        fontWeight:
                            FontWeight.bold,
                        color:
                            darkColor,
                      ),
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    Text(
                      'Manage the services you provide.',
                      style:
                          TextStyle(
                        fontSize: 13,
                        color:
                            Color(0xFF8A8F9F),
                      ),
                    ),
                  ],
                ),
              ),

              _serviceCount(),
            ],
          ),

          const SizedBox(
            height: 22,
          ),

          ...services.map(
            (service) =>
                _buildServiceCard(
              service,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SERVICE COUNT
  // ============================================================

  Widget _serviceCount() {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration:
          BoxDecoration(
        color:
            const Color(0xFFEEEAFE),
        borderRadius:
            BorderRadius.circular(
          20,
        ),
      ),
      child: Text(
        '${services.length} service${services.length == 1 ? '' : 's'}',
        style:
            const TextStyle(
          color:
              primaryColor,
          fontWeight:
              FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  // ============================================================
  // SERVICE CARD
  // ============================================================

  Widget _buildServiceCard(
    Service service,
  ) {
    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 16,
      ),
      padding:
          const EdgeInsets.all(17),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          20,
        ),
        border: Border.all(
          color:
              const Color(0xFFE6E8EF),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(
              0.03,
            ),
            blurRadius: 10,
            offset:
                const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              _buildServiceImage(
                service,
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
                      service.title,
                      maxLines: 2,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style:
                          const TextStyle(
                        fontSize: 15,
                        fontWeight:
                            FontWeight.bold,
                        color:
                            Color(0xFF202337),
                      ),
                    ),

                    const SizedBox(
                      height: 6,
                    ),

                    Text(
                      service.description,
                      maxLines: 2,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style:
                          const TextStyle(
                        fontSize: 11,
                        height: 1.4,
                        color:
                            Color(0xFF8A8F9F),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 16,
          ),

          const Divider(
            color:
                Color(0xFFECEEF3),
          ),

          const SizedBox(
            height: 12,
          ),

          Row(
            children: [
              _infoItem(
                Icons
                    .attach_money_rounded,
                '\$${service.price.toStringAsFixed(2)}',
              ),

              const SizedBox(
                width: 18,
              ),

              _infoItem(
                Icons
                    .access_time_rounded,
                '${service.duration} min',
              ),

              const SizedBox(
                width: 18,
              ),

              _infoItem(
                Icons.star_rounded,
                service.rating
                    .toStringAsFixed(
                  1,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 15,
          ),

          // EDIT + VIEW

          Row(
            children: [
              Expanded(
                child:
                    OutlinedButton
                        .icon(
                  onPressed: () {
                    editService(
                      service,
                    );
                  },
                  icon:
                      const Icon(
                    Icons
                        .edit_rounded,
                    size: 16,
                  ),
                  label:
                      const Text(
                    'Edit',
                  ),
                  style:
                      OutlinedButton
                          .styleFrom(
                    foregroundColor:
                        primaryColor,
                    side:
                        const BorderSide(
                      color:
                          Color(0xFFDCD8FA),
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        12,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              Expanded(
                child:
                    OutlinedButton
                        .icon(
                  onPressed: () {
                    _showServiceDetails(
                      service,
                    );
                  },
                  icon:
                      const Icon(
                    Icons
                        .visibility_rounded,
                    size: 16,
                  ),
                  label:
                      const Text(
                    'View',
                  ),
                  style:
                      OutlinedButton
                          .styleFrom(
                    foregroundColor:
                        const Color(
                      0xFF374151,
                    ),
                    side:
                        const BorderSide(
                      color:
                          Color(0xFFE5E7EB),
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius
                              .circular(
                        12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 10,
          ),

          // DELETE

          SizedBox(
            width:
                double.infinity,
            child:
                OutlinedButton
                    .icon(
              onPressed: () {
                deleteService(
                  service,
                );
              },
              icon:
                  const Icon(
                Icons
                    .delete_outline_rounded,
                size: 17,
              ),
              label:
                  const Text(
                'Delete Service',
              ),
              style:
                  OutlinedButton
                      .styleFrom(
                foregroundColor:
                    Colors.red,
                side:
                    const BorderSide(
                  color:
                      Color(0xFFFECACA),
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius
                          .circular(
                    12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SERVICE IMAGE
  // ============================================================

  Widget _buildServiceImage(
    Service service,
  ) {
    final image =
        service.image;

    if (image != null &&
        image.isNotEmpty) {
      String imageUrl =
          image;

      if (!imageUrl
          .startsWith('http')) {
        imageUrl =
            'http://127.0.0.1:8000/storage/$imageUrl';
      }

      return ClipRRect(
        borderRadius:
            BorderRadius.circular(
          16,
        ),
        child:
            Image.network(
          imageUrl,
          width: 65,
          height: 65,
          fit: BoxFit.cover,
          errorBuilder:
              (
            context,
            error,
            stackTrace,
          ) {
            return _defaultServiceIcon();
          },
        ),
      );
    }

    return _defaultServiceIcon();
  }

  Widget _defaultServiceIcon() {
    return Container(
      width: 65,
      height: 65,
      decoration:
          BoxDecoration(
        color:
            const Color(0xFFEEEAFE),
        borderRadius:
            BorderRadius.circular(
          16,
        ),
      ),
      child: const Icon(
        Icons
            .design_services_rounded,
        color:
            primaryColor,
        size: 28,
      ),
    );
  }

  // ============================================================
  // INFO ITEM
  // ============================================================

  Widget _infoItem(
    IconData icon,
    String text,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color:
              primaryColor,
        ),
        const SizedBox(
          width: 4,
        ),
        Text(
          text,
          style:
              const TextStyle(
            fontSize: 11,
            fontWeight:
                FontWeight.w600,
            color:
                Color(0xFF4B5563),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmpty() {
    return RefreshIndicator(
      color:
          primaryColor,
      onRefresh:
          loadServices,
      child: ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height:
                MediaQuery.of(context)
                        .size
                        .height *
                    0.65,
            child: Center(
              child: Padding(
                padding:
                    const EdgeInsets
                        .all(30),
                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .center,
                  children: [
                    const Icon(
                      Icons
                          .design_services_outlined,
                      size: 65,
                      color:
                          Color(0xFF9CA3AF),
                    ),

                    const SizedBox(
                      height: 18,
                    ),

                    const Text(
                      'No Services Yet',
                      style:
                          TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
                        color:
                            darkColor,
                      ),
                    ),

                    const SizedBox(
                      height: 8,
                    ),

                    const Text(
                      'Create your first service to '
                      'start receiving bookings.',
                      textAlign:
                          TextAlign.center,
                      style:
                          TextStyle(
                        fontSize: 13,
                        color:
                            Color(0xFF8A8F9F),
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    ElevatedButton
                        .icon(
                      onPressed:
                          addService,
                      icon:
                          const Icon(
                        Icons.add,
                      ),
                      label:
                          const Text(
                        'Add Service',
                      ),
                      style:
                          ElevatedButton
                              .styleFrom(
                        backgroundColor:
                            primaryColor,
                        foregroundColor:
                            Colors.white,
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
            const EdgeInsets.all(
          30,
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment
                  .center,
          children: [
            const Icon(
              Icons
                  .cloud_off_rounded,
              size: 60,
              color:
                  Color(0xFF9CA3AF),
            ),

            const SizedBox(
              height: 15,
            ),

            const Text(
              'Unable to Load Services',
              style:
                  TextStyle(
                fontSize: 19,
                fontWeight:
                    FontWeight.bold,
                color:
                    darkColor,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            const Text(
              'Please check your connection '
              'and try again.',
              textAlign:
                  TextAlign.center,
              style:
                  TextStyle(
                fontSize: 13,
                color:
                    Color(0xFF8A8F9F),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            ElevatedButton(
              onPressed:
                  loadServices,
              style:
                  ElevatedButton
                      .styleFrom(
                backgroundColor:
                    primaryColor,
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
  // VIEW SERVICE DETAILS
  // ============================================================

  void _showServiceDetails(
    Service service,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true,
      backgroundColor:
          Colors.transparent,
      builder: (context) {
        return Container(
          padding:
              const EdgeInsets.all(
            24,
          ),
          decoration:
              const BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.vertical(
              top:
                  Radius.circular(
                25,
              ),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
              children: [
                Center(
                  child:
                      Container(
                    width: 40,
                    height: 4,
                    decoration:
                        BoxDecoration(
                      color:
                          const Color(
                        0xFFD1D5DB,
                      ),
                      borderRadius:
                          BorderRadius
                              .circular(
                        10,
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                Text(
                  service.title,
                  style:
                      const TextStyle(
                    fontSize: 22,
                    fontWeight:
                        FontWeight.bold,
                    color:
                        darkColor,
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                Text(
                  service.description,
                  style:
                      const TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color:
                        Color(0xFF6B7280),
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),

                Row(
                  children: [
                    _detailItem(
                      'Price',
                      '\$${service.price.toStringAsFixed(2)}',
                    ),
                    _detailItem(
                      'Duration',
                      '${service.duration} min',
                    ),
                    _detailItem(
                      'Rating',
                      service.rating
                          .toStringAsFixed(
                        1,
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 20,
                ),

                SizedBox(
                  width:
                      double.infinity,
                  child:
                      ElevatedButton(
                    onPressed:
                        () {
                      Navigator.pop(
                        context,
                      );
                    },
                    style:
                        ElevatedButton
                            .styleFrom(
                      backgroundColor:
                          primaryColor,
                      foregroundColor:
                          Colors.white,
                      elevation: 0,
                      padding:
                          const EdgeInsets
                              .symmetric(
                        vertical: 14,
                      ),
                    ),
                    child:
                        const Text(
                      'Close',
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
  // DETAIL ITEM
  // ============================================================

  Widget _detailItem(
    String title,
    String value,
  ) {
    return Expanded(
      child: Column(
        children: [
          Text(
            title,
            style:
                const TextStyle(
              fontSize: 11,
              color:
                  Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            value,
            style:
                const TextStyle(
              fontSize: 14,
              fontWeight:
                  FontWeight.bold,
              color:
                  darkColor,
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
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(
      SnackBar(
        content:
            Text(message),
        behavior:
            SnackBarBehavior
                .floating,
      ),
    );
  }
}