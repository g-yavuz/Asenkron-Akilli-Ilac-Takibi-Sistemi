import 'package:flutter/material.dart';
import '../theme.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _scanController;
  late Animation<double> _scanAnimation;
  bool _isFlashOn = false;
  bool _isScanning = true;

  final List<Map<String, String>> _recentScans = [
    {
      'name': 'Apranax Fort 550mg',
      'barcode': '4987654321098',
      'time': '2 saat önce',
      'status': 'Eklendi',
    },
    {
      'name': 'Vitamin C 1000mg',
      'barcode': '1234567890123',
      'time': 'Dün',
      'status': 'Eklendi',
    },
    {
      'name': 'Glifor 850mg',
      'barcode': '9876543210987',
      'time': '3 gün önce',
      'status': 'Eklendi',
    },
  ];

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _scanAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildScannerView(),
                    _buildControls(),
                    _buildRecentScans(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          const Text(
            'İlaç Tara',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isScanning ? AppTheme.success : AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _isScanning ? 'Aktif' : 'Durduruldu',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _isScanning ? AppTheme.primary : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScannerView() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        height: 280,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1F36),
          borderRadius: BorderRadius.circular(24),
          boxShadow: AppShadow.soft,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Background grid
              CustomPaint(
                size: const Size(double.infinity, 280),
                painter: _GridPainter(),
              ),
              // Corner overlays
              const _ScanFrame(),
              // Animated scan line
              AnimatedBuilder(
                animation: _scanAnimation,
                builder: (_, __) => Positioned(
                  top: 40 + (_scanAnimation.value * 160),
                  left: 40,
                  right: 40,
                  child: Container(
                    height: 2,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppTheme.primary.withValues(alpha: 0.8),
                          AppTheme.primary,
                          AppTheme.primary.withValues(alpha: 0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Center label
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _isScanning
                          ? 'Kamerayı barkod veya QR koda tutun'
                          : 'Tarayıcı durduruldu',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: _ControlButton(
              icon: _isFlashOn
                  ? Icons.flash_on_rounded
                  : Icons.flash_off_rounded,
              label: 'Flaş',
              isActive: _isFlashOn,
              onTap: () => setState(() => _isFlashOn = !_isFlashOn),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ControlButton(
              icon: _isScanning
                  ? Icons.pause_circle_outline_rounded
                  : Icons.play_circle_outline_rounded,
              label: _isScanning ? 'Durdur' : 'Devam',
              isActive: false,
              onTap: () {
                setState(() => _isScanning = !_isScanning);
                if (_isScanning) {
                  _scanController.repeat(reverse: true);
                } else {
                  _scanController.stop();
                }
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _ControlButton(
              icon: Icons.keyboard_outlined,
              label: 'Manuel',
              isActive: false,
              onTap: () => _showManualInput(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentScans() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Son Taramalar',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),
          ..._recentScans.map((scan) => _RecentScanCard(scan: scan)),
        ],
      ),
    );
  }

  void _showManualInput() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppTheme.cardBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppTheme.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Barkod Gir',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                autofocus: true,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Barkod numarasını girin...',
                  hintStyle:
                      const TextStyle(color: AppTheme.textSecondary),
                  filled: true,
                  fillColor: AppTheme.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.qr_code_outlined,
                      color: AppTheme.primary),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'İlaç Ara',
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryLight : AppTheme.cardBackground,
          borderRadius: BorderRadius.circular(14),
          boxShadow: AppShadow.card,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isActive ? AppTheme.primary : AppTheme.textPrimary,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive ? AppTheme.primary : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentScanCard extends StatelessWidget {
  final Map<String, String> scan;
  const _RecentScanCard({required this.scan});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardBackground,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppShadow.card,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.qr_code_2_rounded,
                color: AppTheme.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scan['name']!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  scan['barcode']!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.successLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  scan['status']!,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.success,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                scan['time']!,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScanFrame extends StatelessWidget {
  const _ScanFrame();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: CustomPaint(
        painter: _FramePainter(),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1;

    const spacing = 30.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _FramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primary
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const margin = 40.0;
    const cornerLen = 24.0;
    const radius = 8.0;

    final corners = [
      // Top-left
      [
        Offset(margin, margin + cornerLen),
        Offset(margin, margin + radius),
        Offset(margin + radius, margin),
        Offset(margin + cornerLen, margin),
      ],
      // Top-right
      [
        Offset(size.width - margin - cornerLen, margin),
        Offset(size.width - margin - radius, margin),
        Offset(size.width - margin, margin + radius),
        Offset(size.width - margin, margin + cornerLen),
      ],
      // Bottom-left
      [
        Offset(margin, size.height - margin - cornerLen),
        Offset(margin, size.height - margin - radius),
        Offset(margin + radius, size.height - margin),
        Offset(margin + cornerLen, size.height - margin),
      ],
      // Bottom-right
      [
        Offset(size.width - margin, size.height - margin - cornerLen),
        Offset(size.width - margin, size.height - margin - radius),
        Offset(size.width - margin - radius, size.height - margin),
        Offset(size.width - margin - cornerLen, size.height - margin),
      ],
    ];

    for (final corner in corners) {
      final path = Path()..moveTo(corner[0].dx, corner[0].dy);
      for (int i = 1; i < corner.length; i++) {
        path.lineTo(corner[i].dx, corner[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
