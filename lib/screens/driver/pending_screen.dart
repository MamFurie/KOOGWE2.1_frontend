import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/koogwe_widgets.dart';
import 'driver_document_screen.dart';

class PendingScreen extends StatelessWidget {
  const PendingScreen({super.key});

  static const List<Map<String, dynamic>> _items = [
    {'icon': Icons.badge_outlined, 'label': "Pièce d'identité", 'status': 'EN COURS'},
    {'icon': Icons.credit_card, 'label': 'Permis de conduire', 'status': 'EN COURS'},
    {'icon': Icons.directions_car_outlined, 'label': 'Assurance véhicule', 'status': 'EN COURS'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background.withOpacity(0.96),
      body: Stack(
        children: [
          // Blurred background hint
          Positioned.fill(
            child: Container(
              color: AppColors.background.withOpacity(0.9),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 40, offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72, height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight, borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.assignment_late_outlined, color: AppColors.primary, size: 36),
                    ),
                    const SizedBox(height: 20),
                    Text("Votre compte est en cours d'examen",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(
                        fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.textDark, height: 1.2,
                      )),
                    const SizedBox(height: 10),
                    Text(
                      'Notre équipe vérifie actuellement vos informations pour garantir la sécurité de la plateforme.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.textLight, height: 1.5),
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: AppColors.divider, height: 1),
                    const SizedBox(height: 16),
                    ..._items.map((item) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceGray, borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36, height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(item['icon'] as IconData, color: AppColors.primary, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(child: Text(item['label'] as String, style: GoogleFonts.dmSans(
                            fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark,
                          ))),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.warningLight, borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(item['status'] as String, style: GoogleFonts.dmSans(
                              fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.warning,
                            )),
                          ),
                        ],
                      ),
                    )),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight, borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.access_time, color: AppColors.primary, size: 16),
                          const SizedBox(width: 6),
                          Text('Délai estimé : 24-48h', style: GoogleFonts.dmSans(
                            fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary,
                          )),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    KoogweButton(
                      label: 'Modifier mes documents',
                      icon: Icons.edit_document,
                      onPressed: () => Navigator.push(context, MaterialPageRoute(
                        builder: (_) => const DriverDocumentScreen(),
                      )),
                    ),
                    const SizedBox(height: 10),
                    KoogweOutlinedButton(
                      label: 'Aide & Support',
                      icon: Icons.help_outline,
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // Bottom navigation
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          boxShadow: [BoxShadow(color: Color(0x0F000000), blurRadius: 16)],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(icon: Icons.home_outlined, label: 'Accueil'),
                _NavItem(icon: Icons.account_balance_wallet_outlined, label: 'Revenus'),
                _NavItem(icon: Icons.star_border, label: 'Notes'),
                _NavItem(icon: Icons.person_outline, label: 'Profil'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 22, color: AppColors.textLight),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.dmSans(fontSize: 10, color: AppColors.textLight)),
      ],
    );
  }
}
