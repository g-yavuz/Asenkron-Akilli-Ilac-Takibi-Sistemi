import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';
// ─── SCAN DURUMU ─────────────────────────────────────────────────────────────

enum _ScanDurumu { taraniyor, isleniyor, bulundu, bulunamadi, manuelForm }

// ─── ÖRNEK VERİTABANI ────────────────────────────────────────────────────────

const _ilacVetabani = {
  '4987654321098': {
    'ad': 'Apranax Fort',
    'doz': '550mg',
    'adet': '20',
    'birim': 'tablet',
    'kullanim': 'Günde 2x',
    'zaman': 'Sabah, Akşam',
    'sekil': 'Tok karna',
  },
  '1234567890123': {
    'ad': 'Beloc Zok',
    'doz': '50mg',
    'adet': '30',
    'birim': 'tablet',
    'kullanim': 'Günde 1x',
    'zaman': 'Sabah',
    'sekil': 'Tok karna',
  },
};

// ─── ANA EKRAN ────────────────────────────────────────────────────────────────

class IlacEkleScreen extends StatefulWidget {
  final VoidCallback? onIptal;
  const IlacEkleScreen({super.key, this.onIptal});

  @override
  State<IlacEkleScreen> createState() => _IlacEkleScreenState();
}

class _IlacEkleScreenState extends State<IlacEkleScreen>
    with TickerProviderStateMixin {
  _ScanDurumu _durum = _ScanDurumu.taraniyor;
  bool _flashAcik = false;
  Map<String, String>? _bulunanIlac;

  // Scan çizgisi animasyonu
  late final AnimationController _scanCtrl;
  late final Animation<double> _scanAnim;

  // İşleniyor dönme animasyonu
  late final AnimationController _spinCtrl;

  // Köşe işima animasyonu
  late final AnimationController _pulseCtrl;
  late final Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _scanCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _scanAnim = CurvedAnimation(parent: _scanCtrl, curve: Curves.easeInOut);

    _spinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scanCtrl.dispose();
    _spinCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  // ── DEMO: barkod tarama simülasyonu ──────────────────────────────────────
  void _barkodTarandiSimule(String barkod) {
    HapticFeedback.mediumImpact();
    setState(() => _durum = _ScanDurumu.isleniyor);
    _scanCtrl.stop();
    _spinCtrl.repeat();

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      _spinCtrl.stop();
      final ilac = _ilacVetabani[barkod];
      setState(() {
        _bulunanIlac = ilac;
        _durum = ilac != null ? _ScanDurumu.bulundu : _ScanDurumu.bulunamadi;
      });

      if (ilac != null) {
        _bulunduModalGoster(ilac);
      } else {
        _bulunamadiModalGoster();
      }
    });
  }

  void _taramayaGeriDon() {
    setState(() {
      _durum = _ScanDurumu.taraniyor;
      _bulunanIlac = null;
    });
    _scanCtrl.repeat(reverse: true);
  }

  // ── MODALLER ─────────────────────────────────────────────────────────────
  void _bulunduModalGoster(Map<String, String> ilac) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (_) => _BulunduModal(
        ilac: ilac,
        onOnayla: () {
          Navigator.pop(context);
          _basariliGoster();
        },
        onIptal: () {
          Navigator.pop(context);
          _taramayaGeriDon();
        },
      ),
    );
  }

  void _bulunamadiModalGoster() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (_) => _BulunamadiModal(
        onKaydet: () {
          Navigator.pop(context);
          _basariliGoster();
        },
        onIptal: () {
          Navigator.pop(context);
          _taramayaGeriDon();
        },
      ),
    );
  }

  void _manuelFormGoster() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ManuelFormModal(
        onKaydet: () {
          Navigator.pop(context);
          _basariliGoster();
        },
        onIptal: () => Navigator.pop(context),
      ),
    );
  }

  void _qrManuelGir() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _QrManuelModal(
        onSorgula: (barkod) {
          Navigator.pop(context);
          _barkodTarandiSimule(barkod);
        },
        onIptal: () => Navigator.pop(context),
      ),
    );
  }

  void _basariliGoster() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline_rounded,
                color: Colors.white, size: 18),
            SizedBox(width: 10),
            Text(
              'İlaç başarıyla eklendi!',
              style:
                  TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ],
        ),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: const Duration(seconds: 2),
      ),
    );
    _taramayaGeriDon();
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final cameraH = screenH * 0.75;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Kamera Alani (75%) ──────────────────────────────────────────
          SizedBox(
            height: cameraH,
            width: double.infinity,
            child: Stack(
              children: [
                // Kamera arka plani
                _KameraArkaplan(durum: _durum),

                // Karartma overlay + scan frame
                _ScanOverlay(
                  scanAnim: _scanAnim,
                  pulseAnim: _pulseAnim,
                  durum: _durum,
                  spinCtrl: _spinCtrl,
                ),

                // Üst kontroller
                _UstKontroller(
                  flashAcik: _flashAcik,
                  onFlash: () =>
                      setState(() => _flashAcik = !_flashAcik),
                  onIptal: widget.onIptal,
                ),

                // Kamera alanı alt butonlar
                _DemoButonlar(
                  durum: _durum,
                  onQrManuel: _qrManuelGir,
                  onManuelEkle: _bulunamadiModalGoster,
                ),
              ],
            ),
          ),

          // ── Alt Panel (25%) ──────────────────────────────────────────────
          Positioned(
            top: cameraH,
            left: 0,
            right: 0,
            bottom: 0,
            child: _AltPanel(
              onManuelGir: _manuelFormGoster,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── KAMERA ARKAPLAN ─────────────────────────────────────────────────────────

class _KameraArkaplan extends StatelessWidget {
  final _ScanDurumu durum;
  const _KameraArkaplan({required this.durum});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(
        MediaQuery.of(context).size.width,
        MediaQuery.of(context).size.height * 0.75,
      ),
      painter: _KameraCizici(),
    );
  }
}

