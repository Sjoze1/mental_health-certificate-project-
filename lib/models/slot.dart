import 'package:intl/intl.dart';

class Timeslot {
  String id;
  String status;
  DateTime startTime;
  DateTime endTime;
  DateTime date;

  Timeslot({
    required this.id,
    required this.status,
    required this.startTime,
    required this.endTime,
    required this.date,
  });

  // Factory constructor to create a Timeslot object from JSON data
  factory Timeslot.fromJson(Map<String, dynamic> json) {
    // Use intl package for date and time formatting
    final dateFormat = DateFormat('yyyy-MM-dd');
    final timeFormat = DateFormat('HH:mm:ss');

    // Parse the date.  The date is in the format YYYY-MM-DD
    final parsedDate = dateFormat.parse(json['date']);

    // Parse start and end times, combining them with the date.
    final startTime = timeFormat.parse('${json['date']} ${json['start_time']}').toLocal();
    final endTime = timeFormat.parse('${json['date']} ${json['end_time']}').toLocal();


    return Timeslot(
      id: json['id'].toString(),
      status: json['status'] ??
          'available', // Default to 'available' if status is null
      startTime: startTime,
      endTime: endTime,
      date: parsedDate,
    );
  }

  // Convert the Timeslot object to a JSON map (if needed for sending data)
  Map<String, dynamic> toJson() {
    // Use intl to format the date and time for sending to the backend if needed
    final dateFormat = DateFormat('yyyy-MM-dd');
    final timeFormat = DateFormat('HH:mm:ss');
    return {
      'id': id,
      'status': status,
      'start_time': timeFormat.format(startTime),
      'end_time': timeFormat.format(endTime),
      'date': dateFormat.format(date),
    };
  }
}
