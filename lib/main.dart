import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'db/db_helper.dart';
import 'add_screen.dart';
import 'chart_screen.dart';
import 'category_screen.dart';
import 'settings_screen.dart';

import 'models/user_progress.dart';
import 'widges/avatar_card.dart';
import 'services/xp_service.dart';
import 'services/streak_service.dart';
// SMS SCREEN
import 'services/sms_service.dart';

// VIEW TRANSACTIONS
import 'all_transactions_screen.dart';

//notifi

import 'notification_service.dart';

//quote
import 'quote_screen.dart';

//currency

import 'currency_screen.dart';
//symbol of currency

import 'helpers/currency_helper.dart';  
import 'app_localization.dart';
import 'language_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';


/*void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Notifications
  await NotificationService.init();

  // Schedule Morning & Evening Notifications
  await NotificationService
      .scheduleDailyNotifications();

  final prefs =
      await SharedPreferences.getInstance();

  // final currencySelected =
  //     prefs.getBool('currencySelected') ?? false;

  final currencySelected = false;
  await NotificationService
    .showTestNotification();

  runApp(
    WalletApp(
      currencySelected: currencySelected,
    ),
  );
}*/

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ==============================
  // NOTIFICATIONS INIT
  // ==============================
  await NotificationService.init();
  await NotificationService.scheduleDailyNotifications();

  // ==============================
  // SHARED PREFS
  // ==============================
  final prefs = await SharedPreferences.getInstance();

  // ==============================
  // LOAD SAVED SETTINGS
  // ==============================
  
  final languageSelected = prefs.getBool('languageSelected') ?? false;

  final currencySelected = prefs.getBool('currencySelected') ?? false;
  final savedLanguage = prefs.getString('languageCode') ?? 'en';
  // ==============================
  // TEST NOTIFICATION (optional)
  // ==============================
  await NotificationService.showTestNotification();

  // ==============================
  // RUN APP
  // ==============================
  runApp(
    WalletApp(
      currencySelected: currencySelected,
      languageSelected: languageSelected,
      initialLanguageCode: savedLanguage,
    ),
  );
}
// 👇 ADD HERE (above WalletApp)
class SplashRouter extends StatefulWidget {
  final bool isDark;
  final VoidCallback toggleTheme;
  final Function(Locale) setLocale;

  const SplashRouter({
    super.key,
    required this.isDark,
    required this.toggleTheme,
    required this.setLocale,
  });

  @override
  State<SplashRouter> createState() => _SplashRouterState();
}
class _SplashRouterState extends State<SplashRouter> {
  bool? languageSelected;
  bool? currencySelected;
  String languageCode = "en";

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    languageSelected = prefs.getBool('languageSelected') ?? false;
    currencySelected = prefs.getBool('currencySelected') ?? false;
    languageCode = prefs.getString('languageCode') ?? 'en';

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (languageSelected == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

          if (!languageSelected!) {
        return LanguageScreen(
          isDark: widget.isDark,
          toggleTheme: widget.toggleTheme,
          onLanguageChanged: (Locale locale) {
            widget.setLocale(locale);
          },
        );
      }

    if (!currencySelected!) {
      return CurrencyScreen(
        isDark: widget.isDark,
        toggleTheme: widget.toggleTheme,
      );
    }

    return MainScreen(
      isDark: widget.isDark,
      toggleTheme: widget.toggleTheme,
      onLocaleChange: widget.setLocale,
    );
  }
}
// WALLET APP


