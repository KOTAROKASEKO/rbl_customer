import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rbl/Setting/ColorSetting.dart';

class eventDetailPage extends StatefulWidget {
  final String id;

  const eventDetailPage({super.key, required this.id});

  @override
  _eventDetailPageState createState() => _eventDetailPageState();
}

class _eventDetailPageState extends State<eventDetailPage> {
  String eventlink = '';
  String eventTitle = '';
  String eventDescription = '';
  final CarouselController controller = CarouselController(initialItem: 1);
  List<String> eventLink = [];
  bool isLoading = true;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> load() async {
  try {
    eventlink = widget.id;
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    DocumentSnapshot documentSnapshot = 
        await firestore.collection('news').doc(eventlink).get();

    if (documentSnapshot.exists) {
      setState(() {
        eventTitle = documentSnapshot['title'] ?? 'No Title';
        eventDescription = documentSnapshot['content'] ?? 'No Description';
        eventLink = List<String>.from(documentSnapshot['imageLinks'] ?? []);
        isLoading = false;
      });
    } else {
      throw 'Document does not exist';
    }
  } catch (e) {
    print('Error fetching document: $e');
    setState(() {
      isLoading = false;
    });
  }
}

  Widget getImage(){
    if(eventLink.isEmpty){
      print('eventLink is empty');
      return Container(
        child: const Text('No Image'),
      );
    }else{
      print(eventLink.length);
      for(var i in eventLink){
        // ignore: unnecessary_null_comparison
        if(i == null){
          print('i is is null');
          return Container(
            child: const Text('No Image'),
          );
        }
        else{
          return ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 400),
            child: CarouselView.weighted(
              controller: controller,
              itemSnapping: true,
              flexWeights: const <int>[1, 7, 1],
              children: eventLink.map((link) { // `link` は ImageLinks の各要素
                return Container(
                  child: Image.network(link), // `link` を直接使用
                );
              }).toList(),
            ),
          );
        }
      }
      return Container(
        child: const Text('unknown error'),
      );
    }
  }

  @override
  initState(){
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading? 
    const Center(child:
    Column(children: [
      CircularProgressIndicator(),
      Text('Loading...')
      ])
    )
    : 
    Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child:ListView(
        children: [
          //image
          getImage(),
          //content
          Text(eventTitle, style: const TextStyle(
            fontSize: 30, 
            fontWeight: FontWeight.bold,
            color: Colorsetting.title,
            ),
          ),
          Text(eventDescription, 
          style: const TextStyle(
            fontSize: 14, 
            fontWeight: FontWeight.bold, 
            color: Colorsetting.font
            ),
          ),
        ],)
      ),
    );
  }
}