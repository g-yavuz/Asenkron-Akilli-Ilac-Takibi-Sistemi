import 'package:flutter/material.dart';
import '../models/medicine.dart';
import '../theme.dart';

class PharmaciesScreen extends StatefulWidget {
  const PharmaciesScreen({super.key});

  @override
  State<PharmaciesScreen> createState() => _PharmaciesScreenState();
}

class _PharmaciesScreenState extends State<PharmaciesScreen> {
  String _aramaMetni = '';
  String _secilenFiltre = 'Tümü';
  final TextEditingController _aramaKontrol = TextEditingController();
  final List<String> _filtreler = ['Tümü', 'Şimdi Açık', 'En Yakın', 'En İyi'];

  List<Eczane> get _filtrelenenEczaneler {
    var liste = ornekEczaneler.where((e) {
      if (_aramaMetni.isNotEmpty) {
        return e.ad.toLowerCase().contains(_aramaMetni.toLowerCase()) ||
            e.adres.toLowerCase().contains(_aramaMetni.toLowerCase());
      }
      return true;
    }).toList();

    if (_secilenFiltre == 'Şimdi Açık') {
      liste = liste.where((e) => e.acik).toList();
    } else if (_secilenFiltre == 'En Yakın') {
      liste.sort((a, b) => a.mesafe.compareTo(b.mesafe));
    } else if (_secilenFiltre == 'En İyi') {
      liste.sort((a, b) => b.puan.compareTo(a.puan));
    }
    return liste;
  }

