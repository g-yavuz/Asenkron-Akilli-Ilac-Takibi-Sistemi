import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/medicine.dart';
import '../services/ilac_depo.dart';
import '../theme.dart';

// ─── VERİTABANI ──────────────────────────────────────────────────────────────

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

// ─── DURUM ───────────────────────────────────────────────────────────────────

enum _ScanDurumu { taraniyor, isleniyor }

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
  final MobileScannerController _kameraCtrl = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );
  bool _islemde = false;

  late final AnimationController _scanCtrl;
  late final Animation<double> _scanAnim;
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
    _kameraCtrl.dispose();
    _scanCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _barkodTarandi(BarcodeCapture capture) {
    if (_islemde || _durum != _ScanDurumu.taraniyor) return;
    final barkod = capture.barcodes.firstOrNull?.rawValue;
    if (barkod == null || barkod.isEmpty) return;

    _islemde = true;
    HapticFeedback.mediumImpact();
    _kameraCtrl.stop();
    setState(() => _durum = _ScanDurumu.isleniyor);

    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      setState(() => _durum = _ScanDurumu.taraniyor);
      final ilac = _ilacVetabani[barkod];
      if (ilac != null) {
        _bulunduModalGoster(ilac);
      } else {
        _bulunamadiModalGoster(barkod);
      }
    });
  }

  void _taramayaGeriDon() {
    _islemde = false;
    _kameraCtrl.start();
    setState(() => _durum = _ScanDurumu.taraniyor);
  }

  void _bulunduModalGoster(Map<String, String> ilac) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (_) => _BulunduModal(
        ilac: ilac,
        onDevamEt: () {
          Navigator.pop(context);
          _dozAyarlariAc(ilac);
        },
        onIptal: () {
          Navigator.pop(context);
          _taramayaGeriDon();
        },
      ),
    );
  }

  void _bulunamadiModalGoster(String barkod) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (_) => _BulunamadiModal(
        barkod: barkod,
        onManuelDevam: () {
          Navigator.pop(context);
          _dozAyarlariAc(null);
        },
        onIptal: () {
          Navigator.pop(context);
          _taramayaGeriDon();
        },
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
          _kameraCtrl.stop();
          setState(() => _durum = _ScanDurumu.isleniyor);
          Future.delayed(const Duration(milliseconds: 900), () {
            if (!mounted) return;
            setState(() => _durum = _ScanDurumu.taraniyor);
            final ilac = _ilacVetabani[barkod];
            if (ilac != null) {
              _bulunduModalGoster(ilac);
            } else {
              _bulunamadiModalGoster(barkod);
            }
          });
        },
        onIptal: () => Navigator.pop(context),
      ),
    );
  }

  void _dozAyarlariAc(Map<String, String>? ilac) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DozAyarlariSayfasi(
          ilacBilgisi: ilac,
          onKaydet: () {
            Navigator.pop(context);
            _basariliGoster();
          },
          onIptal: () {
            Navigator.pop(context);
            _taramayaGeriDon();
          },
        ),
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
            Text('İlaç başarıyla eklendi!',
                style: TextStyle(
                    fontWeight: FontWeight.w600, color: Colors.white)),
          ],
        ),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        duration: const Duration(seconds: 2),
      ),
    );
    _taramayaGeriDon();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // ── Kamera Alanı (flex 3) ────────────────────────────────────────
          Expanded(
            flex: 3,
            child: Stack(
              fit: StackFit.expand,
              children: [
                MobileScanner(
                  controller: _kameraCtrl,
                  onDetect: _barkodTarandi,
                  errorBuilder: (ctx, error) => _IzinEkrani(
                    reddedildi: error.errorCode ==
                        MobileScannerErrorCode.permissionDenied,
                    onTekrarIste: () => _kameraCtrl.start(),
                  ),
                ),

                _ScanOverlay(
                  scanAnim: _scanAnim,
                  pulseAnim: _pulseAnim,
                  yukleniyor: _durum == _ScanDurumu.isleniyor,
                ),

                _UstKontroller(
                  flashDestegi: _durum == _ScanDurumu.taraniyor,
                  onFlash: () => _kameraCtrl.toggleTorch(),
                  onIptal: widget.onIptal,
                ),

                if (_durum == _ScanDurumu.taraniyor)
                  _AltButonlar(
                    onQrManuel: _qrManuelGir,
                    onManuelEkle: () => _dozAyarlariAc(null),
                  ),
              ],
            ),
          ),

          // ── Alt Panel ───────────────────────────────────────────────────
          _AltPanel(),
        ],
      ),
    );
  }
}

