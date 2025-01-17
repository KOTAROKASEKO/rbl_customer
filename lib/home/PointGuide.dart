import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rbl/Setting/ColorSetting.dart';
import 'package:rbl/tabProviderService.dart';


class PointGuide extends StatelessWidget{
  

  @override
  Widget build(BuildContext context){
    var instance = Provider.of<Tabproviderservice>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('what is point?',
        style: TextStyle(
          fontFamily: 'juliousSans',
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
        centerTitle: true,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 20, top: 10),
              child:Text(
              'simple point system!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colorsetting.title
              ),
            ),
          ),
          const Padding(
            padding : EdgeInsets.all(10),
            child:
            Text('You can get an exiciting coupon by exchanging your point!',style: TextStyle(fontWeight: FontWeight.bold,color:Colorsetting.font),),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              //first step
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 206, 206, 206),
                  borderRadius: BorderRadius.circular(20)
                ),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child:Column(
                  spacing: 20,
                  children: [
                    Text('1st step'
                    ,style: TextStyle(fontWeight: FontWeight.bold,color:Colorsetting.title),
                    ),
                    Icon(Icons.control_point_duplicate_sharp),
                    Text('Earn points!',
                      style: TextStyle(
                        fontFamily: 'juliousSans',
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),)
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 206, 206, 206),
                  borderRadius: BorderRadius.circular(20)
                ),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child:Column(
                  spacing: 20,
                  children: [
                    Text('2nd step',style: TextStyle(fontWeight: FontWeight.bold,color:Colorsetting.title),),
                    Icon(Icons.airplane_ticket_rounded),
                    Text('Get a coupon',
                      style: TextStyle(
                        fontFamily: 'juliousSans',
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                      ),
                    )
                  ],
                ),)
              )
            ],
          ),
          Padding(padding: EdgeInsets.only(top:20, left: 20),
          child: Text('Terms and condition:', style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colorsetting.title,
            fontSize: 16,
            ),),
          ),
          Padding(padding: EdgeInsets.only(left: 20),
            child: Text('・You cannot use screen shot of a QR code\n・Expired coupon cannot be used\n・Same coupon can be used only once\n・Illegaly genedrated code cannot be used',
             style: TextStyle(fontWeight: FontWeight.bold,
              color: Colorsetting.font,
              ),
            ),
            ),
          SizedBox(height: 20,),
          GestureDetector(
            onTap: (){
              Navigator.pop(context);
              instance.changeIndex(2);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:[
              SizedBox(width: 10,),
              Container(
                width: 200,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 213, 86),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [BoxShadow(
                    color: const Color.fromARGB(255, 224, 224, 224),
                    spreadRadius: 4,
                    blurRadius: 5,
                    offset: Offset(1,1)
                  )]
                ),
                child: const Center(
                  child: Text(
                    'see available coupons →',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox(width: 10,),
            ]),
          )
        ],
      ),
    );
  }
}