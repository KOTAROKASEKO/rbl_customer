import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rbl/Account/AccountData.dart';
import 'package:rbl/Account/userId.dart';

// O N L Y   P R O V I D E   A N   I N S T A N C E 
class CurrentUser{

  // C U R R E N T   U S E R   I N S T A N C E
  //===================================
  static late UserData currentUser;
  static int? userPoint=0;
  //===================================
  static Future<void> initCurrentUser() async {
    try{
      print('==============================');
      print('MY DATA IS INITIALISING...');
      
      String? userName;
      int? phoneNum;
      String? gender;
      DateTime dob;
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      DocumentSnapshot? userDoc = await firestore.collection('userData').doc(AccountId.userId).get();

      if(userDoc.exists){
        userName = userDoc['name']??'RBL john';
        phoneNum = userDoc['phoneNum']??1111312834;
        gender = userDoc['gender']??'Female';
        dob = (userDoc['dob'] ?? DateTime.now() as Timestamp).toDate();
        userPoint = userDoc['point']??0;
      }else{
        userName = 'RBL Jonny';
        phoneNum = 111138234;
        gender = 'Female';
        dob = DateTime.now();
        userPoint = 0;
      }
      currentUser = UserData(userName: userName!, phoneNum: phoneNum!, gender: gender!, userId: AccountId.userId, dob: dob);
      print('===FINISH INITIALIZING USER===');
      }catch(e){
        print('error happened furing getting a user data: $e');
      }
  }
}