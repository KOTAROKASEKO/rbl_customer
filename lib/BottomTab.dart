import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rbl/Account/userId.dart';
import 'package:rbl/Setting/ColorSetting.dart';
import 'package:rbl/coupon/PAGE_Coupon.dart';
import 'package:rbl/home/PAGE_homePage.dart';
import 'package:rbl/reservationService/ceilingTab.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BottomTabView extends StatefulWidget {
  const BottomTabView({super.key});

  @override
  _BottomTabViewState createState() => _BottomTabViewState();
}

class _BottomTabViewState extends State<BottomTabView> {
  // Index for the selected tab
  int _selectedIndex = 0;

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkInvitationList();
  }
  void changeSelectedTab() {
    setState(() {
      _selectedIndex = 2;
    });
  }

  Future<void> checkInvitationList() async {
   FirebaseFirestore firestore = FirebaseFirestore.instance;
   DocumentSnapshot snapshot = await firestore.collection('userData').doc(AccountId.userId).get();
   SharedPreferences prefs = await SharedPreferences.getInstance();
    if (snapshot.exists) {
      var data = snapshot.data() as Map<String, dynamic>;
      if (data['invitationList'] != null) {
        List<dynamic> invitationList = data['invitationList'];
        if (invitationList.isNotEmpty && mounted) {
          if(invitationList.length==3||invitationList.length==6||invitationList.length==9){
            
            
            if(await checkIfItshouldBeShown(prefs, invitationList.length)){
              prefs.setInt('alreadyShow',invitationList.length);
              showDialog(
                    context: context,
                    builder: (context) {
                      return StatefulBuilder(
                        
                        builder: (context, setState){
                        return  AlertDialog( // Use AlertDialog for a proper dialog
                        content: SizedBox( // Wrap content in Container for styling
                          width: 130,
                          height: 200,
                          child: Center(
                            child: ListView(
                              children: [
                                
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text('WoHooo!!!!', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
                                  ],
                                ),
                                const Padding(padding: EdgeInsets.all(10),
                                child: Text('Wow! You got a special coupon! Let\'s Enjoy and become the best beauty in Malaysia!',style: TextStyle(fontWeight: FontWeight.bold,color: Colorsetting.font),),),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    GestureDetector(
                                      onTap:(){
                                        Navigator.pop(context);
                                      },
                                    child:Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 15),
                                        child:Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10.0),
                                        color: const Color.fromARGB(255, 236, 219, 160)
                                      ),
                                      child: const Padding(padding: EdgeInsets.symmetric(horizontal: 10), child:Text('close'),)
                                    ),),),

                                    GestureDetector(
                                      onTap: () {
                                        changeSelectedTab();
                                        Navigator.pop(context);
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 15),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10.0),
                                            color: const Color.fromARGB(255, 171, 212, 245),
                                          ),
                                          child: const Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 10),
                                            child: Text('claim'),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        shape: RoundedRectangleBorder( // Apply rounded corners
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      );

                        });
                    },
                  );

            }
          }
        }
      }
    }
  }

  Future<bool> checkIfItshouldBeShown(SharedPreferences pref, int NumberOfInvitedPpl) async{
    int? lasttime = pref.getInt('alreadyShow');
    if(lasttime==null){
      return true;
    }else if(NumberOfInvitedPpl == lasttime){
      return false;
    }else if(NumberOfInvitedPpl != lasttime){
      return true;
    }else{
      return false;
    }
  }
  
  // Function to handle tab change
  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
    } else {
      // Pop to the first screen if the current tab is tapped again
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
    }
  }

  Future<bool> _onWillPop() async {
    final isFirstRouteInCurrentTab =
        await _navigatorKeys[_selectedIndex].currentState?.maybePop() ?? false;
    if (!isFirstRouteInCurrentTab) {
      // If not in the first route of the current tab, exit the app
      return true;
    }
    return false;
  }

  Widget _buildOffstageNavigator(int index) {
    return Offstage(
      offstage: _selectedIndex != index,
      child: Navigator(
        key: _navigatorKeys[index],
        onGenerateRoute: (routeSettings) {
          Widget page;
          switch (index) {
            case 0:
              page = const HomePage();
              break;
            case 1:
              page = const ReservationTab();
              break;
            case 2:
              page = const CouponListview();
              break;
            default:
              page = const HomePage();
          }
          return MaterialPageRoute(builder: (_) => page);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Stack(
          children: List.generate(
            _navigatorKeys.length,
            (index) => _buildOffstageNavigator(index),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          selectedIconTheme: const IconThemeData(color: Colorsetting.tabColor),
          selectedItemColor: Colorsetting.tabColor,
          unselectedItemColor: Colorsetting.nonSelectedColor,
          currentIndex: _selectedIndex, // Current selected tab
          onTap: _onItemTapped, // Update selected tab when tapped
          items: [
            BottomNavigationBarItem(
              icon: Image.asset('assets/Icon_RBL.png', width: 25, height: 20, color: _selectedIndex == 0 ? Colorsetting.tabColor : Colorsetting.nonSelectedColor),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(
                Icons.check_box,
              ),
              label: 'Reservations',
            ),
            const BottomNavigationBarItem(
              icon: Icon(
                Icons.card_giftcard,
              ),
              label: 'Coupons',
            ),
          ],
        ),
      ),
    );
  }
}
