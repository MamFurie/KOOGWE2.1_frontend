import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/koogwe_widgets.dart';

class DriverDocumentScreen extends StatelessWidget {
  const DriverDocumentScreen({super.key});

  static const List<_DocItem> _docs = [
    _DocItem(icon: Icons.badge_outlined, title: 'Identité', subtitle: 'CNI ou Passeport', status: 'Validé'),
    _DocItem(icon: Icons.car_crash_outlined, title: 'Conduite', subtitle: 'Permis de conduire', status: 'Validé'),
    _DocItem(icon: Icons.star_border, title: 'Accréditation', subtitle: 'Carte Pro VTC', status: 'En attente'),
    _DocItem(icon: Icons.gavel, title: 'Moralité', subtitle: 'Casier judiciaire (B3)', status: 'Refusé'),
    _DocItem(icon: Icons.shield_outlined, title: 'Assurance', subtitle: 'Attestation RC Pro', status: 'Validé'),
    _DocItem(icon: Icons.directions_car_outlined, title: 'Véhicule', subtitle: 'Carte grise', status: 'Validé'),
    _DocItem(icon: Icons.build_outlined, title: 'Sécurité Auto', subtitle: 'Contrôle technique', status: 'Validé'),
    _DocItem(icon: Icons.account_balance_outlined, title: 'Paiement', subtitle: 'RIB / IBAN', status: 'Validé'),
  ];

  int get _validatedCount => _docs.where((d) => d.status == 'Validé').length;
  double get _progress => _validatedCount / _docs.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.surfaceGray, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.arrow_back_ios_new, size: 16, color: AppColors.textDark),
          ),
        ),
        title: Text('Dossier Professionnel', style: GoogleFonts.dmSans(
          fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark,
        )),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Progress card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder),
                boxShadow: [const BoxShadow(color: Color(0x08000000), blurRadius: 16)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Progression globale', style: GoogleFonts.dmSans(
                    fontSize: 13, color: AppColors.textLight,
                  )),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text('$_validatedCount / ${_docs.length} complétés', style: GoogleFonts.dmSans(
                        fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark,
                      )),
                      const Spacer(),
                      Text('${(_progress * 100).round()}%', style: GoogleFonts.dmSans(
                        fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textLight,
                      )),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: _progress,
                      minHeight: 8,
                      backgroundColor: AppColors.surfaceGray,
                      valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.info_outline, size: 14, color: AppColors.textLight),
                      const SizedBox(width: 6),
                      Text('Complétez tous les modules pour activer votre compte.',
                        style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textLight)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ..._docs.map((doc) => _DocTile(doc: doc)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Text('Besoin d\'aide avec vos documents ?', style: GoogleFonts.dmSans(
                    fontSize: 14, color: AppColors.textLight,
                  )),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.help_outline, size: 16),
                    label: Text('Contacter le support', style: GoogleFonts.dmSans(
                      fontSize: 14, fontWeight: FontWeight.w600,
                    )),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _DocItem {
  final IconData icon;
  final String title, subtitle, status;
  const _DocItem({required this.icon, required this.title, required this.subtitle, required this.status});
}

class _DocTile extends StatelessWidget {
  final _DocItem doc;
  const _DocTile({super.key, required this.doc});

  Color get _statusBg {
    switch (doc.status) {
      case 'Validé': return AppColors.successLight;
      case 'Refusé': return AppColors.errorLight;
      default: return AppColors.warningLight;
    }
  }

  Color get _statusColor {
    switch (doc.status) {
      case 'Validé': return AppColors.success;
      case 'Refusé': return AppColors.error;
      default: return AppColors.warning;
    }
  }

  IconData get _statusIcon {
    switch (doc.status) {
      case 'Validé': return Icons.check_circle;
      case 'Refusé': return Icons.cancel;
      default: return Icons.access_time;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: ListTile(
        leading: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(doc.icon, color: AppColors.primary, size: 20),
        ),
        title: Text(doc.title, style: GoogleFonts.dmSans(
          fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textDark,
        )),
        subtitle: Text(doc.subtitle, style: GoogleFonts.dmSans(
          fontSize: 12, color: AppColors.textLight,
        )),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: _statusBg, borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_statusIcon, size: 12, color: _statusColor),
                  const SizedBox(width: 4),
                  Text(doc.status, style: GoogleFonts.dmSans(
                    fontSize: 11, fontWeight: FontWeight.w600, color: _statusColor,
                  )),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.textHint),
          ],
        ),
        onTap: () {},
      ),
    );
  }
}
