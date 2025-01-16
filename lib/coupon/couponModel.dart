import 'package:cloud_firestore/cloud_firestore.dart';

class Coupon {
  final String id;
  final String description;
  final DateTime expiryDate;
  final String discountType;
  final String discountAmount;
  final String imageURL;

  Coupon({
    required this.id,
    required this.description,
    required this.expiryDate,
    required this.discountType,
    required this.discountAmount,
    required this.imageURL,
  });

  // Method to create Coupon object from Firestore Document
  factory Coupon.fromFirestore(DocumentSnapshot doc) {
    return Coupon(
      id: doc['couponId'],
      description: doc['description'] ?? '',
      expiryDate: (doc['validUntil'] as Timestamp).toDate(),
      discountType: doc['discountType'],
      discountAmount: (doc['discountValue']).toString(),
      imageURL: doc['imageUrl'],
    );
  }
}
