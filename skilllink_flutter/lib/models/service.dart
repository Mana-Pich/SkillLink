class Service {
  final int id;
  final int categoryId;
  final int providerId;
  final String title;
  final String description;
  final double price;
  final int duration;
  final String? image;
  final double rating;
  final String providerName;
  final String categoryName;

  Service({
    required this.id,
    required this.categoryId,
    required this.providerId,
    required this.title,
    required this.description,
    required this.price,
    required this.duration,
    required this.image,
    required this.rating,
    required this.providerName,
    required this.categoryName,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] ?? 0,
      categoryId: json['category_id'] ?? 0,
      providerId: json['provider_id'] ?? 0,

      title: json['title'] ?? '',

      description: json['description'] ?? '',

      price: double.tryParse(
            json['price']?.toString() ?? '',
          ) ??
          0.0,

      duration: int.tryParse(
            json['duration']?.toString() ?? '',
          ) ??
          0,

      image: json['image'],

      rating: double.tryParse(
            json['rating']?.toString() ?? '',
          ) ??
          0.0,

      providerName:
          json['provider']?['name'] ?? 'Unknown Provider',

      categoryName:
          json['category']?['name'] ?? 'Other',
    );
  }
}