import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme.dart';
import 'screens/home_screen.dart';
import 'screens/ilac_ekle_screen.dart';
import 'screens/pharmacies_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/splash_screen.dart';
import 'services/ilac_depo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await IlacDepo.yukle();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
  );
  runApp(const MedTrackerApp());
}

class MedTrackerApp extends StatelessWidget {
  const MedTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Asenkron',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const _GirisYonlendirici(),
    );
  }
}

class _GirisYonlendirici extends StatefulWidget {
  const _GirisYonlendirici();

  @override
  State<_GirisYonlendirici> createState() => _GirisYonlendiriciState();
}

class _GirisYonlendiriciState extends State<_GirisYonlendirici> {
  bool _splashBitti = false;

  @override
  Widget build(BuildContext context) {
    if (!_splashBitti) {
      return SplashScreen(
        onBitti: () => setState(() => _splashBitti = true),
      );
    }
    return const MainShell();
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  List<Widget> get _screens => [
        const HomeScreen(),
        IlacEkleScreen(onIptal: () => setState(() => _currentIndex = 0)),
        const PharmaciesScreen(),
        const ProfileScreen(),
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _currentIndex == 1 ? null : _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.72),
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.5),
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(8, 6, 8, MediaQuery.of(context).padding.bottom > 0 ? 12 : 8),
              child: Row(
                children: [
                  _NavItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home_rounded,
                    label: 'Ana Sayfa',
                    isActive: _currentIndex == 0,
                    onTap: () => _onNavTap(0),
                  ),
                  _NavItem(
                    icon: Icons.add_circle_outline_rounded,
                    activeIcon: Icons.add_circle_rounded,
                    label: 'İlaç Ekle',
                    isActive: _currentIndex == 1,
                    onTap: () => _onNavTap(1),
                  ),
                  _NavItem(
                    icon: Icons.local_pharmacy_outlined,
                    activeIcon: Icons.local_pharmacy_rounded,
                    label: 'Eczaneler',
                    isActive: _currentIndex == 2,
                    onTap: () => _onNavTap(2),
                  ),
                  _NavItem(
                    icon: Icons.person_outline_rounded,
                    activeIcon: Icons.person_rounded,
                    label: 'Profil',
                    isActive: _currentIndex == 3,
                    onTap: () => _onNavTap(3),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onNavTap(int index) {
    HapticFeedback.lightImpact();
    setState(() => _currentIndex = index);
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: isActive
                ? AppTheme.primary.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isActive ? activeIcon : icon,
                  key: ValueKey(isActive),
                  color: isActive ? AppTheme.primary : AppTheme.textSecondary,
                  size: 24,
                ),
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                  color: isActive ? AppTheme.primary : AppTheme.textSecondary,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
