import 'package:flutter/material.dart';
import 'package:rbl/Setting/ColorSetting.dart';
import 'package:rbl/home/searchModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class dialogClass extends StatefulWidget {
  ReservationFilterProvider filterProvider;
  dialogClass({super.key, required this.filterProvider});

  @override
  dialogClassState createState() => dialogClassState();
}

class dialogClassState extends State<dialogClass> {
  String _pickedTreatment = 'Any';
  String _selectedReservationType = 'future';

  void saveCondition() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString('pickedTreatment', _pickedTreatment);
    pref.setString('selectedReservationType', _selectedReservationType);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog( // Wrap your Container with Dialog
      child: Container(
          width: 200,
          height: 450,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Column(children: [
            const SizedBox(
              height: 20,
            ),
            Row(

              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const SizedBox(width: 20),
                Container(
                    width: 100,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: Colors.lightGreen,
                      borderRadius: BorderRadius.all(
                          Radius.circular(20)),
                    ),
                    child: const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.filter_list),
                            Text('Filter', style: TextStyle(
                                fontFamily: 'juliousSans')),
                          ],
                        ))),

                
                  GestureDetector(
                    child: const Icon(Icons.save_as_outlined, color: Colorsetting.appBarColor2,),
                    onTap: (){
                  saveCondition();
                  widget.filterProvider.setSearchedTreatment(_pickedTreatment);
                  widget.filterProvider.setTimeCondition(_selectedReservationType);
                  Navigator.of(context).pop();
                }, )
              ],
            ),


            const SizedBox(height: 30,),
            Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text('treatment', style: TextStyle()),
                      DropdownButton<String>(
                      value: _pickedTreatment,
                      items: [
                        'Any',
                        'Hifu',
                        'Hydrafacial',
                        'Electroporation',
                        'Collagenpealing',
                        'Hair removal',
                        'Botox',
                        'Lemon Bottle',
                        'Skin Booster',
                        'PRP',
                      ]
                          .map((treatment) =>
                          DropdownMenuItem(
                            value: treatment,
                            child: Text(treatment),
                          )).toList(),
                      onChanged: (treatment) {
                        if (treatment != null) {
                          setState(() {
                            _pickedTreatment = treatment;
                          });
                        }
                      },
                    ),
                    ])),
            Padding(
                padding: const EdgeInsets.only(left: 20),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [Container(
                      width: 240,
                      height: 150,
                      decoration: const BoxDecoration(
                        color: Colors.lightGreen,
                        borderRadius: BorderRadius.all(
                            Radius.circular(20)),
                      ),
                      child: ListView(
                            children: [
                              RadioListTile<String>(
                                title: const Text('Past Reservations'),
                                value: 'past',
                                groupValue: _selectedReservationType,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedReservationType = value!;
                                  });
                                },
                              ),
                              RadioListTile<String>(
                                title: const Text(
                                    'Future Reservations'),
                                value: 'future',
                                groupValue: _selectedReservationType,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedReservationType = value!;
                                  });
                                },
                              ),
                              RadioListTile<String>(
                                title: const Text(
                                    'Any Time'),
                                value: 'Any',
                                groupValue: _selectedReservationType,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedReservationType = value!;
                                  });
                                },
                              )
                            ],
                      )
                    )
                    ])),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children:[
                  Column(
                      children: [
                  IconButton(onPressed: (){
                    widget.filterProvider.setSearchedTreatment('Any');
                    widget.filterProvider.setTimeCondition('Any');
                      Navigator.of(context).pop();
                    }, icon: const Icon(Icons.clear, color: Colors.red,)),
                        const Text('clear')
                      ]),
            Column(children:[
              IconButton(onPressed: (){
              widget.filterProvider.setSearchedTreatment(_pickedTreatment);
              widget.filterProvider.setTimeCondition(_selectedReservationType);
              Navigator.of(context).pop();
            }, icon: const Icon(Icons.content_paste_search, color: Colors.lightGreen,))
            ,const Text('apply')])
                ])
          ])
        // Add your filter content here
      ),
    );
  }
}