class _KameraCizici extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Koyu arka plan (kamera simülasyonu)
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF0D1117),
    );

    // Hafif grid doku
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 0.5;

    const spacing = 24.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Vignette efekti (kenarlar daha koyu)
    final vignette = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.85,
        colors: [
          Colors.transparent,
          Colors.black.withValues(alpha: 0.6),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), vignette);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── SCAN OVERLAY ─────────────────────────────────────────────────────────────

class _ScanOverlay extends StatelessWidget {
  final Animation<double> scanAnim;
  final Animation<double> pulseAnim;
  final _ScanDurumu durum;
  final AnimationController spinCtrl;

  const _ScanOverlay({
    required this.scanAnim,
    required this.pulseAnim,
    required this.durum,
    required this.spinCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height * 0.75;
    const frameW = 260.0;
    const frameH = 200.0;
    final frameL = (w - frameW) / 2;
    final frameT = (h - frameH) / 2 - 20;

    return Stack(
      children: [
        // Karartilmiş kenar alanlar
        CustomPaint(
          size: Size(w, h),
          painter: _OverlayCizici(
            frameRect: Rect.fromLTWH(frameL, frameT, frameW, frameH),
          ),
        ),

        // İşleniyor: dönüyor spinner
        if (durum == _ScanDurumu.isleniyor)
          Positioned(
            left: frameL,
            top: frameT,
            width: frameW,
            height: frameH,
            child: Center(
              child: AnimatedBuilder(
                animation: spinCtrl,
                builder: (_, child) => Transform.rotate(
                  angle: spinCtrl.value * 2 * math.pi,
                  child: child,
                ),
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTheme.primary,
                      width: 3,
                    ),
                  ),
                  child: const Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.only(top: 3),
                      child: Icon(Icons.circle, size: 6, color: AppTheme.primary),
                    ),
                  ),
                ),
              ),
            ),
          )
        // Taraniyor: scan çizgisi
        else if (durum == _ScanDurumu.taraniyor)
          AnimatedBuilder(
            animation: scanAnim,
            builder: (_, __) => Positioned(
              left: frameL + 12,
              right: w - frameL - frameW + 12,
              top: frameT + 12 + (scanAnim.value * (frameH - 24)),
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppTheme.primary.withValues(alpha: 0.6),
                      AppTheme.primary,
                      AppTheme.primary.withValues(alpha: 0.6),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

        // Köşe çerçevesi (pulse)
        AnimatedBuilder(
          animation: pulseAnim,
          builder: (_, __) => Positioned(
            left: frameL,
            top: frameT,
            width: frameW,
            height: frameH,
            child: CustomPaint(
              painter: _KoseFrameCizici(
                renk: durum == _ScanDurumu.isleniyor
                    ? AppTheme.warning
                    : AppTheme.primary,
                parlaklik: durum == _ScanDurumu.taraniyor
                    ? pulseAnim.value
                    : 1.0,
              ),
            ),
          ),
        ),

        // Metin overlay (sadece taraniyor modunda)
        if (durum == _ScanDurumu.taraniyor)
          Positioned(
            left: 0,
            right: 0,
            top: frameT + frameH + 24,
            child: Column(
              children: [
                const Text(
                  'İlaç barkodunu okutun',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Kamerayı barkod üzerine getirin',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

        // İşleniyor metni
        if (durum == _ScanDurumu.isleniyor)
          Positioned(
            left: 0,
            right: 0,
            top: frameT + frameH + 24,
            child: Column(
              children: [
                const Text(
                  'Barkod okunuyor...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'İlaç bilgileri sorgulanıyor',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ─── OVERLAY BOYAYICI ────────────────────────────────────────────────────────

class _OverlayCizici extends CustomPainter {
  final Rect frameRect;
  const _OverlayCizici({required this.frameRect});

  @override
  void paint(Canvas canvas, Size size) {
    final karartma = Paint()..color = Colors.black.withValues(alpha: 0.55);

    // 4 kenar şerit — frame dişi karartma
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, frameRect.top), karartma);
    canvas.drawRect(
        Rect.fromLTWH(0, frameRect.bottom, size.width,
            size.height - frameRect.bottom),
        karartma);
    canvas.drawRect(
        Rect.fromLTWH(0, frameRect.top, frameRect.left, frameRect.height),
        karartma);
    canvas.drawRect(
        Rect.fromLTWH(frameRect.right, frameRect.top,
            size.width - frameRect.right, frameRect.height),
        karartma);
  }

  @override
  bool shouldRepaint(covariant _OverlayCizici old) =>
      old.frameRect != frameRect;
}

// ─── KÖŞE ÇERÇEVE BOYAYICI ───────────────────────────────────────────────────

class _KoseFrameCizici extends CustomPainter {
  final Color renk;
  final double parlaklik;
  const _KoseFrameCizici({required this.renk, required this.parlaklik});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = renk.withValues(alpha: parlaklik)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const margin = 0.0;
    const cornerLen = 28.0;
    const radius = 10.0;

    // Glow efekti
    final glowPaint = Paint()
      ..color = renk.withValues(alpha: 0.25 * parlaklik)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    void drawCorner(List<Offset> pts) {
      final path = Path()..moveTo(pts[0].dx, pts[0].dy);
      for (int i = 1; i < pts.length; i++) {
        path.lineTo(pts[i].dx, pts[i].dy);
      }
      canvas.drawPath(path, glowPaint);
      canvas.drawPath(path, paint);
    }

    // Sol-üst
    drawCorner([
      Offset(margin, margin + cornerLen),
      Offset(margin, margin + radius),
      Offset(margin + radius, margin),
      Offset(margin + cornerLen, margin),
    ]);
    // Sağ-üst
    drawCorner([
      Offset(size.width - margin - cornerLen, margin),
      Offset(size.width - margin - radius, margin),
      Offset(size.width - margin, margin + radius),
      Offset(size.width - margin, margin + cornerLen),
    ]);
    // Sol-alt
    drawCorner([
      Offset(margin, size.height - margin - cornerLen),
      Offset(margin, size.height - margin - radius),
      Offset(margin + radius, size.height - margin),
      Offset(margin + cornerLen, size.height - margin),
    ]);
    // Sağ-alt
    drawCorner([
      Offset(size.width - margin, size.height - margin - cornerLen),
      Offset(size.width - margin, size.height - margin - radius),
      Offset(size.width - margin - radius, size.height - margin),
      Offset(size.width - margin - cornerLen, size.height - margin),
    ]);
  }

  @override
  bool shouldRepaint(covariant _KoseFrameCizici old) =>
      old.renk != renk || old.parlaklik != parlaklik;
}

// ─── ÜST KONTROLLER ──────────────────────────────────────────────────────────

class _UstKontroller extends StatelessWidget {
  final bool flashAcik;
  final VoidCallback onFlash;
  final VoidCallback? onIptal;

  const _UstKontroller({required this.flashAcik, required this.onFlash, this.onIptal});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 16,
      right: 16,
      child: Row(
        children: [
          // Geri / İptal
          GestureDetector(
            onTap: onIptal,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15), width: 1),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 14),
                  SizedBox(width: 6),
                  Text(
                    'İptal',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          // Başlik
          const Text(
            'İlaç Ekle',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const Spacer(),
          // Flash butonu
          GestureDetector(
            onTap: onFlash,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: flashAcik
                    ? Colors.white.withValues(alpha: 0.9)
                    : Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2), width: 1),
              ),
              child: Icon(
                flashAcik
                    ? Icons.flash_on_rounded
                    : Icons.flash_off_rounded,
                color: flashAcik ? const Color(0xFF1A1F36) : Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── DEMO BUTONLAR ───────────────────────────────────────────────────────────

class _DemoButonlar extends StatelessWidget {
  final _ScanDurumu durum;
  final VoidCallback onQrManuel;
  final VoidCallback onManuelEkle;

  const _DemoButonlar({
    required this.durum,
    required this.onQrManuel,
    required this.onManuelEkle,
  });

  @override
  Widget build(BuildContext context) {
    if (durum != _ScanDurumu.taraniyor) return const SizedBox.shrink();

    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Row(
        children: [
          Expanded(
            child: _DemoBtn(
              icon: Icons.qr_code_rounded,
              label: "QR'ı Manuel Ekle",
              renk: AppTheme.primary,
              onTap: onQrManuel,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _DemoBtn(
              icon: Icons.edit_note_rounded,
              label: 'İlacı Manuel Ekle',
              renk: AppTheme.warning,
              onTap: onManuelEkle,
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color renk;
  final VoidCallback onTap;
  const _DemoBtn(
      {required this.icon, required this.label, required this.renk, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: renk.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: renk.withValues(alpha: 0.4), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: renk, size: 14),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: renk,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── ALT PANEL ────────────────────────────────────────────────────────────────

class _AltPanel extends StatelessWidget {
  final VoidCallback onManuelGir;
  const _AltPanel({required this.onManuelGir});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Çekiş çubuğu
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Barkodu Elle Gir
            GestureDetector(
              onTap: onManuelGir,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.keyboard_outlined,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Barkodu Elle Gir',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Barkod numarasını klavye ile girin',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        color: Colors.white60, size: 14),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Manuel İlaç Ekle
            GestureDetector(
              onTap: onManuelGir,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppShadow.card,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.add_circle_outline_rounded,
                          color: AppTheme.primary, size: 20),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Manuel İlaç Ekle',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Tüm bilgileri kendiniz girin',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        color: AppTheme.textSecondary, size: 14),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Bilgi metni
            Center(
              child: Text(
                'Barkod okunamazsa manuel giriş yapabilirsiniz',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── QR MANUEL GİRİŞ MODALI ──────────────────────────────────────────────────

class _QrManuelModal extends StatefulWidget {
  final void Function(String barkod) onSorgula;
  final VoidCallback onIptal;

  const _QrManuelModal({required this.onSorgula, required this.onIptal});

  @override
  State<_QrManuelModal> createState() => _QrManuelModalState();
}

class _QrManuelModalState extends State<_QrManuelModal> {
  final _ctrl = TextEditingController();
  bool _bos = true;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        decoration: const BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tutamac
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Baslik
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.qr_code_rounded,
                      color: AppTheme.primary, size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "QR'ı Manuel Gir",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        'Barkod numarasini girin',
                        style: TextStyle(
                            fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Barkod numarasi alani
            Container(
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.divider, width: 1.5),
              ),
              child: TextField(
                controller: _ctrl,
                keyboardType: TextInputType.number,
                autofocus: true,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                  letterSpacing: 2,
                ),
                decoration: const InputDecoration(
                  hintText: '0000000000000',
                  hintStyle: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 2,
                  ),
                  prefixIcon: Icon(Icons.pin_outlined,
                      color: AppTheme.primary, size: 22),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                onChanged: (v) => setState(() => _bos = v.trim().isEmpty),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kutunun üzerindeki 13 haneli barkod numarasini girin',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 24),
            // Butonlar
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: widget.onIptal,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.background,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Text(
                        'İptal',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: _bos
                        ? null
                        : () => widget.onSorgula(_ctrl.text.trim()),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: _bos
                            ? AppTheme.primary.withValues(alpha: 0.4)
                            : AppTheme.primary,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: _bos
                            ? null
                            : [
                                BoxShadow(
                                  color:
                                      AppTheme.primary.withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_rounded,
                              color: Colors.white, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Sorgula',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── BULUNDU MODALI ───────────────────────────────────────────────────────────

class _BulunduModal extends StatelessWidget {
  final Map<String, String> ilac;
  final VoidCallback onOnayla;
  final VoidCallback onIptal;

  const _BulunduModal({
    required this.ilac,
    required this.onOnayla,
    required this.onIptal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: const BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Çekiş çubuğu
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: AppTheme.divider,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          // Başlik satiri
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.successLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.check_circle_outline_rounded,
                    color: AppTheme.success, size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'İlaç Bulundu!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      'Bilgiler otomatik dolduruldu',
                      style: TextStyle(
                          fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Otomatik dolu form
          _DoluFormSatiri(
              ikon: Icons.medication_outlined,
              etiket: 'İlaç Adı',
              deger: ilac['ad'] ?? ''),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _DoluFormSatiri(
                    ikon: Icons.science_outlined,
                    etiket: 'Doz',
                    deger: ilac['doz'] ?? ''),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DoluFormSatiri(
                    ikon: Icons.inventory_2_outlined,
                    etiket: 'Miktar',
                    deger:
                        '${ilac['adet']} ${ilac['birim']}'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _DoluFormSatiri(
                    ikon: Icons.repeat_rounded,
                    etiket: 'Kullanım',
                    deger: ilac['kullanim'] ?? ''),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DoluFormSatiri(
                    ikon: Icons.wb_sunny_outlined,
                    etiket: 'Zaman',
                    deger: ilac['zaman'] ?? ''),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _DoluFormSatiri(
              ikon: Icons.restaurant_outlined,
              etiket: 'Kullanım Şekli',
              deger: ilac['sekil'] ?? ''),
          const SizedBox(height: 24),
          // Butonlar
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onIptal,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.background,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text(
                      'İptal',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: onOnayla,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.success,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.success.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_rounded,
                            color: Colors.white, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Onayla ve Ekle',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DoluFormSatiri extends StatelessWidget {
  final IconData ikon;
  final String etiket;
  final String deger;
  const _DoluFormSatiri(
      {required this.ikon, required this.etiket, required this.deger});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(ikon, size: 16, color: AppTheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  etiket,
                  style: const TextStyle(
                      fontSize: 10, color: AppTheme.textSecondary),
                ),
                Text(
                  deger,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── BULUNAMADI MODALI ────────────────────────────────────────────────────────

class _BulunamadiModal extends StatefulWidget {
  final VoidCallback onKaydet;
  final VoidCallback onIptal;

  const _BulunamadiModal({required this.onKaydet, required this.onIptal});

  @override
  State<_BulunamadiModal> createState() => _BulunamadiModalState();
}

class _BulunamadiModalState extends State<_BulunamadiModal> {
  String _secilenBirim = 'tablet';
  String _secilenGunlukDoz = 'Günde 1x';
  final List<String> _secilenZamanlar = [];
  String _secilenSekil = 'Tok karna';

  final List<String> _birimler = ['tablet', 'kapsül', 'ml', 'damla'];
  final List<String> _gunlukDozlar = [
    'Günde 1x',
    'Günde 2x',
    'Günde 3x',
    'Haftada 1x',
  ];
  final List<String> _zamanlar = ['Sabah', 'Öğle', 'Akşam', 'Gece'];
  final List<String> _sekiller = ['Tok karna', 'Aç karna', 'Fark etmez'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        decoration: const BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tutamaç
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            // Başlik
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.warningLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.search_off_rounded,
                        color: AppTheme.warning, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'İlaç Bilgisi Bulunamadı',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          'Bilgileri kendiniz girin',
                          style: TextStyle(
                              fontSize: 12, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Form içeriği
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FormBaslik('İlaç Adı'),
                    _GirisAlani(
                      hint: 'İlaç adı girin',
                      ikon: Icons.medication_outlined,
                    ),
                    const SizedBox(height: 16),
                    _FormBaslik('Toplam Miktar'),
                    Row(
                      children: [
                        const Expanded(
                          flex: 2,
                          child: _GirisAlani(
                            hint: 'Adet',
                            ikon: Icons.format_list_numbered_rounded,
                            klavye: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 3,
                          child: _BirimSecici(
                            secili: _secilenBirim,
                            secenekler: _birimler,
                            onSecildi: (v) =>
                                setState(() => _secilenBirim = v),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _FormBaslik('Günlük Doz'),
                    _ChipSecici(
                      secenekler: _gunlukDozlar,
                      secili: _secilenGunlukDoz,
                      onSecildi: (v) =>
                          setState(() => _secilenGunlukDoz = v),
                    ),
                    const SizedBox(height: 16),
                    _FormBaslik('Kullanım Zamanı'),
                    _CokluChipSecici(
                      secenekler: _zamanlar,
                      secilenler: _secilenZamanlar,
                      ikonlar: const [
                        Icons.wb_sunny_outlined,
                        Icons.wb_cloudy_outlined,
                        Icons.wb_twilight_outlined,
                        Icons.bedtime_outlined,
                      ],
                      onDegisti: (v) =>
                          setState(() {
                        if (_secilenZamanlar.contains(v)) {
                          _secilenZamanlar.remove(v);
                        } else {
                          _secilenZamanlar.add(v);
                        }
                      }),
                    ),
                    const SizedBox(height: 16),
                    _FormBaslik('Kullanım Şekli'),
                    _ChipSecici(
                      secenekler: _sekiller,
                      secili: _secilenSekil,
                      onSecildi: (v) =>
                          setState(() => _secilenSekil = v),
                    ),
                    const SizedBox(height: 24),
                    // Butonlar
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: widget.onIptal,
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: AppTheme.background,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Text(
                                'İptal',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: GestureDetector(
                            onTap: widget.onKaydet,
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: AppTheme.primary,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primary
                                        .withValues(alpha: 0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.save_outlined,
                                      color: Colors.white, size: 16),
                                  SizedBox(width: 6),
                                  Text(
                                    'İlacı Kaydet',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── MANUEL FORM MODALI ───────────────────────────────────────────────────────

class _ManuelFormModal extends StatefulWidget {
  final VoidCallback onKaydet;
  final VoidCallback onIptal;

  const _ManuelFormModal({required this.onKaydet, required this.onIptal});

  @override
  State<_ManuelFormModal> createState() => _ManuelFormModalState();
}

class _ManuelFormModalState extends State<_ManuelFormModal> {
  String _secilenBirim = 'tablet';
  String _secilenGunlukDoz = 'Günde 1x';
  final List<String> _secilenZamanlar = [];
  String _secilenSekil = 'Tok karna';

  final List<String> _birimler = ['tablet', 'kapsül', 'ml', 'damla'];
  final List<String> _gunlukDozlar = [
    'Günde 1x',
    'Günde 2x',
    'Günde 3x',
    'Haftada 1x',
  ];
  final List<String> _zamanlar = ['Sabah', 'Öğle', 'Akşam', 'Gece'];
  final List<String> _sekiller = ['Tok karna', 'Aç karna', 'Fark etmez'];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.90),
        decoration: const BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.add_circle_outline_rounded,
                        color: AppTheme.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Manuel İlaç Ekle',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          'İlaç bilgilerini doldurun',
                          style: TextStyle(
                              fontSize: 12, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FormBaslik('İlaç Adı'),
                    const _GirisAlani(
                      hint: 'İlaç adı girin',
                      ikon: Icons.medication_outlined,
                    ),
                    const SizedBox(height: 16),
                    _FormBaslik('Toplam Miktar'),
                    Row(
                      children: [
                        const Expanded(
                          flex: 2,
                          child: _GirisAlani(
                            hint: 'Adet',
                            ikon: Icons.format_list_numbered_rounded,
                            klavye: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 3,
                          child: _BirimSecici(
                            secili: _secilenBirim,
                            secenekler: _birimler,
                            onSecildi: (v) =>
                                setState(() => _secilenBirim = v),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _FormBaslik('Günlük Doz'),
                    _ChipSecici(
                      secenekler: _gunlukDozlar,
                      secili: _secilenGunlukDoz,
                      onSecildi: (v) =>
                          setState(() => _secilenGunlukDoz = v),
                    ),
                    const SizedBox(height: 16),
                    _FormBaslik('Kullanım Zamanı'),
                    _CokluChipSecici(
                      secenekler: _zamanlar,
                      secilenler: _secilenZamanlar,
                      ikonlar: const [
                        Icons.wb_sunny_outlined,
                        Icons.wb_cloudy_outlined,
                        Icons.wb_twilight_outlined,
                        Icons.bedtime_outlined,
                      ],
                      onDegisti: (v) => setState(() {
                        if (_secilenZamanlar.contains(v)) {
                          _secilenZamanlar.remove(v);
                        } else {
                          _secilenZamanlar.add(v);
                        }
                      }),
                    ),
                    const SizedBox(height: 16),
                    _FormBaslik('Kullanım Şekli'),
                    _ChipSecici(
                      secenekler: _sekiller,
                      secili: _secilenSekil,
                      onSecildi: (v) =>
                          setState(() => _secilenSekil = v),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: widget.onIptal,
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: AppTheme.background,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Text(
                                'İptal',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: GestureDetector(
                            onTap: widget.onKaydet,
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: AppTheme.primary,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primary
                                        .withValues(alpha: 0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.save_outlined,
                                      color: Colors.white, size: 16),
                                  SizedBox(width: 6),
                                  Text(
                                    'İlacı Kaydet',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── FORM YARDIMCI WİDGETLER ─────────────────────────────────────────────────

class _FormBaslik extends StatelessWidget {
  final String metin;
  const _FormBaslik(this.metin);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        metin,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppTheme.textPrimary,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}

class _GirisAlani extends StatelessWidget {
  final String hint;
  final IconData ikon;
  final TextInputType klavye;

  const _GirisAlani({
    required this.hint,
    required this.ikon,
    this.klavye = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      keyboardType: klavye,
      style: const TextStyle(
          fontSize: 14,
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        prefixIcon: Icon(ikon, color: AppTheme.primary, size: 18),
        filled: true,
        fillColor: AppTheme.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppTheme.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      ),
    );
  }
}

class _BirimSecici extends StatelessWidget {
  final String secili;
  final List<String> secenekler;
  final ValueChanged<String> onSecildi;

  const _BirimSecici({
    required this.secili,
    required this.secenekler,
    required this.onSecildi,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: secili,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: AppTheme.primary, size: 18),
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          items: secenekler
              .map((s) => DropdownMenuItem(
                    value: s,
                    child: Text(s),
                  ))
              .toList(),
          onChanged: (v) => v != null ? onSecildi(v) : null,
        ),
      ),
    );
  }
}

class _ChipSecici extends StatelessWidget {
  final List<String> secenekler;
  final String secili;
  final ValueChanged<String> onSecildi;

  const _ChipSecici({
    required this.secenekler,
    required this.secili,
    required this.onSecildi,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: secenekler.map((s) {
        final aktif = s == secili;
        return GestureDetector(
          onTap: () => onSecildi(s),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: aktif ? AppTheme.primary : AppTheme.background,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: aktif
                    ? AppTheme.primary
                    : AppTheme.divider,
                width: 1.5,
              ),
            ),
            child: Text(
              s,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: aktif ? Colors.white : AppTheme.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _CokluChipSecici extends StatelessWidget {
  final List<String> secenekler;
  final List<String> secilenler;
  final List<IconData> ikonlar;
  final ValueChanged<String> onDegisti;

  const _CokluChipSecici({
    required this.secenekler,
    required this.secilenler,
    required this.ikonlar,
    required this.onDegisti,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(secenekler.length, (i) {
        final aktif = secilenler.contains(secenekler[i]);
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < secenekler.length - 1 ? 8 : 0),
            child: GestureDetector(
              onTap: () => onDegisti(secenekler[i]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  color: aktif ? AppTheme.primaryLight : AppTheme.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: aktif
                        ? AppTheme.primary
                        : AppTheme.divider,
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      ikonlar[i],
                      size: 18,
                      color: aktif
                          ? AppTheme.primary
                          : AppTheme.textSecondary,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      secenekler[i],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: aktif
                            ? AppTheme.primary
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
