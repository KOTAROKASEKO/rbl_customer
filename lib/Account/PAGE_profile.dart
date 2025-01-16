import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rbl/Account/CurrentUserInstance.dart';
import 'package:rbl/Account/userId.dart';
import 'package:rbl/BottomTab.dart';
import 'package:rbl/Setting/ColorSetting.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController phoneNumController = TextEditingController();
  String? gender;
  DateTime? dob;
  int? point;

    @override
  void initState() {
    super.initState();
    _loadExistingData();
  }
  
  Future<void> _loadExistingData() async {
    await CurrentUser.initCurrentUser();

    setState(() {
      userNameController.text = CurrentUser.currentUser.userName;
      phoneNumController.text = CurrentUser.currentUser.phoneNum.toString();
      gender = CurrentUser.currentUser.gender;
      dob = CurrentUser.currentUser.dob;
      point = CurrentUser.userPoint;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: dob ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != dob) {
      setState(() {
        dob = pickedDate;
      });
    }
  }

  Future<void> uploadDataToFirestore() async {
    final String userName = userNameController.text;
    final String phoneNum = phoneNumController.text;

    if (userName.isEmpty || phoneNum.isEmpty || gender == null || dob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(
          'uploading...',
          )),
      );
      return;
    }
    try {
      await FirebaseFirestore.instance.collection('userData').doc(AccountId.userId).set({
        'name': userName,
        'phoneNum': int.tryParse(phoneNum) ?? 0,
        'gender': gender,
        'userId': AccountId.userId,
        'dob': dob,
        'invitationList':[],//this can reset the invitation! fix this!
        'point': point ?? 0,
      },SetOptions(merge: true));
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('successfully uploaded!')),
      );
      final prefs = await SharedPreferences.getInstance();
      prefs.setBool('hasAccountData', true);
      const SnackBar(content: Text(
          'Upload Successful! Thank you for your cooperation!',
          ));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BottomTabView()),
      );
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('an error occured during the upload: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: SingleChildScrollView( // SingleChildScrollViewを追加
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column( // Columnに変更
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Hey there!!\nWe had been waiting to see you here!!\nKindly provide us following data. We use this data to manage the reservation only.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colorsetting.font,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: TextField(
                  controller: userNameController,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                    labelText: 'Your Name',
                    
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: TextField(
                  controller: phoneNumController,
                  decoration: const InputDecoration(
                    icon: Icon(Icons.phone),
                    border: OutlineInputBorder(),
                    labelText: 'Phone Number',
                  ),
                  keyboardType: TextInputType.phone,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Icon(Icons.male),
                    const SizedBox(width: 10,),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: gender,
                        decoration: const InputDecoration(
                          labelText: 'Biological Gender',
                        ),
                        items: ['Male', 'Female']
                            .map(
                              (value) => DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              ),
                            )
                            .toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            gender = newValue;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dob == null
                        ? 'Date of Birth'
                        : 'Your birthday : ${dob!.toLocal().year}/${dob!.toLocal().month}/${dob!.toLocal().day}',
                        style: const TextStyle(
                    color:Colorsetting.font,
                    fontWeight: FontWeight.bold,
                  ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today, color: Colors.blueAccent,),
                    onPressed: () => _selectDate(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  uploadDataToFirestore();
                },
                child: Container(
                  width: 200,
                  height: 50,
                  decoration: BoxDecoration(
                    boxShadow: const [
                      BoxShadow(
                        spreadRadius: 1.0,
                        offset: Offset(0, 1),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(25),
                    color: const Color.fromARGB(255, 21, 0, 255),
                  ),
                  child: const Center(
                    child: Text(
                      'Confirm',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
