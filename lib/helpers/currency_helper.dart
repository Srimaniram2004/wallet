import 'package:shared_preferences/shared_preferences.dart';

class CurrencyHelper {

  //////////////////////////////////////////////////
  // GET CURRENCY SYMBOL
  //////////////////////////////////////////////////

  static Future<String> getCurrencySymbol() async {

    final prefs =
        await SharedPreferences.getInstance();

    return prefs.getString('currency') ?? "₹";
  }
}