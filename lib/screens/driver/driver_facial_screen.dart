import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/koogwe_widgets.dart';
import 'pending_screen.dart';

class DriverFacialScreen extends StatefulWidget {
  const DriverFacialScreen({super.key});

  @override
  State<DriverFacialScreen> createState() => _DriverFacialScreenState();
}

class _DriverFacialScreenState extends State<DriverFacialScreen> with SingleTickerProviderStateMixin {
  late AnimationController _progressCtrl;
  double _progress = 0.65;
  bool _faceDetected = true;
  bool _awaitingBlink = true;

  @override
  void initState() {
    super.initState();
    _progressCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    // Simulate progress
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _progress = 0.85);
    });
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() {
        _progress = 1.0;
        _awaitingBlink = false;
      });
    });
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const PendingScreen()));
    });
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    super.dispose();
  }

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
        title: Text('Onboarding Chauffeur', style: GoogleFonts.dmSans(
          fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textDark,
        )),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Vérification Faciale', style: GoogleFonts.dmSans(
              fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.primary,
            )),
            const SizedBox(height: 8),
            Text(
              'Veuillez tourner la tête et cligner des yeux\npour confirmer votre identité.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textLight, height: 1.5),
            ),
            const SizedBox(height: 40),
            // Face scan widget
            SizedBox(
              width: 240, height: 240,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer ring
                  AnimatedBuilder(
                    animation: _progressCtrl,
                    builder: (_, __) => Container(
                      width: 240, height: 240,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primaryLight.withOpacity(0.5 + _progressCtrl.value * 0.3),
                          width: 8,
                        ),
                      ),
                    ),
                  ),
                  // Progress arc
                  SizedBox(
                    width: 240, height: 240,
                    child: CircularProgressIndicator(
                      value: _progress,
                      strokeWidth: 5,
                      backgroundColor: AppColors.surfaceGray,
                      valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                    ),
                  ),
                  // Inner face area
                  Container(
                    width: 200, height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFF8D5C8),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Face silhouette
                        const Icon(Icons.person, size: 100, color: Color(0xFFD4A090)),
                        // Camera overlay
                        Container(
                          width: 80, height: 60,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.primary.withOpacity(0.5)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.camera_alt, color: AppColors.primary, size: 24),
                              // Dot indicator
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(width: 4, height: 4, decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5), shape: BoxShape.circle,
                                  )),
                                  const SizedBox(width: 4),
                                  Container(width: 4, height: 4, decoration: const BoxDecoration(
                                    color: Colors.black, shape: BoxShape.circle,
                                  )),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Dashed circle guides
                  Container(
                    width: 180, height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.6),
                        width: 1,
                        style: BorderStyle.solid,
                      ),
                    ),
                  ),
                  // Percentage
                  Positioned(
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [const BoxShadow(color: Color(0x12000000), blurRadius: 8)],
                      ),
                      child: Text(
                        '${(_progress * 100).round()}% Analyse',
                        style: GoogleFonts.dmSans(
                          fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Face detected status
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.successLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32, height: 32,
                    decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                    child: const Icon(Icons.check, color: Colors.white, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Visage détecté', style: GoogleFonts.dmSans(
                        fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.success,
                      )),
                      Text('Positionnement optimal', style: GoogleFonts.dmSans(
                        fontSize: 12, color: AppColors.success,
                      )),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            if (_awaitingBlink)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: const Icon(Icons.visibility_outlined, color: AppColors.primary, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Action requise : Clignez des yeux', style: GoogleFonts.dmSans(
                          fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary,
                        )),
                        Text('Maintenez le regard fixe', style: GoogleFonts.dmSans(
                          fontSize: 12, color: AppColors.primary,
                        )),
                      ],
                    ),
                  ],
                ),
              ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceGray, borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.lock_outlined, size: 14, color: AppColors.textLight),
                      const SizedBox(width: 4),
                      Text('Session sécurisée et cryptée de bout en bout', style: GoogleFonts.dmSans(
                        fontSize: 12, color: AppColors.textLight,
                      )),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Vos données biométriques sont traitées conformément à notre politique de confidentialité et ne seront jamais partagées.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textHint, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
