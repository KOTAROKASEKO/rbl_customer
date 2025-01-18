import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:rbl/Account/PAGE_authentication.dart';
import 'package:rbl/Account/PAGE_profile.dart';
import 'package:rbl/Account/userId.dart';
import 'package:rbl/Setting/ColorSetting.dart';
import 'package:rbl/coupon/CouponService.dart';
import 'package:rbl/coupon/PAGE_redeemCoupon.dart';
import 'package:rbl/coupon/couponModel.dart';
import 'package:rbl/referralPage.dart/referralPage.dart';

class CouponListview extends StatefulWidget {
  const CouponListview({super.key});

  @override
  CouponListviewState createState() => CouponListviewState();
}

class CouponListviewState extends State<CouponListview> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool showAvaialbleCoupon = true;
  late Future<List<Coupon>> _couponsFuture;
  late Future<List<Coupon>> _ExpiredCouponsFuture;
  

  List<String> CouponIds =[];
  List<String> CouponNames = [];
  List<String> titles = [];
  List<int> redeemPoints = [];
  List<int> values = [];
  List<String> linkOfDefaultCoupons = [
  ];


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _couponsFuture = CouponService.getUserCouponsWithDetails(); // Fetch coupons when the screen is initialized
    _ExpiredCouponsFuture = CouponService.getExpiredUserCouponsWithDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int i = -1;


  getPath(int index){
    int index1 = index%3;
    List<String> photos = [
      'assets/beautyGirl.webp',
      'assets/beautyGirl1.webp',
      'assets/beautyGirl2.webp',
    ];
    return photos[index1];
  }
  Widget buildRedeemCouponWidget(DocumentSnapshot document) {
    
    // Access data from the document
    String? name = document['name'] ?? 'N/A'; // Replace 'name' with your actual field name
    String? title = document['title'] ?? 'N/A'; // Replace 'title' with your actual field name
    int? redeemPoint = document['redeemPoint'] ?? 0;
    int? value = document['value'] ?? 0;
    String? id = document.id;
    int? number = document['index'] ?? 0;
    String? imageUrl = document['imageUrl'] ?? '';

    CouponIds.add(id);
    CouponNames.add(name!);
    titles.add(title!);
    redeemPoints.add(redeemPoint!);
    values.add(value!);
    linkOfDefaultCoupons.add(imageUrl!);

    return SizedBox(
      child: GestureDetector(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FittedBox(
            fit: BoxFit.cover, // Or BoxFit.contain based on your preference
            child: Image.asset('assets/coupon$number.webp',), // Your image asset
          ),
        ),
      ),
    );
  }

  Color selectedOptionColor = const Color.fromARGB(255, 255, 98, 51);
  Color selectedOptionTextColor = Colors.white;
  Color unselectedOptionColor = const Color.fromARGB(255, 212, 212, 212);

  
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('coupon',style: TextStyle(fontFamily: 'juliousSans', fontWeight: FontWeight.bold)),
        backgroundColor: Colorsetting.appBarColor2
        ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.bolt),
              title: const Text('invite friend'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const referralPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.send),
              title: const Text('Feed back'),
              onTap: () {
                
                showDialog(context: context, builder: (context){
                  return Container(
                    width: 200,
                    height: 150,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                  );
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('logout'),
              onTap: () {
                AccountId.setLoginStatusToSignedOut();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context){
                    return const AuthView();
                  })
                );
              },
            ),
          ],
        ),
      ),

      body: LiquidPullToRefresh(
        springAnimationDurationInMilliseconds: 300,
          onRefresh: () async{
            _couponsFuture = CouponService.getUserCouponsWithDetails(); // Fetch coupons when the screen is initialized
            _ExpiredCouponsFuture = CouponService.getExpiredUserCouponsWithDetails();
            setState(() {
              _couponsFuture;
              _ExpiredCouponsFuture;
            });
          },
          child: Column(children: [
          const SizedBox(height: 10,),
          Container(
            width: 200,
            height: 40,
              decoration: BoxDecoration(
                color: unselectedOptionColor, // Containerの背景色
                borderRadius: BorderRadius.circular(20),
              ),
            child:Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child:Center(child:Text('Redeem with Point!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),)),),
            ),
          const SizedBox(height: 10,),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 170),
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('redeemCoupon').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return CarouselView(
                    itemExtent: 330,
                    shrinkExtent: 230,
                    children: snapshot.data!.docs.map((document) {
                      return buildRedeemCouponWidget(document);
                    }).toList(),
                    onTap: (index) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => redeemDetail(
                            imageUrl: linkOfDefaultCoupons[index],
                            contextForPreviousPage:context,
                            id: CouponIds[index], 
                            name: CouponNames[index], 
                            title: titles[index],
                            redeemPoint: redeemPoints[index], 
                            value: values[index],
                            path: getPath(index)
                          )),
                        );
                    },
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        
        const SizedBox(height: 20,),
       Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 212, 212, 212), // 背景色
            borderRadius: BorderRadius.circular(30), // 全体の角丸
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // "available" ボタン
              GestureDetector(
                onTap: () {
                  setState(() {
                    showAvaialbleCoupon = true;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: showAvaialbleCoupon ? selectedOptionColor : unselectedOptionColor, // 選択状態で色を変える
                    borderRadius: BorderRadius.circular(20), // 角丸
                  ),
                  child: Text(
                    'Available',
                    style: TextStyle(
                      color: showAvaialbleCoupon ? selectedOptionTextColor : selectedOptionColor, // テキスト色
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // "past" ボタン
              GestureDetector(
                onTap: () {
                  setState(() {
                    showAvaialbleCoupon = false;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: showAvaialbleCoupon ? unselectedOptionColor: selectedOptionColor, // 選択状態で色を変える
                    borderRadius: BorderRadius.circular(20), // 角丸
                  ),
                  child: Text(
                    'Past',
                    style: TextStyle(
                      color: showAvaialbleCoupon ? selectedOptionColor:selectedOptionTextColor , // テキスト色
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        showAvaialbleCoupon ? Expanded(
          flex: 6,
          child: FutureBuilder<List<Coupon>>(
        future: _couponsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: Image.asset('assets/gif/loading.gif')); // Show loading while fetching
          } else if (snapshot.hasError) {
            return
              LiquidPullToRefresh(
                  springAnimationDurationInMilliseconds: 300,
                  onRefresh: () async{
                    _couponsFuture = CouponService.getUserCouponsWithDetails(); // Fetch coupons when the screen is initialized
                    _ExpiredCouponsFuture = CouponService.getExpiredUserCouponsWithDetails();
                    setState(() {
                      _couponsFuture;
                      _ExpiredCouponsFuture;
                    });
                  },
              child:Center(child: Text('Error: ${snapshot.error}'))); // Handle error if any
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return LiquidPullToRefresh(
                springAnimationDurationInMilliseconds: 300,
                onRefresh: () async{
              _couponsFuture = CouponService.getUserCouponsWithDetails(); // Fetch coupons when the screen is initialized
              _ExpiredCouponsFuture = CouponService.getExpiredUserCouponsWithDetails();
              setState(() {
                _couponsFuture;
                _ExpiredCouponsFuture;
              });
            },
            child: const Center(
              child: Text('There is no available coupon :(',style: TextStyle(fontWeight: FontWeight.bold,color: Colorsetting.font),),
            ),
            );// Handle empty state
          } else {
            List<Coupon> coupons = snapshot.data!;
            return ListView.builder(
              itemCount: coupons.length,
              itemBuilder: (context, index) {
                Coupon coupon = coupons[index];
                return ListTile(
                  title:
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Container(
                        child:Column(children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(6.0), topRight: Radius.circular(6.0)),
                              boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.9), // 陰の色と透明度
                                spreadRadius: 1, // 陰の広がり
                                blurRadius: 1, // 陰のぼかし半径
                                offset: const Offset(0, 2), // 陰のオフセット（x, y）
                              ),]
                              ),
                            child: FittedBox(
                              fit: BoxFit.cover, // Or BoxFit.contain based on your preference
                              child: Image.network(coupon.imageURL), // Your image asset
                            ),
                          ),

                          Container(
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.white, // Containerの背景色
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.9), // 陰の色と透明度
                                spreadRadius: 1, // 陰の広がり
                                blurRadius: 1, // 陰のぼかし半径
                                offset: const Offset(0, 2), // 陰のオフセット（x, y）
                              ),
                            ],
                      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(6.0), bottomRight: Radius.circular(6.0)),
                          ),
                          child: Padding(padding: const EdgeInsets.all(4.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Text(coupon.discountType == 'subtraction'
                                      ? 'RM ${coupon.discountAmount}'
                                      : '${coupon.discountAmount} %',
                                      style: const TextStyle( fontSize: 15.0),),
                                  const Text(' discount',style: TextStyle(fontSize: 15,color: Color.fromARGB(255, 103, 103, 103)),)
                                ],
                              ),
                              
                              const SizedBox(height: 10,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [Text('expires at:  ${DateFormat('yyyy-MM-dd').format(coupon.expiryDate)}',style: const TextStyle(fontFamily: 'neat', fontSize: 10),)],
                              ),
                            ],
                          ),
                        )
                      ),
                        ],),
                      ),
                    ),
                  onTap: () {
                    // Handle tap (e.g., show more details)

                    showModalBottomSheet<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return SizedBox(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const Text('show QR code to our staff'),
                                QrImageView(
                                  data: '${coupon.id}_${AccountId.userId}',
                                  version: QrVersions.auto,
                                  size: 200.0,
                                  gapless: false, // ギャップの無い描画
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

                    print('Tapped on coupon: ${coupon.id}');
                  },
                );
              },
            );
          }
        },
      ),
        )
        :
        Expanded(
          flex:6,
          child: FutureBuilder<List<Coupon>>(

        future: _ExpiredCouponsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: Image.asset('assets/gif/loading.gif')); // Show loading while fetching
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}')); // Handle error if any
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('You have not used any coupon yet',style: TextStyle(fontWeight: FontWeight.bold,color: Colorsetting.font))); // Handle empty state
          } else {
            List<Coupon> expiredCoupons = snapshot.data!;

            return ListView.builder(
              itemCount: expiredCoupons.length,
              itemBuilder: (context, index) {
                Coupon coupon = expiredCoupons[index];

                return ListTile(
                  title:
                    Container(
                    decoration: BoxDecoration(
                      color: Colors.white, // Containerの背景色
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.9), // 陰の色と透明度
                          spreadRadius: 5, // 陰の広がり
                          blurRadius: 7, // 陰のぼかし半径
                          offset: const Offset(3, 6), // 陰のオフセット（x, y）
                        ),
                      ],
                      borderRadius: BorderRadius.circular(6.0),
                    ),
                    child: Padding(padding: const EdgeInsets.all(10.0),
                     child: Column(
                      children: [
                        Row(
                          children: [
                            Text(coupon.discountType == 'subtraction'
                                ? 'RM ${coupon.discountAmount}'
                                : '${coupon.discountAmount} %',
                                style: const TextStyle(fontFamily: 'juliousSans', fontSize: 20.0),),
                            const Text(' discount',style: TextStyle(fontSize: 20,fontFamily: 'juliousSans', color: Color.fromARGB(255, 255, 191, 0)),)
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [Text(coupon.description, style: const TextStyle(fontFamily: 'fancy',),
                          maxLines: 2,)],

                        ),
                        const SizedBox(height: 10,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [Text('expired at:  ${coupon.expiryDate}',style: const TextStyle(fontFamily: 'neat', fontSize: 10),)],
                        ),
                      ],
                    ),
                        )
                      ),
                  onTap: () {
                    print('Tapped on coupon: ${coupon.id}');
                  },
                );
              },
            );
          }
        },
      ),
          ),
      ],))
    );
  }
}


class UncontainedLayoutCard extends StatelessWidget {
  const UncontainedLayoutCard({
    super.key,
    required this.index,
    required this.label,
  });

  final int index;
  final String label;

  @override
  Widget build(BuildContext context) {

    return  ColoredBox(
      
      color: Colors.primaries[index % Colors.primaries.length].withOpacity(0.5),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 20),
          overflow: TextOverflow.clip,
          softWrap: false,
        ),
      ),
    );
    
  }
}