/*class WalletApp extends StatefulWidget {
  
  final bool currencySelected;

  const WalletApp({
    super.key,
    required this.currencySelected,
  });

  @override
  State<WalletApp> createState() =>
      _WalletAppState();
}
class _WalletAppState
    extends State<WalletApp> {

  //////////////////////////////////////////////////
  // THEME
  //////////////////////////////////////////////////

  bool isDark = false;

  //////////////////////////////////////////////////
  // TOGGLE THEME
  //////////////////////////////////////////////////

  void toggleTheme() {

    setState(() {

      isDark = !isDark;
    });
  }

  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      debugShowCheckedModeBanner:
          false,

      //////////////////////////////////////////////////
      // ROUTES
      //////////////////////////////////////////////////

      routes: {

        '/sms': (_) =>
            const SMSStyledScreen(),
      },

      //////////////////////////////////////////////////
      // THEME MODE
      //////////////////////////////////////////////////

      themeMode:
          isDark
              ? ThemeMode.dark
              : ThemeMode.light,

      //////////////////////////////////////////////////
      // LIGHT THEME
      //////////////////////////////////////////////////

      theme: ThemeData(

        brightness: Brightness.light,

        primarySwatch: Colors.teal,

        scaffoldBackgroundColor:
            const Color(0xFFF4F6FA),

        useMaterial3: true,
      ),

      //////////////////////////////////////////////////
      // DARK THEME
      //////////////////////////////////////////////////

      darkTheme: ThemeData(

        brightness: Brightness.dark,

        primarySwatch: Colors.teal,

        scaffoldBackgroundColor:
            const Color(0xFF121212),

        cardColor:
            const Color(0xFF1E1E1E),

        useMaterial3: true,
      ),

      //////////////////////////////////////////////////
      // HOME FLOW
      //////////////////////////////////////////////////

      home: widget.currencySelected

          //////////////////////////////////////////////////
          // MAIN SCREEN
          //////////////////////////////////////////////////

          ? MainScreen(
              isDark: isDark,
              toggleTheme:
                  toggleTheme,
            )

          //////////////////////////////////////////////////
          // FIRST INSTALL FLOW
          //////////////////////////////////////////////////

          : QuoteScreen(
              isDark: isDark,
              toggleTheme:
                  toggleTheme,
            ),
    );
  }
}*/

class WalletApp extends StatefulWidget {
  final bool currencySelected;
  final bool languageSelected;
  final String initialLanguageCode;

  const WalletApp({
    super.key,
    required this.currencySelected,
    required this.languageSelected,
    required this.initialLanguageCode,
  });

  @override
  State<WalletApp> createState() => _WalletAppState();
}

class _WalletAppState extends State<WalletApp> {
  //////////////////////////////////////////////////
  // THEME
  //////////////////////////////////////////////////
  bool isDark = false;
  bool _isLoggedIn = false;
  bool _checkingLogin = true;

  //////////////////////////////////////////////////
  // LANGUAGE
  //////////////////////////////////////////////////
  late Locale _locale;
  bool quoteShown = false;

  @override
 void initState() {
  super.initState();

  _locale = Locale(widget.initialLanguageCode);

  loadQuoteStatus();
  checkLoginStatus();
}
Future<void> loadQuoteStatus() async {

  final prefs =
      await SharedPreferences.getInstance();

  setState(() {

    quoteShown =
        prefs.getBool('quoteShown') ?? false;
  });
}

  void toggleTheme() {
    setState(() {
      isDark = !isDark;
    });
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }
//check login status
Future<void> checkLoginStatus() async {
  final prefs = await SharedPreferences.getInstance();

  setState(() {
    _isLoggedIn =
        prefs.getBool('isLoggedIn') ?? false;

    _checkingLogin = false;
  });
}

  //////////////////////////////////////////////////
  // ONBOARDING FLOW CONTROL
  //////////////////////////////////////////////////
  late bool _languageDone;
  late bool _currencyDone;

  @override
  Widget build(BuildContext context) {
    _languageDone = widget.languageSelected;
    _currencyDone = widget.currencySelected;

    Widget homeScreen;

    // FLOW 1: LANGUAGE
   
    if (!_languageDone) {
        homeScreen = LanguageScreen(
        isDark: isDark,
        toggleTheme: toggleTheme,
        onLanguageChanged: (Locale locale) {
          setLocale(locale);
        },
      );
    }


    // FLOW 2: CURRENCY
  
    else if (!_currencyDone) {
      homeScreen = CurrencyScreen(
        isDark: isDark,
        toggleTheme: toggleTheme,
        );
    }
    //qoutescreen
    else if (!quoteShown) {
        homeScreen = QuoteScreen(
          isDark: isDark,
          toggleTheme: toggleTheme,
        );
      }

    
    // FLOW 3: MAIN APP

    else {
      homeScreen = MainScreen(
        isDark: isDark,
        toggleTheme: toggleTheme,
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      
      // LOCALIZATION FIX (IMPORTANT)
      localizationsDelegates:  [
         AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      supportedLocales: const [
        Locale('en'),
        Locale('ta'),
        Locale('hi'),
        Locale('te'),
        Locale('ml'),
        Locale('kn'),
        Locale('bn'),
        Locale('gu'),
        Locale('mr'),
        Locale('pa'),
        Locale('ur'),
        Locale('or'),
      ],

      locale: _locale,

      localeResolutionCallback: (locale, supportedLocales) {
        if (locale == null) return supportedLocales.first;

        for (var supported in supportedLocales) {
          if (supported.languageCode == locale.languageCode) {
            return supported;
          }
        }
        return supportedLocales.first;
      },

      //////////////////////////////////////////////////
      // THEME
      //////////////////////////////////////////////////
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,

      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFFF4F6FA),
        useMaterial3: true,
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        useMaterial3: true,
      ),

      home: homeScreen,
    );
  }
}


