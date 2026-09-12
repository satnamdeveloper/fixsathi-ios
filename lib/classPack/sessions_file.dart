import 'package:shared_preferences/shared_preferences.dart';

class SessionUrl {
  String baseUrl = 'fixsathi.com';
  String httpUrl = 'https://fixsathi.com';
  String imgProfile = 'https://fixsathi.com/assets/uploads/';
  String keyUsername = 'username';
  String keyUserAcc = 'usertype';

  // GET URLS
  String getBaseUrl() {
    return baseUrl;
  }

  String gethttpUrl() {
    return httpUrl;
  }

  // SET SESSION
  Future<bool> setUsername(String username) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return await sharedPreferences.setString(keyUsername, username);
  }

  Future<bool> setUserAcc(String usertype) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return await sharedPreferences.setString(keyUserAcc, usertype);
  }

  // GET SESSION
  Future getUserdata() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(keyUsername);
  }

  Future getUserAcc() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(keyUserAcc);
  }

  // REMOVE SESSION
  Future removeUserData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return await sharedPreferences.remove(keyUsername);
  }

  Future removeSession() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return await sharedPreferences.clear();
  }

  Future removeUserAcc() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return await sharedPreferences.remove(keyUserAcc);
  }
}
