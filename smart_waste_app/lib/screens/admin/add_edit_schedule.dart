import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/schedule_provider.dart';
import '../../models/schedule_model.dart';
import '../../models/zone_model.dart';
import '../../config/theme.dart';

class AddEditSchedule extends StatefulWidget {
  final ScheduleModel? schedule;

  const AddEditSchedule({super.key, this.schedule});

  @override
  State<AddEditSchedule> createState() => _AddEditScheduleState();
}

class _AddEditScheduleState extends State<AddEditSchedule> {
  final _formKey = GlobalKey<FormState>();
  
  String? _selectedZoneId;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 11, minute: 0);
  bool _isRecurring = true;
  final _instructionsController = TextEditingController();
  String _selectedStatus = 'Pending';
  
  bool _isLoading = false;
  bool get _isEditing => widget.schedule != null;

  @override
  void initState() {
    super.initState();
    if (widget.schedule != null) {
      _selectedZoneId = widget.schedule!.zoneId;
      _selectedDate = widget.schedule!.date;
      _isRecurring = widget.schedule!.isRecurring;
      _instructionsController.text = widget.schedule!.specialInstructions ?? '';
      _selectedStatus = widget.schedule!.status;
      
      // Parse pickup time
      final timeParts = widget.schedule!.pickupTime.split(' - ');
      if (timeParts.length == 2) {
        _startTime = _parseTime(timeParts[0]);
        _endTime = _parseTime(timeParts[1]);
      }
    }
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.replaceAll(' AM', '').replaceAll(' PM', '').split(':');
    int hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    
    if (time.contains('PM') && hour != 12) hour += 12;
    if (time.contains('AM') && hour == 12) hour = 0;
    
    return TimeOfDay(hour: hour, minute: minute);
  }

  String _formatTimeRange() {
    final startHour = _startTime.hourOfPeriod == 0 ? 12 : _startTime.hourOfPeriod;
    final endHour = _endTime.hourOfPeriod == 0 ? 12 : _endTime.hourOfPeriod;
    final startPeriod = _startTime.period == DayPeriod.am ? 'AM' : 'PM';
    final endPeriod = _endTime.period == DayPeriod.am ? 'AM' : 'PM';
    
    return '${startHour.toString().padLeft(2, '0')}:${_startTime.minute.toString().padLeft(2, '0')} $startPeriod - '
        '${endHour.toString().padLeft(2, '0')}:${_endTime.minute.toString().padLeft(2, '0')} $endPeriod';
  }

  @override
  void dispose() {
    _instructionsController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_selectedZoneId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a zone')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final scheduleProvider =
        Provider.of<ScheduleProvider>(context, listen: false);
    final zoneName = scheduleProvider.getZoneName(_selectedZoneId!);

    final schedule = ScheduleModel(
      scheduleId: widget.schedule?.scheduleId ?? '',
      zoneId: _selectedZoneId!,
      zoneName: zoneName,
      date: _selectedDate,
      pickupTime: _formatTimeRange(),
      status: _selectedStatus,
      message: '',
      updatedAt: DateTime.now(),
      isRecurring: _isRecurring,
      specialInstructions: _instructionsController.text.isEmpty
          ? null
          : _instructionsController.text,
    );

    bool success;
    if (_isEditing) {
      success = await scheduleProvider.updateSchedule(
        widget.schedule!.scheduleId,
        schedule.toFirestore(),
      );
    } else {
      success = await scheduleProvider.createSchedule(schedule);
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEditing ? 'Schedule updated' : 'Schedule created',
          ),
          backgroundColor: AppTheme.accentGreen,
        ),
      );
    }
  }

  Future<void> _handleDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardDark,
        title: const Text('Delete Schedule'),
        content: const Text('Are you sure you want to delete this schedule?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: TextStyle(color: AppTheme.statusCancelled),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      
      final scheduleProvider =
          Provider.of<ScheduleProvider>(context, listen: false);
      final success =
          await scheduleProvider.deleteSchedule(widget.schedule!.scheduleId);
      
      setState(() => _isLoading = false);

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Schedule deleted'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

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
        title: Text(_isEditing ? 'Edit Schedule' : 'Add Schedule'),
        actions: [
          if (_isEditing)
            IconButton(
              icon: Icon(Icons.delete_outline, color: AppTheme.statusCancelled),
              onPressed: _handleDelete,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Zone Selection
              _buildSectionLabel('ZONE SELECTION'),
              Consumer<ScheduleProvider>(
                builder: (context, scheduleProvider, _) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.cardDark,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.accentGreen.withOpacity(0.3),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedZoneId,
                        hint: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppTheme.gold.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.location_on,
                                color: AppTheme.gold,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Select a zone',
                              style: TextStyle(color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                        isExpanded: true,
                        dropdownColor: AppTheme.cardDark,
                        items: scheduleProvider.zones.map((zone) {
                          return DropdownMenuItem(
                            value: zone.zoneId,
                            child: _buildZoneDropdownItem(zone),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => _selectedZoneId = value);
                        },
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Schedule Details
              _buildSectionLabel('SCHEDULE DETAILS'),
              
              // Date Selection
              GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    builder: (context, child) {
                      return Theme(
                        data: ThemeData.dark().copyWith(
                          colorScheme: ColorScheme.dark(
                            primary: AppTheme.accentGreen,
                            surface: AppTheme.cardDark,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (date != null) {
                    setState(() => _selectedDate = date);
                  }
                },
                child: _buildDetailCard(
                  Icons.calendar_today,
                  DateFormat('EEEE, MMM d').format(_selectedDate),
                  'COLLECTION DATE',
                  trailing: Icon(Icons.calendar_month, color: AppTheme.gold),
                ),
              ),
              const SizedBox(height: 12),
              
              // Time Selection
              GestureDetector(
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _startTime,
                    builder: (context, child) {
                      return Theme(
                        data: ThemeData.dark().copyWith(
                          colorScheme: ColorScheme.dark(
                            primary: AppTheme.accentGreen,
                            surface: AppTheme.cardDark,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (time != null) {
                    setState(() {
                      _startTime = time;
                      _endTime = TimeOfDay(
                        hour: (time.hour + 3) % 24,
                        minute: time.minute,
                      );
                    });
                  }
                },
                child: _buildDetailCard(
                  Icons.access_time,
                  _formatTimeRange(),
                  'TIME WINDOW',
                  trailing: Icon(Icons.timer, color: AppTheme.gold),
                ),
              ),
              const SizedBox(height: 24),

              // Configuration
              _buildSectionLabel('CONFIGURATION'),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardDark,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildConfigOption('Recurring', true),
                    ),
                    Expanded(
                      child: _buildConfigOption('One-time', false),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Status Selection (for editing)
              if (_isEditing) ...[
                _buildSectionLabel('STATUS'),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardDark,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedStatus,
                      isExpanded: true,
                      dropdownColor: AppTheme.cardDark,
                      items: ['Pending', 'On Time', 'Delayed', 'Cancelled', 'Completed']
                          .map((status) {
                        return DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedStatus = value);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Special Instructions
              _buildSectionLabel('SPECIAL INSTRUCTIONS'),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardDark,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _instructionsController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'e.g. Ensure bins are curbside by 7 AM...',
                    hintStyle: TextStyle(color: AppTheme.textMuted),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'OPTIONAL',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleSave,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_outline),
                      const SizedBox(width: 8),
                      Text(_isEditing ? 'Update Schedule' : 'Save Schedule'),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: AppTheme.gold,
          letterSpacing: 1.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildZoneDropdownItem(ZoneModel zone) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.gold.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.location_on, color: AppTheme.gold),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                zone.zoneName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              if (zone.description != null)
                Text(
                  zone.description!,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textMuted,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailCard(
    IconData icon,
    String value,
    String label, {
    Widget? trailing,
  }) {
    return Container(
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
              color: AppTheme.cardElevated,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.gold),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.textMuted,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildConfigOption(String label, bool recurring) {
    final isSelected = _isRecurring == recurring;
    return GestureDetector(
      onTap: () {
        setState(() => _isRecurring = recurring);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accentGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : AppTheme.textMuted,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