/*class MainScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback toggleTheme;

  const MainScreen({
    super.key,
    required this.isDark,
    required this.toggleTheme,
  });

  @override
  State<MainScreen> createState() =>
      _MainScreenState();
}*/
class MainScreen extends StatefulWidget {
  final bool isDark;
  final VoidCallback toggleTheme;

  // ==============================
  // LANGUAGE CHANGE CALLBACK
  // ==============================
  final ValueChanged<Locale>? onLocaleChange;

  const MainScreen({
    super.key,
    required this.isDark,
    required this.toggleTheme,
    this.onLocaleChange,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState
    extends State<MainScreen> {

  int index = 0;

  //////////////////////////////////////////////////
  // CURRENCY SYMBOL
  //////////////////////////////////////////////////

  String currencySymbol = "₹";

  List<Map<String, dynamic>> transactions = [];

  Map<String, List<String>> categories = {};

  double income = 0;
  double expense = 0;

  double weeklyExpense = 0;
  double monthlyExpense = 0;
  double yearlyExpense = 0;
  double totalExpense = 0;

UserProgress progress = UserProgress(
  xp: 0,
  level: 1,
  stars: 0,
  streak: 0,
  avatar: 'assets/avatar1.png',
  lastLogin: '',
);
  @override
  void initState() {
    super.initState();

    loadCurrency();
    loadData();
    loadGamification();

  //checkLoginStatus();
  }
 

  //////////////////////////////////////////////////
  // LOAD CURRENCY
  //////////////////////////////////////////////////

  Future<void> loadCurrency() async {

    final prefs =
        await SharedPreferences.getInstance();

    setState(() {

      currencySymbol =
          prefs.getString('currency') ?? "₹";
    });
  }

Future<void> showProfileMenu() async {
  final prefs = await SharedPreferences.getInstance();

  String username =
      prefs.getString('username') ?? 'User';

  int xp = prefs.getInt('xp') ?? 0;
  int level = prefs.getInt('level') ?? 1;
  int stars = prefs.getInt('stars') ?? 0;

  if (!mounted) return;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(25),
      ),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            //////////////////////////////////////////////////
            // PROFILE ICON
            //////////////////////////////////////////////////

            CircleAvatar(
              radius: 40,
              backgroundColor:
                  Colors.teal.withOpacity(0.15),
              child: const Icon(
                Icons.person,
                size: 45,
                color: Colors.teal,
              ),
            ),

            const SizedBox(height: 15),

            //////////////////////////////////////////////////
            // USERNAME
            //////////////////////////////////////////////////

            Text(
              username,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            //////////////////////////////////////////////////
            // USER INFO
            //////////////////////////////////////////////////

            Card(
              elevation: 2,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text("Username"),
                    subtitle: Text(username),
                  ),

                  ListTile(
                    leading: const Icon(Icons.bolt),
                    title: const Text("XP"),
                    subtitle: Text("$xp XP"),
                  ),

                  ListTile(
                    leading: const Icon(Icons.trending_up),
                    title: const Text("Level"),
                    subtitle: Text("Level $level"),
                  ),

                  ListTile(
                    leading: const Icon(Icons.star),
                    title: const Text("Stars"),
                    subtitle: Text("$stars Stars"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            //////////////////////////////////////////////////
            // LOGOUT BUTTON
            //////////////////////////////////////////////////

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.logout),
                label: const Text(
                  "Logout",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(15),
                  ),
                ),
                onPressed: () async {
                  await prefs.setBool(
                    'isLoggedIn',
                    false,
                  );

                  if (!mounted) return;

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LoginScreen(
                        isDark: widget.isDark,
                        toggleTheme:
                            widget.toggleTheme,
                        onLocaleChange:
                            widget.onLocaleChange,
                      ),
                    ),
                    (route) => false,
                  );
                },
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      );
    },
  );
}


