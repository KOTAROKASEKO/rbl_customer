import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rbl/Setting/ColorSetting.dart';
import 'package:rbl/customerSupport.dart';
import 'package:rbl/home/MODELReservation.dart';

class manageReservation extends StatefulWidget{
  final Reservation reservation;
  final String id;
  const manageReservation({super.key, required this.reservation, required this.id});
  @override
  manageReservationState createState() => manageReservationState();
}

class manageReservationState extends State<manageReservation>{
  late Reservation reservation;
  bool isLoading = true;

  @override
  void initState() {
    reservation = widget.reservation;
    setState(() {
      isLoading=false;
    });
    // TODO: implement initState
    super.initState();
  }

  Future<void> cancelReservation(String id) async{
    //turn the status into deleted
    try{
      FirebaseFirestore instance = FirebaseFirestore.instance;
    instance.collection('reservations').doc(id).set({
      'status':'deleted',
    },SetOptions(merge: true));
    }catch(e){
      print('error during cancelling');
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Your reservation'),
      ),
      body: isLoading?
      const CircularProgressIndicator()
      :
      ListView(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 45, top: 20,bottom: 20),
                child: Text(
                  'Treatment : ${reservation.treatment}', 
                  style: const TextStyle(
                    fontWeight: FontWeight.bold, 
                    color: Colorsetting.font,
                    fontSize: 17,
                    ),
                  ),
                ),
            ],),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 45,bottom: 20),
                child: Text(
                  'Date : ${reservation.date}', 
                  style: const TextStyle(
                    fontWeight: FontWeight.bold, 
                    color: Colorsetting.font,
                    fontSize: 17,
                    ),
                  ),
                ),
            ],),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 45),
                child: Text(
                  'Duration : ${reservation.start}-${reservation.end}', 
                  style: const TextStyle(
                    fontWeight: FontWeight.bold, 
                    color: Colorsetting.font,
                    fontSize: 17,
                    ),
                  ),
                ),
            ],),
            const SizedBox(height: 40,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=> const CustomerSupport()));
                },
                child: Container(
                width: 150,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color.fromARGB(255, 88, 46, 255),
                ),
                child: const Center(
                  child: Text(
                  'Ask our AI', 
                    style: TextStyle(
                      fontWeight: FontWeight.bold, 
                      color: Colors.white,
                      fontSize: 17,
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: (){
                  //cancelling logic
                  print(widget.id);
                  cancelReservation(widget.id);
                },
                child:Container(
                  width: 100,
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.red,
                  ),
                  child: const Center(
                    child: Text(
                    'Cancel', 
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        color: Colors.white,
                        fontSize: 17,
                        ),
                      ),
                    ),
                  ),            
              ),
            ],
          ),
        ],
      ),
    );
  }
}