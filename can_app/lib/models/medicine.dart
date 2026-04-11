import 'package:flutter/material.dart';
import '../theme.dart';

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
  final String kullanimBilgisi;   // "Günde 2x - Tok karna"
  final KullanimZamani zaman;
  final String birim;             // "tablet", "ml", "kapsül"

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

// Örnek ilaç verileri (Türkçe)
final List<Ilac> ornekIlaclar = [
  const Ilac(
    id: '1',
    ad: 'Apranax Fort',
    doz: '550mg',
    saat: '08:00',
    durum: IlacDurumu.alindi,
    tur: IlacTuru.tablet,
    renk: AppTheme.success,
    not: 'Tok karna alınmalı',
    kalanAdet: 4,
    toplamAdet: 20,
    kullanimBilgisi: 'Günde 2x · Tok karna',
    zaman: KullanimZamani.sabah,
    birim: 'tablet',
  ),
  const Ilac(
    id: '2',
    ad: 'Beloc Zok',
    doz: '50mg',
    saat: '12:00',
    durum: IlacDurumu.bekliyor,
    tur: IlacTuru.tablet,
    renk: AppTheme.primary,
    not: 'Tansiyon ilacı',
    kalanAdet: 22,
    toplamAdet: 30,
    kullanimBilgisi: 'Günde 1x · Tok karna',
    zaman: KullanimZamani.ogle,
    birim: 'tablet',
  ),
  const Ilac(
    id: '3',
    ad: 'Glifor',
    doz: '850mg',
    saat: '14:00',
    durum: IlacDurumu.bekliyor,
    tur: IlacTuru.tablet,
    renk: AppTheme.warning,
    not: 'Yemekle birlikte al',
    kalanAdet: 5,
    toplamAdet: 60,
    kullanimBilgisi: 'Günde 2x · Tok karna',
    zaman: KullanimZamani.ogle,
    birim: 'tablet',
  ),
  const Ilac(
    id: '4',
    ad: 'D-Vit 1000',
    doz: '1000 IU',
    saat: '18:00',
    durum: IlacDurumu.yakinda,
    tur: IlacTuru.kapsul,
    renk: Color(0xFF8B2FE8),
    not: '',
    kalanAdet: 45,
    toplamAdet: 60,
    kullanimBilgisi: 'Günde 1x · Aç veya tok',
    zaman: KullanimZamani.aksam,
    birim: 'kapsül',
  ),
  const Ilac(
    id: '5',
    ad: 'Benexol B12',
    doz: '1000mcg',
    saat: '21:00',
    durum: IlacDurumu.atildi,
    tur: IlacTuru.tablet,
    renk: AppTheme.critical,
    not: 'Akşam yemeğiyle al',
    kalanAdet: 0,
    toplamAdet: 30,
    kullanimBilgisi: 'Günde 1x · Tok karna',
    zaman: KullanimZamani.gece,
    birim: 'tablet',
  ),
];

// Stoku biten ilaçlar
List<Ilac> get stokuBitenler =>
    ornekIlaclar.where((i) => i.bitti).toList();

// Az kalan ilaçlar
List<Ilac> get azKalanlar =>
    ornekIlaclar.where((i) => i.azKaldi && !i.bitti).toList();

// Atılan dozlar
List<Ilac> get atilanlar =>
    ornekIlaclar.where((i) => i.durum == IlacDurumu.atildi).toList();

final List<Eczane> ornekEczaneler = [
  const Eczane(
    id: '1',
    ad: 'Yıldız Eczanesi',
    adres: 'Bağcılar Mah. 142 No, İstanbul',
    mesafe: 0.3,
    acik: true,
    calismaInfo: '22:00\'a kadar açık',
    puan: 4.8,
    telefon: '+90 212 000 0000',
  ),
  const Eczane(
    id: '2',
    ad: 'Güneş Eczanesi',
    adres: 'Merkez Cad. 87, İstanbul',
    mesafe: 0.7,
    acik: true,
    calismaInfo: '21:00\'a kadar açık',
    puan: 4.6,
    telefon: '+90 212 000 0001',
  ),
  const Eczane(
    id: '3',
    ad: 'Nöbetçi Eczane',
    adres: 'Tıp Bulvarı 23, İstanbul',
    mesafe: 1.2,
    acik: false,
    calismaInfo: 'Yarın 08:00\'de açılıyor',
    puan: 4.3,
    telefon: '+90 212 000 0002',
  ),
  const Eczane(
    id: '4',
    ad: 'Sağlık Eczanesi',
    adres: 'Meşe Sok. 56, İstanbul',
    mesafe: 1.8,
    acik: true,
    calismaInfo: '24 saat açık',
    puan: 4.9,
    telefon: '+90 212 000 0003',
  ),
];