// ─── İZİN EKRANI ─────────────────────────────────────────────────────────────

class _IzinEkrani extends StatelessWidget {
  final bool reddedildi;
  final VoidCallback onTekrarIste;
  const _IzinEkrani({required this.reddedildi, required this.onTekrarIste});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0D1117),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.camera_alt_outlined,
                  color: AppTheme.primary, size: 34),
            ),
            const SizedBox(height: 20),
            Text(
              reddedildi ? 'Kamera İzni Reddedildi' : 'Kamera İzni Gerekli',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              reddedildi
                  ? 'Ayarlardan kamera iznini açın'
                  : 'Barkod taramak için izin verin',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55), fontSize: 13),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: reddedildi ? openAppSettings : onTekrarIste,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  reddedildi ? 'Ayarlara Git' : 'İzin Ver',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── SCAN OVERLAY ─────────────────────────────────────────────────────────────

class _ScanOverlay extends StatelessWidget {
  final Animation<double> scanAnim;
  final Animation<double> pulseAnim;
  final bool yukleniyor;

  const _ScanOverlay({
    required this.scanAnim,
    required this.pulseAnim,
    required this.yukleniyor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final w = constraints.maxWidth;
      final h = constraints.maxHeight;
      const frameW = 260.0;
      const frameH = 200.0;
      final frameL = (w - frameW) / 2;
      final frameT = (h - frameH) / 2 - 20;

      return Stack(
        children: [
          CustomPaint(
            size: Size(w, h),
            painter: _OverlayCizici(
                frameRect: Rect.fromLTWH(frameL, frameT, frameW, frameH)),
          ),
        if (yukleniyor)
          Positioned(
            left: frameL,
            top: frameT,
            width: frameW,
            height: frameH,
            child: const Center(
              child: CircularProgressIndicator(
                  color: AppTheme.primary, strokeWidth: 3),
            ),
          )
        else
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
        AnimatedBuilder(
          animation: pulseAnim,
          builder: (_, __) => Positioned(
            left: frameL,
            top: frameT,
            width: frameW,
            height: frameH,
            child: CustomPaint(
              painter: _KoseFrameCizici(
                renk: yukleniyor ? AppTheme.warning : AppTheme.primary,
                parlaklik: yukleniyor ? 1.0 : pulseAnim.value,
              ),
            ),
          ),
        ),
        if (!yukleniyor)
          Positioned(
            left: 0,
            right: 0,
            top: frameT + frameH + 24,
            child: Column(
              children: [
                const Text('İlaç barkodunu okutun',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.3)),
                const SizedBox(height: 6),
                Text('Kamerayı barkod veya QR üzerine getirin',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 13)),
              ],
            ),
          ),
        if (yukleniyor)
          Positioned(
            left: 0,
            right: 0,
            top: frameT + frameH + 24,
            child: Column(
              children: [
                const Text('Barkod okunuyor...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('İlaç bilgileri sorgulanıyor',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 13)),
              ],
            ),
          ),
      ],
    );
    }); // LayoutBuilder
  }
}

