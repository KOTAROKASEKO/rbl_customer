import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:rbl/reservationService/ModelReservation.dart';

class ReservationViewModel {

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static List<Reservation> reservations = [];

 static Future<List<Reservation>> fetchReservationsForDayAndMachine(DateTime pickedDate, String pickedMachine) async {
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  var formatedDate = formatter.format(pickedDate);
  print('vmreservartion class picked date is $formatedDate and pickedTreatment is $pickedMachine');

  try {
    QuerySnapshot snapshot = await _firestore
    .collection('reservations')
    .where('date', isEqualTo: formatedDate)
    .where('usedMachine', isEqualTo: pickedMachine)
    .where('status', isEqualTo: 'confirmed')
    .get();

    return snapshot.docs
        .map((doc) =>
            Reservation.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
        .toList();
  } catch (e) {
    throw Exception('Failed to fetch reservations: $e');
  }
}

  // Add or update a reservation
  static Future<void> saveReservationRequest(Reservation reservation) async {
  try {
    print('saving function was called ${reservation.usedMachine}');
    if (reservation.id.isEmpty) {
      print('id is not empty');
      // Add a new document and let Firestore generate an ID
      await _firestore.collection('reservations').add(reservation.toFirestore());
    } else {
      // Update an existing document with a specified ID
      print('id is empty');
      await _firestore
          .collection('reservations')
          .doc(reservation.id)
          .set(reservation.toFirestore());
    }
  } catch (e) {
    throw Exception('Failed to save reservation: $e');
  }
}


  // Delete a reservation
  Future<void> deleteReservation(String id) async {
    try {
      await _firestore.collection('reservations').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete reservation: $e');
    }
  }
}
