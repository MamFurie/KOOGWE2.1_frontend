import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'api_service.dart';

/// Service Socket.io — gère le temps réel entre passager et chauffeur
class SocketService {
  static IO.Socket? _socket;
  static bool _isConnected = false;

  // ── Connexion au serveur Socket.io ─────────────────────────────────────────
  // ✅ FIX : connect() est maintenant async pour lire le vrai token JWT
  static Future<void> connect() async {
    if (_isConnected) return;

    // ✅ FIX CRITIQUE : Lire le token depuis SharedPreferences (plus de '' vide)
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token') ?? '';

    _socket = IO.io(
      ApiService.baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setExtraHeaders({'Authorization': 'Bearer $token'})
          .setAuth({'token': token}) // Aussi via auth pour compatibilité
          .build(),
    );

    _socket!.connect();

    _socket!.onConnect((_) {
      _isConnected = true;
      print('🔌 Socket connecté');
    });

    _socket!.onDisconnect((_) {
      _isConnected = false;
      print('🔌 Socket déconnecté');
    });

    _socket!.onConnectError((data) {
      print('❌ Erreur connexion socket: $data');
    });
  }

  // ── Déconnexion ────────────────────────────────────────────────────────────
  static void disconnect() {
    _socket?.disconnect();
    _socket = null;
    _isConnected = false;
  }

  // ── PASSAGER : Rejoindre la room d'une course ──────────────────────────────
  static void joinRide(String rideId) {
    _socket?.emit('join_ride', {'rideId': rideId});
  }

  static void leaveRide(String rideId) {
    _socket?.emit('leave_ride', {'rideId': rideId});
  }

  // Écouter les mises à jour du statut d'une course
  static void onRideStatus(String rideId, Function(Map<String, dynamic>) callback) {
    _socket?.on('ride_status_$rideId', (data) {
      callback(Map<String, dynamic>.from(data));
    });
  }

  // Écouter la position GPS du chauffeur
  static void onDriverLocation(String rideId, Function(double lat, double lng) callback) {
    _socket?.on('driver_location_$rideId', (data) {
      callback(
        (data['lat'] as num).toDouble(),
        (data['lng'] as num).toDouble(),
      );
    });
  }

  // Écouter les messages du chat
  static void onChatMessage(String rideId, Function(Map<String, dynamic>) callback) {
    _socket?.on('chat_$rideId', (data) {
      callback(Map<String, dynamic>.from(data));
    });
  }

  // Envoyer un message chat
  static void sendChatMessage({
    required String rideId,
    required String senderId,
    required String message,
  }) {
    _socket?.emit('chat_message', {
      'rideId': rideId,
      'senderId': senderId,
      'message': message,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // ── CHAUFFEUR : Gérer la disponibilité ────────────────────────────────────
  static void goOnline(String driverId) {
    _socket?.emit('driver_online', {'driverId': driverId});
  }

  static void goOffline(String driverId) {
    _socket?.emit('driver_offline', {'driverId': driverId});
  }

  // Écouter les nouvelles courses disponibles
  static void onNewRide(Function(Map<String, dynamic>) callback) {
    _socket?.on('new_ride', (data) {
      callback(Map<String, dynamic>.from(data));
    });
  }

  // Accepter une course
  static void acceptRide({required String rideId, required String driverId}) {
    _socket?.emit('accept_ride', {
      'rideId': rideId,
      'driverId': driverId,
    });
  }

  // Signaler l'arrivée
  static void driverArrived(String rideId) {
    _socket?.emit('driver_arrived', {'rideId': rideId});
  }

  // Démarrer la course
  static void startTrip(String rideId) {
    _socket?.emit('start_trip', {'rideId': rideId});
  }

  // Terminer la course
  static void finishTrip(String rideId) {
    // ✅ FIX SÉCURITÉ : Plus de prix côté client (le backend utilise le prix DB)
    _socket?.emit('finish_trip', {'rideId': rideId});
  }

  // Mettre à jour la position GPS (chauffeur)
  static void updateLocation({
    required String rideId,
    required double lat,
    required double lng,
  }) {
    _socket?.emit('update_location', {
      'rideId': rideId,
      'lat': lat,
      'lng': lng,
    });
  }

  // Écouter la fin de course (pour rafraîchir l'historique)
  static void onTripFinished(Function(Map<String, dynamic>) callback) {
    _socket?.on('trip_finished', (data) {
      callback(Map<String, dynamic>.from(data));
    });
  }

  // Supprimer un listener
  static void off(String event) {
    _socket?.off(event);
  }

  // Vérifier la connexion
  static bool get isConnected => _isConnected;
}
