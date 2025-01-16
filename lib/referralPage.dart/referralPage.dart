import 'package:flutter/material.dart';
import 'package:rbl/Account/userId.dart';
import 'package:flutter/services.dart';

class referralPage extends StatefulWidget {
  const referralPage({super.key});

  @override
  _referralPageState createState() => _referralPageState();
}
class _referralPageState extends State<referralPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Referral'),
      ),
      body: Center(
        child: ListView(
          children: <Widget>[
            const SizedBox(height: 20),
            Image.asset('assets/friendInvitation.webp', width: 300,height: 300,),
            const SizedBox(height: 20,),
             Row(
              children: [
                const SizedBox(width: 10,),
                // Uneditable TextField to display the user ID
                Expanded(
                  child: TextField(
                    controller: TextEditingController(text: AccountId.userId),
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'User ID',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Copy button
                IconButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: AccountId.userId));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User ID copied to clipboard')),
                    );
                  },
                  icon: const Icon(Icons.copy),
                ),
              ],
            ),
            const Padding(padding: EdgeInsets.all(20), child:Text('Invite your friends and get 10% off on your next purchase', style: TextStyle(fontSize: 20), textAlign: TextAlign.center,),),
            const Padding(padding: EdgeInsets.all(20), child:Text('How it works:', style: TextStyle(fontSize: 20), textAlign: TextAlign.center,),),
            Padding(
              padding: const EdgeInsets.all(20), 
            child:SizedBox(
              height: 130,
                child:
                  const Row(children: [
                  //1st step
                  Expanded(
                    flex:1,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('1, Share your referral code to when you invite your friend!!', maxLines: 3,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Icon(Icons.share, size: 40,),Icon(Icons.phone_android, size: 40,)])
                    ],
                  ),),
                  
                  //2nd step
                  SizedBox(width: 10,),
                  
                Expanded(
                  flex: 1,
                  child:Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('3, Your friend will paste your referral code when she/he logs in!', maxLines: 5,),
                      
                      Icon(Icons.login, size: 40,),
                        
                    ],
                  ),)

                ],)   
            )),
          ],
        ),
      ),
    );
  }
}