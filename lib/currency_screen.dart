// FILE NAME: currency_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'quote_screen.dart';
import 'main.dart';
import 'app_localization.dart';

class CurrencyScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback toggleTheme;

  const CurrencyScreen({
    super.key,
    required this.isDark,
    required this.toggleTheme,
  });

  @override
  State<CurrencyScreen> createState() =>
      _CurrencyScreenState();
}

class _CurrencyScreenState
    extends State<CurrencyScreen> {

  //////////////////////////////////////////////////
  // CURRENCY LIST
  //////////////////////////////////////////////////

  final List<Map<String, String>> currencies = [

    {
      "name": "Indian Rupee",
      "symbol": "₹",
      "code": "INR",
      "flag": "🇮🇳",
    },

    {
      "name": "US Dollar",
      "symbol": "\$",
      "code": "USD",
      "flag": "🇺🇸",
    },

    {
      "name": "Euro",
      "symbol": "€",
      "code": "EUR",
      "flag": "🇪🇺",
    },

    {
      "name": "British Pound",
      "symbol": "£",
      "code": "GBP",
      "flag": "🇬🇧",
    },

    {
      "name": "UAE Dirham",
      "symbol": "د.إ",
      "code": "AED",
      "flag": "🇦🇪",
    },
  ];

  //////////////////////////////////////////////////
  // SAVE CURRENCY
  //////////////////////////////////////////////////

  Future<void> saveCurrency(
    String symbol,
  ) async {

    try {

      final prefs =
          await SharedPreferences.getInstance();

      //////////////////////////////////////////////////
      // SAVE CURRENCY SYMBOL
      //////////////////////////////////////////////////

      await prefs.setString(
        'currency',
        symbol,
      );

      //////////////////////////////////////////////////
      // SAVE STATUS
      //////////////////////////////////////////////////

      await prefs.setBool(
        'currencySelected',
        true,
      );

      //////////////////////////////////////////////////
      // DEBUG PRINT
      //////////////////////////////////////////////////

      print(
        "Currency Saved: $symbol",
      );

      print(
        "Currency Selected Saved Successfully",
      );

      if (!mounted) return;

      //////////////////////////////////////////////////
      // NAVIGATE TO MAIN SCREEN
      //////////////////////////////////////////////////

      Navigator.pushReplacement(
      context,
      MaterialPageRoute(
    builder: (_) => QuoteScreen(
      isDark: widget.isDark,
      toggleTheme: widget.toggleTheme,
    ),
  ),
);
    }

    catch (e) {

      print(
        "Currency Save Error: $e",
      );
    }
  }

  //////////////////////////////////////////////////
  // UI
  //////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      //////////////////////////////////////////////////
      // BACKGROUND
      //////////////////////////////////////////////////

      body: Container(

        decoration: const BoxDecoration(

          gradient: LinearGradient(

            begin: Alignment.topLeft,
            end: Alignment.bottomRight,

            colors: [

              Color(0xFF020617),

              Color(0xFF0F172A),

              Color(0xFF111827),

              Color(0xFF1E293B),
            ],
          ),
        ),

        child: SafeArea(

          child: Padding(

            padding:
                const EdgeInsets.all(24),

            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                const SizedBox(height: 20),

                //////////////////////////////////////////////////
                // TITLE
                //////////////////////////////////////////////////

                Text(
                  AppLocalizations.of(context)
                      .tr('select_currency'),


                  style: TextStyle(

                    color: Colors.white,

                    fontSize: 34,

                    fontWeight:
                        FontWeight.bold,

                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: 12),

                //////////////////////////////////////////////////
                // SUBTITLE
                //////////////////////////////////////////////////

                Text(
                  AppLocalizations.of(context).tr(
                    'choose_currency_subtitle',
                  ),

                  style: TextStyle(

                    color: Colors.white70,

                    fontSize: 17,

                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 40),

                //////////////////////////////////////////////////
                // CURRENCY LIST
                //////////////////////////////////////////////////

                Expanded(

                  child: ListView.builder(

                    physics:
                        const BouncingScrollPhysics(),

                    itemCount:
                        currencies.length,

                    itemBuilder: (_, i) {

                      final currency =
                          currencies[i];

                      return GestureDetector(

                        onTap: () async {

                          //////////////////////////////////////////////////
                          // SAVE CURRENCY
                          //////////////////////////////////////////////////

                          await saveCurrency(
                            currency['symbol']!,
                          );
                        },

                        child: AnimatedContainer(

                          duration:
                              const Duration(
                                  milliseconds: 300),

                          margin:
                              const EdgeInsets.only(
                            bottom: 18,
                          ),

                          padding:
                              const EdgeInsets.all(
                                  20),

                          decoration: BoxDecoration(

                            color: Colors.white
                                .withOpacity(0.06),

                            borderRadius:
                                BorderRadius.circular(
                                    28),

                            border: Border.all(

                              color: Colors.white
                                  .withOpacity(0.08),
                            ),

                            boxShadow: [

                              BoxShadow(

                                color: Colors.black
                                    .withOpacity(0.25),

                                blurRadius: 20,

                                offset:
                                    const Offset(0, 8),
                              ),
                            ],
                          ),

                          child: Row(

                            children: [

                              //////////////////////////////////////////////////
                              // FLAG + SYMBOL
                              //////////////////////////////////////////////////

                              Container(

                                height: 72,
                                width: 72,

                                decoration:
                                    BoxDecoration(

                                  gradient:
                                      const LinearGradient(

                                    colors: [

                                      Color(0xFF14B8A6),

                                      Color(0xFF0EA5E9),
                                    ],
                                  ),

                                  borderRadius:
                                      BorderRadius.circular(
                                          22),
                                ),

                                child: Column(

                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .center,

                                  children: [

                                    Text(

                                      currency['flag']!,

                                      style:
                                          const TextStyle(
                                        fontSize: 22,
                                      ),
                                    ),

                                    const SizedBox(
                                        height: 2),

                                    Text(

                                      currency['symbol']!,

                                      style:
                                          const TextStyle(

                                        color:
                                            Colors.white,

                                        fontSize: 20,

                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(width: 18),

                              //////////////////////////////////////////////////
                              // DETAILS
                              //////////////////////////////////////////////////

                              Expanded(

                                child: Column(

                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,

                                  children: [

                                    Text(

                                      currency['name']!,

                                      style:
                                          const TextStyle(

                                        color:
                                            Colors.white,

                                        fontSize: 20,

                                        fontWeight:
                                            FontWeight.w700,
                                      ),
                                    ),

                                    const SizedBox(
                                        height: 5),

                                    Text(

                                      currency['code']!,

                                      style:
                                          const TextStyle(

                                        color:
                                            Colors.white54,

                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              //////////////////////////////////////////////////
                              // ARROW
                              //////////////////////////////////////////////////

                              Container(

                                padding:
                                    const EdgeInsets
                                        .all(10),

                                decoration:
                                    BoxDecoration(

                                  color: Colors.white
                                      .withOpacity(0.08),

                                  shape: BoxShape.circle,
                                ),

                                child: const Icon(

                                  Icons
                                      .arrow_forward_ios_rounded,

                                  color: Colors.white70,

                                  size: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                //////////////////////////////////////////////////
                // FOOTER
                //////////////////////////////////////////////////

                Center(

                  child: Text(

                    "You can change this later in Settings",

                    style: TextStyle(

                      color: Colors.white
                          .withOpacity(0.5),

                      fontSize: 14,
                    ),
                  ),
                ),

                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}