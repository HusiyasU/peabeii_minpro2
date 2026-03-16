import 'dart:typed_data';

class Car {
  final String? id;
  final String name;
  final String color;
  final String price;
  final String? imageUrl;       // URL dari Supabase Storage
  final Uint8List? imageBytes;  // Untuk preview lokal sebelum upload
  final String? userId;
  final DateTime? createdAt;

  const Car({
    this.id,
    required this.name,
    required this.color,
    required this.price,
    this.imageUrl,
    this.imageBytes,
    this.userId,
    this.createdAt,
  });

  /// Dari JSON Supabase
  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id:        json['id'] as String?,
      name:      json['name'] as String? ?? '',
      color:     json['color'] as String? ?? '',
      price:     json['price']?.toString() ?? '',
      imageUrl:  json['image_url'] as String?,
      userId:    json['user_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  /// Ke JSON untuk insert/update Supabase
  Map<String, dynamic> toJson() {
    return {
      'name':      name,
      'color':     color,
      'price':     price,
      'image_url': imageUrl,
      if (userId != null) 'user_id': userId,
    };
  }

  Car copyWith({
    String? id,
    String? name,
    String? color,
    String? price,
    String? imageUrl,
    Uint8List? imageBytes,
    String? userId,
    DateTime? createdAt,
  }) {
    return Car(
      id:        id        ?? this.id,
      name:      name      ?? this.name,
      color:     color     ?? this.color,
      price:     price     ?? this.price,
      imageUrl:  imageUrl  ?? this.imageUrl,
      imageBytes: imageBytes ?? this.imageBytes,
      userId:    userId    ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
