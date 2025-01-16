import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rbl/Account/userId.dart';
import 'package:rbl/coupon/couponModel.dart';

class CouponService {
  static final FirebaseFirestore _instance = FirebaseFirestore.instance;

  static Future<List<Coupon>> getExpiredUserCouponsWithDetails() async {
    // Step 1: Fetch the user's coupon IDs
    List<String> expiredCouponIds = await fetchExpiredUserCoupons();

    // Step 2: Fetch the coupon details based on the coupon IDs
    List<Coupon> expiredCoupons = await fetchCouponDetails(expiredCouponIds);

    return expiredCoupons;
  }

  static Future<List<String>> fetchExpiredUserCoupons() async {
    QuerySnapshot snapshot = await _instance
        .collection('userData')
        .doc(AccountId.userId)
        .collection('coupons')
        .where('isUsed', isEqualTo: true)
        .get();

    List<String> couponIds = snapshot.docs.map((doc) => doc.id).toList();
    return couponIds;
  }

  static Future<List<Coupon>> getUserCouponsWithDetails() async {
    List<String> couponIds = await fetchUserCoupons();
    List<Coupon> coupons = await fetchCouponDetails(couponIds);
    return coupons;
  }

  static Future<List<String>> fetchUserCoupons() async {
    QuerySnapshot snapshot = await _instance
        .collection('userData')
        .doc(AccountId.userId)
        .collection('coupons')
        .where('isUsed', isEqualTo: false)
        .get();

    List<String> couponIds = snapshot.docs.map((doc) => doc.id).toList();
    return couponIds;
  }

  static Future<List<Coupon>> fetchCouponDetails(List<String> couponIds) async {
    List<Coupon> coupons = [];

    for (String couponId in couponIds) {
      DocumentSnapshot couponDoc = await _instance.collection('coupons')
      .doc(couponId).get();
      if (couponDoc.exists) {
        if((couponDoc['validUntil'] as Timestamp).toDate().isAfter(DateTime.now())){
          coupons.add(Coupon.fromFirestore(couponDoc));
        }
        
      }
    }
    return coupons;
  }
}
