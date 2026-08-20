import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../models/service.dart';
import '../models/wallet.dart';

class ApiService {
  static const String baseUrl =
      'http://127.0.0.1:8000/api';

  // ============================================================
  // GET SERVICES
  // ============================================================

  static Future<List<Service>> getServices() async {
    final response = await http.get(
      Uri.parse('$baseUrl/services'),
      headers: {
        'Accept': 'application/json',
      },
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final List data = body['data'];

      return data
          .map(
            (json) => Service.fromJson(
              Map<String, dynamic>.from(json),
            ),
          )
          .toList();
    }

    throw Exception(
      body['message'] ?? 'Failed to load services.',
    );
  }

  // ============================================================
  // CREATE SERVICE
  // ============================================================

  static Future<Service> createService({
    required int providerId,
    required int categoryId,
    required String title,
    required String description,
    required double price,
    required int duration,
    XFile? image,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/services'),
    );

    request.headers['Accept'] =
        'application/json';

    request.fields['category_id'] =
        categoryId.toString();

    request.fields['provider_id'] =
        providerId.toString();

    request.fields['title'] = title;

    request.fields['description'] =
        description;

    request.fields['price'] =
        price.toString();

    request.fields['duration'] =
        duration.toString();

    if (image != null) {
      final bytes =
          await image.readAsBytes();

      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: image.name,
        ),
      );
    }

    final streamedResponse =
        await request.send();

    final response =
        await http.Response.fromStream(
      streamedResponse,
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return Service.fromJson(
        Map<String, dynamic>.from(
          body['data'],
        ),
      );
    }

    throw Exception(
      body['message'] ??
          'Failed to create service.',
    );
  }

  // ============================================================
  // UPDATE SERVICE
  // ============================================================

  static Future<Service> updateService({
    required int serviceId,
    required int providerId,
    required int categoryId,
    required String title,
    required String description,
    required double price,
    required int duration,
    XFile? image,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
        '$baseUrl/services/$serviceId',
      ),
    );

    request.headers['Accept'] =
        'application/json';

    // Laravel method spoofing
    request.fields['_method'] = 'PATCH';

    request.fields['category_id'] =
        categoryId.toString();

    request.fields['provider_id'] =
        providerId.toString();

    request.fields['title'] = title;

    request.fields['description'] =
        description;

    request.fields['price'] =
        price.toString();

    request.fields['duration'] =
        duration.toString();

    if (image != null) {
      final bytes =
          await image.readAsBytes();

      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: image.name,
        ),
      );
    }

    final streamedResponse =
        await request.send();

    final response =
        await http.Response.fromStream(
      streamedResponse,
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Service.fromJson(
        Map<String, dynamic>.from(
          body['data'],
        ),
      );
    }

    throw Exception(
      body['message'] ??
          'Failed to update service.',
    );
  }

  // ============================================================
  // DELETE SERVICE
  // ============================================================

  static Future<void> deleteService({
    required int serviceId,
  }) async {
    final response = await http.delete(
      Uri.parse(
        '$baseUrl/services/$serviceId',
      ),
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return;
    }

    final body = jsonDecode(response.body);

    throw Exception(
      body['message'] ??
          'Failed to delete service.',
    );
  }

  // ============================================================
  // CREATE BOOKING
  // ============================================================

  static Future<Map<String, dynamic>>
      createBooking({
    required int userId,
    required int serviceId,
    required DateTime bookingDate,
    required TimeOfDay bookingTime,
    required double totalAmount,
  }) async {
    final formattedDate =
        '${bookingDate.year.toString().padLeft(4, '0')}-'
        '${bookingDate.month.toString().padLeft(2, '0')}-'
        '${bookingDate.day.toString().padLeft(2, '0')}';

    final formattedTime =
        '${bookingTime.hour.toString().padLeft(2, '0')}:'
        '${bookingTime.minute.toString().padLeft(2, '0')}';

    final response = await http.post(
      Uri.parse('$baseUrl/bookings'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'user_id': userId,
        'service_id': serviceId,
        'booking_date': formattedDate,
        'booking_time': formattedTime,
        'total_amount': totalAmount,
      }),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 201 ||
        response.statusCode == 200) {
      return Map<String, dynamic>.from(
        body['data'],
      );
    }

    throw Exception(
      body['message'] ??
          'Failed to create booking.',
    );
  }

  // ============================================================
  // GET CUSTOMER BOOKINGS
  // ============================================================

  static Future<List<Map<String, dynamic>>>
      getBookings({
    required int userId,
  }) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/bookings?user_id=$userId',
      ),
      headers: {
        'Accept': 'application/json',
      },
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final List data = body['data'];

      return data
          .map(
            (item) => Map<String, dynamic>.from(
              item,
            ),
          )
          .toList();
    }

    throw Exception(
      body['message'] ??
          'Failed to load bookings.',
    );
  }

  // ============================================================
  // CREATE PAYMENT
  // ============================================================

  static Future<Map<String, dynamic>>
      createPayment({
    required int bookingId,
    required String paymentMethod,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/payments'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'booking_id': bookingId,
        'payment_method': paymentMethod,
      }),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 201 ||
        response.statusCode == 200) {
      return Map<String, dynamic>.from(
        body['data'],
      );
    }

    throw Exception(
      body['message'] ??
          'Failed to process payment.',
    );
  }

  // ============================================================
  // GET PROVIDER BOOKINGS
  // ============================================================

  static Future<List<Map<String, dynamic>>>
      getProviderBookings({
    required int providerId,
  }) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/bookings?provider_id=$providerId',
      ),
      headers: {
        'Accept': 'application/json',
      },
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final List data = body['data'];

      return data
          .map(
            (item) => Map<String, dynamic>.from(
              item,
            ),
          )
          .toList();
    }

    throw Exception(
      body['message'] ??
          'Failed to load provider bookings.',
    );
  }

  // ============================================================
  // UPDATE BOOKING STATUS
  // ============================================================

  static Future<Map<String, dynamic>>
      updateBookingStatus({
    required int bookingId,
    required String status,
  }) async {
    final response = await http.patch(
      Uri.parse(
        '$baseUrl/bookings/$bookingId',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'status': status,
      }),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Map<String, dynamic>.from(
        body['data'],
      );
    }

    throw Exception(
      body['message'] ??
          'Failed to update booking.',
    );
  }

  // ============================================================
  // GET SKILL LINK WALLET
  // ============================================================

  static Future<Wallet> getWallet({
    required int userId,
  }) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/users/$userId/wallet',
      ),
      headers: {
        'Accept': 'application/json',
      },
    );

    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return Wallet.fromJson(
        Map<String, dynamic>.from(
          body['data']['wallet'],
        ),
      );
    }

    throw Exception(
      body['message'] ??
          'Failed to load wallet.',
    );
  }
}