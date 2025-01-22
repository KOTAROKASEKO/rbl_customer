import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:rbl/Account/userId.dart';
import 'package:rbl/Setting/ColorSetting.dart';
import 'package:uuid/uuid.dart';


// ignore: must_be_immutable
class redeemDetail extends StatefulWidget {
  final String id;
  final String name;
  final String title;
  final int redeemPoint;
  final int value;
  final String path;
  final BuildContext contextForPreviousPage;
  final String imageUrl;
  

  const redeemDetail({super.key, required this.imageUrl ,required this.contextForPreviousPage, required this.id, required this.name, required this.title, required this.redeemPoint, required this.value, required this.path});
    @override
  redeemDetailState createState() => redeemDetailState();
  }

class redeemDetailState extends State<redeemDetail> {
  Uuid uuid = const Uuid();
  
  late String couponId;
  int redeemPoint = 0;
  int DiscountPrice = 0;
  bool bolehRedeem=false;
  String path = 'assets/beautyGirl.webp';
  int currentPoint = 0;
  bool isLoading = false;
  bool showAnimation = false;
  late BuildContext contextForPreviousPage;
  String imageUrl = '';

  @override
  initState(){
    getId();
    super.initState();
    checkGenerateValidity();
  }

  getId(){
    couponId = widget.id;
    redeemPoint = widget.redeemPoint;
    DiscountPrice = widget.value;
    path = widget.path;
    contextForPreviousPage = widget.contextForPreviousPage;
    imageUrl = widget.imageUrl;
    setState(() {
      couponId;
      redeemPoint;
      DiscountPrice;
    });
  }

  Future<void> checkGenerateValidity() async {

    try {
      couponId = uuid.v4();
      // Reference to the specific document in the 'point' collection
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('userData')
          .doc(AccountId.userId)
          .get();

      if (snapshot.exists) {
        currentPoint = snapshot['point'];
        if(currentPoint>=redeemPoint){
          setState(() {
            bolehRedeem = true;
          });
        }else{
          setState(() {
            bolehRedeem = false;
          });
          print('tak boleh');
        }
      }
    } catch (e) {
      print("Error fetching user point: $e");
    }
  }

