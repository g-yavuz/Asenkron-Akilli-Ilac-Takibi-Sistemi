import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme.dart';

// ─── ANA PROFİL EKRANI ───────────────────────────────────────────────────────

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _remindersEnabled = true;
  bool _refillAlertsEnabled = true;
  bool _healthInsightsEnabled = false;
  bool _biometricEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeader(context),
              _buildSection('BİLDİRİMLER', _buildNotificationSettings()),
              _buildSection('GÜVENLİK', _buildSecuritySettings()),
              _buildSection('TERCİHLER', _buildPreferenceSettings()),
              _buildSection('DESTEK', _buildSupportSettings()),
              _buildLogoutButton(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const HastaBilgileriSayfasi()),
      ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4A90E2), Color(0xFF6EA8F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.3),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.5), width: 2),
                  ),
                  child: ClipOval(
                    child: Container(
                      color: Colors.white.withValues(alpha: 0.2),
                      child: const Icon(Icons.person_outline_rounded,
                          color: Colors.white, size: 36),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Ahmet Yılmaz',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.favorite_outline_rounded,
                      color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Hasta Bilgilerini Görüntüle & Düzenle',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.arrow_forward_ios_rounded,
                      color: Colors.white70, size: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppShadow.card,
            ),
            child: Column(
              children: List.generate(items.length, (i) {
                return Column(
                  children: [
                    items[i],
                    if (i < items.length - 1)
                      Divider(
                          height: 1,
                          indent: 56,
                          endIndent: 16,
                          color: AppTheme.divider),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildNotificationSettings() {
    return [
      _ToggleRow(
        icon: Icons.alarm_outlined,
        iconColor: AppTheme.primary,
        iconBg: AppTheme.primaryLight,
        label: 'İlaç Hatırlatıcıları',
        subtitle: 'Her doz için uyarı alın',
        value: _remindersEnabled,
        onChanged: (v) => setState(() => _remindersEnabled = v),
      ),
      _ToggleRow(
        icon: Icons.inventory_2_outlined,
        iconColor: AppTheme.warning,
        iconBg: AppTheme.warningLight,
        label: 'Stok Uyarıları',
        subtitle: 'Düşük stok bildirimleri',
        value: _refillAlertsEnabled,
        onChanged: (v) => setState(() => _refillAlertsEnabled = v),
      ),
      _ToggleRow(
        icon: Icons.insights_outlined,
        iconColor: const Color(0xFF8B2FE8),
        iconBg: const Color(0xFFF3ECFF),
        label: 'Sağlık Analizleri',
        subtitle: 'Haftalık sağlık raporları',
        value: _healthInsightsEnabled,
        onChanged: (v) => setState(() => _healthInsightsEnabled = v),
      ),
    ];
  }

  List<Widget> _buildSecuritySettings() {
    return [
      _ToggleRow(
        icon: Icons.fingerprint_rounded,
        iconColor: AppTheme.success,
        iconBg: AppTheme.successLight,
        label: 'Biyometrik Giriş',
        subtitle: 'Face ID / Parmak İzi',
        value: _biometricEnabled,
        onChanged: (v) => setState(() => _biometricEnabled = v),
      ),
      _ActionRow(
        icon: Icons.lock_outline_rounded,
        iconColor: AppTheme.textSecondary,
        iconBg: AppTheme.divider,
        label: 'Şifre Değiştir',
        onTap: () {},
      ),
    ];
  }

  List<Widget> _buildPreferenceSettings() {
    return [
      _ActionRow(
        icon: Icons.language_outlined,
        iconColor: AppTheme.primary,
        iconBg: AppTheme.primaryLight,
        label: 'Dil',
        trailing: 'Türkçe',
        onTap: () {},
      ),
      _ActionRow(
        icon: Icons.palette_outlined,
        iconColor: const Color(0xFF8B2FE8),
        iconBg: const Color(0xFFF3ECFF),
        label: 'Görünüm',
        trailing: 'Açık',
        onTap: () {},
      ),
      _ActionRow(
        icon: Icons.share_outlined,
        iconColor: AppTheme.success,
        iconBg: AppTheme.successLight,
        label: 'Sağlık Verilerini Paylaş',
        onTap: () {},
      ),
    ];
  }

  List<Widget> _buildSupportSettings() {
    return [
      _ActionRow(
        icon: Icons.help_outline_rounded,
        iconColor: AppTheme.primary,
        iconBg: AppTheme.primaryLight,
        label: 'Yardım Merkezi',
        onTap: () {},
      ),
      _ActionRow(
        icon: Icons.bug_report_outlined,
        iconColor: AppTheme.warning,
        iconBg: AppTheme.warningLight,
        label: 'Sorun Bildir',
        onTap: () {},
      ),
      _ActionRow(
        icon: Icons.star_outline_rounded,
        iconColor: const Color(0xFFFFB800),
        iconBg: const Color(0xFFFFF8E1),
        label: 'Uygulamayı Değerlendir',
        onTap: () {},
      ),
    ];
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: GestureDetector(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppTheme.criticalLight,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, color: AppTheme.critical, size: 18),
              SizedBox(width: 8),
              Text(
                'Çıkış Yap',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.critical),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── HASTA BİLGİLERİ SAYFASI ─────────────────────────────────────────────────

class HastaBilgileriSayfasi extends StatefulWidget {
  const HastaBilgileriSayfasi({super.key});

  @override
  State<HastaBilgileriSayfasi> createState() => _HastaBilgileriSayfasiState();
}

class _HastaBilgileriSayfasiState extends State<HastaBilgileriSayfasi> {
  bool _editMode = false;

  final _adController = TextEditingController(text: 'Ahmet Yılmaz');
  final _emailController = TextEditingController(text: 'ahmet.yilmaz@mail.com');
  final _telefonController = TextEditingController(text: '0532 000 00 00');
  final _dogumController = TextEditingController(text: '15.03.1985');
  String _cinsiyet = 'Erkek';

  String _kanGrubu = 'A Rh+';
  final _boyController = TextEditingController(text: '178');
  final _kiloController = TextEditingController(text: '82');
  final _kronikController =
      TextEditingController(text: 'Hipertansiyon, Tip 2 Diyabet');
  final _alerjiController = TextEditingController(text: 'Penisilin');

  final _acilKisiController = TextEditingController(text: 'Fatma Yılmaz');
  final _acilTelController = TextEditingController(text: '0533 000 00 00');

  double get _vki {
    final boy = double.tryParse(_boyController.text) ?? 0;
    final kilo = double.tryParse(_kiloController.text) ?? 0;
    if (boy <= 0 || kilo <= 0) return 0;
    return kilo / ((boy / 100) * (boy / 100));
  }

  String get _vkiEtiket {
    final v = _vki;
    if (v == 0) return '—';
    if (v < 18.5) return 'Zayıf';
    if (v < 25.0) return 'Normal';
    if (v < 30.0) return 'Fazla Kilolu';
    return 'Obez';
  }

  Color get _vkiRenk {
    final v = _vki;
    if (v == 0) return AppTheme.textSecondary;
    if (v < 18.5) return AppTheme.warning;
    if (v < 25.0) return AppTheme.success;
    if (v < 30.0) return AppTheme.warning;
    return AppTheme.critical;
  }

  @override
  void dispose() {
    _adController.dispose();
    _emailController.dispose();
    _telefonController.dispose();
    _dogumController.dispose();
    _boyController.dispose();
    _kiloController.dispose();
    _kronikController.dispose();
    _alerjiController.dispose();
    _acilKisiController.dispose();
    _acilTelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.cardBackground,
              borderRadius: BorderRadius.circular(10),
              boxShadow: AppShadow.card,
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded,
                color: AppTheme.textPrimary, size: 16),
          ),
        ),
        title: Text(
          'Hasta Bilgileri',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
            letterSpacing: -0.4,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () => setState(() => _editMode = !_editMode),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _editMode ? AppTheme.primary : AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _editMode ? Icons.check_rounded : Icons.edit_outlined,
                    color: _editMode ? Colors.white : AppTheme.primary,
                    size: 15,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _editMode ? 'Kaydet' : 'Düzenle',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _editMode ? Colors.white : AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Column(
          children: [
            _buildSectionKart(
              baslik: 'KİŞİSEL BİLGİLER',
              ikon: Icons.person_outline_rounded,
              ikonRenk: AppTheme.primary,
              ikonBg: AppTheme.primaryLight,
              children: [
                _buildAlan('Ad Soyad', _adController,
                    ikon: Icons.badge_outlined),
                _buildAlan('Doğum Tarihi', _dogumController,
                    ikon: Icons.cake_outlined,
                    hint: 'GG.AA.YYYY',
                    keyboard: TextInputType.datetime),
                _buildDropdown(
                  baslik: 'Cinsiyet',
                  ikon: Icons.wc_rounded,
                  deger: _cinsiyet,
                  secenekler: const [
                    'Erkek',
                    'Kadın',
                    'Belirtmek İstemiyorum'
                  ],
                  onChanged: (v) => setState(() => _cinsiyet = v!),
                ),
                _buildAlan('Telefon', _telefonController,
                    ikon: Icons.phone_outlined,
                    keyboard: TextInputType.phone),
                _buildAlan('E-posta', _emailController,
                    ikon: Icons.email_outlined,
                    keyboard: TextInputType.emailAddress,
                    isLast: true),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionKart(
              baslik: 'SAĞLIK BİLGİLERİ',
              ikon: Icons.favorite_outline_rounded,
              ikonRenk: AppTheme.critical,
              ikonBg: AppTheme.criticalLight,
              children: [
                _buildDropdown(
                  baslik: 'Kan Grubu',
                  ikon: Icons.water_drop_outlined,
                  deger: _kanGrubu,
                  secenekler: const [
                    'A Rh+', 'A Rh-', 'B Rh+', 'B Rh-',
                    'AB Rh+', 'AB Rh-', '0 Rh+', '0 Rh-'
                  ],
                  onChanged: (v) => setState(() => _kanGrubu = v!),
                  vurgu: true,
                  vurguRenk: AppTheme.critical,
                ),
                Row(
                  children: [
                    Expanded(
                      child: _buildAlan('Boy (cm)', _boyController,
                          ikon: Icons.height_rounded,
                          keyboard: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ]),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildAlan('Kilo (kg)', _kiloController,
                          ikon: Icons.monitor_weight_outlined,
                          keyboard: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ]),
                    ),
                  ],
                ),
                if (!_editMode) _buildVkiGostergesi(),
                _buildAlan('Kronik Hastalıklar', _kronikController,
                    ikon: Icons.medical_information_outlined,
                    maxLines: 2,
                    hint: 'Varsa belirtin'),
                _buildAlan('Alerjiler', _alerjiController,
                    ikon: Icons.warning_amber_rounded,
                    maxLines: 2,
                    hint: 'İlaç, gıda veya madde alerjisi',
                    isLast: true),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionKart(
              baslik: 'ACİL İLETİŞİM',
              ikon: Icons.local_hospital_outlined,
              ikonRenk: const Color(0xFF8B2FE8),
              ikonBg: const Color(0xFFF3ECFF),
              children: [
                _buildAlan('Acil Durum Kişisi', _acilKisiController,
                    ikon: Icons.contact_emergency_outlined),
                _buildAlan('Acil Durum Telefonu', _acilTelController,
                    ikon: Icons.emergency_outlined,
                    keyboard: TextInputType.phone,
                    isLast: true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionKart({
    required String baslik,
    required IconData ikon,
    required Color ikonRenk,
    required Color ikonBg,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(18),
        boxShadow: AppShadow.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                      color: ikonBg,
                      borderRadius: BorderRadius.circular(8)),
                  child: Icon(ikon, color: ikonRenk, size: 14),
                ),
                const SizedBox(width: 10),
                Text(
                  baslik,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                if (_editMode) ...[
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Düzenleniyor',
                      style: TextStyle(
                          fontSize: 10,
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Divider(height: 1, color: AppTheme.divider),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlan(
    String baslik,
    TextEditingController controller, {
    required IconData ikon,
    String? hint,
    int maxLines = 1,
    TextInputType keyboard = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 10 : 14),
      child: _editMode
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(baslik,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary)),
                const SizedBox(height: 5),
                TextField(
                  controller: controller,
                  maxLines: maxLines,
                  keyboardType: keyboard,
                  inputFormatters: inputFormatters,
                  onChanged: (_) => setState(() {}),
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    hintText: hint ?? baslik,
                    hintStyle: TextStyle(
                        color: AppTheme.textSecondary.withValues(alpha: 0.5),
                        fontSize: 14,
                        fontWeight: FontWeight.w400),
                    prefixIcon: Icon(ikon, size: 16, color: AppTheme.primary),
                    filled: true,
                    fillColor: AppTheme.background,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppTheme.divider)),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: AppTheme.divider)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide:
                            BorderSide(color: AppTheme.primary, width: 1.5)),
                  ),
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(ikon, size: 15, color: AppTheme.textSecondary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(baslik,
                          style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      Text(
                        controller.text.isEmpty ? '—' : controller.text,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: controller.text.isEmpty
                              ? AppTheme.textSecondary
                              : AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildDropdown({
    required String baslik,
    required IconData ikon,
    required String deger,
    required List<String> secenekler,
    required ValueChanged<String?> onChanged,
    bool vurgu = false,
    Color? vurguRenk,
  }) {
    final renk = vurgu ? (vurguRenk ?? AppTheme.primary) : AppTheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: _editMode
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(baslik,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary)),
                const SizedBox(height: 5),
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.divider),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: deger,
                      isExpanded: true,
                      icon: Icon(Icons.expand_more_rounded,
                          size: 18, color: AppTheme.textSecondary),
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary),
                      items: secenekler
                          .map((s) =>
                              DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: onChanged,
                    ),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Icon(ikon, size: 15, color: AppTheme.textSecondary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(baslik,
                          style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      Text(deger,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: vurgu ? renk : AppTheme.textPrimary)),
                    ],
                  ),
                ),
                if (vurgu)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: renk.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(deger,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: renk)),
                  ),
              ],
            ),
    );
  }

  Widget _buildVkiGostergesi() {
    final v = _vki;
    if (v == 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _vkiRenk.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _vkiRenk.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(Icons.monitor_heart_outlined, size: 16, color: _vkiRenk),
            const SizedBox(width: 8),
            Text('VKİ',
                style: TextStyle(
                    fontSize: 12,
                    color: _vkiRenk,
                    fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            Text(v.toStringAsFixed(1),
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: _vkiRenk)),
            const SizedBox(width: 6),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _vkiRenk.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(_vkiEtiket,
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _vkiRenk)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── TOGGLE ROW ──────────────────────────────────────────────────────────────

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: iconBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary)),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppTheme.primary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}

// ─── ACTION ROW ──────────────────────────────────────────────────────────────

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final String? trailing;
  final VoidCallback onTap;

  const _ActionRow({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: iconBg, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary)),
            ),
            if (trailing != null) ...[
              Text(trailing!,
                  style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500)),
              const SizedBox(width: 6),
            ],
            Icon(Icons.chevron_right_rounded,
                color: AppTheme.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}

