import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/schedule_provider.dart';
import '../../models/schedule_model.dart';
import '../../config/theme.dart';
import '../../widgets/status_badge.dart';
import 'add_edit_schedule.dart';

class ScheduleManagement extends StatefulWidget {
  const ScheduleManagement({super.key});

  @override
  State<ScheduleManagement> createState() => _ScheduleManagementState();
}

class _ScheduleManagementState extends State<ScheduleManagement> {
  int _selectedFilter = 0;
  final _filters = ['All Zones', 'Active', 'Flagged'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceDark,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Manage Schedules'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {},
              ),
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppTheme.gold,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Chips
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              children: List.generate(_filters.length, (index) {
                final isSelected = _selectedFilter == index;
                return ChoiceChip(
                  label: Text(_filters[index]),
                  selected: isSelected,
                  selectedColor: AppTheme.accentGreen,
                  backgroundColor: AppTheme.cardDark,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.textSecondary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (selected) {
                    setState(() {
                      _selectedFilter = index;
                    });
                  },
                );
              }),
            ),
          ),

          // Section Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'CURRENT ASSIGNMENTS',
              style: TextStyle(
                fontSize: 11,
                color: AppTheme.textMuted,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Schedule List
          Expanded(
            child: Consumer<ScheduleProvider>(
              builder: (context, scheduleProvider, _) {
                if (scheduleProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                var schedules = scheduleProvider.schedules;

                // Apply filters
                if (_selectedFilter == 1) {
                  schedules = schedules
                      .where((s) =>
                          s.status == 'On Time' || s.status == 'Pending')
                      .toList();
                } else if (_selectedFilter == 2) {
                  schedules = schedules
                      .where((s) =>
                          s.status == 'Delayed' || s.status == 'Cancelled')
                      .toList();
                }

                if (schedules.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 64,
                          color: AppTheme.textMuted,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No schedules found',
                          style: TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: schedules.length,
                  itemBuilder: (context, index) {
                    final schedule = schedules[index];
                    return _buildScheduleCard(
                      context,
                      schedule,
                      scheduleProvider,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddEditSchedule(),
            ),
          );
        },
        backgroundColor: AppTheme.accentGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildScheduleCard(
    BuildContext context,
    ScheduleModel schedule,
    ScheduleProvider scheduleProvider,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddEditSchedule(schedule: schedule),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.cardElevated),
        ),
        child: Row(
          children: [
            // Zone info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // District tag
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.accentGreen.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'DISTRICT',
                          style: TextStyle(
                            fontSize: 9,
                            color: AppTheme.accentGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '#${schedule.scheduleId.substring(0, 4).toUpperCase()}',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppTheme.gold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Zone name
                  Text(
                    schedule.zoneName ?? scheduleProvider.getZoneName(schedule.zoneId),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Date and time
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: AppTheme.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_getDayName(schedule.date)}, ${schedule.pickupTime}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Status with dropdown
                  StatusBadge(
                    status: schedule.status,
                    showDropdown: true,
                    onChanged: (newStatus) async {
                      await scheduleProvider.updateScheduleStatus(
                        schedule.scheduleId,
                        newStatus,
                      );
                    },
                  ),
                ],
              ),
            ),
            // Zone map placeholder
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.cardElevated,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CustomPaint(
                  painter: _ZoneMapPainter(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDayName(DateTime date) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return days[date.weekday - 1];
  }
}

class _ZoneMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.accentGreen.withOpacity(0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw zone outline
    final path = Path();
    path.moveTo(size.width * 0.2, size.height * 0.3);
    path.lineTo(size.width * 0.8, size.height * 0.2);
    path.lineTo(size.width * 0.9, size.height * 0.7);
    path.lineTo(size.width * 0.4, size.height * 0.85);
    path.lineTo(size.width * 0.1, size.height * 0.6);
    path.close();

    final fillPaint = Paint()
      ..color = AppTheme.accentGreen.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, paint);

    // Add some road lines
    final roadPaint = Paint()
      ..color = AppTheme.cardElevated
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(size.width * 0.3, 0),
      Offset(size.width * 0.5, size.height),
      roadPaint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.4),
      Offset(size.width, size.height * 0.5),
      roadPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
