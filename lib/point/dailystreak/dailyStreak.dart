import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rbl/Account/CurrentUserInstance.dart';
import 'package:rbl/Account/userId.dart';

class Dailystreak {
  static List<DateTime> streaks = [];
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static int streakNum=0;
  static DateTime lastLogInDate = DateTime.now(); // Default value until fetched
  static bool didUserLoginTdy = false;

  static int getshownStreakNum(){

    //Logic to remain showing 7 cats if the user logged in 7th day
    if(didUserLoginTdy && streakNum % 7 == 0 && streakNum != 0){
      return 7;
    }else{
      return streakNum % 7;
    }
  }

  // Fetch the current streaks from Firestore and update data within the app
  static Future<void> fetchCurrentStreaks() async {
    try {
      DocumentSnapshot? userDoc = await _firestore.collection('loginStreaks').doc(AccountId.userId).get();
      if (userDoc.exists) {
        
        lastLogInDate = (userDoc['lastLogInDate'] as Timestamp).toDate();
        streakNum = userDoc['streakNum'];
        
          // Check if last login was yesterday
      if (getLastLogin()=='today') {

        print("User logged in today.");
        didUserLoginTdy = true;

        //If yesterday's login is 7th day, reset it to zero
      } else if (getLastLogin()=='yesterday') {

        print('user logged in yesterday');
        didUserLoginTdy = false;

      }else if(getLastLogin()=='2 days ago or more'){
        //The user didn't login either yesterday or today(more than 2days ago). just reset.

        print('user logged in 2 days ago or more'); 
        await resetDailyStreak();
        didUserLoginTdy = false;
      }
      } else {
        lastLogInDate = DateTime.now();
        streakNum = 0;
      }
    } catch (e) {
      print("Error fetching streaks: $e");
    }
  }

  static String getLastLogin() {

    print('last login date is $lastLogInDate');

    DateTime now = DateTime.now();
    DateTime yesterday = now.subtract(const Duration(days: 1));

    // Extract only the date portion for comparison
    DateTime lastLogin = DateTime(lastLogInDate.year, lastLogInDate.month, lastLogInDate.day); // login date
    DateTime yesterdayOnly = DateTime(yesterday.year, yesterday.month, yesterday.day); // Yesterday date
    DateTime today = DateTime(now.year, now.month, now.day); // Today's date

    if(lastLogin == yesterdayOnly){
      return'yesterday';
    }else if(lastLogin == today){
      return 'today';
    }else{
      return '2 days ago or more';
    }
  }

  // Update the streak when the user taps
  static Future<void> increaseDailyStreak(DateTime tappedTime, int givenPoint) async {

    try {
      await _firestore.collection('loginStreaks').doc(AccountId.userId).set({

        'lastLogInDate': DateTime.now(),
        'streakNum': streakNum + 1,

      }, SetOptions(merge: true));

      await _firestore.collection('userData').doc(AccountId.userId).set({

        'point': (CurrentUser.userPoint??0) + givenPoint,

      }, SetOptions(merge: true));

      didUserLoginTdy = true;
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

      streakNum = 0;
      didUserLoginTdy = false;

      print("Streak has been reset.");
    } catch (e) {
      print("Error resetting streak: $e");
    }
  }
}

