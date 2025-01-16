import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:rbl/Account/CurrentUserInstance.dart';
import 'package:rbl/Account/userId.dart';
import 'package:rbl/Setting/ColorSetting.dart';
import 'package:rbl/event/PAGE_eventDetail.dart';
import 'package:rbl/home/MODELReservation.dart';
import 'package:rbl/home/PAGE_tierGuide.dart';
import 'package:rbl/home/searchModel.dart';
import 'package:rbl/point/dailystreak/dailyStreak.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:rbl/referralPage.dart/referralPage.dart';

import 'PointGuide.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int howManyStreaks = Dailystreak.howManyStreaks;
  List<Widget> icons = [];
  bool? tdyLoggedIn=Dailystreak.didUserLoginTdy;
  bool isLoading = true;
  int point  = 0;
  String? tier;

  final List<Reservation> reservations = [];
  ScrollController parentController = ScrollController();
  List <String> eventPosterLinks = [];
  List <String> contents = [];
  List <String> titles = [];
  List <String> ids = [];
  int nextPoint = 0;
  List<String> tiers = ['snake','crocodile','tiger','dragon'];

  @override
  void initState() {
    super.initState();
    fetchStreakData();
    fetchEventPosterLinks();
    Future.microtask(() => Provider.of<ReservationFilterProvider>(context, listen: false).loadPreference());
  }

  Future<void> fetchEventPosterLinks() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('news').get();
      List<String> links = [];
      for (var doc in snapshot.docs) {
        ids.add(doc.id);
        if (doc['imageLinks'] != null && doc['imageLinks'].isNotEmpty) {
          links.add(doc['imageLinks'][0]);
          titles.add(doc['title']);
          contents.add(doc['content']);
        }
      }
      setState(() {
        eventPosterLinks = links;
      });
    } catch (e) {
      print("Error fetching event posters: $e");
    }
  }

  @override
  void dispose() {
    parentController.dispose(); // Dispose to avoid memory leaks
    super.dispose();
  }

  int purchasePoint = 0;

  Future<int> fetchUserData() async{
    try{
      FirebaseFirestore instance = FirebaseFirestore.instance;
      var userDoc = await instance.collection('userData').doc(AccountId.userId).get();
      if(userDoc.exists){
        setState(() {
          purchasePoint = userDoc['purchasePoint']??0;
        });
        return purchasePoint;
      }else{
        print('doc not found');
        return 0;
      }
      }catch(e){
        print('error happened during fetching the user data : $e');
        return 0;
      }
  }

  Future<void> fetchStreakData() async {
    await Dailystreak.fetchCurrentStreaks();
    await fetchUserData();
    setState(() {
      isLoading = false;
      howManyStreaks = Dailystreak.howManyStreaks;
      point = CurrentUser.userPoint??0;
    });
  }

  int getWhichDay(int day){
    switch(day){
      case 1||2||3||5:
        return 10;
      case 4:
        return 20;
      case 6:
        return 30;
      case 7:
        return 2000;
      default : return 0;
    }
  }

  Widget getNotLoggedInIcon() {
    return const Icon(Icons.close, color: Colors.red);
  }

  Widget createDayIcon(int day, IconData iconData, Color color) {
    return Row(
      children: [
        const SizedBox(width: 10),
        Column(
          children: [
            Text('${day+1}'),
            Icon(iconData,color:color),
            Text('${getWhichDay(day+1)}pt'),
          ],
        ),
      ],
    );
  }

  Widget showCurrentProgress() {
    icons.clear();
    if(howManyStreaks >= 7){
      Dailystreak.resetDailyStreak();
      howManyStreaks=0;
    }

    for (var i = 0; i < howManyStreaks; i++) {
    switch (i) {
      case 0:
        icons.add(createDayIcon(i, Icons.check_circle_outlined, Colors.green));
        break;
      case 1:
        icons.add(createDayIcon(i, Icons.check_circle_outlined,Colors.green));
        break;
      case 2:
        icons.add(createDayIcon(i, Icons.check_circle_outlined,Colors.green));
        break;
      case 3:
        icons.add(createDayIcon(i, Icons.check_circle_outlined,Colors.green));
        break;
      case 4:
        icons.add(createDayIcon(i, Icons.check_circle_outlined,Colors.green));
        break;
      case 5:
        icons.add(createDayIcon(i, Icons.check_circle_outlined,Colors.green));
        break;
      case 6:
        icons.add(createDayIcon(i, Icons.check_circle_outlined,Colors.green));
        break;
      default:
        break;
    }
  }
    //show rest of days

  if (howManyStreaks < 7) {
    for (var j = 0; j < (7 - howManyStreaks); j++) {
      icons.add(createDayIcon(j+howManyStreaks ,Icons.ac_unit_rounded,Colors.blue));
    }
  }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: icons,
    );
  }

  void calculateStreakPoint() async{
    var givePoint = 0;
    if(kDebugMode){
      print('howManyStreaks: $howManyStreaks');
    }
      if(howManyStreaks == 0||howManyStreaks == 1 || howManyStreaks == 2 || howManyStreaks == 4){
        givePoint = 10;
      } 
      else if(howManyStreaks == 3){
        givePoint = 20;
      } 
      else if( howManyStreaks == 5){
        givePoint = 30;
      }
      else if(howManyStreaks == 6){
        givePoint = 100;
      }
      if(!Dailystreak.didUserLoginTdy){
        await Dailystreak.updateDailyStreak(DateTime.now(), howManyStreaks + 1, givePoint);
        await CurrentUser.initCurrentUser();

        setState(() {
        howManyStreaks = howManyStreaks + 1;
        point = CurrentUser.userPoint??0;
        tdyLoggedIn = Dailystreak.didUserLoginTdy;
      });
      }
  }

  Widget getTier(){
    if(purchasePoint<900){

      tier=tiers[0];
      nextPoint = 900;
      return Text(tiers[0],
      style: const TextStyle(
                color: Colorsetting.font,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ));

    }else if(purchasePoint>=900 && purchasePoint <2000){
      tier=tiers[1];
      nextPoint = 2000;
      return Text(tiers[1],
      style: const TextStyle(
              color: Colorsetting.font,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ));
    }else if(purchasePoint>=2000 && purchasePoint<5000){
      tier = tiers[2];
      nextPoint = 5000;
      return Text(tiers[2],
      style: const TextStyle(
                color: Colorsetting.font,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ));
    }else if(purchasePoint>=5000){
      tier=tiers[3];
      nextPoint = 5001;
      return Text(tiers[3],
      style: const TextStyle(
              color: Colorsetting.font,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ));
    }else{
      tier = 'error';
      return const Text('error',
      style: TextStyle(
                color: Colorsetting.font,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
    ?
    // L O A D I N G . . . 
    const Center(
      child:Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children:[
        Text('getting ready now\n80%...', style: TextStyle(fontFamily: 'juliousSans', fontWeight: FontWeight.bold),textAlign: TextAlign.center),
      ]),
    )
    :
    Scaffold(
      appBar: AppBar(
        backgroundColor: Colorsetting.appBarColor2,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/Icon_RBL.png', width: 40, height: 30,),
            const SizedBox(width: 10),
            const Text('Home',style: TextStyle(fontFamily: 'juliousSans', fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: LiquidPullToRefresh(
        springAnimationDurationInMilliseconds: 300,
          onRefresh: () async{
           CurrentUser.initCurrentUser();
            setState(() {
              point = CurrentUser.userPoint??0;
            });
          },
      child: ListView(
        physics: const BouncingScrollPhysics(),
        controller: parentController,
        children: [
          const SizedBox(
            height: 40
            ),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
          GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context){
                  return PageTierGuide(userTier: tier!,purchasePoint: purchasePoint, nextPoint: nextPoint, tiers:tiers,);
                }));
              },
              child: Stack(
              clipBehavior: Clip.none, // Allows the child widgets to overflow the boundaries
              children: [
                Container(
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                    boxShadow: const [
                      BoxShadow(
                        spreadRadius: 1.0,
                        color: Colors.grey,
                        offset: Offset(0.8, 0.8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          const Text('tier point', style: TextStyle(
                            color: Colorsetting.font,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),),
                          Text('$purchasePoint pt',
                          style: const TextStyle(
                            color: Colorsetting.font,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: -10, // Adjust these to place the image
                  left: -20,
                  child: ClipRRect(
                    child: Center(
                      child:Image.asset(
                        'assets/Icon_RBL.png', // Path to the image
                        width: 40,
                        height: 20,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context){
                return PageTierGuide(userTier: tier!,purchasePoint: purchasePoint, nextPoint: nextPoint,tiers: tiers,);
              }));
            },
            child: Stack(
            clipBehavior: Clip.none, // Allows the child widgets to overflow the boundaries
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                  boxShadow: const [
                    BoxShadow(
                      spreadRadius: 1.0,
                      color: Colors.grey,
                      offset: Offset(0.8, 0.8),
                    ),
                  ],
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        const Text(
                          'Your tier:',
                          style: TextStyle(
                            color: Colorsetting.font,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        getTier(),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: -20, // Adjust these to place the image
                left: -20,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40), // Round the image if needed
                  child: Image.asset(
                    'assets/beautyGirl.webp', // Path to the image
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),

          )
        
          ],),
          const SizedBox(
            height: 18
            ),
          CarouselSlider(
          options: CarouselOptions(
          height: 300,
          viewportFraction: 0.7,
          autoPlay: true,
          autoPlayInterval: const Duration(seconds: 4),
          autoPlayAnimationDuration: const Duration(milliseconds: 800),
          enlargeCenterPage: true,
          aspectRatio: 2.0,
        ),
        items: eventPosterLinks.map((link) {
          return Builder(
            builder: (BuildContext context) {
              return GestureDetector(
                child:Container(
                  width: 300,
                  margin: const EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    image: DecorationImage(
                      image: NetworkImage(link),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => eventDetailPage(
                      id: ids[eventPosterLinks.indexOf(link)],
                      )
                    )
                  );
                },
              );
            },
          );
        }).toList(),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(children: [
            const SizedBox(width: 10),
            Expanded(
              child: Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 188, 188, 188),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const SizedBox(height:20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 200,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 247, 88, 186),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child:const Center(child:Text('Daily Bonus!!',style: TextStyle(fontSize: 23, color: Colors.white, fontWeight: FontWeight.bold),),),
                      ),
                  ],
                ),

          const SizedBox(
            height: 15,
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:[
              GestureDetector(
                onTap:(){
                  Navigator.push(context, MaterialPageRoute(builder: (context){
                    return PointGuide();
                  }));
              },
                child:Text('${point}pt',style: const TextStyle(
                  fontSize: 30,
                  fontFamily: 'number',
                  ),),
              ),
              const SizedBox(width: 20,),
              GestureDetector(
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(5.0),
                      boxShadow: const [BoxShadow(
                        color: Colors.grey,
                        blurRadius: 2.0,
                        spreadRadius: 2.0,
                        offset: Offset(1.0, 1.0)
                      )]
                    ),
                  child:Padding(
                    padding: const EdgeInsets.all(5.0),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children:[
                      const Icon(
                        Icons.qr_code
                      ),
                      Positioned(
                        right: -20,
                        top: -15,
                        child:Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(7.5),
                          ),
                          child:const Center(
                            child: Padding(padding:EdgeInsets.all(4),child:Icon(Icons.saved_search_sharp, size: 14,color: Colors.amber,))
                          )
                        )
                      )
                    ])
                    ),
                  ),
                onTap: () {
                  showModalBottomSheet<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return SizedBox(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const Text('Scan to get a point before you pay!'),
                                QrImageView(
                                  data: AccountId.userId,
                                  version: QrVersions.auto,
                                  size: 200.0,
                                  gapless: false,
                                  errorStateBuilder: (cxt, err) {
                                    return const Center(
                                      child: Text(
                                        "Error generating QR code",
                                        textAlign: TextAlign.center,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                },
              )
            ]
          ),
          
          const SizedBox(
            height: 20,
          ),
          
          showCurrentProgress(),

          const SizedBox(height: 20,),
            
          Row(
            children: [
              Expanded(
                child: Container()
              ),
            GestureDetector(
              child: Container(
                width: 200,
                height: 60,
                decoration: BoxDecoration(
                  color: Dailystreak.didUserLoginTdy ? const Color.fromARGB(255, 180, 178, 178): const Color.fromARGB(255, 24, 171, 80),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: Dailystreak.didUserLoginTdy ?
                  const Text('See you tomorrow!', style: TextStyle(fontFamily: 'fancy', fontSize: 20, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 0, 0, 0)),)
                  :
                  const Text('Log in',style: TextStyle(fontFamily: 'fancy', fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),),
                ),
              ),
              onTap: () async {
               calculateStreakPoint();
              },
            ),
            
            Expanded(
              child: 
                Container(),
                ),
              ]
            ),
          
          //grid of reservations
          const SizedBox(height: 20,)
              ],
            ),
          ),
            ),
            
            const SizedBox(width: 10),
          ]),
          //login function 


          const SizedBox(height:20),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const referralPage()));
                },
                child:Container(
                width: 350,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 97, 155, 255),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: const Padding(padding: EdgeInsets.all(10), child:Center(
                  child: Text('Invite friend and get maximum 80% off!', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),),
                ),)
              ),)
            ]),),
          const SizedBox(height: 20),
                    ],
      ),
      )
    );
  }
}
