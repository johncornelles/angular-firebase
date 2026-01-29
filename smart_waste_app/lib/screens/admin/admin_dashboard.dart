import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/schedule_provider.dart';
import '../../config/theme.dart';
import '../../services/firestore_service.dart';
import '../auth/login_screen.dart';
import 'schedule_management.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 0;
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ScheduleProvider>(context, listen: false).initForAdmin();
    });
  }

  Future<void> _loadStats() async {
    try {
      final firestoreService = FirestoreService();
      final stats = await firestoreService.getScheduleStats();
      setState(() {
        _stats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _DashboardContent(stats: _stats, isLoading: _isLoading),
      const ScheduleManagement(),
      _AlertsContent(),
      _AdminSettingsContent(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      body: screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home, 'HOME'),
                _buildNavItem(1, Icons.route, 'ROUTES'),
                _buildNavItem(2, Icons.notifications, 'ALERTS'),
                _buildNavItem(3, Icons.settings, 'SETUP'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.accentGreen : AppTheme.textMuted,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? AppTheme.accentGreen : AppTheme.textMuted,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final Map<String, dynamic>? stats;
  final bool isLoading;

  const _DashboardContent({this.stats, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          expandedHeight: 80,
          floating: false,
          pinned: true,
          backgroundColor: AppTheme.surfaceDark,
          leading: Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.accentGreen,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.recycling,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          title: const Text(
            'EcoTrack',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.gold.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.gold.withOpacity(0.5)),
              ),
              child: Text(
                'ADMIN',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.gold,
                ),
              ),
            ),
          ],
        ),

        // Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text(
                  'System Overview',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  'Live updates from monitoring nodes',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                // Active Zones Card
                _buildMainStatCard(
                  'Active Collection Zones',
                  '${stats?['totalZones'] ?? 0}',
                  '+2% vs last week',
                  Icons.location_city,
                ),
                const SizedBox(height: 16),

                // Stats Row
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'TODAY PICKUPS',
                        '${stats?['todayPickups'] ?? 0}',
                        Icons.local_shipping,
                        AppTheme.accentGreen,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        'DELAYED',
                        '${stats?['delayedCount'] ?? 0}',
                        Icons.warning,
                        AppTheme.statusDelayed,
                        subtitle: '-5% IMPROVEMENT',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Schedule Management Button
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ScheduleManagement(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.accentGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.calendar_today, color: Colors.white),
                        SizedBox(width: 12),
                        Text(
                          'Schedule Management',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Critical Alerts Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Critical Alerts',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'VIEW ALL',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.gold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Alert Items
                _buildAlertItem(
                  'Zone 4 Overflow',
                  'Sensor detected 95% capacity in Bin #A-21',
                  '10:30 AM',
                  Icons.error,
                  AppTheme.statusCancelled,
                ),
                const SizedBox(height: 8),
                _buildAlertItem(
                  'Route Delay - Driver #204',
                  'Heavy traffic reported on Main St. (+15m)',
                  '09:15 AM',
                  Icons.access_time,
                  AppTheme.statusDelayed,
                ),
                const SizedBox(height: 8),
                _buildAlertItem(
                  'Zone 12 Cleared',
                  'Morning collection successfully completed.',
                  '08:45 AM',
                  Icons.check_circle,
                  AppTheme.accentGreen,
                ),
                const SizedBox(height: 24),

                // Live Network Map
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppTheme.cardDark,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.cardElevated),
                  ),
                  child: Stack(
                    children: [
                      // Map pattern
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: CustomPaint(
                          size: const Size(double.infinity, 200),
                          painter: _NetworkMapPainter(),
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        left: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Live Network Map',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              '32 ACTIVE HUBS',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.accentGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppTheme.cardElevated,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.fullscreen,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainStatCard(
    String title,
    String value,
    String change,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryGreen.withOpacity(0.4),
            AppTheme.cardDark,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.accentGreen.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      change,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.accentGreen,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.accentGreen.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: AppTheme.accentGreen,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color, {
    String? subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardElevated),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: AppTheme.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: color,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAlertItem(
    String title,
    String description,
    String time,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 11,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _NetworkMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.accentGreen.withOpacity(0.1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw concentric circles
    for (int i = 1; i <= 4; i++) {
      canvas.drawCircle(
        Offset(size.width * 0.6, size.height * 0.5),
        i * 40.0,
        paint,
      );
    }

    // Draw nodes
    final nodePaint = Paint()
      ..color = AppTheme.accentGreen
      ..style = PaintingStyle.fill;

    final nodePositions = [
      Offset(size.width * 0.3, size.height * 0.3),
      Offset(size.width * 0.5, size.height * 0.25),
      Offset(size.width * 0.7, size.height * 0.35),
      Offset(size.width * 0.4, size.height * 0.6),
      Offset(size.width * 0.6, size.height * 0.5),
      Offset(size.width * 0.75, size.height * 0.55),
      Offset(size.width * 0.55, size.height * 0.7),
    ];

    for (final pos in nodePositions) {
      canvas.drawCircle(pos, 4, nodePaint);
    }

    // Draw connections
    final linePaint = Paint()
      ..color = AppTheme.accentGreen.withOpacity(0.3)
      ..strokeWidth = 1;

    for (int i = 0; i < nodePositions.length - 1; i++) {
      canvas.drawLine(nodePositions[i], nodePositions[i + 1], linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AlertsContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceDark,
        title: const Text('Alerts'),
      ),
      body: Center(
        child: Text(
          'Alerts Screen',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      ),
    );
  }
}

class _AdminSettingsContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceDark,
        title: const Text('Admin Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildSettingItem(
              Icons.people,
              'User Management',
              'Manage users and roles',
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _buildSettingItem(
              Icons.location_on,
              'Zone Management',
              'Add or edit zones',
              onTap: () {},
            ),
            const SizedBox(height: 12),
            _buildSettingItem(
              Icons.notifications,
              'Notification Settings',
              'Configure push notifications',
              onTap: () {},
            ),
            const SizedBox(height: 24),
            Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                return SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async {
                      await authProvider.signOut();
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                          (route) => false,
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTheme.statusCancelled),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout, color: AppTheme.statusCancelled),
                        const SizedBox(width: 8),
                        Text(
                          'Sign Out',
                          style: TextStyle(
                            color: AppTheme.statusCancelled,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    IconData icon,
    String title,
    String subtitle, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.accentGreen.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppTheme.accentGreen, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }
}
