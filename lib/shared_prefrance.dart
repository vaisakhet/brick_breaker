
import 'package:shared_preferences/shared_preferences.dart';

const kHighScore = "highScore";

class SharedPrefResponse {
  static SharedPreferences? _prefns;
  static SharedPrefResponse? _instance;

  SharedPrefResponse._(SharedPreferences prefs) {
    _prefns = prefs;
  }

  static Future<void> initialize() async {
    _instance ??= SharedPrefResponse._(await SharedPreferences.getInstance());
  }

  static SharedPrefResponse get instance => _instance!;


  void setHighScore(int accessToken) {
    _prefns!.setInt(kHighScore, accessToken);
  }


  /// Sign Out clrear All Data

  void resetHighScore() {
    // _prefns!.clear();
    _prefns!.remove(kHighScore);
  }

  int? get getHighScore {
    return _prefns!.getInt(kHighScore);
  }

}