class _OverlayCizici extends CustomPainter {
  final Rect frameRect;
  const _OverlayCizici({required this.frameRect});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.black.withValues(alpha: 0.55);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, frameRect.top), p);
    canvas.drawRect(
        Rect.fromLTWH(
            0, frameRect.bottom, size.width, size.height - frameRect.bottom),
        p);
    canvas.drawRect(
        Rect.fromLTWH(0, frameRect.top, frameRect.left, frameRect.height), p);
    canvas.drawRect(
        Rect.fromLTWH(frameRect.right, frameRect.top,
            size.width - frameRect.right, frameRect.height),
        p);
  }

  @override
  bool shouldRepaint(covariant _OverlayCizici old) =>
      old.frameRect != frameRect;
}

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
    final glow = Paint()
      ..color = renk.withValues(alpha: 0.25 * parlaklik)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    const cL = 28.0;
    const r = 10.0;

    void drawCorner(List<Offset> pts) {
      final path = Path()..moveTo(pts[0].dx, pts[0].dy);
      for (int i = 1; i < pts.length; i++) { path.lineTo(pts[i].dx, pts[i].dy); }
      canvas.drawPath(path, glow);
      canvas.drawPath(path, paint);
    }

    drawCorner([Offset(0, cL), Offset(0, r), Offset(r, 0), Offset(cL, 0)]);
    drawCorner([
      Offset(size.width - cL, 0),
      Offset(size.width - r, 0),
      Offset(size.width, r),
      Offset(size.width, cL)
    ]);
    drawCorner([
      Offset(0, size.height - cL),
      Offset(0, size.height - r),
      Offset(r, size.height),
      Offset(cL, size.height)
    ]);
    drawCorner([
      Offset(size.width, size.height - cL),
      Offset(size.width, size.height - r),
      Offset(size.width - r, size.height),
      Offset(size.width - cL, size.height)
    ]);
  }

  @override
  bool shouldRepaint(covariant _KoseFrameCizici old) =>
      old.renk != renk || old.parlaklik != parlaklik;
}

// ─── ÜST KONTROLLER ──────────────────────────────────────────────────────────

class _UstKontroller extends StatelessWidget {
  final bool flashDestegi;
  final VoidCallback onFlash;
  final VoidCallback? onIptal;

  const _UstKontroller(
      {required this.flashDestegi,
      required this.onFlash,
      required this.onIptal});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      left: 16,
      right: 16,
      child: Row(
        children: [
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
                  Text('İptal',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
          const Spacer(),
          const Text('İlaç Ekle',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3)),
          const Spacer(),
          if (flashDestegi)
            GestureDetector(
              onTap: onFlash,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2), width: 1),
                ),
                child: const Icon(Icons.flash_on_rounded,
                    color: Colors.white, size: 20),
              ),
            )
          else
            const SizedBox(width: 42),
        ],
      ),
    );
  }
}

// ─── ALT BUTONLAR ────────────────────────────────────────────────────────────

class _AltButonlar extends StatelessWidget {
  final VoidCallback onQrManuel;
  final VoidCallback onManuelEkle;
  const _AltButonlar({required this.onQrManuel, required this.onManuelEkle});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Row(
        children: [
          Expanded(
            child: _DemoBtn(
                icon: Icons.qr_code_rounded,
                label: "Kodu Elle Gir",
                renk: AppTheme.primary,
                onTap: onQrManuel),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _DemoBtn(
                icon: Icons.edit_note_rounded,
                label: 'Manuel Ekle',
                renk: AppTheme.warning,
                onTap: onManuelEkle),
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
      {required this.icon,
      required this.label,
      required this.renk,
      required this.onTap});

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
              child: Text(label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: renk,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── ALT PANEL ────────────────────────────────────────────────────────────────

class _AltPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(20, 10, 20, bottomInset + 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 3,
              decoration: BoxDecoration(
                  color: AppTheme.divider,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('İpuçları',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary)),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('3',
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _IpucuSatiri(
              ikon: Icons.qr_code_rounded,
              metin: 'Kutudaki QR veya barkodu okutun'),
          const SizedBox(height: 6),
          _IpucuSatiri(
              ikon: Icons.light_mode_outlined,
              metin: 'Işık yetersizse flaşı kullanın'),
          const SizedBox(height: 6),
          _IpucuSatiri(
              ikon: Icons.keyboard_outlined,
              metin: 'Okutamazsanız kodu elle girin'),
        ],
      ),
    );
  }
}

class _IpucuSatiri extends StatelessWidget {
  final IconData ikon;
  final String metin;
  const _IpucuSatiri({required this.ikon, required this.metin});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(ikon, size: 14, color: AppTheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(metin,
              style: const TextStyle(
                  fontSize: 13, color: AppTheme.textSecondary)),
        ),
      ],
    );
  }
}

