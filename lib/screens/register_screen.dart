import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../app_localization.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() =>
      _RegisterScreenState();
}

class _RegisterScreenState
    extends State<RegisterScreen> {
  final usernameController =
      TextEditingController();

  final passwordController =
      TextEditingController();

  final confirmPasswordController =
      TextEditingController();

  bool obscurePassword = true;

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    final loc = AppLocalizations.of(context);

    String username =
        usernameController.text.trim();

    String password =
        passwordController.text.trim();

    String confirmPassword =
        confirmPasswordController.text.trim();

    if (username.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            loc.tr('fill_all_fields'),
          ),
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            loc.tr('password_not_match'),
          ),
        ),
      );
      return;
    }

    bool success =
        await DBHelper.registerUser(
      username,
      password,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            loc.tr('account_created'),
          ),
        ),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            loc.tr('username_exists'),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      body: Container(
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
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 25,
              vertical: 20,
            ),
            child: Card(
              elevation: 20,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(25),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.all(25),
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    //////////////////////////////////////////////////
                    // ICON
                    //////////////////////////////////////////////////

                    Container(
                      padding:
                          const EdgeInsets.all(
                        20,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.teal
                            .withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_add_alt_1,
                        size: 80,
                        color: Colors.teal,
                      ),
                    ),

                    const SizedBox(height: 20),

                    //////////////////////////////////////////////////
                    // TITLE
                    //////////////////////////////////////////////////

                    Text(
                      loc.tr(
                          'create_account'),
                      style:
                          const TextStyle(
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
                      decoration:
                          InputDecoration(
                        labelText:
                            loc.tr(
                                'username'),
                        prefixIcon:
                            const Icon(
                          Icons
                              .person_outline,
                        ),
                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                                      15),
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
                      decoration:
                          InputDecoration(
                        labelText:
                            loc.tr(
                                'password'),
                        prefixIcon:
                            const Icon(
                          Icons
                              .lock_outline,
                        ),
                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                                      15),
                        ),
                        suffixIcon:
                            IconButton(
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

                    const SizedBox(height: 20),

                    //////////////////////////////////////////////////
                    // CONFIRM PASSWORD
                    //////////////////////////////////////////////////

                    TextField(
                      controller:
                          confirmPasswordController,
                      obscureText:
                          obscurePassword,
                      decoration:
                          InputDecoration(
                        labelText:
                            loc.tr(
                                'confirm_password'),
                        prefixIcon:
                            const Icon(
                          Icons.lock_reset,
                        ),
                        border:
                            OutlineInputBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                                      15),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    //////////////////////////////////////////////////
                    // REGISTER BUTTON
                    //////////////////////////////////////////////////

                    SizedBox(
                      width:
                          double.infinity,
                      height: 55,
                      child:
                          ElevatedButton(
                        onPressed:
                            register,
                        style:
                            ElevatedButton
                                .styleFrom(
                          shape:
                              RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius
                                    .circular(
                                        15),
                          ),
                        ),
                        child: Text(
                          loc.tr(
                              'create_account'),
                          style:
                              const TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    //////////////////////////////////////////////////
                    // BACK TO LOGIN
                    //////////////////////////////////////////////////

                    TextButton(
                      onPressed: () {
                        Navigator.pop(
                            context);
                      },
                      child: Text(
                        loc.tr(
                            'already_have_account'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}