//load  gamification

/*Future<void> loadGamification() async {

  final prefs =
      await SharedPreferences.getInstance();

  progress = UserProgress(

    xp:
        prefs.getInt('xp') ?? 0,

    level:
        prefs.getInt('level') ?? 1,

    stars:
        prefs.getInt('stars') ?? 0,

    streak:
        prefs.getInt('streak') ?? 0,

    avatar:
        prefs.getString('avatar') ??
            'assets/avatar1.png',

    lastLogin:
        prefs.getString('lastLogin') ?? '',
  );

  progress =
      StreakService.updateLoginStreak(
          progress);

  progress =
      XPService.updateAvatar(progress);

 

  await saveProgress();

  setState(() {});
}*/
Future<void> loadGamification() async {
  final prefs = await SharedPreferences.getInstance();

  print("Loaded XP = ${prefs.getInt('xp')}");
  print("Loaded Level = ${prefs.getInt('level')}");

  progress = UserProgress(
    xp: prefs.getInt('xp') ?? 0,
    level: prefs.getInt('level') ?? 1,
    stars: prefs.getInt('stars') ?? 0,
    streak: prefs.getInt('streak') ?? 0,
    avatar: prefs.getString('avatar') ?? 'assets/avatar1.png',
    lastLogin: prefs.getString('lastLogin') ?? '',
  );

  progress = StreakService.updateLoginStreak(progress);
  progress = XPService.updateAvatar(progress);

  await saveProgress();

  setState(() {});
}
Future<void> saveProgress() async {

  final prefs =
      await SharedPreferences.getInstance();

  await prefs.setInt(
      'xp', progress.xp);

  await prefs.setInt(
      'level', progress.level);

  await prefs.setInt(
      'stars', progress.stars);

  await prefs.setInt(
      'streak', progress.streak);

  await prefs.setString(
      'avatar', progress.avatar);

  await prefs.setString(
      'lastLogin',
      progress.lastLogin);

    
}

  //load data
  Future<void> loadData() async {

    final tx =
        await DBHelper.getTransactions();

    final cat =
        await DBHelper.getCategories();

    final sub =
        await DBHelper.getSubCategories();

    double inc = 0;
    double exp = 0;

    double weekExp = 0;
    double monthExp = 0;
    double yearExp = 0;

    DateTime now = DateTime.now();

    for (var t in tx) {

      double amount =
          (t['amount'] ?? 0).toDouble();

      DateTime date =
          DateTime.tryParse(
                t['date'].toString(),
              ) ??
              DateTime.now();

      //////////////////////////////////////////////////
      // INCOME
      //////////////////////////////////////////////////

      if (t['type'] == "Income") {

        inc += amount;
      }

      //////////////////////////////////////////////////
      // EXPENSE
      //////////////////////////////////////////////////

      else if (t['type'] == "Expense") {

        exp += amount;

        // WEEKLY

        if (now
                .difference(date)
                .inDays <=
            7) {

          weekExp += amount;
        }

        // MONTHLY

        if (date.month == now.month &&
            date.year == now.year) {

          monthExp += amount;
        }

        // YEARLY

        if (date.year == now.year) {

          yearExp += amount;
        }
      }
    }

    //////////////////////////////////////////////////
    // CATEGORY
    //////////////////////////////////////////////////

    Map<String, List<String>> temp = {};

    for (var c in cat) {

      temp[c['name'].toString()] = [];
    }

    for (var s in sub) {

      if (temp.containsKey(
          s['category'])) {

        temp[s['category']]!
            .add(s['name']);
      }
    }

    setState(() {

      transactions = tx;

      categories = temp;

      income = inc;

      expense = exp;

      totalExpense = exp;

      weeklyExpense = weekExp;

      monthlyExpense = monthExp;

      yearlyExpense = yearExp;
    });
  }

  //////////////////////////////////////////////////
  // BUILD METHOD
  //////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {

    final pages = [

      //////////////////////////////////////////////////
      // HOME
      //////////////////////////////////////////////////

      HomeDashboard(

        income: income,
        expense: expense,
        balance: income - expense,

        transactions: transactions,

        onDelete: (id) async {

          await DBHelper.deleteTransaction(
              id);

          await loadData();
        },

        weeklyExpense: weeklyExpense,
        monthlyExpense: monthlyExpense,
        yearlyExpense: yearlyExpense,
        totalExpense: totalExpense,

        //////////////////////////////////////////////////
        // CURRENCY
        //////////////////////////////////////////////////

        currencySymbol: currencySymbol,
        progress: progress,
      ),

      //////////////////////////////////////////////////
      // CHART
      //////////////////////////////////////////////////

      ChartScreen(
        transactions: transactions,
      ),

      //////////////////////////////////////////////////
      // CATEGORY
      //////////////////////////////////////////////////

      CategoryScreen(

        categories: categories,

        onAddCategory: (name) async {

          await DBHelper.insertCategory(
              name);

          await loadData();
        },

        onAddSubCategory:
            (category, sub) async {

          await DBHelper.insertSubCategory(
            category,
            sub,
          );

          await loadData();
        },
      ),

      //////////////////////////////////////////////////
      // REPORT
      //////////////////////////////////////////////////

      ReportScreen(
        data: transactions,
        onRefresh: loadData,
      ),
    ];

    return Scaffold(

      //////////////////////////////////////////////////
      // APP BAR
      //////////////////////////////////////////////////

      appBar: AppBar(

        title:  Text(AppLocalizations.of(context).tr('my_wallet')),

        actions: [

          IconButton(

            icon: Icon(
              Theme.of(context)
                          .brightness ==
                      Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),

            onPressed:
               widget.toggleTheme,
          ),
        
   
        IconButton(
          icon: const CircleAvatar(
            radius: 14,
            child: Icon(
              Icons.person,
              size: 18,
            ),
          ),
          onPressed: showProfileMenu,
        ),
        ],
      ),

      //////////////////////////////////////////////////
      // BODY
      //////////////////////////////////////////////////

      body: pages[index],

      //////////////////////////////////////////////////
      // FLOATING BUTTONS
      //////////////////////////////////////////////////

      floatingActionButton: index == 0
          ? Column(
              mainAxisAlignment:
                  MainAxisAlignment.end,

              children: [

               
               
              /*  FloatingActionButton(

                  heroTag: "sms",

                  backgroundColor:
                      Colors.orange,

                  child:
                      const Icon(Icons.sms),

                  onPressed: () async {

                   

                    await Navigator.pushNamed(
                      context,
                      '/sms',
                    );

                    

                    await loadData();
                  },
                ),

                const SizedBox(height: 12),*/

               FloatingActionButton.extended(
                heroTag: "add",
                backgroundColor: Colors.teal,
                icon: const Icon(Icons.add),
                label: Text(
                  AppLocalizations.of(context).translate('add'),
                ),
                onPressed: () async {
                  final res = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AddScreen(
                        categories: categories.keys.toList(),
                        subCategories: categories,
                      ),
                    ),
                  );

                  if (res != null) {
                    await DBHelper.insertTransaction(
                      res['amount'],
                      res['type'],
                      res['category'],
                      res['subCategory'] ?? "", // FIXED
                    );

                    setState(() {
                      progress = XPService.addXP(progress, 15);
                      progress = XPService.addStars(progress, 2);
                      progress = XPService.updateProgress(progress);
                    });

                    await saveProgress();
                    await loadData();
                  }
                },
              )
              ],
            )
          : null,

   

      bottomNavigationBar:
          NavigationBar(

        selectedIndex: index,

        onDestinationSelected:
            (i) {

          setState(() {

            index = i;
          });
        },

        destinations:  [

        NavigationDestination(
          icon: Icon(Icons.home),
          label: AppLocalizations.of(context).tr('home'),
        ),

        NavigationDestination(
          icon: Icon(Icons.pie_chart),
          label: AppLocalizations.of(context).tr('stats'),
        ),

        NavigationDestination(
          icon: Icon(Icons.category),
          label: AppLocalizations.of(context).tr('category'),
        ),

        NavigationDestination(
          icon: Icon(Icons.settings),
          label: AppLocalizations.of(context).tr('settings'),
        ),
      ],
      ),
    );
  }
}