// ─── BULUNDU MODALI ───────────────────────────────────────────────────────────

class _BulunduModal extends StatelessWidget {
  final Map<String, String> ilac;
  final VoidCallback onDevamEt;
  final VoidCallback onIptal;

  const _BulunduModal(
      {required this.ilac,
      required this.onDevamEt,
      required this.onIptal});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 28),
      decoration: const BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                    color: AppTheme.successLight,
                    borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.check_circle_outline_rounded,
                    color: AppTheme.success, size: 22),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('İlaç Bulundu!',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary)),
                    Text('Bilgiler otomatik dolduruldu',
                        style: TextStyle(
                            fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
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
                      deger: ilac['doz'] ?? '')),
              const SizedBox(width: 10),
              Expanded(
                  child: _DoluFormSatiri(
                      ikon: Icons.inventory_2_outlined,
                      etiket: 'Miktar',
                      deger: '${ilac['adet']} ${ilac['birim']}')),
            ],
          ),
          const SizedBox(height: 10),
          _DoluFormSatiri(
              ikon: Icons.restaurant_outlined,
              etiket: 'Kullanım Şekli',
              deger: ilac['sekil'] ?? ''),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onIptal,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                        color: AppTheme.background,
                        borderRadius: BorderRadius.circular(14)),
                    child: const Text('İptal',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: onDevamEt,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.success,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                            color: AppTheme.success.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4))
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_forward_rounded,
                            color: Colors.white, size: 16),
                        SizedBox(width: 6),
                        Text('Devam Et',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700)),
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

// ─── BULUNAMADI MODALI ────────────────────────────────────────────────────────

class _BulunamadiModal extends StatelessWidget {
  final String barkod;
  final VoidCallback onManuelDevam;
  final VoidCallback onIptal;

  const _BulunamadiModal(
      {required this.barkod,
      required this.onManuelDevam,
      required this.onIptal});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 28),
      decoration: const BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
                color: AppTheme.warningLight,
                borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.search_off_rounded,
                color: AppTheme.warning, size: 26),
          ),
          const SizedBox(height: 14),
          const Text('İlaç Bulunamadı',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary)),
          const SizedBox(height: 6),
          Text('Barkod ($barkod)\nveritabanında bulunamadı.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13, color: AppTheme.textSecondary)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: onIptal,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                        color: AppTheme.background,
                        borderRadius: BorderRadius.circular(14)),
                    child: const Text('Tekrar Tara',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: onManuelDevam,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                            color: AppTheme.primary.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4))
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit_note_rounded,
                            color: Colors.white, size: 16),
                        SizedBox(width: 6),
                        Text('Manuel Gir',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700)),
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

// ─── QR MANUEL GİRİŞ ─────────────────────────────────────────────────────────

class _QrManuelModal extends StatefulWidget {
  final void Function(String) onSorgula;
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
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.qr_code_rounded,
                      color: AppTheme.primary, size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Barkodu Elle Gir",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary)),
                      Text('Kutudaki barkod numarasını girin',
                          style: TextStyle(
                              fontSize: 12, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
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
                    letterSpacing: 2),
                decoration: const InputDecoration(
                  hintText: '0000000000000',
                  hintStyle: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 2),
                  prefixIcon:
                      Icon(Icons.pin_outlined, color: AppTheme.primary, size: 22),
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
                onChanged: (v) => setState(() => _bos = v.trim().isEmpty),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: widget.onIptal,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                          color: AppTheme.background,
                          borderRadius: BorderRadius.circular(14)),
                      child: const Text('İptal',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary)),
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
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_rounded,
                              color: Colors.white, size: 16),
                          SizedBox(width: 6),
                          Text('Sorgula',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700)),
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

