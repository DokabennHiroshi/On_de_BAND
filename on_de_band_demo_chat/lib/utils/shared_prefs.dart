import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static SharedPreferences? _preferences;

  static Future<void> setPrefsInstance() async {
    _preferences ??= await SharedPreferences.getInstance();  //null演算子
  }

  //作成されたユーザーIDを端末に保存
  static Future<void> setUid(String uid) async {
    await _preferences!.setString('uid', uid);
  }

  static String? fetchUid() {
    return _preferences!.getString('uid');
  }
}