import 'package:flutter/material.dart';

enum IlacDurumu { alindi, bekliyor, atildi, yakinda }

enum IlacTuru { tablet, kapsul, sivi, enjeksiyon, topikal }

enum KullanimZamani { sabah, ogle, aksam, gece }

class Ilac {
  final String id;
  final String ad;
  final String doz;
  final String saat;
  final IlacDurumu durum;
  final IlacTuru tur;
  final Color renk;
  final String not;
  final int kalanAdet;
  final int toplamAdet;
  final String kullanimBilgisi;
  final KullanimZamani zaman;
  final String birim;

  const Ilac({
    required this.id,
    required this.ad,
    required this.doz,
    required this.saat,
    required this.durum,
    required this.tur,
    required this.renk,
    this.not = '',
    required this.kalanAdet,
    required this.toplamAdet,
    required this.kullanimBilgisi,
    required this.zaman,
    this.birim = 'tablet',
  });

  double get stokOrani => kalanAdet / (toplamAdet == 0 ? 1 : toplamAdet);
  bool get azKaldi => stokOrani < 0.2;
  bool get bitti => kalanAdet == 0;

  // ── JSON ────────────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
        'id': id,
        'ad': ad,
        'doz': doz,
        'saat': saat,
        'durum': durum.index,
        'tur': tur.index,
        'renk': renk.toARGB32(),
        'not': not,
        'kalanAdet': kalanAdet,
        'toplamAdet': toplamAdet,
        'kullanimBilgisi': kullanimBilgisi,
        'zaman': zaman.index,
        'birim': birim,
      };

  factory Ilac.fromJson(Map<String, dynamic> j) => Ilac(
        id: j['id'] as String,
        ad: j['ad'] as String,
        doz: j['doz'] as String,
        saat: j['saat'] as String,
        durum: IlacDurumu.values[j['durum'] as int],
        tur: IlacTuru.values[j['tur'] as int],
        renk: Color(j['renk'] as int),
        not: j['not'] as String? ?? '',
        kalanAdet: j['kalanAdet'] as int,
        toplamAdet: j['toplamAdet'] as int,
        kullanimBilgisi: j['kullanimBilgisi'] as String,
        zaman: KullanimZamani.values[j['zaman'] as int],
        birim: j['birim'] as String? ?? 'tablet',
      );

  // ── copyWith ─────────────────────────────────────────────────────────────

  Ilac copyWith({
    String? id,
    String? ad,
    String? doz,
    String? saat,
    IlacDurumu? durum,
    IlacTuru? tur,
    Color? renk,
    String? not,
    int? kalanAdet,
    int? toplamAdet,
    String? kullanimBilgisi,
    KullanimZamani? zaman,
    String? birim,
  }) =>
      Ilac(
        id: id ?? this.id,
        ad: ad ?? this.ad,
        doz: doz ?? this.doz,
        saat: saat ?? this.saat,
        durum: durum ?? this.durum,
        tur: tur ?? this.tur,
        renk: renk ?? this.renk,
        not: not ?? this.not,
        kalanAdet: kalanAdet ?? this.kalanAdet,
        toplamAdet: toplamAdet ?? this.toplamAdet,
        kullanimBilgisi: kullanimBilgisi ?? this.kullanimBilgisi,
        zaman: zaman ?? this.zaman,
        birim: birim ?? this.birim,
      );
}

class Eczane {
  final String id;
  final String ad;
  final String adres;
  final double mesafe;
  final bool acik;
  final String calismaInfo;
  final double puan;
  final String telefon;

  const Eczane({
    required this.id,
    required this.ad,
    required this.adres,
    required this.mesafe,
    required this.acik,
    required this.calismaInfo,
    required this.puan,
    required this.telefon,
  });
}