// ─── DOZ AYARLARI SAYFASI ─────────────────────────────────────────────────────

const _dozRenkleri = [
  AppTheme.primary,
  AppTheme.success,
  AppTheme.warning,
  Color(0xFF8B2FE8),
  AppTheme.critical,
  Color(0xFF00BCD4),
  Color(0xFFFF6B6B),
];

class DozAyarlariSayfasi extends StatefulWidget {
  final Map<String, String>? ilacBilgisi;
  final VoidCallback onKaydet;
  final VoidCallback onIptal;

  const DozAyarlariSayfasi({
    super.key,
    required this.ilacBilgisi,
    required this.onKaydet,
    required this.onIptal,
  });

  @override
  State<DozAyarlariSayfasi> createState() => _DozAyarlariSayfasiState();
}

class _DozAyarlariSayfasiState extends State<DozAyarlariSayfasi> {
  final _adCtrl = TextEditingController();
  final _dozCtrl = TextEditingController();
  final _adetCtrl = TextEditingController();

  String _gunlukDoz = 'Günde 1x';
  String _kullanimSekli = 'Tok karna';
  final List<_AlimZamani> _alimZamanlari = [];
  DateTime _baslangicTarihi = DateTime.now();

  final _gunlukDozlar = ['Günde 1x', 'Günde 2x', 'Günde 3x', 'Haftada 1x'];
  final _sekiller = ['Tok karna', 'Aç karna', 'Fark etmez'];

  @override
  void initState() {
    super.initState();
    final b = widget.ilacBilgisi;
    if (b != null) {
      _adCtrl.text = b['ad'] ?? '';
      _dozCtrl.text = b['doz'] ?? '';
      _adetCtrl.text = b['adet'] ?? '';
      _gunlukDoz = b['kullanim'] ?? 'Günde 1x';
      _kullanimSekli = b['sekil'] ?? 'Tok karna';
      final zamanStr = b['zaman'] ?? '';
      for (final z in zamanStr.split(',')) {
        final isim = z.trim();
        if (isim.isNotEmpty) {
          final saat = _varsayilanSaat(isim);
          _alimZamanlari
              .add(_AlimZamani(isim: isim, saat: saat));
        }
      }
    }
    // En az 1 zaman olsun
    if (_alimZamanlari.isEmpty) {
      _alimZamanlari.add(_AlimZamani(isim: 'Sabah', saat: const TimeOfDay(hour: 8, minute: 0)));
    }
  }

  TimeOfDay _varsayilanSaat(String isim) {
    switch (isim) {
      case 'Sabah': return const TimeOfDay(hour: 8, minute: 0);
      case 'Öğle': return const TimeOfDay(hour: 12, minute: 0);
      case 'Akşam': return const TimeOfDay(hour: 18, minute: 0);
      case 'Gece': return const TimeOfDay(hour: 22, minute: 0);
      default: return const TimeOfDay(hour: 9, minute: 0);
    }
  }

  @override
  void dispose() {
    _adCtrl.dispose();
    _dozCtrl.dispose();
    _adetCtrl.dispose();
    super.dispose();
  }