class HomeDashboard extends StatelessWidget {
  final double income;
  final double expense;
  final double balance;

  final double weeklyExpense;
  final double monthlyExpense;
  final double yearlyExpense;
  final double totalExpense;

  final UserProgress progress;

  //////////////////////////////////////////////////
  // CURRENCY SYMBOL
  //////////////////////////////////////////////////

  final String currencySymbol;

  final List<Map<String, dynamic>> transactions;

  final Function(int) onDelete;

  const HomeDashboard({
    super.key,
    required this.income,
    required this.expense,
    required this.balance,
    required this.transactions,
    required this.onDelete,
    required this.weeklyExpense,
    required this.monthlyExpense,
    required this.yearlyExpense,
    required this.totalExpense,
    required this.currencySymbol,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              //////////////////////////////////////////////////
              // HEADER
              //////////////////////////////////////////////////

              Row(
                children: [
                   Expanded(
                    child: Text(
                       AppLocalizations.of(context).tr('my_wallet'),

                      maxLines: 1,

                      overflow:
                          TextOverflow.ellipsis,

                      style: TextStyle(
                        fontSize: 24,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),

               
                ],
              ),

              const SizedBox(height: 20),

              //////////////////////////////////////////////////
              // AVATAR CARD
              //////////////////////////////////////////////////

              AvatarCard(
             //   height: 100,
               // width: double.infinity,
                //color: Colors.teal,
                progress:progress,
              ),

              const SizedBox(height: 20),

              //////////////////////////////////////////////////
              // EXPENSE CARDS
              //////////////////////////////////////////////////

              Row(
                children: [
                  Expanded(
                    child: _premiumCard(
                      title: AppLocalizations.of(context).tr('weekly'),
                      amount: weeklyExpense,
                      color: Colors.orange,
                      icon: Icons
                          .calendar_view_week,
                    ),
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: _premiumCard(
                      title: AppLocalizations.of(context).tr('monthly'),
                      amount: monthlyExpense,
                      color: Colors.blue,
                      icon:
                          Icons.calendar_month,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: _premiumCard(
                      title: AppLocalizations.of(context).tr('yearly'),
                      amount: yearlyExpense,
                      color: Colors.purple,
                      icon: Icons.date_range,
                    ),
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: _premiumCard(
                      title: AppLocalizations.of(context).tr('total'),
                      amount: totalExpense,
                      color: Colors.red,
                      icon: Icons
                          .account_balance_wallet,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              //////////////////////////////////////////////////
              // INCOME / EXPENSE
              //////////////////////////////////////////////////

              Row(
                children: [
                  Expanded(
                    child: _premiumCard(
                      title: AppLocalizations.of(context).tr('income'),
                      amount: income,
                      color: Colors.green,
                      icon:
                          Icons.arrow_downward,
                    ),
                  ),

                  const SizedBox(width: 8),

                  Expanded(
                    child: _premiumCard(
                      title: AppLocalizations.of(context).tr('expense'),
                      amount: expense,
                      color: Colors.red,
                      icon:
                          Icons.arrow_upward,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              //////////////////////////////////////////////////
              // RECENT TRANSACTIONS
              //////////////////////////////////////////////////

              Row(
                children: [
                   Expanded(
                    child: Text(
                      AppLocalizations.of(context)
                         .tr('recent_transactions'),

                      maxLines: 1,

                      overflow:
                          TextOverflow.ellipsis,

                      style: TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),

                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,

                        MaterialPageRoute(
                          builder: (_) =>
                              AllTransactionsScreen(
                            transactions:
                                transactions,

                            onDelete:
                                onDelete,
                          ),
                        ),
                      );
                    },

                    child:  Text(
                       AppLocalizations.of(context)
                      .translate('view_all'),

                      style: TextStyle(
                        color: Colors.teal,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              //////////////////////////////////////////////////
              // TRANSACTION LIST
              //////////////////////////////////////////////////

              ListView.builder(
                shrinkWrap: true,

                physics:
                    const NeverScrollableScrollPhysics(),

                itemCount:
                    transactions.length > 10
                        ? 10
                        : transactions.length,

                itemBuilder: (_, i) {
                  final tx =
                      transactions[i];

                  final isIncome =
                      tx['type'] == "Income";

                  return Container(
                    width: double.infinity,

                    margin:
                        const EdgeInsets.only(
                      bottom: 10,
                    ),

                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 12,
                    ),

                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(
                              0xFF1E1E1E)
                          : Colors.white,

                      borderRadius:
                          BorderRadius.circular(
                              15),

                      boxShadow: [
                        if (!isDark)
                          BoxShadow(
                            color: Colors.black
                                .withOpacity(
                                    0.05),

                            blurRadius: 8,

                            offset:
                                const Offset(
                                    0, 4),
                          ),
                      ],
                    ),

                    child: Row(
                      children: [
                        //////////////////////////////////////////////////
                        // ICON
                        //////////////////////////////////////////////////

                        CircleAvatar(
                          radius: 18,

                          backgroundColor:
                              isIncome
                                  ? Colors.green
                                      .withOpacity(
                                          0.2)
                                  : Colors.red
                                      .withOpacity(
                                          0.2),

                          child: Icon(
                            isIncome
                                ? Icons
                                    .arrow_downward
                                : Icons
                                    .arrow_upward,

                            size: 18,

                            color: isIncome
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),

                        const SizedBox(width: 10),

                        //////////////////////////////////////////////////
                        // CATEGORY
                        //////////////////////////////////////////////////

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,

                            children: [
                              Text(
                                tx['category']
                                    .toString(),

                                maxLines: 1,

                                overflow:
                                    TextOverflow
                                        .ellipsis,

                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight
                                          .w600,
                                ),
                              ),

                              if (tx['subcategory'] !=
                                      null &&
                                  tx['subcategory']
                                      .toString()
                                      .isNotEmpty)

                                Text(
                                  tx['subcategory']
                                      .toString(),

                                  maxLines: 1,

                                  overflow:
                                      TextOverflow
                                          .ellipsis,

                                  style:
                                      TextStyle(
                                    fontSize: 12,

                                    color: Colors
                                        .grey
                                        .shade600,
                                  ),
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 6),

                        //////////////////////////////////////////////////
                        // CURRENCY
                        //////////////////////////////////////////////////

                        Flexible(
                          child: FittedBox(
                            fit:
                                BoxFit.scaleDown,

                            child: Text(
                              "${isIncome ? "+" : "-"} $currencySymbol${tx['amount']}",

                              maxLines: 1,

                              style: TextStyle(
                                fontWeight:
                                    FontWeight
                                        .bold,

                                color: isIncome
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ),
                        ),

                        //////////////////////////////////////////////////
                        // DELETE BUTTON
                        //////////////////////////////////////////////////

                        SizedBox(
                          width: 32,

                          child: IconButton(
                            padding:
                                EdgeInsets.zero,

                            constraints:
                                const BoxConstraints(),

                            icon: const Icon(
                              Icons
                                  .delete_outline,

                              size: 20,
                            ),

                            onPressed:
                                () async {
                              await onDelete(
                                tx['id'],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  //////////////////////////////////////////////////
  // PREMIUM CARD
  //////////////////////////////////////////////////

  Widget _premiumCard({
    required String title,
    required double amount,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 12,
      ),

      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.85),
            color.withOpacity(0.55),
          ],
        ),

        borderRadius:
            BorderRadius.circular(18),

        boxShadow: [
          BoxShadow(
            color:
                color.withOpacity(0.25),

            blurRadius: 12,

            offset: const Offset(0, 6),
          ),
        ],
      ),

      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 22,
          ),

          const SizedBox(height: 8),

          Text(
            title,

            maxLines: 1,

            overflow:
                TextOverflow.ellipsis,

            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 6),

          //////////////////////////////////////////////////
          // CURRENCY
          //////////////////////////////////////////////////

          FittedBox(
            fit: BoxFit.scaleDown,

            child: Text(
              "$currencySymbol ${amount.toStringAsFixed(0)}",

              maxLines: 1,

              overflow:
                  TextOverflow.ellipsis,

              style: const TextStyle(
                color: Colors.white,
                fontWeight:
                    FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class AppRestartTrigger extends StatelessWidget {
  const AppRestartTrigger({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = SharedPreferences.getInstance();

    return FutureBuilder(
      future: prefs,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return const SizedBox.shrink(); // triggers rebuild
      },
    );
  }
}