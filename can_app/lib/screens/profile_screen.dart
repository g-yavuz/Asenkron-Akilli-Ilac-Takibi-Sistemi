import 'package:flutter/material.dart';
import '../theme.dart';

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
              _buildHeader(),
              _buildStatsRow(),
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

  Widget _buildHeader() {
    return Container(
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
            color: AppTheme.primary.withOpacity(0.35),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: Container(
                    color: Colors.white.withOpacity(0.2),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppTheme.success,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Ahmet Yılmaz',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'ahmet.yilmaz@mail.com',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 6),
                _PlanBadge(),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.edit_outlined,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          _buildStatCard(
            icon: Icons.local_fire_department_outlined,
            value: '14',
            label: 'Günlük Seri',
            iconColor: AppTheme.warning,
            bgColor: AppTheme.warningLight,
          ),
          const SizedBox(width: 10),
          _buildStatCard(
            icon: Icons.medication_outlined,
            value: '5',
            label: 'İlaçlarım',
            iconColor: AppTheme.primary,
            bgColor: AppTheme.primaryLight,
          ),
          const SizedBox(width: 10),
          _buildStatCard(
            icon: Icons.check_circle_outline_rounded,
            value: '94%',
            label: 'Uyum Oranı',
            iconColor: AppTheme.success,
            bgColor: AppTheme.successLight,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppShadow.card,
        ),
        child: Column(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
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
            style: const TextStyle(
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
                      const Divider(
                        height: 1,
                        indent: 56,
                        endIndent: 16,
                        color: AppTheme.divider,
                      ),
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
        iconColor: const Color(0xFFAB7AEB),
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
        iconColor: const Color(0xFFAB7AEB),
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
                  color: AppTheme.critical,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlanBadge extends StatelessWidget {
  const _PlanBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.25),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.workspace_premium_outlined,
              color: Colors.white, size: 12),
          SizedBox(width: 4),
          Text(
            'Pro Üye',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

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
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppTheme.primary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}

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
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            if (trailing != null) ...[
              Text(
                trailing!,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 6),
            ],
            const Icon(
              Icons.chevron_right_rounded,
              color: AppTheme.textSecondary,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
