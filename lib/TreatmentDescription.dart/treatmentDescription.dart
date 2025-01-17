import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rbl/Setting/ColorSetting.dart';

class treatmentDescription extends StatefulWidget {
  final String treatment;
  const treatmentDescription({super.key, required this.treatment});

  @override
  _treatmentDescriptionState createState() => _treatmentDescriptionState();
}

class _treatmentDescriptionState extends State<treatmentDescription> {
  
  String? detail;

  @override
  void initState() {
    super.initState();
    fetchTreatment();
  }
  
  Future<void> fetchTreatment() async{
    DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('treatment')
    .doc(widget.treatment)
    .get();

    detail = snapshot['detail'];
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor:Colorsetting.font,
        title: const Text('Treatment Description'),
      ),
      body: Container(
        child: Column(
          children: [
            Container(
              height: 200,
              width: 200,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/1.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              'Treatment Name',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              'Treatment Description',
              style: TextStyle(
                fontSize: 15,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              'Treatment Price',
              style: TextStyle(
                fontSize: 15,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              'Treatment Duration',
              style: TextStyle(
                fontSize: 15,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () {},
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colorsetting.font),
              ),
              child: const Text('Book Now'),
            ),
          ],
        ),
      ),
    );
  }
}