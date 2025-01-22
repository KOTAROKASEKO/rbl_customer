import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rbl/Account/userId.dart';
import 'package:rbl/Setting/ColorSetting.dart';
import 'package:rbl/coupon/PAGE_Coupon.dart';
import 'package:rbl/home/PAGE_homePage.dart';
import 'package:rbl/reservationService/ceilingTab.dart';
import 'package:rbl/tabProviderService.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class BottomTabView extends StatefulWidget {
  const BottomTabView({super.key});

  @override
  _BottomTabViewState createState() => _BottomTabViewState();
}

class _BottomTabViewState extends State<BottomTabView> {
  int _selectedIndex = 0;

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  List<String>linkLists = [
    'https://qyvladzxxzhsacvdmyft.supabase.co/storage/v1/object/public/images/uploads/1737549214800',//20%
    'https://qyvladzxxzhsacvdmyft.supabase.co/storage/v1/object/public/images/uploads/1737549265697',//50%
    'https://qyvladzxxzhsacvdmyft.supabase.co/storage/v1/object/public/images/uploads/1737549312727',//80%
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
            if(
              await doesShowNotification(prefs, invitationList.length)){
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
                                            child: Text('OK'),
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

  Future<bool> doesShowNotification(SharedPreferences pref, int NumberOfInvitedPpl) async{
    int? lasttime = pref.getInt('alreadyShow');
    print('record of invitation is ${lasttime}');
    if(lasttime==null){
      generateInvitationCoupon(NumberOfInvitedPpl);
      return true;
    }else if(NumberOfInvitedPpl == lasttime){
      return false; 
    }else if(NumberOfInvitedPpl != lasttime){
      generateInvitationCoupon(NumberOfInvitedPpl);
      return true; 
    }else{
      return false; 
    }
  }

  Future<void> generateInvitationCoupon(NumberOfInvitedPpl)async{
    try {
      print('generateInvitationCoupon');
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Reference to the user's point document
    
    //===============================for individual =============
    
    Uuid uuid = Uuid();
    String couponId = uuid.v4();

    await firestore
      .collection('userData')
      .doc(AccountId.userId)
      .collection('coupons')
      .doc(couponId)
      .set({'isUsed':false});
    //===========================coupon data==========================
    
    //userData/couponId/isUsed
    //coupons/couponId/details

    Map<String, dynamic> individualCouponData = {
      'isForEveryone':false,
      'imageUrl': getDetail(NumberOfInvitedPpl).imageUrl,
      'couponId':couponId,
      'description':'RBL with you',
      'discountValue': getDetail(NumberOfInvitedPpl).value,
      'discountType':'subtraction',
      'validUntil': DateTime.now().add(const Duration(days: 30)),
      'whoUsed':[],
    };
    await firestore
      .collection('coupons')
      .doc(couponId)
      .set(individualCouponData);

      print('coupon generated. the id is : $couponId');
    
  } catch (e) {
    print("Failed to update points: $e");
  }
}
  
  Detail getDetail(int NumberOfInvitedPpl){
    if(NumberOfInvitedPpl==3){
        return Detail(imageUrl: linkLists[0], value: 10);
      }else if(NumberOfInvitedPpl==6){
        return Detail(imageUrl: linkLists[1], value: 20);
      }else{
        return Detail(imageUrl: linkLists[2], value: 30);
    }
  }


  // Function to handle tab change
  void _onItemTapped(int index) {
    var tabProviderInstance = Provider.of<Tabproviderservice>(context, listen: false);
    if (tabProviderInstance.getTabIndex() != index) {
      setState(() {
        _selectedIndex = index; // Update the local state
      });
      tabProviderInstance.changeIndex(index); // Update the Provider state
    } else {
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
  var tabProviderInstance = Provider.of<Tabproviderservice>(context);

  // Sync `_selectedIndex` with the provider's index
  _selectedIndex = tabProviderInstance.getTabIndex();

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
        currentIndex: _selectedIndex, // Use the local `_selectedIndex`
        onTap: _onItemTapped, // Update selected tab when tapped
        items: [
          BottomNavigationBarItem(
            icon: Image.asset(
              'assets/Icon_RBL.png',
              width: 25,
              height: 20,
              color: _selectedIndex == 0
                  ? Colorsetting.tabColor
                  : Colorsetting.nonSelectedColor,
            ),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.check_box),
            label: 'Reservations',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard),
            label: 'Coupons',
          ),
        ],
      ),
    ),
  );
}
}

class Detail{
  String imageUrl;
  int value;
  Detail({required this.imageUrl,required this.value});
}
