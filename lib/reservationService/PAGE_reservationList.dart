import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rbl/Account/userId.dart';
import 'package:rbl/home/MODELReservation.dart';
import 'package:rbl/home/searchModel.dart';
import 'package:rbl/reservationService/manageReservation.dart';

class ReservationHistory extends StatefulWidget{
  const ReservationHistory({super.key});

  @override
  _ReservationHistoryState createState() => _ReservationHistoryState();
}

class _ReservationHistoryState extends State<ReservationHistory>{
    final List<Reservation> reservations = [];
    final List<String> ids = [];

  @override
  void initState() {
    super.initState();
    fetchReservations();
    Future.microtask(() => Provider.of<ReservationFilterProvider>(context, listen: false).loadPreference());
  }

    Future<void> fetchReservations() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('reservations')
          .where('userId',isEqualTo: AccountId.userId)
          .get();
      final List<Reservation> fetchedReservations = snapshot.docs.map((doc) {
        ids.add(doc.id);
        return Reservation.fromFirestore(doc.data());
      }).toList();

      setState(() {
        reservations.addAll(fetchedReservations);
      });
    } catch (e) {
      print('Error fetching reservations: $e');
    }
  }

  bool shouldShow(ReservationFilterProvider filterProvider, String treatment, String startTime){
    print('filtering with ${filterProvider.getSearchedTreatment}');
    print('the label of the grid is $treatment');
    var format = DateFormat('yyyy-MM-dd-HH:mm');
    var reservedTime = format.parse(startTime);
    var DateTimenow = DateTime.now();
    var now = format.parse(DateFormat('yyyy-MM-dd-HH:mm').format(DateTimenow));
    print('reserved time is $reservedTime');
    print('now is $now');
    if(filterProvider.timeCondition=='future'){
      return
      (
      (reservedTime.isAfter(now) && filterProvider.getSearchedTreatment==treatment)
       || 
      (reservedTime.isAfter(now)&&filterProvider.getSearchedTreatment=='Any')
      );

    }else if(filterProvider.timeCondition=='past'){

      return
      (
        (reservedTime.isBefore(now) && filterProvider.getSearchedTreatment == treatment)
          || 
        (filterProvider.getSearchedTreatment=='Any'&&reservedTime.isBefore(now))
      );
    }
    else if(filterProvider.timeCondition=='Any'){
      return (filterProvider.searchedTreatment==treatment||filterProvider.searchedTreatment=='Any');
    }
    return true;
  }

  Widget getStatusIcon(String status){
    if(status=='confirmed'){
      return const Icon(Icons.check_circle_outline, color: Colors.green,);
    }else if(status=='declined'){
      return const Icon(Icons.cancel,color: Colors.red);
    }else if(status == 'pending'){
      return const Icon(Icons.pending_actions);
    }else if(status == 'deleted'){
      return const Icon(Icons.delete);
    }
    else{
      return const Icon(Icons.error);
    }
  }
  @override
  Widget build(BuildContext context){
    final ReservationFilterProvider filterProvider = Provider.of<ReservationFilterProvider>(context);
    return Scaffold(
      body: Container(
        child: reservations.isEmpty
              ? const Center(child: Text('no reservation'))
              : ListView.builder(
                physics: const ClampingScrollPhysics(),
                itemCount: reservations.length,
                itemBuilder: (context, index) {
                final reservation = reservations[index];
                return shouldShow(filterProvider, reservation.treatment, '${reservation.date}-${reservation.start}')?
                  Column(
                    children: [
                      ListTile(
                        leading: getStatusIcon(reservation.status),
                        title: Text('Treatment : ${reservation.treatment}'),
                        subtitle: Text(
                            '${reservation.date} | ${reservation.start} - ${reservation.end}'),
                        trailing: Text(reservation.status),
                        onTap: (){
                          var id = ids[reservations.indexOf(reservation)];
                          Navigator.push( context, MaterialPageRoute(builder: (context) => manageReservation(reservation:reservation,id:id)) );
                        },
                      ),
                      const Divider(),
                    ],
                  )
                  :
                  Container();
                },
              ),
      ),
    );
  }
}