import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static SharedPreferences instance;

  static Future init() async {
    instance = await SharedPreferences.getInstance();
  }

  static dynamic getValue(String key, dynamic emptyValue) {
    if (LocalStorage.instance.containsKey(key)) {
      return LocalStorage.instance.get(key);
    }
    return emptyValue;
  }
}
