import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReservationFilterProvider extends ChangeNotifier{

  String searchedTreatment = 'Any';
  String timeCondition = 'future';

  String get getSearchedTreatment => searchedTreatment;
  String get getTimeCondition1 => timeCondition;

  void setSearchedTreatment(String machine){
    searchedTreatment = machine;
    notifyListeners();
  }
  void setTimeCondition(String condition) {
    timeCondition = condition;
    notifyListeners();
  }

  void loadPreference() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    searchedTreatment = pref.getString('pickedTreatment') ?? 'Any';
    timeCondition = pref.getString('selectedReservationType') ?? 'future';
    notifyListeners();
  }
}