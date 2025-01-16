import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rbl/Account/PAGE_profile.dart';
import 'package:rbl/Account/userId.dart';
import 'package:rbl/Setting/ColorSetting.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  _AuthViewState createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  bool isLoading = false;
  bool isLoginSuccessful = false;
  bool? isValidCode;

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      AccountId.initUserId();
      AccountId.setLoginStatusToSignedIn();

      // Indicate successful login

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ProfileScreen()),
      );

    } catch (e) {
      debugPrint('Error during Google sign-in: $e');
      setState(() {
        isLoading = false; // Stop loading on error
      });
    }
  }
  
  Future<bool> validateReferralCode(String referralCode) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      // Fetch all documents in the 'userData' collection
      QuerySnapshot querySnapshot = await firestore.collection('userData').get();

      // Iterate through the documents to collect all user IDs
      List<String> userIds = querySnapshot.docs.map((doc) => doc.id).toList();

      // Check if the referral code exists in the list of user IDs
      if (userIds.contains(referralCode)) {
        return true; // Referral code exists
      }
      setState(() {
        isLoading=false;
      });

      return false; // Referral code does not exist
    } catch (e) {
      print('Error validating referral code: $e');
      return false; // Return false in case of any error
    }
  }

  Future<void> addCurrentUserToInvitationList(String whoInvitedMe) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance; 
      // Get the current user's ID
      String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

      if (currentUserId.isEmpty) {
        throw Exception('Current user is not authenticated.');
      }

      DocumentReference invitationListRef = firestore
          .collection('userData')
          .doc(whoInvitedMe)
          .collection('invitationList')
          .doc('list');

      // Fetch the current list of invitations
      DocumentSnapshot invitationListDoc = await invitationListRef.get();
      List<String> invitationList = [];

      if (invitationListDoc.exists && invitationListDoc.data() != null) {
        invitationList = List<String>.from((invitationListDoc.data() as Map<String, dynamic>)['invitationList'] as List<dynamic>);
      }

      // Add the current user ID to the list if not already present
      if (!invitationList.contains(currentUserId)) {
        invitationList.add(currentUserId);

        // Update the list in Firestore
        await invitationListRef.update({'invitationList': invitationList});
      }
    } catch (e) {
      print('Error adding current user to invitation list: $e');
    }
  }

  Widget getText(){
    if(isValidCode==null){
      return Container();
    }else if(isValidCode==false){
      return const Text('404 Not found');
    }
    else{
      return const Text('Let\'s go!!');
    }
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = TextEditingController(); 
    bool? isValidReferral = true;

    return SingleChildScrollView(
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            
            Image.asset('assets/Icon_RBL.png', width: 200,height: 200,),
            const SizedBox(height: 20),
            const Text(
              'Welcome to RBL!',
              maxLines: 2,
                style: TextStyle(
                  fontFamily: 'juliousSans',
                fontSize: 35, color: Colorsetting.title
                ),
              ),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: ()async{
                try{
                  String referralCode = controller.text;
                  print('button pressed');
                if(referralCode.isEmpty){
                  await signInWithGoogle();
                  await addCurrentUserToInvitationList(referralCode);
                }else{
                  isLoading=true;
                  isValidCode = await validateReferralCode(referralCode);
                  print('isvalidreference?: $isValidReferral');
                   if(isValidCode==true){
                    print('ok?: $isValidReferral');
                    addCurrentUserToInvitationList(referralCode);
                    await signInWithGoogle();
                    }else{
                      isValidReferral==false;
                    }
                  }
                }
                catch(e){
                  print('error during logging in $e');
                }
              },
              child:Container(
              width: 220,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                border: Border.all()
              ),
              child: const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:[

                  //Icon(Icons.google_sign_in),
                  SizedBox(width: 5,),
                  Text('G', style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    ),),
                    SizedBox(width: 10,),
                  Text('login with google', 
                    style: TextStyle(
                      color: Color.fromARGB(255, 0, 0, 0), 
                      fontWeight: FontWeight.bold,
                      fontFamily: 'juliousSans'
                      ),
                    ),
                  ]
                )
              ),
            )),
            
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, top: 40),
              child:TextField(
              controller: controller,
              readOnly: false,
              
              decoration: const InputDecoration(
                labelText: 'Referral code',
                border: OutlineInputBorder(),
              ),
            ),),
            
            // ignore: dead_code
            getText(),
            const SizedBox(height: 100,),
          ],
        ),
      ),
    );
  }
}
