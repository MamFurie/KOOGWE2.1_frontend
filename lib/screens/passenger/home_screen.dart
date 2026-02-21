import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/koogwe_widgets.dart';
import '../../services/api_service.dart';
import '../../services/socket_service.dart';
import 'confort_screen.dart';
import 'wallet_screen.dart';
import 'historique_screen.dart';
import '../auth/login_screen.dart';

class PassengerHomeScreen extends StatefulWidget {
  const PassengerHomeScreen({super.key});

  @override
  State<PassengerHomeScreen> createState() => _PassengerHomeScreenState();
}

class _PassengerHomeScreenState extends State<PassengerHomeScreen> {
  int _navIndex = 0;
  String _userName = 'Utilisateur';
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final name = await AuthService.getUserName();
    final id = await AuthService.getUserId();
    if (mounted) setState(() {
      _userName = name ?? 'Utilisateur';
      _userId = id ?? '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _HomeContent(userName: _userName, userId: _userId),
      const _DeliveryPlaceholder(),
      WalletScreen(userId: _userId),
      _ProfilePage(userName: _userName),
    ];

    return Scaffold(
      body: IndexedStack(index: _navIndex, children: pages),
      bottomNavigationBar: PassengerBottomNav(
        currentIndex: _navIndex,
        onTap: (i) => setState(() => _navIndex = i),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  final String userName;
  final String userId;
  const _HomeContent({required this.userName, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: MapPlaceholder()),
        Positioned(
          top: 0, left: 0, right: 0,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [BoxShadow(color: Color(0x12000000), blurRadius: 10)],
                    ),
                    child: const Icon(Icons.menu, color: AppColors.textDark),
                  ),
                  const Spacer(),
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 10)],
                    ),
                    child: const Icon(Icons.security, color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          right: 16, bottom: 280,
          child: Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              boxShadow: const [BoxShadow(color: Color(0x1A000000), blurRadius: 10)],
            ),
            child: const Icon(Icons.my_location, color: AppColors.primary, size: 20),
          ),
        ),
        Positioned(
          left: 0, right: 0, bottom: 0,
          child: _BottomSearchSheet(userName: userName),
        ),
      ],
    );
  }
}

class _BottomSearchSheet extends StatelessWidget {
  final String userName;
  const _BottomSearchSheet({required this.userName});

  String get _firstName => userName.split(' ').first;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [BoxShadow(color: Color(0x15000000), blurRadius: 30, offset: Offset(0, -4))],
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 36, height: 4,
            decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Text('Bonjour, $_firstName 👋', style: GoogleFonts.dmSans(
            fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textDark,
          )),
          Text('Prêt pour un trajet ?', style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.textLight)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ConfortScreen())),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(color: AppColors.surfaceGray, borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  const Icon(Icons.search, color: AppColors.primary, size: 22),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Où allez-vous ?', style: GoogleFonts.dmSans(fontSize: 15, color: AppColors.textHint))),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.cardBorder)),
                    child: const Icon(Icons.access_time, color: AppColors.textLight, size: 16),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _QuickDestCard(icon: Icons.home_outlined, title: 'Maison', subtitle: '12 Rue de Rivoli', color: AppColors.primaryLight, iconColor: AppColors.primary)),
              const SizedBox(width: 12),
              Expanded(child: _QuickDestCard(icon: Icons.work_outline, title: 'Bureau', subtitle: 'La Défense', color: const Color(0xFFEEF9FF), iconColor: const Color(0xFF06B6D4))),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoriqueScreen())),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(color: AppColors.surfaceGray, borderRadius: BorderRadius.circular(14)),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.history, color: AppColors.textLight, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Mes dernières courses', style: GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textDark)),
                        Text('Voir l\'historique', style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.textLight)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textLight),
                ],
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }
}

class _QuickDestCard extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final Color color, iconColor;
  const _QuickDestCard({required this.icon, required this.title, required this.subtitle, required this.color, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.surfaceGray, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Container(width: 36, height: 36, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: iconColor, size: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                Text(subtitle, style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.textLight), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryPlaceholder extends StatelessWidget {
  const _DeliveryPlaceholder();

  @override
  Widget build(BuildContext context) => const Scaffold(
    backgroundColor: AppColors.background,
    body: Center(child: Text('Livraison — Bientôt disponible')),
  );
}

class _ProfilePage extends StatelessWidget {
  final String userName;
  const _ProfilePage({required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Profil', style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textDark)),
        backgroundColor: AppColors.surface, elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryAccent]),
                shape: BoxShape.circle,
              ),
              child: Center(child: Text(
                userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                style: GoogleFonts.dmSans(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white),
              )),
            ),
            const SizedBox(height: 12),
            Text(userName, style: GoogleFonts.dmSans(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textDark)),
            const SizedBox(height: 32),
            _ProfileTile(icon: Icons.history, title: 'Historique', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoriqueScreen()))),
            _ProfileTile(icon: Icons.settings_outlined, title: 'Paramètres', onTap: () {}),
            _ProfileTile(icon: Icons.help_outline, title: 'Aide & Support', onTap: () {}),
            const SizedBox(height: 16),
            KoogweButton(
              label: 'Se déconnecter',
              backgroundColor: AppColors.errorLight,
              textColor: AppColors.error,
              onPressed: () async {
                await AuthService.logout();
                SocketService.disconnect();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (r) => false);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const _ProfileTile({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.cardBorder)),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.textDark)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textLight),
        onTap: onTap,
      ),
    );
  }
}
