import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../db/db_helper.dart';
import '../app_localization.dart';
import '../main.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback toggleTheme;
  final ValueChanged<Locale>? onLocaleChange;

  const LoginScreen({
    super.key,
    required this.isDark,
    required this.toggleTheme,
    this.onLocaleChange,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;
  bool isLoading = false;

  //////////////////////////////////////////////////
  // LOGIN
  //////////////////////////////////////////////////

  Future<void> login() async {
    final loc = AppLocalizations.of(context);

    String username = usernameController.text.trim();
    String password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            loc.tr('enter_credentials'),
          ),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    int? userId =
        await DBHelper.loginUser(username, password);

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            loc.tr('invalid_credentials'),
          ),
        ),
      );
      return;
    }

    //////////////////////////////////////////////////
    // SAVE SESSION
    //////////////////////////////////////////////////

    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('isLoggedIn', true);
    await prefs.setInt('userId', userId);
    await prefs.setString('username', username);

    //////////////////////////////////////////////////
    // SUCCESS
    //////////////////////////////////////////////////

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          loc.tr('login_successful'),
        ),
      ),
    );

    //////////////////////////////////////////////////
    // OPEN MAIN SCREEN
    //////////////////////////////////////////////////

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => MainScreen(
          isDark: widget.isDark,
          toggleTheme: widget.toggleTheme,
          onLocaleChange: widget.onLocaleChange,
        ),
      ),
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0F172A),
              Color(0xFF1E293B),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 450,
                ),
                child: Card(
                  elevation: 15,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(25),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        //////////////////////////////////////////////////
                        // LOGO
                        //////////////////////////////////////////////////

                        Container(
                          padding:
                              const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.teal
                                .withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet,
                            color: Colors.teal,
                            size: 80,
                          ),
                        ),

                        const SizedBox(height: 20),

                        //////////////////////////////////////////////////
                        // TITLE
                        //////////////////////////////////////////////////

                        Text(
                          loc.tr('wallet_login'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 30),

                        //////////////////////////////////////////////////
                        // USERNAME
                        //////////////////////////////////////////////////

                        TextField(
                          controller:
                              usernameController,
                          decoration: InputDecoration(
                            labelText:
                                loc.tr('username'),
                            prefixIcon: const Icon(
                              Icons.person,
                            ),
                            border:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(15),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        //////////////////////////////////////////////////
                        // PASSWORD
                        //////////////////////////////////////////////////

                        TextField(
                          controller:
                              passwordController,
                          obscureText:
                              obscurePassword,
                          decoration: InputDecoration(
                            labelText:
                                loc.tr('password'),
                            prefixIcon: const Icon(
                              Icons.lock,
                            ),
                            border:
                                OutlineInputBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(15),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscurePassword
                                    ? Icons
                                        .visibility
                                    : Icons
                                        .visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  obscurePassword =
                                      !obscurePassword;
                                });
                              },
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        //////////////////////////////////////////////////
                        // LOGIN BUTTON
                        //////////////////////////////////////////////////

                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed:
                                isLoading
                                    ? null
                                    : login,
                            style:
                                ElevatedButton.styleFrom(
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                            15),
                              ),
                            ),
                            child:
                                isLoading
                                    ? const CircularProgressIndicator()
                                    : Text(
                                      loc.tr(
                                        'login',
                                      ),
                                      style:
                                          const TextStyle(
                                            fontSize:
                                                18,
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                          ),
                                    ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        //////////////////////////////////////////////////
                        // REGISTER
                        //////////////////////////////////////////////////

                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) =>
                                        const RegisterScreen(),
                              ),
                            );
                          },
                          child: Text(
                            loc.tr(
                              'register_prompt',
                            ),
                            textAlign:
                                TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}