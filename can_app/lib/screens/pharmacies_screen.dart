import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme.dart';

class GercekEczane {
  final String id;
  final String ad;
  final String adres;
  final double lat;
  final double lon;
  final String telefon;
  final String openingHours;
  bool acik;
  bool nobetci;
  double mesafe;

  GercekEczane({
    required this.id,
    required this.ad,
    required this.adres,
    required this.lat,
    required this.lon,
    this.telefon = '',
    this.openingHours = '',
    this.acik = false,
    this.nobetci = false,
    this.mesafe = 0,
  });
}

class PharmaciesScreen extends StatefulWidget {
  const PharmaciesScreen({super.key});

  @override
  State<PharmaciesScreen> createState() => _PharmaciesScreenState();
}

class _PharmaciesScreenState extends State<PharmaciesScreen> {
  final MapController _mapController = MapController();
  LatLng? _konumum;
  List<GercekEczane> _eczaneler = [];
  bool _yukleniyor = true;
  String? _hata;
  String _aramaMetni = '';
  String _secilenFiltre = 'Tümü';
  final TextEditingController _aramaKontrol = TextEditingController();
  final List<String> _filtreler = ['Tümü', 'Şimdi Açık', 'Nöbetçi', 'En Yakın'];

  List<GercekEczane> get _filtrelenenEczaneler {
    var liste = _eczaneler.where((e) {
      if (_aramaMetni.isNotEmpty) {
        return e.ad.toLowerCase().contains(_aramaMetni.toLowerCase()) ||
            e.adres.toLowerCase().contains(_aramaMetni.toLowerCase());
      }
      return true;
    }).toList();

    if (_secilenFiltre == 'Şimdi Açık') {
      liste = liste.where((e) => e.acik).toList();
    } else if (_secilenFiltre == 'Nöbetçi') {
      liste = liste.where((e) => e.nobetci).toList();
    } else if (_secilenFiltre == 'En Yakın') {
      liste.sort((a, b) => a.mesafe.compareTo(b.mesafe));
    }
    return liste;
  }

  @override
  void initState() {
    super.initState();
    _konumAl();
  }

  @override
  void dispose() {
    _aramaKontrol.dispose();
    super.dispose();
  }

