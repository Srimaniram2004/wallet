// FILE NAME: quote_screen.dart
import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'currency_screen.dart';
import 'main.dart';
import 'app_localization.dart';
import 'screens/login_screen.dart';

class QuoteScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback toggleTheme;

  const QuoteScreen({
    super.key,
    required this.isDark,
    required this.toggleTheme,
  });

  @override
  State<QuoteScreen> createState() =>
      _QuoteScreenState();
}

class _QuoteScreenState
    extends State<QuoteScreen>
    with SingleTickerProviderStateMixin {

  //////////////////////////////////////////////////
  // VARIABLES
  //////////////////////////////////////////////////

  late String selectedQuote;

  late AnimationController controller;

  Timer? timer;

  //////////////////////////////////////////////////
  // INIT
  //////////////////////////////////////////////////

  @override
  void initState() {

    super.initState();

    //////////////////////////////////////////////////
    // ANIMATION
    //////////////////////////////////////////////////

    controller = AnimationController(

      vsync: this,

      duration: const Duration(seconds: 2),

    )..repeat(reverse: true);

    //////////////////////////////////////////////////
    // NAVIGATION TIMER
    //////////////////////////////////////////////////

    timer = Timer(
      const Duration(seconds: 4),
      () async {

        if (!mounted) return;

        final prefs =
            await SharedPreferences.getInstance();

        final currencySelected =
            prefs.getBool(
                  'currencySelected',
                ) ??
                false;

        //////////////////////////////////////////////////
        // IF ALREADY SELECTED
        //////////////////////////////////////////////////

      //final prefs = await SharedPreferences.getInstance();

            bool isLoggedIn =
                prefs.getBool('isLoggedIn') ?? false;

            if (currencySelected) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => isLoggedIn
                      ? MainScreen(
                          isDark: widget.isDark,
                          toggleTheme: widget.toggleTheme,
                        )
                      : LoginScreen(
                          isDark: widget.isDark,
                          toggleTheme: widget.toggleTheme,
                        ),
                ),
              );
            }

        // FIRST TIME USER
        //////////////////////////////////////////////////

        else {

          Navigator.pushReplacement(

            context,

            MaterialPageRoute(

              builder: (_) => CurrencyScreen(

                isDark: widget.isDark,

                toggleTheme:
                    widget.toggleTheme,
              ),
            ),
          );
        }
      },
    );
  }

  //////////////////////////////////////////////////
  // DISPOSE
  //////////////////////////////////////////////////

  @override
  void dispose() {

    timer?.cancel();

    controller.dispose();

    super.dispose();
  }

  //////////////////////////////////////////////////
  // UI
  //////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {

    //////////////////////////////////////////////////
    // LOCALIZED QUOTES
    //////////////////////////////////////////////////

    final quotes = [

      AppLocalizations.of(context).tr('quote1'),

      AppLocalizations.of(context).tr('quote2'),

      AppLocalizations.of(context).tr('quote3'),

      AppLocalizations.of(context).tr('quote4'),

      AppLocalizations.of(context).tr('quote5'),

      AppLocalizations.of(context).tr('quote6'),

      AppLocalizations.of(context).tr('quote7'),

      AppLocalizations.of(context).tr('quote8'),
    ];

    //////////////////////////////////////////////////
    // RANDOM QUOTE
    //////////////////////////////////////////////////

    selectedQuote =
        quotes[Random().nextInt(quotes.length)];

    return Scaffold(

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

        child: Stack(

          children: [

            //////////////////////////////////////////////////
            // TOP GLOW
            //////////////////////////////////////////////////

            Positioned(

              top: -80,
              left: -50,

              child: _glowCircle(

                Colors.teal.withOpacity(0.25),

                220,
              ),
            ),

            //////////////////////////////////////////////////
            // BOTTOM GLOW
            //////////////////////////////////////////////////

            Positioned(

              bottom: -100,
              right: -60,

              child: _glowCircle(

                Colors.blue.withOpacity(0.2),

                260,
              ),
            ),

            //////////////////////////////////////////////////
            // MAIN CONTENT
            //////////////////////////////////////////////////

            Center(

              child: Padding(

                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 30,
                ),

                child: Column(

                  mainAxisAlignment:
                      MainAxisAlignment.center,

                  children: [

                    //////////////////////////////////////////////////
                    // LOGO ANIMATION
                    //////////////////////////////////////////////////

                    AnimatedBuilder(

                      animation: controller,

                      builder: (_, child) {

                        return Transform.scale(

                          scale:
                              1 +
                              (controller.value *
                                  0.05),

                          child: child,
                        );
                      },

                      child: Container(

                        height: 140,
                        width: 140,

                        decoration: BoxDecoration(

                          borderRadius:
                              BorderRadius.circular(
                                  40),

                          gradient:
                              const LinearGradient(

                            colors: [

                              Color(0xFF14B8A6),

                              Color(0xFF0EA5E9),
                            ],
                          ),

                          boxShadow: [

                            BoxShadow(

                              color: Colors.teal
                                  .withOpacity(0.5),

                              blurRadius: 35,

                              spreadRadius: 6,
                            ),
                          ],
                        ),

                        child: Padding(

                          padding:
                              const EdgeInsets.all(
                                  12),

                          child: ClipRRect(

                            borderRadius:
                                BorderRadius.circular(
                                    28),

                            child: Image.asset(

                              'assets/favicon.png',

                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    //////////////////////////////////////////////////
                    // TITLE
                    //////////////////////////////////////////////////
                    ShaderMask(
                        shaderCallback: (bounds) {
                          return const LinearGradient(
                            colors: [Colors.white, Color(0xFF67E8F9)],
                          ).createShader(bounds);
                        },
                        child: SizedBox(
                          width: double.infinity,
                          child: Text(
                            AppLocalizations.of(context).tr('smart_wallet'),
                            textAlign: TextAlign.center, //aligment
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),


                    //////////////////////////////////////////////////
                    // SUBTITLE
                    //////////////////////////////////////////////////

                   Text(

                      AppLocalizations.of(context)
                          .translate('track_save_grow'),

                      style: const TextStyle(

                        color: Colors.white54,

                        fontSize: 16,

                        letterSpacing: 1.2,
                      ),
                    ),

                    const SizedBox(height: 50),

                    //////////////////////////////////////////////////
                    // QUOTE CARD
                    //////////////////////////////////////////////////

                    Container(

                      padding:
                          const EdgeInsets.all(
                              25),

                      decoration: BoxDecoration(

                        color: Colors.white
                            .withOpacity(0.06),

                        borderRadius:
                            BorderRadius.circular(
                                28),

                        border: Border.all(

                          color: Colors.white
                              .withOpacity(0.1),
                        ),

                        boxShadow: [

                          BoxShadow(

                            color: Colors.black
                                .withOpacity(0.25),

                            blurRadius: 20,
                          ),
                        ],
                      ),

                      child: Column(

                        children: [

                          const Icon(

                            Icons
                                .format_quote_rounded,

                            color:
                                Colors.tealAccent,

                            size: 40,
                          ),

                          const SizedBox(height: 10),

                          Text(

                            selectedQuote,

                            textAlign:
                                TextAlign.center,

                            style:
                                const TextStyle(

                              color: Colors.white,

                              fontSize: 21,

                              height: 1.6,

                              fontWeight:
                                  FontWeight.w500,

                              fontStyle:
                                  FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 60),

                    //////////////////////////////////////////////////
                    // LOADING
                    //////////////////////////////////////////////////

                    SizedBox(

                      width: 35,
                      height: 35,

                      child:
                          CircularProgressIndicator(

                        strokeWidth: 3,

                        color:
                            Colors.tealAccent
                                .withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //////////////////////////////////////////////////
  // GLOW CIRCLE
  //////////////////////////////////////////////////

  Widget _glowCircle(
    Color color,
    double size,
  ) {

    return Container(

      height: size,
      width: size,

      decoration: BoxDecoration(

        shape: BoxShape.circle,

        gradient: RadialGradient(

          colors: [

            color,

            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

