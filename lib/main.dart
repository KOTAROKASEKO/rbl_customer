import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rbl/Account/CurrentUserInstance.dart';
import 'package:rbl/BottomTab.dart';
import 'package:rbl/Account/PAGE_authentication.dart';
import 'package:rbl/Account/userId.dart';
import 'package:rbl/firebase_options.dart';
import 'package:rbl/home/searchModel.dart';
import 'package:rbl/tabProviderService.dart';
import 'package:shared_preferences/shared_preferences.dart';

//This page initialises firebase, localdatabase(sharedpreference) ,provider
//firebase-> init database
//sharedpreferences -> get data if the user is logged in or not
//provider -> real time update


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ReservationFilterProvider(),),
        ChangeNotifierProvider(create: (context) => Tabproviderservice(),),
      ],
       child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RBL',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  
  bool? isLoggedIn;

  @override
  void initState() {
    super.initState();
    _loadSharedPreference();
  }

  Future<void> _loadSharedPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if(isLoggedIn==true){
      AccountId.initUserId();
      await CurrentUser.initCurrentUser();
    }
    setState(() {
      isLoggedIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: showFirstUserScreen(),
        ),
    );
  }

  Widget showFirstUserScreen(){

    if(isLoggedIn==null){

      return const Text('confirm your credential...\n50%...', style: TextStyle(fontFamily: 'juliousSans', fontWeight: FontWeight.bold),textAlign: TextAlign.center,);
    
    }else if(isLoggedIn!=null){

      if(isLoggedIn!){

        return const BottomTabView();

      }else if(!isLoggedIn!){
        
        return const AuthView();

      }
    }
    
    return const Text('We are sorry, but unknown error happened. pleases contact us',style: TextStyle(fontFamily: 'juliousSans', fontWeight: FontWeight.bold),textAlign: TextAlign.center,);
  
  }
}