  Future<void> _konumAl() async {
    setState(() {
      _yukleniyor = true;
      _hata = null;
    });

    try {
      LocationPermission izin = await Geolocator.checkPermission();
      if (izin == LocationPermission.denied) {
        izin = await Geolocator.requestPermission();
      }
      if (izin == LocationPermission.deniedForever ||
          izin == LocationPermission.denied) {
        setState(() {
          _hata = 'Konum izni verilmedi.';
          _yukleniyor = false;
        });
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      final konum = LatLng(pos.latitude, pos.longitude);
      setState(() => _konumum = konum);
      await _eczaneleriGetir(konum);
    } catch (e) {
      setState(() {
        _hata = 'Konum alınamadı: $e';
        _yukleniyor = false;
      });
    }
  }

  Future<void> _eczaneleriGetir(LatLng merkez) async {
    const yariCap = 20000;
    final query = '''
[out:json][timeout:25];
(
  node["amenity"="pharmacy"](around:$yariCap,${merkez.latitude},${merkez.longitude});
  way["amenity"="pharmacy"](around:$yariCap,${merkez.latitude},${merkez.longitude});
);
out center tags;
''';

    try {
      final resp = await http.post(
        Uri.parse('https://overpass-api.de/api/interpreter'),
        body: query,
      );

      if (resp.statusCode != 200) {
        setState(() {
          _hata = 'Eczane verisi alınamadı.';
          _yukleniyor = false;
        });
        return;
      }

      final data = jsonDecode(utf8.decode(resp.bodyBytes));
      final elements = data['elements'] as List;

      final List<GercekEczane> liste = [];
      for (final el in elements) {
        final tags = el['tags'] as Map<String, dynamic>? ?? {};
        double lat, lon;
        if (el['type'] == 'way') {
          lat = (el['center']['lat'] as num).toDouble();
          lon = (el['center']['lon'] as num).toDouble();
        } else {
          lat = (el['lat'] as num).toDouble();
          lon = (el['lon'] as num).toDouble();
        }

        final String ad = tags['name'] ??
            tags['name:tr'] ??
            'Eczane';
        final String adres = [
          tags['addr:street'],
          tags['addr:housenumber'],
          tags['addr:district'],
        ].where((s) => s != null).join(' ');
        final String telefon = tags['phone'] ?? tags['contact:phone'] ?? '';
        final String oh = tags['opening_hours'] ?? '';

        final mesafe = _haversine(merkez.latitude, merkez.longitude, lat, lon);
        final acik = _acikMi(oh);
        final nobetci = _nobetciMi(oh, ad);

        liste.add(GercekEczane(
          id: el['id'].toString(),
          ad: ad,
          adres: adres.isEmpty ? 'Adres bilgisi yok' : adres,
          lat: lat,
          lon: lon,
          telefon: telefon,
          openingHours: oh,
          acik: acik,
          nobetci: nobetci,
          mesafe: mesafe,
        ));
      }

      liste.sort((a, b) => a.mesafe.compareTo(b.mesafe));

      setState(() {
        _eczaneler = liste;
        _yukleniyor = false;
      });
    } catch (e) {
      setState(() {
        _hata = 'Veri yüklenirken hata: $e';
        _yukleniyor = false;
      });
    }
  }

  double _haversine(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371000.0;
    final dLat = _rad(lat2 - lat1);
    final dLon = _rad(lon2 - lon1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_rad(lat1)) * cos(_rad(lat2)) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return (r * c / 1000); // km
  }

  double _rad(double deg) => deg * pi / 180;

  bool _acikMi(String oh) {
    if (oh.isEmpty) return false;
    if (oh.contains('24/7')) return true;
    final now = DateTime.now();
    final gun = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'][now.weekday - 1];
    if (!oh.contains(gun) && !oh.contains('Mo-Fr') && !oh.contains('Mo-Su')) {
      return false;
    }
    final match = RegExp(r'(\d{2}):(\d{2})-(\d{2}):(\d{2})').firstMatch(oh);
    if (match == null) return false;
    final acilis = TimeOfDay(
        hour: int.parse(match.group(1)!), minute: int.parse(match.group(2)!));
    final kapanis = TimeOfDay(
        hour: int.parse(match.group(3)!), minute: int.parse(match.group(4)!));
    final simdi = TimeOfDay.now();
    final acilisDk = acilis.hour * 60 + acilis.minute;
    final kapanisDk = kapanis.hour * 60 + kapanis.minute;
    final simdiDk = simdi.hour * 60 + simdi.minute;
    return simdiDk >= acilisDk && simdiDk <= kapanisDk;
  }

  bool _nobetciMi(String oh, String ad) {
    if (oh.contains('24/7')) return true;
    final adLower = ad.toLowerCase();
    if (adLower.contains('nöbetçi') || adLower.contains('nobetci')) {
      return true;
    }
    return false;
  }

  void _araYol(GercekEczane e) async {
    final appleUrl =
        Uri.parse('maps://maps.apple.com/?daddr=${e.lat},${e.lon}');
    final googleUrl =
        Uri.parse('https://www.google.com/maps/dir/?api=1&destination=${e.lat},${e.lon}');
    if (await canLaunchUrl(appleUrl)) {
      launchUrl(appleUrl);
    } else {
      launchUrl(googleUrl, mode: LaunchMode.externalApplication);
    }
  }

  void _ara(GercekEczane e) async {
    if (e.telefon.isEmpty) return;
    final tel = e.telefon.replaceAll(' ', '').replaceAll('-', '');
    final uri = Uri.parse('tel:$tel');
    if (await canLaunchUrl(uri)) launchUrl(uri);
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
            if (_yukleniyor)
              const Expanded(
                  child: Center(child: CircularProgressIndicator()))
            else if (_hata != null)
              Expanded(child: _buildHata())
            else ...[
              _buildHarita(),
              Expanded(child: _buildEczaneListesi()),
            ],
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
          GestureDetector(
            onTap: _konumAl,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.cardBackground,
                borderRadius: BorderRadius.circular(12),
                boxShadow: AppShadow.card,
              ),
              child: const Icon(Icons.refresh_rounded,
                  color: AppTheme.textPrimary, size: 20),
            ),
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
            hintStyle:
                const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
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

  Widget _buildHarita() {
    final filtreEczaneler = _filtrelenenEczaneler;
    final nobetciSayi = _eczaneler.where((e) => e.nobetci).length;
    final acikSayi = _eczaneler.where((e) => e.acik).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppShadow.card,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _konumum ?? const LatLng(41.015, 28.979),
                  initialZoom: 15,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.can_app',
                  ),
                  MarkerLayer(
                    markers: [
                      if (_konumum != null)
                        Marker(
                          point: _konumum!,
                          width: 28,
                          height: 28,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                )
                              ],
                            ),
                          ),
                        ),
                      ...filtreEczaneler.map((e) => Marker(
                            point: LatLng(e.lat, e.lon),
                            width: 32,
                            height: 38,
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: e.nobetci
                                        ? AppTheme.warning
                                        : e.acik
                                            ? AppTheme.success
                                            : AppTheme.textSecondary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                      Icons.local_pharmacy_outlined,
                                      color: Colors.white,
                                      size: 12),
                                ),
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: e.nobetci
                                        ? AppTheme.warning
                                        : e.acik
                                            ? AppTheme.success
                                            : AppTheme.textSecondary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ],
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
                        '$acikSayi Açık · $nobetciSayi Nöbetçi',
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
              Positioned(
                right: 12,
                bottom: 12,
                child: GestureDetector(
                  onTap: () {
                    if (_konumum != null) {
                      _mapController.move(_konumum!, 15);
                    }
                  },
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHata() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_off_rounded,
                size: 48, color: AppTheme.textSecondary),
            const SizedBox(height: 12),
            Text(_hata!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _konumAl,
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
              child: const Text('Tekrar Dene',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEczaneListesi() {
    final eczaneler = _filtrelenenEczaneler;
    if (eczaneler.isEmpty) {
      return const Center(
        child: Text('Bu filtreye uygun eczane bulunamadı.',
            style: TextStyle(color: AppTheme.textSecondary)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      itemCount: eczaneler.length,
      itemBuilder: (_, i) => _EczaneKarti(
        eczane: eczaneler[i],
        onAra: () => _ara(eczaneler[i]),
        onYol: () => _araYol(eczaneler[i]),
        onHaritaGoster: () {
          _mapController.move(LatLng(eczaneler[i].lat, eczaneler[i].lon), 17);
        },
      ),
    );
  }
}

class _EczaneKarti extends StatelessWidget {
  final GercekEczane eczane;
  final VoidCallback onAra;
  final VoidCallback onYol;
  final VoidCallback onHaritaGoster;

  const _EczaneKarti({
    required this.eczane,
    required this.onAra,
    required this.onYol,
    required this.onHaritaGoster,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onHaritaGoster,
      child: Container(
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
                  color: eczane.nobetci
                      ? const Color(0xFFFFF8E1)
                      : eczane.acik
                          ? AppTheme.successLight
                          : AppTheme.divider,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.local_pharmacy_outlined,
                  color: eczane.nobetci
                      ? AppTheme.warning
                      : eczane.acik
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
                        if (eczane.nobetci)
                          _EtiketWidget(
                              label: 'Nöbetçi', renk: AppTheme.warning)
                        else
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
                        const Icon(Icons.location_on_outlined,
                            size: 13, color: AppTheme.textSecondary),
                        const SizedBox(width: 3),
                        Text(
                          '${eczane.mesafe.toStringAsFixed(2)} km',
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.textSecondary),
                        ),
                        if (eczane.openingHours.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              eczane.openingHours,
                              style: const TextStyle(
                                  fontSize: 11, color: AppTheme.textSecondary),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                children: [
                  if (eczane.telefon.isNotEmpty)
                    _IkonButon(
                      ikon: Icons.phone_outlined,
                      renk: AppTheme.primary,
                      bgRenk: AppTheme.primaryLight,
                      onTap: onAra,
                    ),
                  if (eczane.telefon.isNotEmpty) const SizedBox(height: 8),
                  _IkonButon(
                    ikon: Icons.directions_outlined,
                    renk: AppTheme.success,
                    bgRenk: AppTheme.successLight,
                    onTap: onYol,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EtiketWidget extends StatelessWidget {
  final String label;
  final Color renk;
  const _EtiketWidget({required this.label, required this.renk});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: renk.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: renk,
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
