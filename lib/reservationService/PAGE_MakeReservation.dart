import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rbl/Account/userId.dart';
import 'package:rbl/Setting/ColorSetting.dart';
import 'package:rbl/TreatmentDescription.dart/treatmentDescription.dart';
import 'package:rbl/firebaseCloudMessagign/FirebaseApi.dart';
import 'package:rbl/reservationService/ModelReservation.dart';
import 'package:rbl/reservationService/VMReservation.dart';
import 'package:uuid/uuid.dart';

class ReservationView extends StatefulWidget {
  const ReservationView({super.key});

  @override
  _ReservationViewState createState() => _ReservationViewState();
}

class _ReservationViewState extends State<ReservationView> {

  final List<String> _genders = ['Male','Female','Any'];

  final List<DateTime> _dateOptions = [
    DateTime.now(),
    DateTime.now().add(const Duration(days: 1)),
    DateTime.now().add(const Duration(days: 2)),
  ];

  final List<String> _timeSlots = [
    '10:00 - 11:00',
    '11:00 - 12:00',
    '13:00 - 14:00',
    '14:00 - 15:00',
    '15:00 - 16:00',
    '16:00 - 17:00',
    '17:00 - 18:00',
    '18:00 - 19:00',
  ];
  // it is trying to share the index
  final List<String> _treatment = [
    'Hifu', 
    'Hydrafacial',
    'Electroporation', 
    'Collagenpealing',
    'Hair removal',
    'Botox',
    'Lemon Bottle',
    'Skin Booster',
    'PRP',
    ];
  
  final List<String> _treatmentDetails = [
    "Hifu is HIFU (High-Intensity Focused Ultrasound) is a non-invasive medical treatment that usThe ultrasound wave", 
    'Hydrafacial is blabla',
    'Electroporation is blabla', 
    'Collagenpealing is blabla',
    'Hair removal is blabla',
    'Botox is blabla',
    'Lemon Bottle is blabla',
    'Skin Booster is blabla',
    'PRP is blabla',
    ];
  
  final List<String> _usedMachine = [
    'Machine A',//Hifu,
    'Machine B',//Hydrafacial,
    'Machine C',//Electroporation,
    'Machine B',//Collagenpealing,
    'Machine D',//'Hair removal',
    'Machine D',//'Botox',
    'Machine F',//'Lemon Bottle',
    'Machine D',//'Skin Booster',
    'Machine G',//'PRP',
  ];
  
  final List<int> _priceList = [
    388,
    388,
    300,
    700,
    180,
    500,
    2200,
    2900,
    2000,
  ];

  DateTime _pickedDate = DateTime.now();
  String _pickedTreatment = 'Hifu';
  String _pickedGender='Any';
  String _pickedMachine = 'Machine A';
  bool _isLoading = false;            
  int price = 388;                     
  String shownDetail = 'Hifu is blabla, hifu is amazing treatment. this is because hifu is using natural ingredientes coming from Korea that is known as a huge beauty country.\n getting this treatmnet only once doesn\'t really work. So, we are recomming most of the customers to take more than 3 times to get the best result.';
  ScrollController parentController = ScrollController();
  

// Dummy data for demonstration
  final List<String> _bookedSlots = [];

  @override
  void initState() {
    super.initState();
    _fetchReservations(_pickedDate, _pickedMachine);
  }

  void _fetchReservations(DateTime newDate, String pickedMachine) async {
    try {
      final reservations = await ReservationViewModel.fetchReservationsForDayAndMachine(newDate, pickedMachine);
       print('fetching service was called');
      setState(() {
        _bookedSlots.clear();
        _isLoading = true;
      });
      for (var reservation in reservations) {
        print('the id is ${reservation.id}');
        print('reserved slot found: ${reservation.start} - ${reservation.end}');
        _bookedSlots.add('${reservation.start} - ${reservation.end}');
      }
      await Future.delayed(const Duration(seconds: 1));
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('error during fetching $e');
    }
  }

  bool _isSlotAvailable(String slot) {
  var now = DateTime.now();
  int currentHour = now.hour;
  int currentMinute = now.minute;
  String today = DateFormat('yyyy-MM-dd').format(now);

  // Parse the slot's start and end times
  List<String> times = slot.split(' - '); 
  int startHour = int.parse(times[0].split(':')[0]); // Get start hour
  int startMinute = int.parse(times[0].split(':')[1]); // Get start minute

  // If the slot is in the past, return false
  if ((startHour < currentHour || (startHour == currentHour && startMinute <= currentMinute)) && DateFormat('yyyy-MM-dd').format(_pickedDate)==today) {
    return false;
  }

  // Check if the slot is not booked
  return !_bookedSlots.contains(slot);
}

