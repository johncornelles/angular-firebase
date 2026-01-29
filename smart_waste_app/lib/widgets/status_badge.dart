import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Status badge widget for schedule status display
class StatusBadge extends StatelessWidget {
  final String status;
  final bool showDropdown;
  final ValueChanged<String>? onChanged;

  const StatusBadge({
    super.key,
    required this.status,
    this.showDropdown = false,
    this.onChanged,
  });

  Color get _statusColor {
    switch (status) {
      case 'On Time':
        return AppTheme.statusOnTime;
      case 'Delayed':
        return AppTheme.statusDelayed;
      case 'Cancelled':
        return AppTheme.statusCancelled;
      case 'Completed':
        return AppTheme.statusCompleted;
      case 'Pending':
      default:
        return AppTheme.statusPending;
    }
  }

  IconData get _statusIcon {
    switch (status) {
      case 'On Time':
        return Icons.check_circle;
      case 'Delayed':
        return Icons.warning;
      case 'Cancelled':
        return Icons.cancel;
      case 'Completed':
        return Icons.done_all;
      case 'Pending':
      default:
        return Icons.schedule;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (showDropdown && onChanged != null) {
      return _buildDropdownBadge();
    }
    return _buildStaticBadge();
  }

  Widget _buildStaticBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _statusColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _statusColor.withOpacity(0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _statusIcon,
            size: 14,
            color: _statusColor,
          ),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: _statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownBadge() {
    return PopupMenuButton<String>(
      initialValue: status,
      onSelected: onChanged,
      color: AppTheme.cardDark,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _statusColor.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _statusColor.withOpacity(0.4),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _statusIcon,
              size: 14,
              color: _statusColor,
            ),
            const SizedBox(width: 4),
            Text(
              status.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: _statusColor,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              size: 16,
              color: _statusColor,
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        _buildMenuItem('On Time', AppTheme.statusOnTime, Icons.check_circle),
        _buildMenuItem('Delayed', AppTheme.statusDelayed, Icons.warning),
        _buildMenuItem('Cancelled', AppTheme.statusCancelled, Icons.cancel),
        _buildMenuItem('Completed', AppTheme.statusCompleted, Icons.done_all),
        _buildMenuItem('Pending', AppTheme.statusPending, Icons.schedule),
      ],
    );
  }

  PopupMenuItem<String> _buildMenuItem(
    String value,
    Color color,
    IconData icon,
  ) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 12),
          Text(
            value,
            style: TextStyle(color: color),
          ),
        ],
      ),
    );
  }
}
