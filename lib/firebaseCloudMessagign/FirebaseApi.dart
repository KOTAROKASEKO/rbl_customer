import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:rbl/Account/userId.dart';
import 'dart:convert';
import 'package:rbl/filename.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:flutter/services.dart' show rootBundle;

class Firebaseapi {

  Future<void> sendNotificationToAdmins(String title, String body) async {
  try {
    // Fetch admin tokens
    final List<String> adminTokens = await fetchAdminTokens();
    
    // Loop through each token and send a notification
    for (String token in adminTokens) {
      
      await sendPushMessage(token);
    }
    print('Notifications sent to all admins');
  } catch (e) {
    print('Error sending notifications to admins: $e');
  }
}

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotification() async {
    
    await _firebaseMessaging.requestPermission();
    final FCMToken = await _firebaseMessaging.getToken();
    print('FCMToken: $FCMToken');
    FirebaseFirestore.instance.collection('userData').doc(AccountId.userId).set({'token': FCMToken}, SetOptions(merge: true));
  }

  Future<void> sendPushMessage(String token) async {
    final jsonString = await rootBundle.loadString(filename.notificationJsonFile);
    final jsonKey = jsonDecode(jsonString);
    final credentials = ServiceAccountCredentials.fromJson(jsonKey);

    // Define the required Google API scopes for FCM
    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

    // Create an authenticated client using OAuth 2.0
    AuthClient authClient = await clientViaServiceAccount(credentials, scopes);

    // Firebase Cloud Messaging HTTP v1 URL (replace YOUR_PROJECT_ID)
    const url = 'https://fcm.googleapis.com/v1/projects/rblmalaysia/messages:send';

    // Create the payload for the notification
    final payload = {
      'message': {
        'token': token,
        'notification': {
          'title': 'Reservation',
          'body': 'reservation info!',
        },
        'data': {
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'message': 'There is an update in reservation!'
        },
      },
    };

    // Send the HTTP POST request
    final response = await authClient.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    // Handle the response
    if (response.statusCode == 200) {
      print('Notification sent successfully');
    } else {
      print('Failed to send notification: ${response.body}');
    }

    // Close the authenticated client
    authClient.close();
  }

  Future<List<String>> fetchAdminTokens() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('admins')
          .get();

      // Extract FCM tokens
      final List<String> tokens = querySnapshot.docs
          .map((doc) => doc['token'] as String)
          .toList();

      return tokens;
    } catch (e) {
      print('Error fetching admin tokens: $e');
      return [];
    }
  }
}