  Future<void> checkNotificationPermission() async {
    Firebaseapi().initNotification();
  }

  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colorsetting.backGroundColor,
      body:PrimaryScrollController(
        controller: parentController,
        
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child:Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
            // Price and treatment section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child:Text('Tap, Reserve, Enjoy!', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, fontFamily: 'juliousSans'),),
              ),
            const Padding(padding: EdgeInsets.only(top:20,right: 50, left: 16,bottom: 20),
            child: Text('You can send a booking request quickly from down below!\nLet\'s enjoy treatment without waiting!!',style: TextStyle(fontSize: 15, color: Colorsetting.font, fontWeight: FontWeight.bold),),),
            
            Padding(
              padding: const EdgeInsets.symmetric(vertical:20),
              child:getTreatmentBuilder(),
            ),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const SizedBox(width: 4,),
                Expanded(
                    child:Container(
                    height: 190,
                    decoration: BoxDecoration(
                      color: Colorsetting.panelBackground,
                      border:Border.all(width: 1, ),
                      
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Column(children: [
                      const SizedBox(height: 8,),

                      const Row(children: [
                        SizedBox(width: 8,),
                        Icon(Icons.search, size: 25,),
                        SizedBox(width: 4,),
                        Text('Pick Date & Staff Gender', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colorsetting.title),),
                      ],),
                      const SizedBox(height: 15),
                      Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children:[
                //DATE PICKER CONTAINER
                        Container(
                          height: 121,
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                          ),

                          child:Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),

                          child:Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                          children:[
                            const Padding(
                              padding: EdgeInsets.only(top: 8),
                              child:Text(
                                'Select Date',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colorsetting.title),
                              ),),
                            //===============sized box ======================
                            const SizedBox(height: 16),
                            //date drop down menu
                            DropdownButton<String>(
                                value: DateFormat('yyyy-MM-dd').format(_pickedDate),
                                items: _dateOptions
                                    .map((date) => DropdownMenuItem(
                                          value: DateFormat('yyyy-MM-dd').format(date),
                                          child: Text(DateFormat('yyyy-MM-dd').format(date)),
                                        ))
                                    .toList(),
                                onChanged: (formattedDate) {
                                  if (formattedDate != null) {
                                    setState(() {
                                      _pickedDate = _dateOptions.firstWhere((date) =>
                                          DateFormat('yyyy-MM-dd').format(date) == formattedDate);
                                    });
                                    _fetchReservations(_pickedDate, _pickedMachine);
                                  }
                                },
                              ),
                            const SizedBox(height: 16),
                          ]),),
                          ),
                       
