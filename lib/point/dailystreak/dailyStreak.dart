import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rbl/Account/CurrentUserInstance.dart';
import 'package:rbl/Account/userId.dart';

class Dailystreak {
  static List<DateTime> streaks = [];
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static int howManyStreaks = 0;
  static DateTime lastLogInDate = DateTime.now(); // Default value until fetched
  static bool didUserLoginTdy = false;
  
  static bool needsReset = false;

  // Fetch the current streaks from Firestore and update data within the app
  static Future<void> fetchCurrentStreaks() async {
    try {
      final now = DateTime.now();
      DateTime(now.year, now.month, now.day).subtract(const Duration(days: 1));

      DocumentSnapshot? userDoc =
          await _firestore.collection('loginStreaks').doc(AccountId.userId).get();
      if (userDoc.exists) {
        final Timestamp? timestamp = userDoc['lastLogInDate'];
        if (timestamp != null) {
          lastLogInDate = timestamp.toDate();
          
          // Check if last login was yesterday
          if (didYesterdayLogin(lastLogInDate)) {
            howManyStreaks += 1;
            didUserLoginTdy = false; // User hasn't logged in today yet
          } else if (didTodayLogin(lastLogInDate)) {
            didUserLoginTdy = true; // User already logged in today
          } else {
            // If last login is older than yesterday
            needsReset = true;
            await resetDailyStreak();
          }
        } else {
          print('lastLogInDate is null');
          lastLogInDate = DateTime.now();
        }

        howManyStreaks = userDoc['streakNum'] ?? 0;
      } else {
        lastLogInDate = DateTime.now();
        howManyStreaks = 0;
      }
    } catch (e) {
      print("Error fetching streaks: $e");
    }
  }

  static bool didYesterdayLogin(DateTime loginDate) {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    // Extract only the date portion for comparison
    DateTime loginDateOnly = DateTime(loginDate.year, loginDate.month, loginDate.day);
    DateTime yesterdayOnly = DateTime(yesterday.year, yesterday.month, yesterday.day);

    return loginDateOnly == yesterdayOnly;
  }

  static bool didTodayLogin(DateTime loginDate) {
    final now = DateTime.now();

    // Extract only the date portion for comparison
    DateTime loginDateOnly = DateTime(loginDate.year, loginDate.month, loginDate.day);
    DateTime todayOnly = DateTime(now.year, now.month, now.day);

    return loginDateOnly == todayOnly;
  }

  // Update the streak when the user taps
  static Future<void> updateDailyStreak(DateTime tappedTime, int streakNum, int givenPoint) async {
    print('current point: ${CurrentUser.userPoint}');
    print('it shold be ${CurrentUser.userPoint??0 + givenPoint}');
    print('givenpoint: $givenPoint');
    try {
      if (needsReset || howManyStreaks >= 7) {
        print('Resetting streak due to conditions.');
        await resetDailyStreak();
      }

      await _firestore.collection('loginStreaks').doc(AccountId.userId).set({
        'lastLogInDate': DateTime.now(),
        'streakNum': streakNum,
      }, SetOptions(merge: true));

      await _firestore.collection('userData').doc(AccountId.userId).set({
        'point': (CurrentUser.userPoint??0) + givenPoint,
      }, SetOptions(merge: true));

      didUserLoginTdy = true;
      print('the result will be ${CurrentUser.userPoint = givenPoint+CurrentUser.userPoint!}');
      CurrentUser.userPoint = givenPoint+CurrentUser.userPoint!;
      print('point : ${CurrentUser.userPoint}');
    } catch (e) {
      print("Error updating streak: $e");
    }
  }

  static Future<void> resetDailyStreak() async {
    try {
      await _firestore.collection('loginStreaks').doc(AccountId.userId).set({
        'lastLogInDate': DateTime.now(),
        'streakNum': 0,
      }, SetOptions(merge: true));
      howManyStreaks = 0;
      didUserLoginTdy = false;
      print("Streak has been reset.");
    } catch (e) {
      print("Error resetting streak: $e");
    }
  }
}