  Future<void> deductPoint() async {
  try {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    // Deduct points from the current user point
    int afterClaim = currentPoint - redeemPoint;

    // Reference to the user's point document
    DocumentReference userPointRef = FirebaseFirestore.instance
        .collection('userData')
        .doc(AccountId.userId);
    
    await userPointRef.update({
      'point': afterClaim, // Update the 'points' field with the new value
    });
    //===============================for individual =============
    Map<String, dynamic> couponData = {
      "isUsed": false,
    };

    DocumentReference docRef = await firestore
      .collection('userData')
      .doc(AccountId.userId)
      .collection('coupons')
      .add(couponData);
    //===========================coupon data==========================
    couponId = docRef.id;
    //userData/couponId/isUsed
    //coupons/couponId/details

    Map<String, dynamic> individualCouponData = {
      'isForEveryone':false,
      'imageUrl': imageUrl,
      'couponId':couponId,
      'description':'RBL with you',
      'discountValue': DiscountPrice,
      'discountType':'subtraction',
      'validUntil': DateTime.now().add(const Duration(days: 30)),
      'whoUsed':[],
    };
    await firestore
      .collection('coupons')
      .doc(couponId)
      .set(individualCouponData);

    setState(() {
      isLoading = false;
    });

    print("Points successfully updated to $afterClaim");
  } catch (e) {
    print("Failed to update points: $e");
  }
}

  


  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colorsetting.appBarColor2,
        foregroundColor: const Color.fromARGB(255, 0, 0, 0),
        title: const Text('Coupon Detail'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child:ListView(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          children: [
        Stack(
        children: [
        // 背景画像と他の要素
        Column(
        children: [
          Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () {
                if (bolehRedeem) {
                    showDialog(
                    context: context,
                    builder: (context) {
                      bool showAnimation = false;

                      return StatefulBuilder(
                        
                        builder: (context, setState){
                        return  AlertDialog( // Use AlertDialog for a proper dialog
                        content: SizedBox( // Wrap content in Container for styling
                          width: 130,
                          height: 360,
                          child: Center(
                            child: showAnimation? Center(
                                child: Column(
                                  children: [
                                    const Text('making a coupon for you..', style: TextStyle(fontSize: 20.0),),
                                    Lottie.asset('assets/gift.json',)
                                    ]),
                              ) : ListView(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                    children:[
                                      Text('RM$DiscountPrice', style: const TextStyle(fontSize: 37,fontWeight: FontWeight.bold),),
                                      ]),
                                const Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [Text('Discount', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10.0),
                                          color: const Color.fromARGB(255, 249, 240, 205)
                                        ),
                                        child: const Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                                            child:Text('terms & condition', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),))
                                        ,)
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 230,
                                      height: 170,
                                      decoration: BoxDecoration(
                                        color: const Color.fromARGB(255, 221, 221, 221),
                                        borderRadius: BorderRadius.circular(20.0),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(10),
                                        child:ListView(
                                        children:
                                      [
                                        Text('1,Claim the coupon $redeemPoint pt. You must not try to copy and reuse it. Certain action will be taken',maxLines: 15 ,style: const TextStyle(fontSize: 14),),
                                        const Text('2,Claimed coupon will be valid maximum 30days ',maxLines: 15 ,style: TextStyle(fontSize: 14),),
                                        const Text('3,Each user is limmited to receive 1 service',maxLines: 15 ,style: TextStyle(fontSize: 14),),
                                        const Text('4,This voucher can be applied to only 600 and above ',maxLines: 15 ,style: TextStyle(fontSize: 14),),

                                        ]),)
                                    ),
                                  ],
                                ),
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
                                      onTap: () async {
                                        setState(() {
                                          showAnimation = true;
                                          
                                        });
                                        await Future.delayed(const Duration(seconds: 2));
                                        await deductPoint();
                                        setState((){
                                          showAnimation = false;
                                        });
                                        if (context.mounted) {
                                          Navigator.pop(context);
                                          
                                        }
                                        //show snackbar!
                                        _showSnackBar(context);
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
              },

              child: Container(
                width: 150,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.0),
                  color: bolehRedeem? Colors.pinkAccent: Colors.grey,
                ),
                  child: const Center(
                child: Text('redeem!', style: TextStyle(fontSize: 20, fontFamily: 'juliousSans'),),
                  ),
              ),
            ),
          ],
        ),const SizedBox(height: 15,),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Image.asset(
              widget.path,
              width: 200,
              height: 200,
            )
          ],
        ),
        ],
      ),
      // テキスト (上に配置される)
      Positioned(
        top: 0, // Adjust positioning
        left: 0, // Adjust positioning
        child: SizedBox(
          width: 250,
          child: Text(
          'RM $DiscountPrice discount',
          style: const TextStyle(
            fontFamily: 'juliousSans',
            fontSize: 40.0,
          ),
          maxLines: 3,
        ),)
      ),
      ],
    ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('How to Get', style:TextStyle(fontFamily: 'juliousSans', fontSize: 40.0),maxLines: 3,),
              ],
            ),
            Row(
              children: [
                Expanded(
                  flex: 3,
                    child: Container(
                      child: const Text('You can generate your own coupon by spending points that you earned by eaither daily login or purchase', maxLines: 5,
                      style: TextStyle(fontSize: 15.0)),
                    ),
                ),
                Expanded(
                  flex: 1,
                    child: Container(),
                ),
              ],
            ),
            const SizedBox(height: 10.0),
            const Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('How to Use', style:TextStyle(fontFamily: 'juliousSans', fontSize: 40.0),maxLines: 3,),
              ],
            ),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                      child: const Text('Please tap the coupon that was generated in the coupon page, and please show the popped up QR code to our staff!', maxLines: 5,
                        style: TextStyle(fontSize: 15.0),)
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(),
                ),
              ],
            ),
          ],
      ),)
    );
  }
   void _showSnackBar(BuildContext context) {
    final snackBar = SnackBar(
      content: const Text('Coupon was added! refresh and check it!'),
      action: SnackBarAction(
        label: 'Undo',
        onPressed: () {
          // Undo action here
        },
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    Navigator.pop(contextForPreviousPage);
    }
}