                        Container(
                          height: 121,
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child:Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start, // Aligns all child widgets to the left
                            children: [
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Padding(
                              padding: EdgeInsets.only(top: 8),
                              child:Text(
                                    'Staff Gender',
                                    style: TextStyle(
                                      fontSize: 20, 
                                      fontWeight: FontWeight.bold,
                                      color: Colorsetting.title
                                      ),
                                  ),),
                                ],
                              ),
                              const SizedBox(height: 16),
                              DropdownButton<String>(
                                value: _pickedGender,
                                items: _genders.map((treatment) {
                                  return DropdownMenuItem(
                                    value: treatment,
                                    child: Align(
                                      alignment: Alignment.centerLeft, // Aligns the dropdown text to the left
                                      child: Text(treatment),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (gender) {
                                  if (gender != null) {
                                    _pickedGender = gender;
                                    setState(() {
                                      _pickedGender=gender;
                                      shownDetail = _treatmentDetails[selectedIndex];
                                      _pickedMachine = _usedMachine[selectedIndex];
                                      price = _priceList[selectedIndex]; // Update the price
                                    });
                                  }
                                },
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                        ),
                        
                        ],
                      ),
                      const SizedBox(height: 8,),
                    ],),
                    ),
                  ),
                  const SizedBox(width: 4,),
                ]
                ),
            
            const SizedBox(height: 30),

            Row(children:[
            const SizedBox(width: 4,),
                            
            Expanded(
              flex: 110,
              child:Container(
                height: 300,
              decoration: BoxDecoration(
                color: Colorsetting.panelBackground,
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromARGB(255, 147, 147, 147),
                    spreadRadius: 3,
                    blurRadius: 2,
                    offset: Offset(0, 2), // changes position of shadow
                  ),
                ],
                
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is OverscrollNotification) {
                    if (notification.overscroll > 0) {
                      parentController.jumpTo(
                        parentController.offset + notification.overscroll,
                      );
                    } else if (notification.overscroll < 0) {
                      parentController.jumpTo(
                        parentController.offset + notification.overscroll,
                      );
                    }
                  }
                  return false;
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child:ListView(
                  physics: const ClampingScrollPhysics(),
                  shrinkWrap: true,
                  primary: false, 
                  children: [
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child:Text(_pickedTreatment, style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colorsetting.title),),),
                    const SizedBox(height: 15),
                    const Row(children:[SizedBox(width: 16),Icon(Icons.monetization_on, size: 20, color: Colorsetting.title,),Text('Treatment Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colorsetting.title),),
                    ],),
                    
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colorsetting.appBarColor2,
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 16.0,right: 16),
                              child: Row(
                                children:[
                                  const Text(
                                    'Price : ',
                                    style: TextStyle(fontSize: 20.0),
                                  ),
                                  Text(
                                    'RM $price',
                                    style: const TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children:[
                      
                      Column(children:[
                        const Text('Before'),
                        Image.asset('assets/before.jpeg',width: 150,height: 150,),

                      ]),
                      
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children:[
                        const Text('After'),
                        Image.asset('assets/after.jpeg',width: 150,height: 150,),
                      ])
                    ]),
                    
                    const SizedBox(height: 8),
                    
                    ListTile(
                      title: Row(
                        children: [
                          Text(
                            _pickedTreatment,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const Icon(Icons.keyboard_arrow_right_outlined),
                        ],
                      ),
                      subtitle: Text(
                        shownDetail,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colorsetting.font,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => treatmentDescription(treatment:_pickedTreatment)),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 16),
                  ],
                  ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 4,)
            ]),
          
            const SizedBox(height: 4),
            
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Time Slots',
                style: TextStyle(
                  fontSize: 30, 
                  fontWeight: FontWeight.bold,
                  fontFamily: 'juliousSans'
                  ),
              ),
            ),

            const SizedBox(height: 8),
            // Grid view for time slots
            Container(
              decoration: BoxDecoration(
                      color: Colorsetting.panelBackground,
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromARGB(255, 147, 147, 147),
                          spreadRadius: 3,
                          blurRadius: 3,
                          offset: Offset(0, 2),
                        ),
                      ],
                      borderRadius: BorderRadius.circular(10.0),
                    ),
              height: 500,
              // Fixed height for the grid
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Padding(
                padding: const EdgeInsets.all(20),
                child:NotificationListener<ScrollNotification>(
                  onNotification: (notification) {
                    if (notification is OverscrollNotification) {
                      
                      // Pass scroll to parent when overscrolled
                      if (notification.overscroll > 0) {
                        // Scroll down
                        parentController.jumpTo(
                          parentController.offset + notification.overscroll,
                        );
                      } else if (notification.overscroll < 0) {
                        // Scroll up
                        parentController.jumpTo(
                          parentController.offset + notification.overscroll,
                        );
                      }
                    }
                    return false;
                  },
                child:GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                itemCount: _timeSlots.length,
                itemBuilder: (context, index) {
                  final slot = _timeSlots[index];
                  final isAvailable = _isSlotAvailable(slot);
                  return GestureDetector(
                    onTap: () async{
                      // Handle the tap event here
                      var uuid = const Uuid();
                      String ReservationId = uuid.v1();
                      List<String> times = slot.split(' - ');
                      String startTime = times[0];
                      String endTime = times[1];
                      if(!_isSlotAvailable(slot)){
                        showDialog(context: context, builder: (context){
                          return Center(
                            child: Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Center(
                              child: Column(
                                children: [
                                  const Padding(padding: EdgeInsets.all(20),
                                  child: Column(
                                    children: [
                                    Text('Oops!',style: TextStyle(fontFamily: 'neat', fontSize: 20),),
                                    Text('this slot is already reserved by someone else.\ntry booking other slot'),
                                  ],),
                                  ),
                                  GestureDetector( 
                                    child: Container(
                                        width: 50,
                                        height: 35,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          color: const Color.fromARGB(255, 240, 238, 181)
                                        ),
                                        child: const Center(child:Text('ok'),),),
                                  onTap: (){
                                    Navigator.pop(context);
                                  },
                                  )
                                ],
                              )
                            ),
                          ),
                        );});
                      }
                      else{

                      showDialog(context: context, builder: (context){
                        return Center(
                          child: Container(
                            width: 200,
                            height: 250,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(Radius.circular(20)),
                            ),
                            child: Padding(padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                const Text('Confirmation', style: TextStyle(fontSize: 24,fontWeight: FontWeight.bold),),
                                Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                    child: Text('Would you like to send a booking request between $slot?'),
                                  ),
                                const SizedBox(height: 30,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    GestureDetector(
                                      child: GestureDetector(
                                      child: Container(
                                        width: 40,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          color: const Color.fromARGB(255, 240, 238, 181)
                                        ),
                                        child: const Center(child: Text('No'),),),),
                                      onTap: (){
                                        Navigator.pop(context);
                                      },
                                    ),
                                    GestureDetector(
                                      child: Container(
                                        width: 40,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          color: const Color.fromARGB(255, 170, 195, 221)
                                        ),
                                        child: const Center(child:Text('Yes'))
                                        ),
                                      onTap: ()async{
                                        
                                         if(_isSlotAvailable(slot) ){
                                           print('picked machine is $_pickedMachine');
                                          await ReservationViewModel.saveReservationRequest(
                                            Reservation(
                                              usedMachine: _pickedMachine,
                                              id: ReservationId,
                                              userId: AccountId.userId,
                                              date: _pickedDate,
                                              start: startTime,
                                              end: endTime,
                                              treatment: _pickedTreatment,
                                              status: 'pending',
                                              gender: _pickedGender,
                                            ),
                                          );
                                          const SnackBar(content: Text('Booking request sent successfully!'));
                                          Firebaseapi firebaseApi = Firebaseapi();
                                            await firebaseApi.initNotification();
                                            await firebaseApi.sendNotificationToAdmins(
                                              'New Reservation Request',
                                              'A new reservation request has been made. Please check the app for details.',
                                            );
                                          //_fetchReservations(_pickedDate, _pickedMachine);
                                        }
                                        //here
                                        
                                        Navigator.pop(context);
                                        await checkNotificationPermission();
                                        //***************** */
                                        _showSnackBar(context);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                          ),
                        );
                      });
                      }

                      print('Tapped on slot: $slot');
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isAvailable ? const Color.fromARGB(255, 198, 126, 161) : const Color.fromARGB(255, 173, 173, 173),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [BoxShadow(
                          color: Colors.grey,
                          spreadRadius: isAvailable ? 2 : 0,
                          blurRadius: isAvailable ? 4 : 0,
                          offset: isAvailable ? Offset(0, 1) : Offset(0, 0),
                        )]
                      ),
                      child: Text(
                        slot,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                        ),
                      ),
                    ),
                  );
                },
              ),),
            ),
            ),
          ],),
        ),
      ),
    );
  }

  void scrollParentToTopOrBottom(bool toBottom) {
    final double position = toBottom
        ? parentController.position.maxScrollExtent // Scroll to bottom
        : 0.0; // Scroll to top

    parentController.animateTo(
      position,
      duration: const Duration(milliseconds: 300), // Smooth animation duration
      curve: Curves.easeInOut, // Animation curve
    );
  }
     
  void _showSnackBar(BuildContext context) {
const snackBar = SnackBar(
  content: Text('successfully sent a request'),
  
);

ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

  int selectedIndex = 0;
  Widget getTreatmentBuilder() {
    return SizedBox(
      height: 41, // Constrain the height of the Container
      child: ListView.builder(
        scrollDirection: Axis.horizontal, // Scroll horizontally
        itemCount: _treatment.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            child: Container(
              
            margin: const EdgeInsets.symmetric(horizontal: 5), // Add spacing between items
            padding: const EdgeInsets.symmetric(horizontal: 10), // Padding inside each item
            decoration: BoxDecoration(
              color: selectedIndex==index? Colors.pinkAccent:const Color.fromARGB(255, 198, 198, 198),
              borderRadius: BorderRadius.circular(20), // Rounded corners
            ),
            alignment: Alignment.center,
            child: Text(_treatment[index],style: TextStyle(
              color: selectedIndex==index? Colors.white:Colors.teal,
              fontWeight: FontWeight.bold
              ),
            ),
          ),
          onTap: (){
              print('selected index is $selectedIndex');
              print('selected machine is ${_usedMachine[selectedIndex]}');
              print(_usedMachine[selectedIndex]);
              setState(() {
                selectedIndex = _treatment.indexOf(_treatment[index]);
                shownDetail = _treatmentDetails[selectedIndex];
                _pickedTreatment = _treatment[index];
                _pickedMachine = _usedMachine[selectedIndex];
                price = _priceList[selectedIndex];
              });
              _fetchReservations(_pickedDate, _usedMachine[selectedIndex]);
            },
          );
        },
      ),
    );
  }
}
