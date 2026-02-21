import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import '../../theme/app_theme.dart';
import '../../widgets/koogwe_widgets.dart';
import '../../services/api_service.dart';
import 'tracking_screen.dart';

class ConfortScreen extends StatefulWidget {
  const ConfortScreen({super.key});

  @override
  State<ConfortScreen> createState() => _ConfortScreenState();
}

class _ConfortScreenState extends State<ConfortScreen> {
  int _selectedVehicle = 0;
  final Set<String> _selectedOptions = {'Clim'};
  int _selectedPayment = 0;
  bool _loading = false;
  String? _error;

  final List<_Vehicle> _vehicles = const [
    _Vehicle(name: 'Moto', apiType: 'MOTO', price: 8.50, eta: '3 min', seats: 1, desc: 'Rapide et économique'),
    _Vehicle(name: 'Eco', apiType: 'ECO', price: 12.50, eta: '5 min', seats: 4, desc: 'Confortable et abordable'),
    _Vehicle(name: 'Confort', apiType: 'CONFORT', price: 18.90, eta: '8 min', seats: 4, desc: 'Voiture premium spacieuse'),
  ];

  final List<_ComfortOption> _options = const [
    _ComfortOption(id: 'Clim', icon: Icons.ac_unit, label: 'Clim'),
    _ComfortOption(id: 'WiFi', icon: Icons.wifi, label: 'Wi-Fi'),
    _ComfortOption(id: 'Musique', icon: Icons.music_note, label: 'Musique'),
    _ComfortOption(id: 'Silence', icon: Icons.volume_off, label: 'Silencieux'),
  ];

  double get _totalPrice {
    final base = _vehicles[_selectedVehicle].price;
    final extras = _selectedOptions.length > 1 ? (_selectedOptions.length - 1) * 1.5 : 0.0;
    return base + extras;
  }

  Future<void> _confirmRide() async {
    setState(() { _loading = true; _error = null; });

    try {
      // Coordonnées simulées — en prod, utiliser geolocator pour les vraies coords
      final ride = await RidesService.createRide(
        originLat: 5.3548, // Lomé, Togo — adapter selon ta zone
        originLng: 1.1782,
        destLat: 5.3700,
        destLng: 1.1900,
        price: _totalPrice,
        vehicleType: _vehicles[_selectedVehicle].apiType,
      );

      if (!mounted) return;

      Navigator.push(context, MaterialPageRoute(
        builder: (_) => TrackingScreen(rideId: ride['id'] as String, price: _totalPrice),
      ));
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Impossible de créer la course';
      setState(() => _error = msg.toString());
    } catch (e) {
      setState(() => _error = 'Erreur de connexion au serveur');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface, elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.surfaceGray, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.arrow_back_ios_new, size: 16, color: AppColors.textDark),
          ),
        ),
        title: Text('Sélectionnez votre course', style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textDark)),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('TYPE DE VÉHICULE', style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textLight, letterSpacing: 1)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 180,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _vehicles.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (_, i) => _VehicleCard(
                        vehicle: _vehicles[i],
                        selected: i == _selectedVehicle,
                        onTap: () => setState(() => _selectedVehicle = i),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text('OPTIONS DE CONFORT', style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textLight, letterSpacing: 1)),
                  const SizedBox(height: 12),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.5,
                    children: _options.map((opt) => _ComfortCard(
                      option: opt,
                      selected: _selectedOptions.contains(opt.id),
                      onTap: () => setState(() {
                        if (_selectedOptions.contains(opt.id)) _selectedOptions.remove(opt.id);
                        else _selectedOptions.add(opt.id);
                      }),
                    )).toList(),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: AppColors.errorLight, borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                          const SizedBox(width: 8),
                          Expanded(child: Text(_error!, style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.error))),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Bottom bar
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              boxShadow: [BoxShadow(color: Color(0x0F000000), blurRadius: 20, offset: Offset(0, -4))],
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(child: _PaymentChip(icon: Icons.account_balance_wallet, label: 'Wallet', selected: _selectedPayment == 0, onTap: () => setState(() => _selectedPayment = 0))),
                      const SizedBox(width: 8),
                      Expanded(child: _PaymentChip(icon: Icons.payments_outlined, label: 'Cash', selected: _selectedPayment == 1, onTap: () => setState(() => _selectedPayment = 1))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('TOTAL ESTIMÉ', style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textLight, letterSpacing: 0.8)),
                          Text('${_totalPrice.toStringAsFixed(2)} €', style: GoogleFonts.dmSans(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: KoogweButton(
                          label: 'Confirmer ${_vehicles[_selectedVehicle].name}',
                          onPressed: _confirmRide,
                          loading: _loading,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Vehicle {
  final String name, apiType, desc, eta;
  final double price;
  final int seats;
  const _Vehicle({required this.name, required this.apiType, required this.price, required this.eta, required this.seats, required this.desc});
}

class _VehicleCard extends StatelessWidget {
  final _Vehicle vehicle;
  final bool selected;
  final VoidCallback onTap;
  const _VehicleCard({required this.vehicle, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: selected ? AppColors.primary : AppColors.cardBorder, width: selected ? 2 : 1),
          boxShadow: selected ? [BoxShadow(color: AppColors.primary.withOpacity(0.15), blurRadius: 20)] : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: selected ? AppColors.primaryLight : AppColors.surfaceGray, borderRadius: BorderRadius.circular(8)),
                  child: Icon(Icons.directions_car, color: selected ? AppColors.primary : AppColors.textLight, size: 18),
                ),
                if (selected) Container(
                  width: 22, height: 22,
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.check, color: Colors.white, size: 14),
                ),
              ],
            ),
            const Spacer(),
            Text(vehicle.name, style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            Text(vehicle.eta, style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textLight)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${vehicle.price.toStringAsFixed(2)} €', style: GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)),
                Row(children: [
                  const Icon(Icons.person, size: 12, color: AppColors.textLight),
                  Text(' ${vehicle.seats}', style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textLight)),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ComfortOption {
  final String id, label;
  final IconData icon;
  const _ComfortOption({required this.id, required this.icon, required this.label});
}

class _ComfortCard extends StatelessWidget {
  final _ComfortOption option;
  final bool selected;
  final VoidCallback onTap;
  const _ComfortCard({required this.option, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? AppColors.primary : AppColors.cardBorder, width: selected ? 2 : 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(option.icon, color: selected ? AppColors.primary : AppColors.textMedium, size: 28),
            const SizedBox(height: 8),
            Text(option.label, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w500, color: selected ? AppColors.primary : AppColors.textMedium)),
          ],
        ),
      ),
    );
  }
}

class _PaymentChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _PaymentChip({required this.icon, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : AppColors.surfaceGray,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppColors.primary : Colors.transparent),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: selected ? AppColors.primary : AppColors.textLight),
            const SizedBox(width: 6),
            Expanded(child: Text(label, style: GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w500, color: selected ? AppColors.primary : AppColors.textLight), overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }
}
