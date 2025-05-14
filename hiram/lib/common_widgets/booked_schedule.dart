import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookedScheduleDialog extends StatefulWidget {
  final List<Map<String, dynamic>> bookedSchedules;

  const BookedScheduleDialog({super.key, required this.bookedSchedules});

  @override
  State<BookedScheduleDialog> createState() => _BookedScheduleDialogState();
}

class _BookedScheduleDialogState extends State<BookedScheduleDialog> {
  String filter = 'All'; // Options: All, Upcoming, Past

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> sortedSchedules =
        List.from(widget.bookedSchedules);
    sortedSchedules.sort((a, b) {
      DateTime? startA = DateTime.tryParse(a['startDate'] ?? '');
      DateTime? startB = DateTime.tryParse(b['startDate'] ?? '');
      return (startA ?? DateTime(0)).compareTo(startB ?? DateTime(0));
    });

    DateTime now = DateTime.now();
    List<Map<String, dynamic>> filteredSchedules =
        sortedSchedules.where((booking) {
      DateTime? start = DateTime.tryParse(booking['startDate'] ?? '');
      if (start == null) return false;

      if (filter == 'Upcoming') return start.isAfter(now);
      if (filter == 'Past') return start.isBefore(now);
      return true;
    }).toList();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: const [
          Icon(Icons.calendar_today, color: Colors.black87),
          SizedBox(width: 8),
          Text(
            'Booked Schedule',
            style:
                TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ToggleButtons(
              isSelected:
                  ['All', 'Upcoming', 'Past'].map((e) => e == filter).toList(),
              onPressed: (index) {
                setState(() {
                  filter = ['All', 'Upcoming', 'Past'][index];
                });
              },
              borderRadius: BorderRadius.circular(8),
              selectedColor: Colors.white,
              fillColor: Colors.black87,
              color: Colors.black54,
              textStyle: const TextStyle(fontSize: 13),
              children: const [
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('All')),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('Upcoming')),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('Past')),
              ],
            ),
            const SizedBox(height: 16),
            filteredSchedules.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Text(
                      'No bookings found.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: filteredSchedules.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final booking = filteredSchedules[index];
                        final start =
                            DateTime.tryParse(booking['startDate'] ?? '');
                        final end = DateTime.tryParse(booking['endDate'] ?? '');

                        final isValid = start != null && end != null;

                        return Card(
                          color: Colors.grey.shade100,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 1.5,
                          child: ListTile(
                            leading:
                                const Icon(Icons.event, color: Colors.black54),
                            title: isValid
                                ? Text(
                                    '${_formatDate(start)} • ${_formatTime(start)} – ${_formatTime(end)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                      color: Colors.black87,
                                    ),
                                  )
                                : const Text(
                                    'Invalid date range',
                                    style: TextStyle(color: Colors.redAccent),
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      actions: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            label: const Text('Close'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black87,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _formatTime(DateTime date) {
    return DateFormat.jm().format(date); // e.g., 10:00 AM
  }
}
