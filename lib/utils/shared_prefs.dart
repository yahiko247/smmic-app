import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smmic/models/auth_models.dart';
import 'package:smmic/utils/datetime_formatting.dart';

enum Tokens{
  refresh,
  access
}


List<String> _userDataKeys = ['UID', 'first_name', 'last_name', 'province', 'city', 'barangay', 'zone', 'zip_code', 'email', 'password', 'profilepic'];

///SharedPreferences Utilities for setting and getting data from the SharedPreferences
class SharedPrefsUtils {
  final DateTimeFormatting _dateTimeFormatting = DateTimeFormatting();
  ///Gets `refresh` and `access` tokens from SharedPreferences. Returns both tokens by default
  Future<Map<String, dynamic>> getTokens({bool? refresh, bool? access}) async {
    Map<String, dynamic> tokens = {};
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? refreshToken = sharedPreferences.getString('refresh');
    String? accessToken = sharedPreferences.getString('access');
    if(refresh == null && access == null){
      tokens.addAll({'refresh':refreshToken, 'access':accessToken});
      return tokens;
    }
    if(refresh != null && refresh){
      tokens.addAll({'refresh':refreshToken});
    }
    if(access != null && access){
      tokens.addAll({'access':accessToken});
    }
    return tokens;
  }

  ///Stores tokens to SharedPreferences.
  ///
  ///Receives a Key:Value map using Tokens enums as keys (Tokens.refresh or Tokens.access)
  Future<void> setTokens({required Map<Tokens, dynamic> tokens}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (tokens.containsKey(Tokens.refresh) && tokens[Tokens.refresh] != null){
      await sharedPreferences.setString('refresh', tokens[Tokens.refresh]);
    }
    if(tokens.containsKey(Tokens.access) && tokens[Tokens.access] != null){
      await sharedPreferences.setString('access', tokens[Tokens.access]);
    }
    return;
  }

  ///Sets the login timestamp
  Future<void> setLoginFromRefresh({required String refresh}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    Map<String, dynamic> parsed = Jwt.parseJwt(refresh);
    String timestamp = _dateTimeFormatting.fromJWTSeconds(parsed['iat']).toString();
    await sharedPreferences.setString('login', timestamp);
  }

  Future<String?> getLogin() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString('login');
  }

  /// This function clears both refresh and access tokens from SharedPreferences.
  ///
  /// Useful when a forceLogin is required or when the user logs out. Outside of those two scenarios, use with caution.
  Future<void> clearTokens() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.remove('refresh');
    await sharedPreferences.remove('access');
    await sharedPreferences.remove('login');
  }

  /// Stores Map of `user_data` to SharedPreferences as `List<String>`
  Future<void> setUserData({required Map<String,dynamic> userInfo}) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if(userInfo.keys.toList() != _userDataKeys){
      throw ('error: User data Map keys provided to SharedPrefsUtils.setUserData did match registered user_data keys');
    }
    await sharedPreferences.setStringList('user_data', userInfo.keys.map((item) => userInfo[item].toString()).toList());
  }


  // [UID, first_name, last_name, province, city, barangay, zone, zip_code, email, password, profilepic]
  /// Returns the user data stored from SharedPreferences as a Map.
  ///
  /// Returns a null of the `user_data` from SharedPreferences is empty.
  ///
  /// Returns an 'error' key if the registered `keys` length does not match with the retrieved String List length from SharedPreferences
  Future<Map<String, dynamic>?> getUserData() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (!sharedPreferences.containsKey('user_data')){
      return null;
    }
    if (sharedPreferences.getStringList('user_data') != null){
      List<String> userData = sharedPreferences.getStringList('user_data')!;
      return _userDataMapper(userData);
    }
    throw('An unexpected error has occurred on SharedPrefsUtils.getStringList');
  }

  /// Maps the StringList that `getUserData()` returns
  Map<String, dynamic> _userDataMapper(List<String> userData) {
    if(userData.length != _userDataKeys.length){
      return {'error':'userData and keys length not matched, check userData contents'};
    }
    Map<String, dynamic> userMapped = {};
    for(int i = 0; i < _userDataKeys.length; i++){
      userMapped.addAll({_userDataKeys[i]:userData[i]});
    }
    return userMapped;
  }
}