  @override
  void dispose() {
    _aramaKontrol.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildBaslik(),
            _buildArama(),
            _buildFiltreler(),
            _buildHaritaOnizleme(),
            Expanded(child: _buildEczaneListesi()),
          ],
        ),
      ),
    );
  }

  Widget _buildBaslik() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          const Text(
            'Eczaneler',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppShadow.card,
            ),
            child: const Icon(Icons.tune_rounded,
                color: AppTheme.textPrimary, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildArama() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppShadow.card,
        ),
        child: TextField(
          controller: _aramaKontrol,
          onChanged: (v) => setState(() => _aramaMetni = v),
          decoration: InputDecoration(
            hintText: 'Eczane ara...',
            hintStyle: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 14),
            prefixIcon: const Icon(Icons.search_rounded,
                color: AppTheme.textSecondary),
            suffixIcon: _aramaMetni.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _aramaKontrol.clear();
                      setState(() => _aramaMetni = '');
                    },
                    child: const Icon(Icons.close_rounded,
                        color: AppTheme.textSecondary, size: 18),
                  )
                : null,
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildFiltreler() {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        itemCount: _filtreler.length,
        itemBuilder: (_, i) {
          final secili = _secilenFiltre == _filtreler[i];
          return GestureDetector(
            onTap: () => setState(() => _secilenFiltre = _filtreler[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: secili ? AppTheme.primary : AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(20),
                boxShadow: secili ? [] : AppShadow.card,
              ),
              child: Text(
                _filtreler[i],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: secili ? Colors.white : AppTheme.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHaritaOnizleme() {
    final acikSayi = ornekEczaneler.where((e) => e.acik).length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppShadow.card,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              CustomPaint(
                size: const Size(double.infinity, 160),
                painter: _HaritaCizici(),
              ),
              ..._haritaPinleri(),
              Positioned(
                right: 12,
                bottom: 12,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: AppShadow.soft,
                  ),
                  child: const Icon(Icons.my_location_rounded,
                      color: AppTheme.primary, size: 18),
                ),
              ),
              Positioned(
                left: 12,
                top: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppShadow.soft,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: AppTheme.success),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        '$acikSayi Eczane Açık',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _haritaPinleri() {
    final konumlar = [
      const Offset(55, 55),
      const Offset(130, 32),
      const Offset(200, 78),
      const Offset(270, 38),
    ];

    return List.generate(ornekEczaneler.length, (i) {
      final eczane = ornekEczaneler[i];
      final renk = eczane.acik ? AppTheme.primary : AppTheme.textSecondary;
      return Positioned(
        left: konumlar[i].dx,
        top: konumlar[i].dy,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: renk,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: renk.withValues(alpha: 0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.local_pharmacy_outlined,
                  color: Colors.white, size: 12),
            ),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: renk, shape: BoxShape.circle),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildEczaneListesi() {
    final eczaneler = _filtrelenenEczaneler;
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      itemCount: eczaneler.length,
      itemBuilder: (_, i) => _EczaneKarti(eczane: eczaneler[i]),
    );
  }
}

class _EczaneKarti extends StatelessWidget {
  final Eczane eczane;
  const _EczaneKarti({required this.eczane});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadow.card,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: eczane.acik ? AppTheme.successLight : AppTheme.divider,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                Icons.local_pharmacy_outlined,
                color: eczane.acik
                    ? AppTheme.success
                    : AppTheme.textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          eczane.ad,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                      _DurumEtiketi(acik: eczane.acik),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    eczane.adres,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 13, color: Color(0xFFFFB800)),
                      const SizedBox(width: 3),
                      Text(
                        eczane.puan.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.location_on_outlined,
                          size: 13, color: AppTheme.textSecondary),
                      const SizedBox(width: 3),
                      Text(
                        '${eczane.mesafe} km',
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textSecondary),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          eczane.calismaInfo,
                          style: const TextStyle(
                              fontSize: 11, color: AppTheme.textSecondary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              children: [
                _IkonButon(
                  ikon: Icons.phone_outlined,
                  renk: AppTheme.primary,
                  bgRenk: AppTheme.primaryLight,
                  onTap: () {},
                ),
                const SizedBox(height: 8),
                _IkonButon(
                  ikon: Icons.directions_outlined,
                  renk: AppTheme.success,
                  bgRenk: AppTheme.successLight,
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DurumEtiketi extends StatelessWidget {
  final bool acik;
  const _DurumEtiketi({required this.acik});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: acik ? AppTheme.successLight : AppTheme.divider,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        acik ? 'Açık' : 'Kapalı',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: acik ? AppTheme.success : AppTheme.textSecondary,
        ),
      ),
    );
  }
}

class _IkonButon extends StatelessWidget {
  final IconData ikon;
  final Color renk;
  final Color bgRenk;
  final VoidCallback onTap;

  const _IkonButon({
    required this.ikon,
    required this.renk,
    required this.bgRenk,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
            color: bgRenk, borderRadius: BorderRadius.circular(10)),
        child: Icon(ikon, color: renk, size: 16),
      ),
    );
  }
}

class _HaritaCizici extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFFE8F0E9),
    );

    final yolKalin = Paint()
      ..color = Colors.white
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final yolInce = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..strokeWidth = 4;

    canvas.drawLine(Offset(0, size.height * 0.5),
        Offset(size.width, size.height * 0.5), yolKalin);
    canvas.drawLine(Offset(size.width * 0.3, 0),
        Offset(size.width * 0.3, size.height), yolKalin);
    canvas.drawLine(Offset(size.width * 0.7, 0),
        Offset(size.width * 0.7, size.height), yolInce);
    canvas.drawLine(Offset(0, size.height * 0.25),
        Offset(size.width, size.height * 0.25), yolInce);
    canvas.drawLine(Offset(0, size.height * 0.75),
        Offset(size.width, size.height * 0.75), yolInce);

    final blokRenk = Paint()..color = const Color(0xFFD6E4D6);
    final bloklar = [
      Rect.fromLTWH(10, 10, 100, 50),
      Rect.fromLTWH(size.width * 0.35, 10, 110, 40),
      Rect.fromLTWH(size.width * 0.75, 10, 60, 35),
      Rect.fromLTWH(10, size.height * 0.55, 90, 50),
      Rect.fromLTWH(size.width * 0.35, size.height * 0.58, 120, 45),
      Rect.fromLTWH(size.width * 0.75, size.height * 0.55, 70, 40),
    ];
    for (final b in bloklar) {
      canvas.drawRRect(
          RRect.fromRectAndRadius(b, const Radius.circular(4)), blokRenk);
    }

    final locPaint = Paint()..color = AppTheme.primary;
    final locGlowPaint = Paint()
      ..color = AppTheme.primary.withValues(alpha: 0.2);
    final cx = size.width * 0.5;
    final cy = size.height * 0.5;
    canvas.drawCircle(Offset(cx, cy), 16, locGlowPaint);
    canvas.drawCircle(Offset(cx, cy), 8, locPaint);
    canvas.drawCircle(Offset(cx, cy), 4, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_) => false;
}
