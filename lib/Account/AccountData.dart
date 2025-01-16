class UserData{
  //name, phone number, ic, dob, gender, お客様の紹介元
  final String userName;
  final int phoneNum;
  final String gender;
  final String userId;
  final DateTime dob;

  UserData({required this.userId, required this.userName, required this.phoneNum, required this.gender, required this.dob});
}