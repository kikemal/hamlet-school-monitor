import 'package:flutter/material.dart';

import '../../domain/models/teacher_models.dart';
import 'teacher_timetable_slot_card.dart';

/// Week grid: day tabs + slots for the selected day.
class TeacherTimetableWeek extends StatefulWidget {
  const TeacherTimetableWeek({super.key, required this.slots});

  final List<TeacherTimetableSlot> slots;

  static const dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  State<TeacherTimetableWeek> createState() => _TeacherTimetableWeekState();
}

class _TeacherTimetableWeekState extends State<TeacherTimetableWeek> {
  late int _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now().weekday;
  }

  List<TeacherTimetableSlot> get _daySlots =>
      widget.slots.where((s) => s.timetable.dayOfWeek == _selectedDay).toList();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: 7,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, index) {
              final day = index + 1;
              final selected = day == _selectedDay;
              final count =
                  widget.slots.where((s) => s.timetable.dayOfWeek == day).length;
              return ChoiceChip(
                label: Text('${TeacherTimetableWeek.dayLabels[index]} ($count)'),
                selected: selected,
                onSelected: (_) => setState(() => _selectedDay = day),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _daySlots.isEmpty
              ? const Center(child: Text('No lessons scheduled this day'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _daySlots.length,
                  itemBuilder: (_, i) =>
                      TeacherTimetableSlotCard(slot: _daySlots[i]),
                ),
        ),
      ],
    );
  }
}
