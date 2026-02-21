import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/koogwe_widgets.dart';
import '../../services/socket_service.dart';
import 'home_screen.dart';

class TrackingScreen extends StatefulWidget {
  final String rideId;
  final double price;
  const TrackingScreen({super.key, required this.rideId, required this.price});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;

  // Status possible : REQUESTED, ACCEPTED, ARRIVED, IN_PROGRESS, COMPLETED, CANCELLED
  String _status = 'REQUESTED';

  // Infos chauffeur reçues via socket
  String? _driverName;
  String? _driverPhone;
  String? _vehicleInfo;
  String? _licensePlate;

  // Position GPS chauffeur
  double? _driverLat;
  double? _driverLng;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);

    // Rejoindre la room de la course
    SocketService.joinRide(widget.rideId);

    // Écouter les mises à jour du statut
    SocketService.onRideStatus(widget.rideId, (data) {
      if (!mounted) return;
      setState(() {
        _status = data['status'] ?? _status;
        if (data['driverName'] != null) _driverName = data['driverName'];
        if (data['driverPhone'] != null) _driverPhone = data['driverPhone'];
        if (data['vehicleInfo'] != null) _vehicleInfo = data['vehicleInfo'];
        if (data['licensePlate'] != null) _licensePlate = data['licensePlate'];
      });

      // Course terminée → retourner à l'accueil
      if (_status == 'COMPLETED') {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const PassengerHomeScreen()),
              (route) => false,
            );
          }
        });
      }
    });

    // Écouter la position GPS du chauffeur
    SocketService.onDriverLocation(widget.rideId, (lat, lng) {
      if (mounted) setState(() { _driverLat = lat; _driverLng = lng; });
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    SocketService.leaveRide(widget.rideId);
    SocketService.off('ride_status_${widget.rideId}');
    SocketService.off('driver_location_${widget.rideId}');
    super.dispose();
  }

  String get _statusLabel {
    switch (_status) {
      case 'REQUESTED': return 'Recherche d\'un chauffeur...';
      case 'ACCEPTED': return 'Chauffeur en route';
      case 'ARRIVED': return 'Votre chauffeur est arrivé !';
      case 'IN_PROGRESS': return 'Course en cours';
      case 'COMPLETED': return 'Course terminée ✓';
      case 'CANCELLED': return 'Course annulée';
      default: return _status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool driverFound = ['ACCEPTED', 'ARRIVED', 'IN_PROGRESS', 'COMPLETED'].contains(_status);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: MapPlaceholder(showRoute: driverFound)),
          // Back button
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12),
                          boxShadow: const [BoxShadow(color: Color(0x12000000), blurRadius: 10)]),
                        child: const Icon(Icons.arrow_back_ios_new, size: 16, color: AppColors.textDark),
                      ),
                    ),
                    const Spacer(),
                    if (driverFound)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(20),
                          boxShadow: const [BoxShadow(color: Color(0x12000000), blurRadius: 10)]),
                        child: Text(_statusLabel, style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                      ),
                  ],
                ),
              ),
            ),
          ),
          // Live car dot on map
          if (driverFound && _driverLat != null)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.35,
              left: MediaQuery.of(context).size.width * 0.4,
              child: AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (_, child) => Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withOpacity(0.15 + _pulseCtrl.value * 0.1)),
                  child: child,
                ),
                child: Center(child: Container(
                  width: 36, height: 36,
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.directions_car, color: Colors.white, size: 20),
                )),
              ),
            ),
          // Bottom sheet
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: driverFound
                ? _DriverFoundSheet(
                    driverName: _driverName ?? 'Chauffeur',
                    vehicleInfo: _vehicleInfo ?? 'Véhicule en route',
                    licensePlate: _licensePlate ?? '———',
                    status: _status,
                    price: widget.price,
                    rideId: widget.rideId,
                  )
                : _SearchingSheet(pulseCtrl: _pulseCtrl, status: _status),
          ),
        ],
      ),
    );
  }
}

class _SearchingSheet extends StatelessWidget {
  final AnimationController pulseCtrl;
  final String status;
  const _SearchingSheet({required this.pulseCtrl, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [BoxShadow(color: Color(0x15000000), blurRadius: 30, offset: Offset(0, -4))],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 36, height: 4,
            decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 28),
          AnimatedBuilder(
            animation: pulseCtrl,
            builder: (_, child) => Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 80 + pulseCtrl.value * 30,
                  height: 80 + pulseCtrl.value * 30,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withOpacity(0.05 + pulseCtrl.value * 0.05)),
                ),
                Container(
                  width: 80, height: 80,
                  decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
                  child: const Icon(Icons.radar, color: AppColors.primary, size: 36),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text('Recherche d\'un chauffeur...', style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark)),
          const SizedBox(height: 6),
          Text('Nous cherchons le meilleur chauffeur disponible.', textAlign: TextAlign.center,
            style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textLight, height: 1.5)),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler la course', style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.error, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _DriverFoundSheet extends StatelessWidget {
  final String driverName, vehicleInfo, licensePlate, status, rideId;
  final double price;
  const _DriverFoundSheet({required this.driverName, required this.vehicleInfo, required this.licensePlate, required this.status, required this.price, required this.rideId});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [BoxShadow(color: Color(0x15000000), blurRadius: 30, offset: Offset(0, -4))],
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 36, height: 4,
              decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF667EEA), Color(0xFF764BA2)]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(child: Text(driverName[0].toUpperCase(), style: GoogleFonts.dmSans(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white))),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(driverName, style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark)),
                      Text(vehicleInfo, style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textLight)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(color: AppColors.surfaceGray, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.cardBorder)),
                  child: Text(licensePlate, style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textDark, letterSpacing: 1)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Status badge
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: status == 'ARRIVED' ? AppColors.successLight : AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  status == 'ACCEPTED' ? '🚗 En route vers vous' : status == 'ARRIVED' ? '✅ Votre chauffeur est arrivé !' : '🚀 Course en cours',
                  style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600, color: status == 'ARRIVED' ? AppColors.success : AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.chat_bubble_outline, size: 16),
                    label: Text('Message', style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.phone_outlined, size: 16),
                    label: Text('Appeler', style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textDark,
                      side: const BorderSide(color: AppColors.cardBorder),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _SafetyChip(icon: Icons.shield_outlined, label: 'Sécurité', color: AppColors.primaryLight, iconColor: AppColors.primary),
                _SafetyChip(icon: Icons.share_location, label: 'Partager', color: AppColors.successLight, iconColor: AppColors.success),
                _SafetyChip(icon: Icons.cancel_outlined, label: 'Annuler', color: AppColors.errorLight, iconColor: AppColors.error),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _SafetyChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color, iconColor;
  const _SafetyChip({required this.icon, required this.label, required this.color, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 6),
          Text(label, style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600, color: iconColor)),
        ],
      ),
    );
  }
}
