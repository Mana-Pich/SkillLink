import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/service.dart';
import '../services/api_service.dart';

class ProviderServicesFormScreen extends StatefulWidget {
  final int providerId;
  final Service? service;

  const ProviderServicesFormScreen({
    super.key,
    required this.providerId,
    this.service,
  });

  @override
  State<ProviderServicesFormScreen> createState() =>
      _ProviderServicesFormScreenState();
}

class _ProviderServicesFormScreenState
    extends State<ProviderServicesFormScreen> {
  static const Color primaryColor = Color(0xFF5B4FE9);
  static const Color darkColor = Color(0xFF171A35);
  static const Color backgroundColor = Color(0xFFF3F5F9);

  final GlobalKey<FormState> _formKey =
      GlobalKey<FormState>();

  final TextEditingController titleController =
      TextEditingController();

  final TextEditingController descriptionController =
      TextEditingController();

  final TextEditingController priceController =
      TextEditingController();

  final TextEditingController durationController =
      TextEditingController();

  final ImagePicker imagePicker = ImagePicker();

  XFile? selectedImage;
  Uint8List? selectedImageBytes;

  int? selectedCategoryId;

  bool isSaving = false;

  bool get isEditing => widget.service != null;

  @override
  void initState() {
    super.initState();

    if (isEditing) {
      final service = widget.service!;

      titleController.text = service.title;
      descriptionController.text = service.description;
      priceController.text = service.price.toString();
      durationController.text = service.duration.toString();

      selectedCategoryId = service.categoryId;
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    durationController.dispose();

    super.dispose();
  }

  // ============================================================
  // PICK IMAGE
  // ============================================================

  Future<void> pickImage() async {
    try {
      final XFile? image =
          await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1200,
        maxHeight: 1200,
      );

      if (image == null) {
        return;
      }

      final Uint8List bytes =
          await image.readAsBytes();

      if (!mounted) {
        return;
      }

      setState(() {
        selectedImage = image;
        selectedImageBytes = bytes;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to select image.',
          ),
        ),
      );
    }
  }

  // ============================================================
  // SAVE SERVICE
  // ============================================================

  Future<void> saveService() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a category.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      return;
    }

    final double? price =
        double.tryParse(
      priceController.text.trim(),
    );

    final int? duration =
        int.tryParse(
      durationController.text.trim(),
    );

    if (price == null || duration == null) {
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      if (isEditing) {
        await ApiService.updateService(
          serviceId: widget.service!.id,
          providerId: widget.providerId,
          categoryId: selectedCategoryId!,
          title: titleController.text.trim(),
          description:
              descriptionController.text.trim(),
          price: price,
          duration: duration,
          image: selectedImage,
        );
      } else {
        await ApiService.createService(
          providerId: widget.providerId,
          categoryId: selectedCategoryId!,
          title: titleController.text.trim(),
          description:
              descriptionController.text.trim(),
          price: price,
          duration: duration,
          image: selectedImage,
        );
      }

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Service updated successfully.'
                : 'Service created successfully.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to save service: $e',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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
        title: Text(
          isEditing
              ? 'Edit Service'
              : 'Add Service',
          style: const TextStyle(
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
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                40,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  _buildImagePicker(),

                  const SizedBox(height: 25),

                  _buildLabel('Service Title'),

                  const SizedBox(height: 7),

                  _buildTextField(
                    controller: titleController,
                    hint: 'e.g. Home Cleaning',
                    icon: Icons.title_rounded,
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Please enter a service title.';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 18),

                  _buildLabel('Category'),

                  const SizedBox(height: 7),

                  _buildCategoryDropdown(),

                  const SizedBox(height: 18),

                  _buildLabel('Description'),

                  const SizedBox(height: 7),

                  _buildTextField(
                    controller:
                        descriptionController,
                    hint:
                        'Describe your service...',
                    icon:
                        Icons.description_outlined,
                    maxLines: 5,
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Please enter a description.';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 18),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Price'),

                            const SizedBox(height: 7),

                            _buildTextField(
                              controller:
                                  priceController,
                              hint: '0.00',
                              icon:
                                  Icons.attach_money_rounded,
                              keyboardType:
                                  const TextInputType
                                      .numberWithOptions(
                                decimal: true,
                              ),
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty) {
                                  return 'Required';
                                }

                                final price =
                                    double.tryParse(
                                  value.trim(),
                                );

                                if (price == null ||
                                    price < 0) {
                                  return 'Invalid price';
                                }

                                return null;
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            _buildLabel(
                              'Duration',
                            ),

                            const SizedBox(height: 7),

                            _buildTextField(
                              controller:
                                  durationController,
                              hint: '60',
                              icon:
                                  Icons.access_time_rounded,
                              keyboardType:
                                  TextInputType.number,
                              validator: (value) {
                                if (value == null ||
                                    value.trim().isEmpty) {
                                  return 'Required';
                                }

                                final duration =
                                    int.tryParse(
                                  value.trim(),
                                );

                                if (duration == null ||
                                    duration <= 0) {
                                  return 'Invalid';
                                }

                                return null;
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed:
                          isSaving
                              ? null
                              : saveService,
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            primaryColor,
                        foregroundColor:
                            Colors.white,
                        disabledBackgroundColor:
                            const Color(0xFFB9B5E8),
                        elevation: 0,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
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
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              isEditing
                                  ? 'Update Service'
                                  : 'Create Service',
                              style:
                                  const TextStyle(
                                fontSize: 15,
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
        ),
      ),
    );
  }

  // ============================================================
  // IMAGE PICKER
  // ============================================================

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Service Image',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: darkColor,
          ),
        ),

        const SizedBox(height: 8),

        GestureDetector(
          onTap: isSaving ? null : pickImage,
          child: Container(
            width: double.infinity,
            height: 190,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFFE1E3EA),
              ),
            ),
            child: _buildImageContent(),
          ),
        ),

        const SizedBox(height: 7),

        const Text(
          'Tap to choose an image from your device.',
          style: TextStyle(
            fontSize: 10.5,
            color: Color(0xFF8A8F9F),
          ),
        ),
      ],
    );
  }

  Widget _buildImageContent() {
    // New image selected
    if (selectedImageBytes != null) {
      return ClipRRect(
        borderRadius:
            BorderRadius.circular(17),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.memory(
              selectedImageBytes!,
              fit: BoxFit.cover,
            ),

            Positioned(
              right: 10,
              top: 10,
              child: _editIcon(),
            ),
          ],
        ),
      );
    }

    // Existing image
    final String? existingImage =
        widget.service?.image;

    if (existingImage != null &&
        existingImage.isNotEmpty) {
      String imageUrl = existingImage;

      if (!imageUrl.startsWith('http')) {
        imageUrl =
            'http://127.0.0.1:8000/storage/$imageUrl';
      }

      return ClipRRect(
        borderRadius:
            BorderRadius.circular(17),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) {
                return _emptyImage();
              },
            ),

            Positioned(
              right: 10,
              top: 10,
              child: _editIcon(),
            ),
          ],
        ),
      );
    }

    return _emptyImage();
  }

  Widget _editIcon() {
    return Container(
      decoration: BoxDecoration(
        color:
            Colors.black.withOpacity(0.55),
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(7),
      child: const Icon(
        Icons.edit_rounded,
        color: Colors.white,
        size: 18,
      ),
    );
  }

  Widget _emptyImage() {
    return Column(
      mainAxisAlignment:
          MainAxisAlignment.center,
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: const Color(0xFFEEEAFE),
            borderRadius:
                BorderRadius.circular(17),
          ),
          child: const Icon(
            Icons.add_photo_alternate_outlined,
            color: primaryColor,
            size: 30,
          ),
        ),

        const SizedBox(height: 12),

        const Text(
          'Add Service Image',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: darkColor,
          ),
        ),

        const SizedBox(height: 4),

        const Text(
          'JPG, PNG or WebP',
          style: TextStyle(
            fontSize: 10,
            color: Color(0xFF8A8F9F),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CATEGORY
  // ============================================================

  Widget _buildCategoryDropdown() {
    const List<Map<String, dynamic>>
        categories = [
      {
        'id': 1,
        'name': 'Cleaning',
      },
      {
        'id': 2,
        'name': 'Plumbing',
      },
      {
        'id': 3,
        'name': 'Electrical',
      },
      {
        'id': 4,
        'name': 'Home Repair',
      },
      {
        'id': 5,
        'name': 'Beauty',
      },
      {
        'id': 6,
        'name': 'Tutoring',
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE1E3EA),
        ),
      ),
      child: DropdownButtonFormField<int>(
        value: selectedCategoryId,
        decoration: const InputDecoration(
          prefixIcon: Icon(
            Icons.category_outlined,
            color: primaryColor,
          ),
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 15,
          ),
        ),
        hint: const Text(
          'Select category',
          style: TextStyle(
            color: Color(0xFF9CA3AF),
            fontSize: 13,
          ),
        ),
        items: categories.map(
          (category) {
            return DropdownMenuItem<int>(
              value: category['id'] as int,
              child: Text(
                category['name'] as String,
              ),
            );
          },
        ).toList(),
        onChanged: isSaving
            ? null
            : (value) {
                setState(() {
                  selectedCategoryId =
                      value;
                });
              },
        validator: (value) {
          if (value == null) {
            return 'Please select a category.';
          }

          return null;
        },
      ),
    );
  }

  // ============================================================
  // LABEL
  // ============================================================

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: darkColor,
      ),
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      enabled: !isSaving,
      style: const TextStyle(
        fontSize: 13,
        color: darkColor,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(0xFF9CA3AF),
          fontSize: 13,
        ),
        prefixIcon: Padding(
          padding: EdgeInsets.only(
            bottom: maxLines > 1 ? 60 : 0,
          ),
          child: Icon(
            icon,
            color: primaryColor,
            size: 20,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFE1E3EA),
          ),
        ),
        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFE1E3EA),
          ),
        ),
        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: primaryColor,
            width: 1.5,
          ),
        ),
        errorBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFDC2626),
          ),
        ),
        focusedErrorBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFDC2626),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}