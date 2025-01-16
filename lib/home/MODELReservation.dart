class Reservation {
  final String date;
  final String start;
  final String end;
  final String status;
  final String treatment;
  final String userId;

  Reservation({
    required this.date,
    required this.start,
    required this.end,
    required this.status,
    required this.treatment,
    required this.userId,
  });

  // Factory method to create a Reservation instance from Firestore data
  factory Reservation.fromFirestore(Map<String, dynamic> data) {
    return Reservation(
      date: data['date'] ?? '',
      start: data['start'] ?? '',
      end: data['end'] ?? '',
      status: data['status'] ?? '',
      treatment: data['treatment'] ?? '',
      userId: data['userId'] ?? '',
    );
  }
}
