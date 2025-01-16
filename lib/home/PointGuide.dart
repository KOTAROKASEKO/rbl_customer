import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rbl/Setting/ColorSetting.dart';

class PointGuide extends StatelessWidget{
  Widget build(BuildContext context){
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
          Padding(
            padding: EdgeInsets.only(left: 20, top: 10),
              child:Text(
              'simple point system!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colorsetting.title
              ),
            )
          )
        ],
      ),
    );
  }
}