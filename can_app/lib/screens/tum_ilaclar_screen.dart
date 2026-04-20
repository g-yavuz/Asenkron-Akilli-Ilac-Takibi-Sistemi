import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/medicine.dart';
import '../services/ilac_depo.dart';
import '../theme.dart';
import 'home_screen.dart';

class TumIlaclarScreen extends StatefulWidget {
  const TumIlaclarScreen({super.key});

  @override
  State<TumIlaclarScreen> createState() => _TumIlaclarScreenState();
}

class _TumIlaclarScreenState extends State<TumIlaclarScreen> {
  List<Ilac> get ilaclar => IlacDepo.ilaclar.value;

  String _aramaMetni = '';
  IlacDurumu? _filtreDurum;

  @override
  void initState() {
    super.initState();
    IlacDepo.ilaclar.addListener(_yenile);
  }

  @override
  void dispose() {
    IlacDepo.ilaclar.removeListener(_yenile);
    super.dispose();
  }

  void _yenile() => setState(() {});

  List<Ilac> get _filtrelenmis {
    var liste = ilaclar;
    if (_aramaMetni.isNotEmpty) {
      final q = _aramaMetni.toLowerCase();
      liste = liste.where((i) => i.ad.toLowerCase().contains(q)).toList();
    }
    if (_filtreDurum != null) {
      liste = liste.where((i) => i.durum == _filtreDurum).toList();
    }
    return liste;
  }

  Future<void> _ilacSil(String id) async {
    final matches = ilaclar.where((i) => i.id == id);
    if (matches.isEmpty) return;
    final ilac = matches.first;
    final onay = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('İlacı Sil',
            style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        content: Text(
          '"${ilac.ad}" adlı ilacı listeden kaldırmak istediğinize emin misiniz?',
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Vazgeç', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sil',
                style: TextStyle(color: AppTheme.critical, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (onay == true) {
      await IlacDepo.sil(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('"${ilac.ad}" silindi'),
          backgroundColor: AppTheme.critical,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          duration: const Duration(seconds: 2),
        ));
      }
    }
  }

  Future<void> _ilacAl(String id) async {
    final matches = ilaclar.where((i) => i.id == id);
    if (matches.isEmpty) return;
    final ilac = matches.first;
    if (ilac.durum != IlacDurumu.bekliyor) return;
    HapticFeedback.mediumImpact();
    await IlacDepo.guncelle(ilac.copyWith(
      durum: IlacDurumu.alindi,
      renk: AppTheme.success,
      kalanAdet: (ilac.kalanAdet - 1).clamp(0, ilac.toplamAdet),
    ));
  }

  void _detayGoster(Ilac ilac) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => IlacDetaySheet(ilac: ilac),
    );
  }

  @override
  Widget build(BuildContext context) {
    final liste = _filtrelenmis;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          const Positioned(
            top: 0, left: 0, right: 0,
            height: 260,
            child: ColoredBox(color: Color(0xFF3B6CF6)),
          ),
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _buildBaslik()),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Container(
                  color: AppTheme.background,
                  child: liste.isEmpty
                      ? _BosListe(
                          aramaAktif: _aramaMetni.isNotEmpty || _filtreDurum != null,
                        )
                      : Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                          child: Column(
                            children: liste
                                .map((ilac) => Dismissible(
                                      key: ValueKey(ilac.id),
                                      direction: DismissDirection.endToStart,
                                      confirmDismiss: (_) async {
                                        await _ilacSil(ilac.id);
                                        return false;
                                      },
                                      background: Container(
                                        margin: const EdgeInsets.only(bottom: 12),
                                        decoration: BoxDecoration(
                                          color: AppTheme.critical.withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(16),
                                        ),
                                        alignment: Alignment.centerRight,
                                        padding: const EdgeInsets.only(right: 20),
                                        child: const Icon(Icons.delete_outline_rounded,
                                            color: AppTheme.critical, size: 24),
                                      ),
                                      child: IlacKarti(
                                        ilac: ilac,
                                        onAl: ilac.durum == IlacDurumu.bekliyor
                                            ? () => _ilacAl(ilac.id)
                                            : null,
                                        onDetay: () => _detayGoster(ilac),
                                      ),
                                    ))
                                .toList(),
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

  Widget _buildBaslik() {
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
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white, size: 18),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tüm İlaçlar',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          '${ilaclar.length} ilaç kayıtlı',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.75),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25), width: 1),
                ),
                child: TextField(
                  onChanged: (v) => setState(() => _aramaMetni = v),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'İlaç ara...',
                    hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55), fontSize: 14),
                    prefixIcon: Icon(Icons.search_rounded,
                        color: Colors.white.withValues(alpha: 0.7), size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FiltreChip(
                      label: 'Tümü',
                      aktif: _filtreDurum == null,
                      onTap: () => setState(() => _filtreDurum = null),
                    ),
                    const SizedBox(width: 8),
                    _FiltreChip(
                      label: 'Bekliyor',
                      aktif: _filtreDurum == IlacDurumu.bekliyor,
                      onTap: () => setState(() => _filtreDurum =
                          _filtreDurum == IlacDurumu.bekliyor
                              ? null
                              : IlacDurumu.bekliyor),
                    ),
                    const SizedBox(width: 8),
                    _FiltreChip(
                      label: 'Alındı',
                      aktif: _filtreDurum == IlacDurumu.alindi,
                      onTap: () => setState(() => _filtreDurum =
                          _filtreDurum == IlacDurumu.alindi
                              ? null
                              : IlacDurumu.alindi),
                    ),
                    const SizedBox(width: 8),
                    _FiltreChip(
                      label: 'Atlandı',
                      aktif: _filtreDurum == IlacDurumu.atildi,
                      onTap: () => setState(() => _filtreDurum =
                          _filtreDurum == IlacDurumu.atildi
                              ? null
                              : IlacDurumu.atildi),
                    ),
                    const SizedBox(width: 8),
                    _FiltreChip(
                      label: 'Yakında',
                      aktif: _filtreDurum == IlacDurumu.yakinda,
                      onTap: () => setState(() => _filtreDurum =
                          _filtreDurum == IlacDurumu.yakinda
                              ? null
                              : IlacDurumu.yakinda),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── FİLTRE CHİP ─────────────────────────────────────────────────────────────

class _FiltreChip extends StatelessWidget {
  final String label;
  final bool aktif;
  final VoidCallback onTap;
  const _FiltreChip({required this.label, required this.aktif, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: aktif ? Colors.white : Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: aktif ? Colors.white : Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: aktif ? const Color(0xFF3B6CF6) : Colors.white,
          ),
        ),
      ),
    );
  }
}

// ─── BOŞ LİSTE ───────────────────────────────────────────────────────────────

class _BosListe extends StatelessWidget {
  final bool aramaAktif;
  const _BosListe({required this.aramaAktif});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 60, 40, 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              shape: BoxShape.circle,
            ),
            child: Icon(
              aramaAktif ? Icons.search_off_rounded : Icons.medication_outlined,
              color: AppTheme.primary,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            aramaAktif ? 'Sonuç bulunamadı' : 'İlaç bulunamadı',
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            aramaAktif
                ? 'Farklı bir arama deneyin'
                : 'Filtre seçimine uyan ilaç yok',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
