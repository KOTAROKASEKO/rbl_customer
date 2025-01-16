import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:rbl/Setting/ColorSetting.dart';


class PageTierGuide extends StatefulWidget{
  final String userTier;
  final int purchasePoint;
  final int nextPoint;
  final List<String> tiers;

  const PageTierGuide({super.key, required this.userTier,required this.purchasePoint, required this.nextPoint, required this.tiers});
  
  @override
  PageTierGuideState createState()=>PageTierGuideState();
}

class PageTierGuideState extends State<PageTierGuide>{
  String? rewardDetail = '';
  late List<String> tiers;
  late String selectedOption;
  String pickedRewardDetail='';

  Future<void> getCurrentRewardDetail() async{
    try{
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('rewardDetail').doc(widget.userTier).get();
      
      setState(() {
        rewardDetail = snapshot['detail'];
        pickedRewardDetail = snapshot['details'];
      });
    }catch(e){
      print('error happened during getting details : $e');
    }
  }
  
  Future<void> getRewardDetail(String tier) async{
    try{
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('rewardDetail').doc(tier).get();
      
      setState(() {
        pickedRewardDetail = snapshot['detail'];
      });
    }catch(e){
      print('error happened during getting details : $e');
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    selectedOption = widget.userTier;
    tiers = widget.tiers;
    getCurrentRewardDetail();
  }

  Color getTierOptionColor(String tier){
    if(tier==selectedOption){
      return Colors.blue;
    }else if(tiers.indexOf(tier)>tiers.indexOf(widget.userTier)){
      return Colors.grey;
    }else if(tiers.indexOf(tier)<=tiers.indexOf(widget.userTier)){
      return Colors.amber;
    }
    return Colors.red;
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('RBL gangs!', style: TextStyle(fontFamily: 'juliousSans',fontWeight: FontWeight.bold),),
      ),
      body: ListView(
        children: [
          
          const SizedBox(height: 10,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 10,),
              Expanded(child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  boxShadow: const [BoxShadow(
                    spreadRadius: 1.0,
                    color: Colors.grey,
                  )],
                  borderRadius: BorderRadius.circular(10)
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.person),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        const Text('Your tier: ',style: TextStyle(fontFamily: 'juliousSans',fontWeight: FontWeight.bold),),
                        Text(widget.userTier,style: const TextStyle(fontFamily: 'juliousSans',fontWeight: FontWeight.bold, fontSize: 20),)
                      ]),
                      trailing: Column(children:[
                        const Text('To next tier:', style: TextStyle(fontWeight: FontWeight.bold,color: Colorsetting.font, fontSize: 16),),
                        Text(
                        '${widget.purchasePoint}/${widget.nextPoint}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold, 
                          color: Colorsetting.font, 
                          fontSize: 16
                          ),
                        ),
                        ])
                    ),
                    
                    const SizedBox(height: 20,),
                    Row(children:[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child:Text('${widget.userTier}\'s reward', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colorsetting.title),),)
                      ]),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child:Row(children:[Text(rewardDetail!, textAlign: TextAlign.start,)]),)
                  ],
                ),
              ),
              ),
              const SizedBox(width: 10,)
           ],
          ),
          const SizedBox(
            height: 10
            ),
          getTiers(),
          const SizedBox(
            height: 10
            ),
          getDescriptionContainer(),
        ],
      ),
    );
  }
  Widget getTiers(){

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tiers.length,
        
        itemBuilder: (context,index){
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child:GestureDetector(
            child:Container(
              height: 40,
              decoration: BoxDecoration(
                color: getTierOptionColor(tiers[index]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child:Text(tiers[index],style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
                  ),
              ),
            ),
            onTap: (){
              setState(() {
                selectedOption = tiers[index];
              });
            },
          )
        );
      }),
    );
  }
  List<String> descriptions = [
    'snake description',
    'crocodile description',
    'tiger description',
    'dragon description',
  ];

  
  Widget getDescriptionContainer(){
    bool isLoading = true;
    getRewardDetail(selectedOption);
    isLoading=false;
    

    return isLoading==true?
    Container(
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    )
    :
    Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 300, 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child:Text(selectedOption,style: const TextStyle(fontWeight: FontWeight.bold, color: Colorsetting.title,fontSize: 20))
                  ),
                Padding(padding: const EdgeInsets.all(10),
                child: Text(pickedRewardDetail, style: const TextStyle(fontWeight: FontWeight.bold, color: Colorsetting.font,),)
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}