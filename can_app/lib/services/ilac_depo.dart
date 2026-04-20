import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/medicine.dart';

/// Uygulama genelinde ilaç listesini tutan ve SharedPreferences ile
/// local olarak saklayan singleton servis.
class IlacDepo {
  IlacDepo._();

  static const _key = 'ilaclar_v1';

  /// Reaktif ilaç listesi — ValueListenableBuilder ile dinlenebilir
  static final ilaclar = ValueNotifier<List<Ilac>>([]);

  // ── Yükleme ───────────────────────────────────────────────────────────────

  static Future<void> yukle() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null || jsonStr.isEmpty) {
      ilaclar.value = [];
      return;
    }
    try {
      final list = jsonDecode(jsonStr) as List;
      ilaclar.value = list
          .map((e) => Ilac.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      ilaclar.value = [];
    }
  }

  // ── Ekle ──────────────────────────────────────────────────────────────────

  static Future<void> ekle(Ilac ilac) async {
    final yeni = List<Ilac>.from(ilaclar.value)..add(ilac);
    ilaclar.value = yeni;
    await _kaydet();
  }

  // ── Sil ───────────────────────────────────────────────────────────────────

  static Future<void> sil(String id) async {
    final yeni = ilaclar.value.where((e) => e.id != id).toList();
    ilaclar.value = yeni;
    await _kaydet();
  }

  // ── Güncelle (durumu değiştir vb.) ───────────────────────────────────────

  static Future<void> guncelle(Ilac guncel) async {
    final yeni = ilaclar.value
        .map((e) => e.id == guncel.id ? guncel : e)
        .toList();
    ilaclar.value = yeni;
    await _kaydet();
  }

  // ── Hepsini kaydet ────────────────────────────────────────────────────────

  static Future<void> _kaydet([SharedPreferences? prefs]) async {
    final p = prefs ?? await SharedPreferences.getInstance();
    final jsonStr =
        jsonEncode(ilaclar.value.map((e) => e.toJson()).toList());
    await p.setString(_key, jsonStr);
  }

  // ── Tümünü sil (debug/reset) ──────────────────────────────────────────────

  static Future<void> temizle() async {
    ilaclar.value = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
