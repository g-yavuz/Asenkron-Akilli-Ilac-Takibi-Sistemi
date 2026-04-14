import 'package:flutter/material.dart';
import '../models/medicine.dart';
import '../theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Ilac> ilaclar = List.from(ornekIlaclar);

  int get alinanSayisi =>
      ilaclar.where((i) => i.durum == IlacDurumu.alindi).length;

  int get atilanSayisi =>
      ilaclar.where((i) => i.durum == IlacDurumu.atildi).length;

  int get stokuBitenSayisi => ilaclar.where((i) => i.bitti).length;

  int get azKalanSayisi =>
      ilaclar.where((i) => i.azKaldi && !i.bitti).length;

  double get uyumOrani {
    final toplam =
        ilaclar.where((i) => i.durum != IlacDurumu.yakinda).length;
    if (toplam == 0) return 0;
    return alinanSayisi / toplam;
  }

  void _ilacAl(String id) {
    setState(() {
      ilaclar = ilaclar.map((ilac) {
        if (ilac.id == id && ilac.durum == IlacDurumu.bekliyor) {
          return Ilac(
            id: ilac.id,
            ad: ilac.ad,
            doz: ilac.doz,
            saat: ilac.saat,
            durum: IlacDurumu.alindi,
            tur: ilac.tur,
            renk: AppTheme.success,
            not: ilac.not,
            kalanAdet: (ilac.kalanAdet - 1).clamp(0, ilac.toplamAdet),
            toplamAdet: ilac.toplamAdet,
            kullanimBilgisi: ilac.kullanimBilgisi,
            zaman: ilac.zaman,
            birim: ilac.birim,
          );
        }
        return ilac;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF3B6CF6),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildUstBaslik()),
          SliverToBoxAdapter(
            child: Container(
              color: AppTheme.background,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildOzetKartlar(),
                  _buildIlaclarBaslik(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    child: Column(
                      children: ilaclar
                          .map((ilac) => _IlacKarti(
                                ilac: ilac,
                                onAl: ilac.durum == IlacDurumu.bekliyor
                                    ? () => _ilacAl(ilac.id)
                                    : null,
                                onDetay: () => _detayGoster(ilac),
                              ))
                          .toList(),
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

  // ── Üst başlık ────────────────────────────────────────────────────────────
  Widget _buildUstBaslik() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF3B6CF6),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 20, 24),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selamlama(),
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Ahmet Yılmaz',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              _BildirimButonu(
                kritikSayisi: stokuBitenSayisi + atilanSayisi,
                onTap: () => _bildirimGoster(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _selamlama() {
    final saat = DateTime.now().hour;
    if (saat < 12) return 'Günaydın 👋';
    if (saat < 18) return 'İyi günler 👋';
    return 'İyi akşamlar 👋';
  }

  // ── Özet kartlar ──────────────────────────────────────────────────────────
  Widget _buildOzetKartlar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
      child: SizedBox(
        height: 168,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            _OzetKarti(
              baslik: 'Alınmayan\nİlaçlar',
              deger: '$atilanSayisi',
              alt: 'doz atlandı',
              ikon: Icons.access_time_rounded,
              renk: AppTheme.warning,
              bgRenk: AppTheme.warningLight,
            ),
            const SizedBox(width: 12),
            _OzetKarti(
              baslik: 'Stokta\nKalmayanlar',
              deger: '$stokuBitenSayisi',
              alt: 'ilaç tükendi  •  $azKalanSayisi az kaldı',
              ikon: Icons.warning_amber_rounded,
              renk: AppTheme.critical,
              bgRenk: AppTheme.criticalLight,
            ),
            const SizedBox(width: 12),
            _UyumKarti(oran: uyumOrani),
          ],
        ),
      ),
    );
  }

  // ── İlaçlarım başlığı ─────────────────────────────────────────────────────
  Widget _buildIlaclarBaslik() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'İlaçlarım',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${ilaclar.length}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.primary,
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Tümünü gör',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _detayGoster(Ilac ilac) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _IlacDetaySheet(ilac: ilac),
    );
  }

  void _bildirimGoster() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BildirimSheet(
        ilaclar: ilaclar,
        onIlacTap: (ilac) {
          Navigator.pop(context);
          _detayGoster(ilac);
        },
      ),
    );
  }
}

