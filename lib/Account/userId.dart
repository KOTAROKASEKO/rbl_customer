
// U S E R   I D
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountId{

  // C U R R E N T   U S E R   I D 
  //===========================================
  static late String userId;
  //===========================================
  
  static void initUserId(){
    print('I N I T I A L I S I N G   U S E R   I D ');
    final FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;
    userId = user!.uid;
  }

  // T O G G L E    T O   S I G N   I N 
  static void setLoginStatusToSignedIn() async{

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', true);
    
  }

  // T O G G L E   T O    S I G N E D   O U T
  static void setLoginStatusToSignedOut() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', false);
    
  }

  // L O G I N   S T A T U S   G E T T E R   
  static Future <bool> getUserLogInStatus() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isLoggedIn = prefs.getBool('isLoggedIn')??false;
    return isLoggedIn;
  }
}