  Future<void> _kaydetVeKapat() async {
    final ad = _adCtrl.text.trim();
    if (ad.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('İlaç adı boş olamaz'),
        backgroundColor: AppTheme.critical,
      ));
      return;
    }

    final adet = int.tryParse(_adetCtrl.text.trim()) ?? 30;
    final ilkSaat = _alimZamanlari.first.saat;
    final saatStr =
        '${ilkSaat.hour.toString().padLeft(2, '0')}:${ilkSaat.minute.toString().padLeft(2, '0')}';

    final renkIdx = IlacDepo.ilaclar.value.length % _dozRenkleri.length;
    final renk = _dozRenkleri[renkIdx];

    KullanimZamani zamanEnum;
    final h = ilkSaat.hour;
    if (h >= 6 && h < 12) {
      zamanEnum = KullanimZamani.sabah;
    } else if (h >= 12 && h < 17) {
      zamanEnum = KullanimZamani.ogle;
    } else if (h >= 17 && h < 21) {
      zamanEnum = KullanimZamani.aksam;
    } else {
      zamanEnum = KullanimZamani.gece;
    }

    const tur = IlacTuru.tablet;

    final kullanimBilgisi =
        '$_gunlukDoz · $_kullanimSekli';

    final yeniIlac = Ilac(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      ad: ad,
      doz: _dozCtrl.text.trim().isEmpty ? '-' : _dozCtrl.text.trim(),
      saat: saatStr,
      durum: IlacDurumu.bekliyor,
      tur: tur,
      renk: renk,
      not: _kullanimSekli,
      kalanAdet: adet,
      toplamAdet: adet,
      kullanimBilgisi: kullanimBilgisi,
      zaman: zamanEnum,
      birim: 'tablet',
    );

    await IlacDepo.ekle(yeniIlac);
    widget.onKaydet();
  }

  void _zamanEkle() {
    final yeniZaman = _AlimZamani(
        isim: 'Doz ${_alimZamanlari.length + 1}',
        saat: const TimeOfDay(hour: 9, minute: 0));
    setState(() => _alimZamanlari.add(yeniZaman));
  }

  void _zamanSil(int index) {
    if (_alimZamanlari.length <= 1) return;
    setState(() => _alimZamanlari.removeAt(index));
  }

  Future<void> _saatSec(int index) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _alimZamanlari[index].saat,
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _alimZamanlari[index] = _AlimZamani(
          isim: _alimZamanlari[index].isim, saat: picked));
    }
  }

  Future<void> _tarihSec() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _baslangicTarihi,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _baslangicTarihi = picked);
  }

  @override
  Widget build(BuildContext context) {
    final bool ilacBulundu = widget.ilacBilgisi != null;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // ── Header ────────────────────────────────────────────────────────
          Container(
            color: const Color(0xFF3B6CF6),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: widget.onIptal,
                          child: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: Colors.white70, size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Kullanım Ayarları',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            ilacBulundu ? 'Otomatik' : 'Manuel',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      ilacBulundu
                          ? 'Günlük dozunuzu ve saatlerinizi ayarlayın'
                          : 'İlaç bilgilerini ve dozunuzu girin',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Form ──────────────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BolumBaslik('İlaç Bilgileri',
                      ikon: Icons.medication_outlined),
                  const SizedBox(height: 12),
                  _GirisAlani(
                    ctrl: _adCtrl,
                    hint: 'İlaç adı',
                    ikon: Icons.medication_outlined,
                    readOnly: ilacBulundu,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _GirisAlani(
                          ctrl: _dozCtrl,
                          hint: 'Doz (mg)',
                          ikon: Icons.science_outlined,
                          klavye: TextInputType.text,
                          readOnly: ilacBulundu,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _GirisAlani(
                          ctrl: _adetCtrl,
                          hint: 'Toplam adet',
                          ikon: Icons.inventory_2_outlined,
                          klavye: TextInputType.number,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  _BolumBaslik('Günlük Doz', ikon: Icons.repeat_rounded),
                  const SizedBox(height: 12),
                  _ChipSecici(
                    secenekler: _gunlukDozlar,
                    secili: _gunlukDoz,
                    onSecildi: (v) => setState(() => _gunlukDoz = v),
                  ),

                  const SizedBox(height: 24),
                  _BolumBaslik('Alım Saatleri', ikon: Icons.access_time_rounded),
                  const SizedBox(height: 12),
                  ..._alimZamanlari.asMap().entries.map((e) {
                    final i = e.key;
                    final z = e.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _SaatKarti(
                        isim: z.isim,
                        saat: z.saat,
                        silinebilir: _alimZamanlari.length > 1,
                        onSaatSec: () => _saatSec(i),
                        onSil: () => _zamanSil(i),
                        onIsimDegis: (yeni) => setState(
                          () => _alimZamanlari[i] =
                              _AlimZamani(isim: yeni, saat: z.saat),
                        ),
                      ),
                    );
                  }),
                  GestureDetector(
                    onTap: _zamanEkle,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppTheme.primary.withValues(alpha: 0.3),
                            width: 1),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_rounded,
                              color: AppTheme.primary, size: 18),
                          SizedBox(width: 6),
                          Text('Saat Ekle',
                              style: TextStyle(
                                  color: AppTheme.primary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  _BolumBaslik('Kullanım Şekli',
                      ikon: Icons.restaurant_outlined),
                  const SizedBox(height: 12),
                  _ChipSecici(
                    secenekler: _sekiller,
                    secili: _kullanimSekli,
                    onSecildi: (v) => setState(() => _kullanimSekli = v),
                  ),

                  const SizedBox(height: 24),
                  _BolumBaslik('Başlangıç Tarihi',
                      ikon: Icons.calendar_today_outlined),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _tarihSec,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.cardBackground,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: AppShadow.card,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month_outlined,
                              color: AppTheme.primary, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '${_baslangicTarihi.day}.${_baslangicTarihi.month}.${_baslangicTarihi.year}',
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary),
                            ),
                          ),
                          const Icon(Icons.keyboard_arrow_right_rounded,
                              color: AppTheme.textSecondary),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: _kaydetVeKapat,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                              color: AppTheme.primary.withValues(alpha: 0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 6))
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_rounded,
                              color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text('İlacı Kaydet',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlimZamani {
  final String isim;
  final TimeOfDay saat;
  _AlimZamani({required this.isim, required this.saat});
}

// ─── DOZ SAYFASI YARDIMCI WİDGETLER ─────────────────────────────────────────

class _BolumBaslik extends StatelessWidget {
  final String baslik;
  final IconData ikon;
  const _BolumBaslik(this.baslik, {required this.ikon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(ikon, size: 16, color: AppTheme.primary),
        const SizedBox(width: 8),
        Text(baslik,
            style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary)),
      ],
    );
  }
}

