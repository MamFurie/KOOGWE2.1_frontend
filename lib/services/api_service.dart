import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // ✅ FIX : URL correcte selon la plateforme
  static String get baseUrl {
    if (kDebugMode) {
      // ✅ FIX ANDROID : Sur émulateur Android, localhost = l'appareil lui-même
      // 10.0.2.2 pointe vers le PC hôte (émulateur Android Studio)
      if (defaultTargetPlatform == TargetPlatform.android) {
        return 'http://10.0.2.2:3000';
      }
      // iOS simulateur et Web : localhost fonctionne directement
      return 'http://localhost:3000';
    }
    // ✅ Production Railway — remplacer par votre vraie URL
    const railwayUrl = String.fromEnvironment(
      'BACKEND_URL',
      defaultValue: 'https://votre-app.railway.app',
    );
    return railwayUrl;
  }

  static final Dio _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {'Content-Type': 'application/json'},
  ));

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }

    _dio.interceptors.add(InterceptorsWrapper(
      onError: (DioException e, handler) {
        if (e.response?.statusCode == 401) {
          AuthService.logout();
        }
        handler.next(e);
      },
      onRequest: (options, handler) {
        // Log pour debug
        if (kDebugMode) {
          print('📡 ${options.method} ${options.uri}');
        }
        handler.next(options);
      },
    ));
  }

  static void setToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  static void clearToken() {
    _dio.options.headers.remove('Authorization');
  }

  static Dio get dio => _dio;
}

// ─── AUTH SERVICE ─────────────────────────────────────────────────────────────
class AuthService {
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await ApiService.dio.post('/auth/login', data: {
      'email': email,
      'password': password,
    });
    final data = res.data as Map<String, dynamic>;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', data['access_token']);
    await prefs.setString('user_id', data['user']['id']);
    await prefs.setString('user_name', data['user']['name'] ?? '');
    await prefs.setString('user_email', data['user']['email']);
    await prefs.setString('user_role', data['user']['role']);

    ApiService.setToken(data['access_token']);
    return data;
  }

  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String role,
  }) async {
    final res = await ApiService.dio.post('/auth/signup', data: {
      'email': email,
      'password': password,
      'name': name,
      'phone': phone,
      'role': role,
    });
    return res.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> verifyOtp(String email, String code) async {
    final res = await ApiService.dio.post('/auth/verify', data: {
      'email': email,
      'code': code,
    });
    return res.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> getProfile() async {
    final res = await ApiService.dio.get('/users/me');
    return res.data as Map<String, dynamic>;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    ApiService.clearToken();
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_role');
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_name');
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') != null;
  }
}

// ─── RIDES SERVICE ─────────────────────────────────────────────────────────────
class RidesService {
  static Future<Map<String, dynamic>> createRide({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
    required double price,
    required String vehicleType,
  }) async {
    final res = await ApiService.dio.post('/rides', data: {
      'originLat': originLat,
      'originLng': originLng,
      'destLat': destLat,
      'destLng': destLng,
      'price': price,
      'vehicleType': vehicleType,
    });
    return res.data as Map<String, dynamic>;
  }

  static Future<List<dynamic>> getHistory() async {
    final res = await ApiService.dio.get('/rides/history');
    return res.data as List;
  }

  static Future<Map<String, dynamic>> getDriverStats() async {
    final res = await ApiService.dio.get('/rides/driver/stats');
    return res.data as Map<String, dynamic>;
  }
}

// ─── WALLET SERVICE ────────────────────────────────────────────────────────────
class WalletService {
  static Future<double> getBalance(String userId) async {
    final res = await ApiService.dio.get('/wallet/balance/$userId');
    return (res.data['balance'] as num).toDouble();
  }

  static Future<List<dynamic>> getTransactions(String userId) async {
    final res = await ApiService.dio.get('/wallet/transactions/$userId');
    return res.data as List;
  }

  static Future<Map<String, dynamic>> rechargeWithCard({
    required String userId,
    required double amount,
    required String paymentMethodId,
  }) async {
    final res = await ApiService.dio.post('/wallet/recharge-card', data: {
      'userId': userId,
      'amount': amount,
      'paymentMethodId': paymentMethodId,
    });
    return res.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> requestWithdrawal({
    required String userId,
    required double amount,
  }) async {
    final res = await ApiService.dio.post('/wallet/request-withdrawal', data: {
      'userId': userId,
      'amount': amount,
    });
    return res.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> payRide({
    required String userId,
    required String rideId,
    required double amount,
  }) async {
    final res = await ApiService.dio.post('/wallet/pay-ride', data: {
      'userId': userId,
      'rideId': rideId,
      'amount': amount,
    });
    return res.data as Map<String, dynamic>;
  }
}

// ─── USERS SERVICE ────────────────────────────────────────────────────────────
class UsersService {
  static Future<Map<String, dynamic>> getDriverStatus() async {
    final res = await ApiService.dio.get('/users/driver-status');
    return res.data as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> updateVehicle({
    String? vehicleMake,
    String? vehicleModel,
    String? vehicleColor,
    String? licensePlate,
  }) async {
    final res = await ApiService.dio.patch('/users/update-vehicle', data: {
      if (vehicleMake != null) 'vehicleMake': vehicleMake,
      if (vehicleModel != null) 'vehicleModel': vehicleModel,
      if (vehicleColor != null) 'vehicleColor': vehicleColor,
      if (licensePlate != null) 'licensePlate': licensePlate,
    });
    return res.data as Map<String, dynamic>;
  }
}
