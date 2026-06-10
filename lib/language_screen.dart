import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'currency_screen.dart';

class LanguageScreen extends StatelessWidget {

  //////////////////////////////////////////////////
  // CALLBACK
  //////////////////////////////////////////////////
  final Function(Locale) onLanguageChanged;

  final bool isDark;
  final VoidCallback toggleTheme;

  const LanguageScreen({
    super.key,
    required this.onLanguageChanged,
    required this.isDark,
    required this.toggleTheme,
  });

  //////////////////////////////////////////////////
  // SAVE LANGUAGE
  //////////////////////////////////////////////////
  Future<void> selectLanguage(
    BuildContext context,
    String languageCode,
  ) async {

    final prefs = await SharedPreferences.getInstance();

    //////////////////////////////////////////////////
    // SAVE LANGUAGE
    //////////////////////////////////////////////////

    await prefs.setString(
      'languageCode',
      languageCode,
    );

    //////////////////////////////////////////////////
    // MARK LANGUAGE SELECTED
    //////////////////////////////////////////////////

    await prefs.setBool(
      'languageSelected',
      true,
    );

    //////////////////////////////////////////////////
    // CHANGE LANGUAGE INSTANTLY
    //////////////////////////////////////////////////

    onLanguageChanged(
      Locale(languageCode),
    );

    //////////////////////////////////////////////////
    // NAVIGATE TO CURRENCY SCREEN
    //////////////////////////////////////////////////

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => CurrencyScreen(
          isDark: isDark,
          toggleTheme: toggleTheme,
        ),
      ),
    );
  }

  //////////////////////////////////////////////////
  // UI
  //////////////////////////////////////////////////
  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;

    return Scaffold(

      body: Container(

        height: size.height,
        width: size.width,

        decoration: const BoxDecoration(

          gradient: LinearGradient(

            begin: Alignment.topLeft,
            end: Alignment.bottomRight,

            colors: [
              Color(0xFF0F2027),
              Color(0xFF203A43),
              Color(0xFF2C5364),
            ],
          ),
        ),

        child: SafeArea(

          child: SingleChildScrollView(

            physics: const BouncingScrollPhysics(),

            child: Padding(

              padding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 20,
              ),

              child: Column(

                children: [

                  const SizedBox(height: 10),

                  //////////////////////////////////////////////////
                  // APP ICON
                  //////////////////////////////////////////////////

                  Container(

                    height: 110,
                    width: 110,

                    decoration: BoxDecoration(

                      borderRadius:
                          BorderRadius.circular(30),

                      gradient:
                          const LinearGradient(

                        colors: [
                          Color(0xFF6A11CB),
                          Color(0xFF2575FC),
                        ],
                      ),

                      boxShadow: [

                        BoxShadow(

                          color:
                              Colors.black.withOpacity(0.25),

                          blurRadius: 15,

                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),

                    child: const Icon(

                      Icons.account_balance_wallet_rounded,

                      size: 55,

                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 28),

                  //////////////////////////////////////////////////
                  // TITLE
                  //////////////////////////////////////////////////

                  const Text(

                    "Choose Your Language",

                    textAlign: TextAlign.center,

                    style: TextStyle(

                      color: Colors.white,

                      fontSize: 30,

                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  //////////////////////////////////////////////////
                  // SUBTITLE
                  //////////////////////////////////////////////////

                  const Text(

                    "Select your preferred language\nfor the Wallet App",

                    textAlign: TextAlign.center,

                    style: TextStyle(

                      color: Colors.white70,

                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 35),

                  //////////////////////////////////////////////////
                  // LANGUAGES
                  //////////////////////////////////////////////////

                  buildLanguageCard(
                    context,
                    //"🇬🇧",
                    "English",
                    "en",
                  ),

                  buildLanguageCard(
                    context,
                   // "🇮🇳",
                    "தமிழ் (Tamil)",
                    "ta",
                  ),

                  buildLanguageCard(
                    context,
                    //"🇮🇳",
                    "हिन्दी (Hindi)",
                    "hi",
                  ),

                  buildLanguageCard(
                    context,
                   // "🇮🇳",
                    "తెలుగు (Telugu)",
                    "te",
                  ),

                  buildLanguageCard(
                    context,
                    //"🇮🇳",
                    "മലയാളം (Malayalam)",
                    "ml",
                  ),

                  buildLanguageCard(
                    context,
                    //"🇮🇳",
                    "ಕನ್ನಡ (Kannada)",
                    "kn",
                  ),

                  buildLanguageCard(
                    context,
                   // "🇧🇩",
                    "বাংলা (Bengali)",
                    "bn",
                  ),

                  buildLanguageCard(
                    context,
                    //"🇮🇳",
                    "ગુજરાતી (Gujarati)",
                    "gu",
                  ),

                  buildLanguageCard(
                    context,
                    //"🇮🇳",
                    "मराठी (Marathi)",
                    "mr",
                  ),

                  buildLanguageCard(
                    context,
                    //"🇮🇳",
                    "ਪੰਜਾਬੀ (Punjabi)",
                    "pa",
                  ),

                  buildLanguageCard(
                    context,
                    //"🇵🇰",
                    "اُردُو (Urdu)",
                    "ur",
                  ),

                  buildLanguageCard(
                    context,
                    //"🇮🇳",
                    "ଓଡ଼ିଆ (Odia)",
                    "or",
                  ),

                  const SizedBox(height: 25),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  //////////////////////////////////////////////////
  // LANGUAGE CARD
  //////////////////////////////////////////////////
  Widget buildLanguageCard(
    BuildContext context,
   // String flag,
    String language,
    String code,
  ) {

    return Padding(

      padding: const EdgeInsets.only(bottom: 16),

      child: InkWell(

        borderRadius:
            BorderRadius.circular(22),

        onTap: () async {

          await selectLanguage(
            context,
            code,
          );
        },

        child: Container(

          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),

          decoration: BoxDecoration(

            color:
                Colors.white.withOpacity(0.12),

            borderRadius:
                BorderRadius.circular(22),

            border: Border.all(
              color: Colors.white24,
              width: 1.4,
            ),
          ),

          child: Row(

            children: [

              //////////////////////////////////////////////////
              // FLAG
              //////////////////////////////////////////////////

             /* Container(

                height: 55,
                width: 55,

                decoration: BoxDecoration(

                  color: Colors.white,

                  borderRadius:
                      BorderRadius.circular(16),
                ),

                child: Center(

                  child: Text(

                    flag,

                    style:
                        const TextStyle(
                      fontSize: 30,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 18),*/

              //////////////////////////////////////////////////
              // LANGUAGE NAME
              //////////////////////////////////////////////////

              Expanded(

                child: Text(

                  language,

                  style: const TextStyle(

                    color: Colors.white,

                    fontSize: 18,

                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ),

              //////////////////////////////////////////////////
              // ARROW
              //////////////////////////////////////////////////

              const Icon(

                Icons.arrow_forward_ios_rounded,

                color: Colors.white70,

                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}