class _GirisAlani extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final IconData ikon;
  final TextInputType klavye;
  final bool readOnly;

  const _GirisAlani({
    required this.ctrl,
    required this.hint,
    required this.ikon,
    this.klavye = TextInputType.text,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      keyboardType: klavye,
      readOnly: readOnly,
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
        fillColor:
            readOnly ? AppTheme.divider : AppTheme.cardBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      ),
    );
  }
}

class _SaatKarti extends StatelessWidget {
  final String isim;
  final TimeOfDay saat;
  final bool silinebilir;
  final VoidCallback onSaatSec;
  final VoidCallback onSil;
  final ValueChanged<String> onIsimDegis;

  const _SaatKarti({
    required this.isim,
    required this.saat,
    required this.silinebilir,
    required this.onSaatSec,
    required this.onSil,
    required this.onIsimDegis,
  });

  @override
  Widget build(BuildContext context) {
    final saatStr =
        '${saat.hour.toString().padLeft(2, '0')}:${saat.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppShadow.card,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.access_alarm_rounded,
                color: AppTheme.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isim,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary)),
                Text('Alım vakti',
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          GestureDetector(
            onTap: onSaatSec,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(saatStr,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary)),
            ),
          ),
          if (silinebilir) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onSil,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                    color: AppTheme.criticalLight,
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.close_rounded,
                    color: AppTheme.critical, size: 16),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ChipSecici extends StatelessWidget {
  final List<String> secenekler;
  final String secili;
  final ValueChanged<String> onSecildi;

  const _ChipSecici(
      {required this.secenekler,
      required this.secili,
      required this.onSecildi});

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
              color: aktif ? AppTheme.primary : AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                  color: aktif ? AppTheme.primary : AppTheme.divider,
                  width: 1.5),
              boxShadow: aktif ? [] : AppShadow.card,
            ),
            child: Text(s,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: aktif ? Colors.white : AppTheme.textSecondary)),
          ),
        );
      }).toList(),
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
          borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(ikon, size: 16, color: AppTheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(etiket,
                    style: const TextStyle(
                        fontSize: 10, color: AppTheme.textSecondary)),
                Text(deger,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
