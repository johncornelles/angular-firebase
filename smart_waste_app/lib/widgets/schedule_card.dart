import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/schedule_model.dart';
import '../config/theme.dart';
import 'status_badge.dart';

/// Reusable schedule card widget
class ScheduleCard extends StatelessWidget {
  final ScheduleModel schedule;
  final VoidCallback? onTap;
  final bool showZone;

  const ScheduleCard({
    super.key,
    required this.schedule,
    this.onTap,
    this.showZone = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.cardElevated,
          ),
        ),
        child: Row(
          children: [
            // Date box
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.cardElevated,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('d').format(schedule.date),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    DateFormat('MMM').format(schedule.date).toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      color: AppTheme.gold,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Schedule details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showZone && schedule.zoneName != null) ...[
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
                            schedule.zoneName!,
                            style: TextStyle(
                              fontSize: 10,
                              color: AppTheme.accentGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    DateFormat('EEEE').format(schedule.date),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: AppTheme.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        schedule.pickupTime,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Status badge
            StatusBadge(status: schedule.status),
          ],
        ),
      ),
    );
  }
}
