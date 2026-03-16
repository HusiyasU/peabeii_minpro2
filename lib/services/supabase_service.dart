import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/car.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  // ─── AUTH ──────────────────────────────────────────────────────────────────

  static User? get currentUser => _client.auth.currentUser;
  static bool get isLoggedIn => currentUser != null;

  static Stream<AuthState> get authStream => _client.auth.onAuthStateChange;

  static Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signUp(email: email, password: password);
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // ─── CARS CRUD ─────────────────────────────────────────────────────────────

  static Future<List<Car>> getCars() async {
    final userId = currentUser?.id;
    if (userId == null) return [];

    final data = await _client
        .from('cars')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (data as List).map((e) => Car.fromJson(e)).toList();
  }

  static Future<Car> addCar(Car car, {Uint8List? imageBytes}) async {
    final userId = currentUser?.id;
    if (userId == null) throw Exception('User tidak ditemukan');

    String? imageUrl;
    if (imageBytes != null) {
      imageUrl = await _uploadImage(imageBytes, userId);
    }

    final data = await _client
        .from('cars')
        .insert({
          ...car.toJson(),
          'user_id':   userId,
          'image_url': imageUrl,
        })
        .select()
        .single();

    return Car.fromJson(data);
  }

  static Future<Car> updateCar(Car car, {Uint8List? imageBytes}) async {
    if (car.id == null) throw Exception('ID mobil tidak ditemukan');
    final userId = currentUser?.id ?? '';

    String? imageUrl = car.imageUrl;
    if (imageBytes != null) {
      imageUrl = await _uploadImage(imageBytes, userId, existingId: car.id);
    }

    final data = await _client
        .from('cars')
        .update({
          ...car.toJson(),
          'image_url': imageUrl,
        })
        .eq('id', car.id!)
        .select()
        .single();

    return Car.fromJson(data);
  }

  static Future<void> deleteCar(String id) async {
    await _client.from('cars').delete().eq('id', id);
  }

  // ─── IMAGE UPLOAD ──────────────────────────────────────────────────────────

  static Future<String> _uploadImage(
    Uint8List bytes,
    String userId, {
    String? existingId,
  }) async {
    final fileName = '${userId}_${existingId ?? DateTime.now().millisecondsSinceEpoch}.jpg';
    final path = 'car_images/$fileName';

    await _client.storage.from('cars').uploadBinary(
      path,
      bytes,
      fileOptions: const FileOptions(
        contentType: 'image/jpeg',
        upsert: true,
      ),
    );

    return _client.storage.from('cars').getPublicUrl(path);
  }
}
