import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onBitti;
  const SplashScreen({super.key, required this.onBitti});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoCtrl;
  late final AnimationController _metin1Ctrl;
  late final AnimationController _metin2Ctrl;
  late final AnimationController _cikisCtrl;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<Offset> _metin1Slide;
  late final Animation<double> _metin1Opacity;
  late final Animation<Offset> _metin2Slide;
  late final Animation<double> _metin2Opacity;
  late final Animation<double> _cikisOpacity;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ));

    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _metin1Ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _metin2Ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _cikisCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl,
          curve: const Interval(0.0, 0.5, curve: Curves.easeIn)),
    );

    _metin1Slide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _metin1Ctrl, curve: Curves.easeOutCubic));
    _metin1Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _metin1Ctrl, curve: Curves.easeIn),
    );

    _metin2Slide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _metin2Ctrl, curve: Curves.easeOutCubic));
    _metin2Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _metin2Ctrl, curve: Curves.easeIn),
    );

    _cikisOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _cikisCtrl, curve: Curves.easeIn),
    );

    _baslatAnimasyonlar();
  }

  Future<void> _baslatAnimasyonlar() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    await _logoCtrl.forward();

    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;
    await _metin1Ctrl.forward();

    await Future.delayed(const Duration(milliseconds: 80));
    if (!mounted) return;
    await _metin2Ctrl.forward();

    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    await _cikisCtrl.forward();

    widget.onBitti();
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _metin1Ctrl.dispose();
    _metin2Ctrl.dispose();
    _cikisCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _cikisOpacity,
      child: Scaffold(
        backgroundColor: const Color(0xFF3B6CF6),
        body: Stack(
          children: [
            // Arka plan desen
            Positioned.fill(child: CustomPaint(painter: _ArkaplanCizici())),

            // İçerik
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo ikonu
                  AnimatedBuilder(
                    animation: _logoCtrl,
                    builder: (_, __) => Transform.scale(
                      scale: _logoScale.value,
                      child: Opacity(
                        opacity: _logoOpacity.value.clamp(0.0, 1.0),
                        child: Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.medication_rounded,
                            color: Colors.white,
                            size: 44,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // "Asenkron"
                  SlideTransition(
                    position: _metin1Slide,
                    child: FadeTransition(
                      opacity: _metin1Opacity,
                      child: const Text(
                        'Asenkron',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1.5,
                          height: 1.0,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // "Akıllı İlaç Uygulamanız"
                  SlideTransition(
                    position: _metin2Slide,
                    child: FadeTransition(
                      opacity: _metin2Opacity,
                      child: Text(
                        'Akıllı İlaç Uygulamanız',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Alt versiyon yazısı
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 24,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _metin2Opacity,
                child: Text(
                  'v1.0',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArkaplanCizici extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..style = PaintingStyle.fill;

    // Büyük daire — sağ üst
    canvas.drawCircle(
      Offset(size.width + 40, -60),
      220,
      paint,
    );

    // Orta daire — sol alt
    canvas.drawCircle(
      Offset(-60, size.height + 20),
      180,
      paint,
    );

    // Küçük daire — merkez sağ
    final paint2 = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(
      Offset(size.width * 0.8, size.height * 0.35),
      80,
      paint2,
    );
    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.65),
      60,
      paint2,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}