// ─── ÖZET KARTI ──────────────────────────────────────────────────────────────

class _OzetKarti extends StatelessWidget {
  final String baslik;
  final String deger;
  final String alt;
  final IconData ikon;
  final Color renk;
  final Color bgRenk;

  const _OzetKarti({
    required this.baslik,
    required this.deger,
    required this.alt,
    required this.ikon,
    required this.renk,
    required this.bgRenk,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 164,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadow.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: bgRenk,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(ikon, color: renk, size: 17),
              ),
              const Spacer(),
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                    color: renk, shape: BoxShape.circle),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            deger,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: renk,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            baslik,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            alt,
            style: TextStyle(
              fontSize: 10,
              color: AppTheme.textSecondary.withValues(alpha: 0.8),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── UYUM KARTI ──────────────────────────────────────────────────────────────

class _UyumKarti extends StatelessWidget {
  final double oran;
  const _UyumKarti({required this.oran});

  @override
  Widget build(BuildContext context) {
    final yuzde = (oran * 100).toInt();
    return Container(
      width: 164,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppShadow.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppTheme.successLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.insights_rounded,
                    color: AppTheme.success, size: 17),
              ),
              const Spacer(),
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                    color: AppTheme.success, shape: BoxShape.circle),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '%$yuzde',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.success,
                  letterSpacing: -1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: oran,
              backgroundColor: AppTheme.successLight,
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppTheme.success),
              minHeight: 5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Kullanım Düzeni',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── BİLDİRİM BUTONU ─────────────────────────────────────────────────────────

class _BildirimButonu extends StatelessWidget {
  final int kritikSayisi;
  final VoidCallback onTap;
  const _BildirimButonu({required this.kritikSayisi, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: const Icon(Icons.notifications_none_rounded,
                color: Colors.white, size: 22),
          ),
          if (kritikSayisi > 0)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: AppTheme.critical,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── İLAÇ KARTI (RENK SİSTEMLİ) ─────────────────────────────────────────────

class _IlacKarti extends StatelessWidget {
  final Ilac ilac;
  final VoidCallback? onAl;
  final VoidCallback onDetay;

  const _IlacKarti({
    required this.ilac,
    this.onAl,
    required this.onDetay,
  });

  // ── Kart rengini belirle ────────────────────────────────────────────────
  Color get _kartBgRenk {
    if (ilac.bitti) return const Color(0xFFFFF5F5);
    if (ilac.azKaldi) return const Color(0xFFFFFAEE);
    if (ilac.durum == IlacDurumu.yakinda ||
        ilac.durum == IlacDurumu.alindi ||
        ilac.durum == IlacDurumu.bekliyor) {
      return ilac.renk.withValues(alpha: 0.03);
    }
    return AppTheme.cardBackground;
  }

  Color? get _kartBorderRenk {
    if (ilac.bitti) return const Color(0xFFFFD0D0);
    if (ilac.azKaldi) return const Color(0xFFFFDFA0);
    if (ilac.durum == IlacDurumu.yakinda ||
        ilac.durum == IlacDurumu.alindi ||
        ilac.durum == IlacDurumu.bekliyor) {
      return ilac.renk.withValues(alpha: 0.18);
    }
    return null;
  }

  List<BoxShadow> get _kartGolge {
    if (ilac.bitti) {
      return [
        BoxShadow(
          color: AppTheme.critical.withValues(alpha: 0.14),
          blurRadius: 20,
          offset: const Offset(0, 5),
        ),
        BoxShadow(
          color: AppTheme.critical.withValues(alpha: 0.06),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];
    }
    if (ilac.azKaldi) {
      return [
        BoxShadow(
          color: AppTheme.warning.withValues(alpha: 0.14),
          blurRadius: 20,
          offset: const Offset(0, 5),
        ),
        BoxShadow(
          color: AppTheme.warning.withValues(alpha: 0.06),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];
    }
    if (ilac.durum == IlacDurumu.yakinda ||
        ilac.durum == IlacDurumu.alindi ||
        ilac.durum == IlacDurumu.bekliyor) {
      return [
        BoxShadow(
          color: ilac.renk.withValues(alpha: 0.08),
          blurRadius: 20,
          offset: const Offset(0, 5),
        ),
        BoxShadow(
          color: ilac.renk.withValues(alpha: 0.03),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];
    }
    return AppShadow.card;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onDetay,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: _kartBgRenk,
          borderRadius: BorderRadius.circular(18),
          border: _kartBorderRenk != null
              ? Border.all(color: _kartBorderRenk!, width: 1.5)
              : null,
          boxShadow: _kartGolge,
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Üst satır: ikon + ad + badge ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _IlacIkonu(ilac: ilac),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // İlaç adı + durum badge
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                ilac.ad,
                                style: TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textPrimary,
                                  letterSpacing: -0.4,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _DurumBadge(ilac: ilac),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Kullanım bilgisi
                        Text(
                          ilac.kullanimBilgisi,
                          style: TextStyle(
                            fontSize: 15,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // ── Orta satır: zaman + al butonu ──
              Row(
                children: [
                  _ZamanChip(zaman: ilac.zaman, saat: ilac.saat),
                  const Spacer(),
                  if (onAl != null) _AlButonu(onTap: onAl!),
                ],
              ),
              const SizedBox(height: 14),

              // ── Stok bilgisi + progress ──
              _StokBolumu(ilac: ilac),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── İLAÇ İKONU ──────────────────────────────────────────────────────────────

class _IlacIkonu extends StatelessWidget {
  final Ilac ilac;
  const _IlacIkonu({required this.ilac});

  IconData get _ikon {
    switch (ilac.tur) {
      case IlacTuru.tablet:
        return Icons.radio_button_checked_outlined;
      case IlacTuru.kapsul:
        return Icons.medication_outlined;
      case IlacTuru.sivi:
        return Icons.water_drop_outlined;
      case IlacTuru.enjeksiyon:
        return Icons.colorize_outlined;
      case IlacTuru.topikal:
        return Icons.healing_outlined;
    }
  }

  Color get _bgRenk {
    if (ilac.bitti) return const Color(0xFFFFD0D0);
    if (ilac.azKaldi) return const Color(0xFFFFDFA0);
    return ilac.renk.withValues(alpha: 0.12);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: _bgRenk,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(_ikon, color: ilac.renk, size: 26),
    );
  }
}

// ─── DURUM BADGE ─────────────────────────────────────────────────────────────

class _DurumBadge extends StatelessWidget {
  final Ilac ilac;
  const _DurumBadge({required this.ilac});

  @override
  Widget build(BuildContext context) {
    Color renk;
    Color bgRenk;
    String metin;
    IconData ikon;

    if (ilac.bitti) {
      renk = AppTheme.critical;
      bgRenk = const Color(0xFFFFD5D5);
      metin = 'Tükendi';
      ikon = Icons.cancel_outlined;
    } else if (ilac.azKaldi) {
      renk = AppTheme.warning;
      bgRenk = const Color(0xFFFFE5B4);
      metin = 'Az kaldı';
      ikon = Icons.warning_amber_rounded;
    } else {
      switch (ilac.durum) {
        case IlacDurumu.alindi:
          renk = ilac.renk;
          bgRenk = ilac.renk.withValues(alpha: 0.10);
          metin = 'Alındı';
          ikon = Icons.check_circle_outline_rounded;
          break;
        case IlacDurumu.bekliyor:
          renk = ilac.renk;
          bgRenk = ilac.renk.withValues(alpha: 0.10);
          metin = 'Bekliyor';
          ikon = Icons.schedule_rounded;
          break;
        case IlacDurumu.atildi:
          renk = AppTheme.critical;
          bgRenk = AppTheme.criticalLight;
          metin = 'Atlandı';
          ikon = Icons.cancel_outlined;
          break;
        case IlacDurumu.yakinda:
          renk = ilac.renk;
          bgRenk = ilac.renk.withValues(alpha: 0.10);
          metin = 'Yakında';
          ikon = Icons.access_time_rounded;
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: bgRenk,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(ikon, size: 12, color: renk),
          const SizedBox(width: 4),
          Text(
            metin,
            style: TextStyle(
              fontSize: 12,
              color: renk,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── ZAMAN CHİP ──────────────────────────────────────────────────────────────

class _ZamanChip extends StatelessWidget {
  final KullanimZamani zaman;
  final String saat;
  const _ZamanChip({required this.zaman, required this.saat});

  IconData get _ikon {
    switch (zaman) {
      case KullanimZamani.sabah:
        return Icons.wb_sunny_outlined;
      case KullanimZamani.ogle:
        return Icons.wb_cloudy_outlined;
      case KullanimZamani.aksam:
        return Icons.wb_twilight_outlined;
      case KullanimZamani.gece:
        return Icons.bedtime_outlined;
    }
  }

  String get _metin {
    switch (zaman) {
      case KullanimZamani.sabah:
        return 'Sabah';
      case KullanimZamani.ogle:
        return 'Öğle';
      case KullanimZamani.aksam:
        return 'Akşam';
      case KullanimZamani.gece:
        return 'Gece';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_ikon, size: 15, color: AppTheme.primary),
          const SizedBox(width: 5),
          Text(
            '$_metin · $saat',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── AL BUTONU ────────────────────────────────────────────────────────────────

class _AlButonu extends StatelessWidget {
  final VoidCallback onTap;
  const _AlButonu({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppTheme.primary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_rounded, color: Colors.white, size: 16),
            SizedBox(width: 6),
            Text(
              'Al',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── STOK BÖLÜMÜ ──────────────────────────────────────────────────────────────

class _StokBolumu extends StatelessWidget {
  final Ilac ilac;
  const _StokBolumu({required this.ilac});

  Color get _progressRenk {
    if (ilac.stokOrani <= 0.0) return AppTheme.critical;
    if (ilac.stokOrani <= 0.2) return AppTheme.critical;
    if (ilac.stokOrani <= 0.35) return AppTheme.warning;
    return AppTheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final renk = _progressRenk;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stok metni
          Row(
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 15,
                color: renk,
              ),
              const SizedBox(width: 6),
              Text(
                'Kalan:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '${ilac.kalanAdet} / ${ilac.toplamAdet} ${ilac.birim}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: renk,
                  letterSpacing: -0.2,
                ),
              ),
              const Spacer(),
              // Yüzde
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: renk.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '%${(ilac.stokOrani * 100).toInt()}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: renk,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ilac.stokOrani,
              backgroundColor: renk.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(renk),
              minHeight: 8,
            ),
          ),
          // Uyarı mesajı
          if (ilac.bitti) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.error_outline_rounded,
                    size: 14, color: AppTheme.critical),
                const SizedBox(width: 5),
                const Expanded(
                  child: Text(
                    'Stok tükendi — en yakın eczaneden temin edin',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.critical,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ] else if (ilac.azKaldi) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.info_outline_rounded,
                    size: 14, color: AppTheme.warning),
                const SizedBox(width: 5),
                const Expanded(
                  child: Text(
                    'Stok azalıyor — yenilemeyi unutmayın',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.warning,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─── İLAÇ DETAY SAYFASI ──────────────────────────────────────────────────────

class _IlacDetaySheet extends StatelessWidget {
  final Ilac ilac;
  const _IlacDetaySheet({required this.ilac});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: ilac.renk.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.medication_outlined,
                    color: ilac.renk, size: 28),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ilac.ad,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    ilac.doz,
                    style: TextStyle(
                        fontSize: 14, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          _DetayRow(
              ikon: Icons.schedule_rounded,
              baslik: 'Kullanım Saati',
              deger: ilac.saat),
          const SizedBox(height: 10),
          _DetayRow(
              ikon: Icons.repeat_rounded,
              baslik: 'Kullanım Şekli',
              deger: ilac.kullanimBilgisi),
          const SizedBox(height: 10),
          _DetayRow(
              ikon: Icons.inventory_2_outlined,
              baslik: 'Kalan Stok',
              deger:
                  '${ilac.kalanAdet} / ${ilac.toplamAdet} ${ilac.birim}'),
          if (ilac.not.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline_rounded,
                      size: 16, color: AppTheme.warning),
                  const SizedBox(width: 8),
                  Text(
                    ilac.not,
                    style: TextStyle(
                        fontSize: 13, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Text('Kapat',
                  style:
                      TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _DetayRow extends StatelessWidget {
  final IconData ikon;
  final String baslik;
  final String deger;
  const _DetayRow(
      {required this.ikon, required this.baslik, required this.deger});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppTheme.primaryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(ikon, color: AppTheme.primary, size: 17),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(baslik,
                style: TextStyle(
                    fontSize: 11, color: AppTheme.textSecondary)),
            Text(
              deger,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ─── BİLDİRİM SAYFASI ────────────────────────────────────────────────────────

class _BildirimSheet extends StatelessWidget {
  final List<Ilac> ilaclar;
  final void Function(Ilac) onIlacTap;
  const _BildirimSheet({required this.ilaclar, required this.onIlacTap});

  List<_Bildirim> get _bildirimler {
    final liste = <_Bildirim>[];

    for (final ilac in ilaclar) {
      if (ilac.durum == IlacDurumu.atildi) {
        liste.add(_Bildirim(
          ilac: ilac,
          baslik: 'Doz atlandı',
          aciklama: '${ilac.ad} · ${ilac.saat} dozunu almadın',
          ikon: Icons.cancel_outlined,
          renk: AppTheme.critical,
          bgRenk: AppTheme.criticalLight,
          oncelik: 0,
        ));
      }
      if (ilac.bitti) {
        liste.add(_Bildirim(
          ilac: ilac,
          baslik: 'Stok tükendi',
          aciklama: '${ilac.ad} için ilaç kalmadı, eczaneden temin edin',
          ikon: Icons.medication_outlined,
          renk: AppTheme.critical,
          bgRenk: AppTheme.criticalLight,
          oncelik: 1,
        ));
      } else if (ilac.azKaldi) {
        liste.add(_Bildirim(
          ilac: ilac,
          baslik: 'Stok azalıyor',
          aciklama: '${ilac.ad} için yalnızca ${ilac.kalanAdet} ${ilac.birim} kaldı',
          ikon: Icons.warning_amber_rounded,
          renk: AppTheme.warning,
          bgRenk: AppTheme.warningLight,
          oncelik: 2,
        ));
      }
      if (ilac.durum == IlacDurumu.bekliyor) {
        liste.add(_Bildirim(
          ilac: ilac,
          baslik: 'Almanın zamanı',
          aciklama: '${ilac.ad} · ${ilac.saat} dozunu almayı unutma',
          ikon: Icons.schedule_rounded,
          renk: ilac.renk,
          bgRenk: ilac.renk.withValues(alpha: 0.10),
          oncelik: 3,
        ));
      }
      if (ilac.durum == IlacDurumu.yakinda) {
        liste.add(_Bildirim(
          ilac: ilac,
          baslik: 'Yakında alınacak',
          aciklama: '${ilac.ad} · ${ilac.saat} saatinde hatırlatılacak',
          ikon: Icons.access_time_rounded,
          renk: ilac.renk,
          bgRenk: ilac.renk.withValues(alpha: 0.10),
          oncelik: 4,
        ));
      }
    }

    liste.sort((a, b) => a.oncelik.compareTo(b.oncelik));
    return liste;
  }

  @override
  Widget build(BuildContext context) {
    final bildirimler = _bildirimler;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
            child: Row(
              children: [
                Text(
                  'Bildirimler',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(width: 8),
                if (bildirimler.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.critical.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${bildirimler.length}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.critical,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (bildirimler.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppTheme.successLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_rounded,
                        color: AppTheme.success, size: 32),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Her şey yolunda!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Şu an için bekleyen bildirim yok.',
                    style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            )
          else
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                itemCount: bildirimler.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final b = bildirimler[index];
                  return GestureDetector(
                    onTap: () => onIlacTap(b.ilac),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: b.bgRenk,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: b.renk.withValues(alpha: 0.18),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: b.renk.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: Icon(b.ikon, color: b.renk, size: 18),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  b.baslik,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: b.renk,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  b.aciklama,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: b.renk.withValues(alpha: 0.6),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _Bildirim {
  final Ilac ilac;
  final String baslik;
  final String aciklama;
  final IconData ikon;
  final Color renk;
  final Color bgRenk;
  final int oncelik;

  const _Bildirim({
    required this.ilac,
    required this.baslik,
    required this.aciklama,
    required this.ikon,
    required this.renk,
    required this.bgRenk,
    required this.oncelik,
  });
}
