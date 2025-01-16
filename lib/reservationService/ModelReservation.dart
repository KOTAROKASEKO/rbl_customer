
import 'package:intl/intl.dart';

class Reservation {
  final String id;
  final String userId;
  final DateTime date;
  final String start;
  final String end;
  final String treatment;
  final String usedMachine;
  final String status;
  final String gender;

  Reservation({
    required this.usedMachine,
    required this.id,
    required this.userId,
    required this.date,
    required this.start,
    required this.end,
    required this.treatment,
    required this.status,
    required this.gender
  });

  // Convert Firestore document to Reservation object
  factory Reservation.fromFirestore(Map<String, dynamic> data, String id) {
    return Reservation(
      usedMachine: data['usedMachine'],
      id: id,
      userId: data['userId'],
      date: DateTime.parse(data['date']),
      start: data['start'],
      end: data['end'],
      treatment: data['treatment'],
      status: data['status'],
      gender: data['gender'],
    );
  }

  // Convert Reservation object to Firestore document
  Map<String, dynamic> toFirestore() {
    final DateFormat formatter = DateFormat('yyyy-MM-dd'); 
    return {
    'usedMachine': usedMachine,
    'id': id,
    'userId': userId,
    'date': formatter.format(date), // Format the date as yyyy-MM-dd 
    'start': start,
    'end': end,
    'treatment': treatment,
    'status': status,
    'gender':gender,
    };
  }
}
