import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rbl/Setting/ColorSetting.dart';
import 'package:rbl/customerSupport.dart';
import 'package:rbl/home/dialogue.dart';
import 'package:rbl/home/searchModel.dart';
import 'package:rbl/reservationService/PAGE_MakeReservation.dart';
import 'package:rbl/reservationService/PAGE_reservationList.dart';

class ReservationTab extends StatefulWidget {
  const ReservationTab({super.key});

  @override
  _ReservationTabState createState() => _ReservationTabState();
}

class _ReservationTabState extends State<ReservationTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ReservationFilterProvider filterProvider = Provider.of<ReservationFilterProvider>(context);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colorsetting.appBarColor2,
        title: const Text('Reservations',style: TextStyle(fontFamily: 'juliousSans', fontWeight: FontWeight.bold),),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            
            Tab(text: 'Reserve',icon: Icon(Icons.check_circle_outline_outlined)),
            Tab(text: 'All Reservations', icon: Icon(Icons.history_outlined)),
          ],
        ),
        actions: [
          // タブが "Your Reservations" の場合のみフィルターアイコンを表示
          
            IconButton(

              icon: const Padding(padding: EdgeInsets.only(right:10),child: Icon(Icons.support_agent, size: 30,),),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CustomerSupport()));
              },
            ),
            
          if (_tabController.index == 1)
            IconButton(
              icon: const Padding(padding: EdgeInsets.only(right:10),child: Icon(Icons.filter_list, size: 30,),),
              onPressed: () {
                showDialog(
                context: context,
                builder: (BuildContext context) {
                  return dialogClass(filterProvider: filterProvider,);
                },
              );
              },
            ),
            
        ],
        
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          ReservationView(),
          ReservationHistory(),
        ],
      ),
    );
  }
}
