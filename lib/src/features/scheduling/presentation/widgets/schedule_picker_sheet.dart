import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Bottom sheet for scheduling a post.
///
/// Allows the user to select a date and time for the post to be scheduled.
/// Defaults to 1 hour from now.
class SchedulePickerSheet extends StatefulWidget {
  const SchedulePickerSheet({this.initialScheduledAt, super.key});

  final DateTime? initialScheduledAt;

  @override
  State<SchedulePickerSheet> createState() => _SchedulePickerSheetState();
}

class _SchedulePickerSheetState extends State<SchedulePickerSheet> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialScheduledAt ?? DateTime.now().add(const Duration(hours: 1));
    _selectedDate = DateTime(initial.year, initial.month, initial.day);
    _selectedTime = TimeOfDay(hour: initial.hour, minute: initial.minute);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _selectedTime);

    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  DateTime get _scheduledDateTime {
    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
  }

  bool get _isValid {
    return _scheduledDateTime.isAfter(DateTime.now().add(const Duration(minutes: 1)));
  }

  void _confirm() {
    if (_isValid) {
      Navigator.pop(context, _scheduledDateTime.toUtc());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Post'),
        actions: [
          TextButton(onPressed: _isValid ? _confirm : null, child: const Text('Schedule')),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildDatePicker(colorScheme, textTheme),
          const SizedBox(height: 12),
          _builtTimePicker(colorScheme, textTheme),
          const SizedBox(height: 24),
          _buildPreviewCard(colorScheme, textTheme),
        ],
      ),
    );
  }

  Widget _buildDatePicker(ColorScheme colorScheme, TextTheme textTheme) => Card(
    elevation: 0,
    color: colorScheme.surfaceContainerHighest,
    child: ListTile(
      leading: const Icon(Icons.calendar_today),
      title: const Text('Date'),
      subtitle: Text(DateFormat.yMMMd().format(_selectedDate)),
      trailing: const Icon(Icons.chevron_right),
      onTap: _pickDate,
    ),
  );

  Widget _builtTimePicker(ColorScheme colorScheme, TextTheme textTheme) => Card(
    elevation: 0,
    color: colorScheme.surfaceContainerHighest,
    child: ListTile(
      leading: const Icon(Icons.access_time),
      title: const Text('Time'),
      subtitle: Text(
        DateFormat.jm().format(
          DateTime(
            _selectedDate.year,
            _selectedDate.month,
            _selectedDate.day,
            _selectedTime.hour,
            _selectedTime.minute,
          ),
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: _pickTime,
    ),
  );

  Widget _buildPreviewCard(ColorScheme colorScheme, TextTheme textTheme) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Scheduled for',
          style: textTheme.labelMedium?.copyWith(color: colorScheme.onPrimaryContainer),
        ),
        const SizedBox(height: 4),
        Text(
          DateFormat('MMM d, y • h:mm a').format(_scheduledDateTime),
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isValid ? _getTimeRemaining() : 'Scheduled time must be in the future',
          style: textTheme.bodySmall?.copyWith(
            color: _isValid ? colorScheme.onPrimaryContainer.withAlpha(179) : colorScheme.error,
          ),
        ),
      ],
    ),
  );

  String _getTimeRemaining() {
    final now = DateTime.now();
    final difference = _scheduledDateTime.difference(now);

    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;

    if (days > 0) {
      return 'in $days day${days == 1 ? '' : 's'}';
    } else if (hours > 0) {
      return 'in $hours hour${hours == 1 ? '' : 's'}';
    } else if (minutes > 0) {
      return 'in $minutes minute${minutes == 1 ? '' : 's'}';
    } else {
      return 'due soon';
    }
  }
}
