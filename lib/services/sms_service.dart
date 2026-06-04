import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../db/db_helper.dart';

//////////////////////////////////////////////////////////////
// SMS SERVICE
//////////////////////////////////////////////////////////////

class SMSService {
  final SmsQuery query = SmsQuery();

  ////////////////////////////////////////////////////
  // FETCH SMS
  ////////////////////////////////////////////////////

  Future<List<Map<String, dynamic>>> getSMS() async {
    final PermissionStatus status =
        await Permission.sms.request();

    if (!status.isGranted) {
      throw Exception("SMS permission denied");
    }

    final List<SmsMessage> messages =
        await query.getAllSms;

    final filtered = messages.where((msg) {
      return msg.body != null &&
          msg.body.toString().trim().isNotEmpty;
    }).toList();

    ////////////////////////////////////////////////////
    // SORT NEWEST FIRST
    ////////////////////////////////////////////////////

    filtered.sort((a, b) {
      final aDate =
          a.date?.millisecondsSinceEpoch ?? 0;

      final bDate =
          b.date?.millisecondsSinceEpoch ?? 0;

      return bDate.compareTo(aDate);
    });

    ////////////////////////////////////////////////////
    // CONVERT TO MAP
    ////////////////////////////////////////////////////

    final List<Map<String, dynamic>> smsList =
        filtered.map((msg) {
      String body = msg.body ?? "";

      double amount = extractAmount(body);

      return {
        "body": body,
        "address": msg.address ?? "Unknown",
        "date":
            msg.date
                    ?.millisecondsSinceEpoch
                    .toString() ??
                "0",
        "amount": amount,
        "type": "Not Selected",
      };
    }).toList();

    return smsList;
  }

  ////////////////////////////////////////////////////
  // EXTRACT AMOUNT
  ////////////////////////////////////////////////////

  double extractAmount(String text) {
    final regex =
        RegExp(r'(\d+[.,]?\d*)');

    final match =
        regex.firstMatch(text);

    if (match != null) {
      return double.tryParse(
            match
                .group(0)!
                .replaceAll(",", ""),
          ) ??
          0;
    }

    return 0;
  }
}

//////////////////////////////////////////////////////////////
// SMS SCREEN
//////////////////////////////////////////////////////////////

class SMSStyledScreen
    extends StatefulWidget {
  const SMSStyledScreen({super.key});

  @override
  State<SMSStyledScreen> createState() =>
      _SMSStyledScreenState();
}

class _SMSStyledScreenState
    extends State<SMSStyledScreen> {
  final SMSService service =
      SMSService();

  List<Map<String, dynamic>> smsList =
      [];

  bool loading = true;

  ////////////////////////////////////////////////////
  // CURRENCY SYMBOL
  ////////////////////////////////////////////////////

  String currencySymbol = "₹";

  @override
  void initState() {
    super.initState();

    loadCurrency();
    loadSMS();
  }

  ////////////////////////////////////////////////////
  // LOAD CURRENCY
  ////////////////////////////////////////////////////

  Future<void> loadCurrency() async {
    final prefs =
        await SharedPreferences.getInstance();

    setState(() {
      currencySymbol =
          prefs.getString('currency') ?? "₹";
    });
  }

  ////////////////////////////////////////////////////
  // LOAD SMS
  ////////////////////////////////////////////////////

  Future<void> loadSMS() async {
    try {
      final data =
          await service.getSMS();

      setState(() {
        smsList =
            data.take(100).toList();

        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
        ),
      );
    }
  }

  ////////////////////////////////////////////////////
  // FORMAT DATE
  ////////////////////////////////////////////////////

  String formatDate(String millis) {
    try {
      final date =
          DateTime
              .fromMillisecondsSinceEpoch(
        int.parse(millis),
      );

      return DateFormat(
        "dd MMM • hh:mm a",
      ).format(date);
    } catch (_) {
      return "";
    }
  }

  ////////////////////////////////////////////////////
  // SELECT TYPE
  ////////////////////////////////////////////////////

  void selectType(int index) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text(
            "Transaction Type",
          ),

          content: const Text(
            "Choose Income or Expense",
          ),

          actions: [

            //////////////////////////////////////////////////
            // INCOME
            //////////////////////////////////////////////////

            ElevatedButton.icon(
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.green,
              ),

              onPressed: () async {

                //////////////////////////////////////////////////
                // SAVE DATABASE
                //////////////////////////////////////////////////

                await DBHelper
                    .insertTransaction(
                  smsList[index]
                          ['amount'] ??
                      0,

                  "Income",

                  "SMS",

                  "",
                );

                //////////////////////////////////////////////////
                // UPDATE UI
                //////////////////////////////////////////////////

                setState(() {
                  smsList[index]
                      ['type'] = "Income";
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(
                        context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Income Added",
                    ),
                  ),
                );
              },

              icon: const Icon(
                Icons.arrow_downward,
              ),

              label:
                  const Text("Income"),
            ),

            //////////////////////////////////////////////////
            // EXPENSE
            //////////////////////////////////////////////////

            ElevatedButton.icon(
              style:
                  ElevatedButton.styleFrom(
                backgroundColor:
                    Colors.red,
              ),

              onPressed: () async {

                //////////////////////////////////////////////////
                // SAVE DATABASE
                //////////////////////////////////////////////////

                await DBHelper
                    .insertTransaction(
                  smsList[index]
                          ['amount'] ??
                      0,

                  "Expense",

                  "SMS",

                  "",
                );

                //////////////////////////////////////////////////
                // UPDATE UI
                //////////////////////////////////////////////////

                setState(() {
                  smsList[index]
                      ['type'] = "Expense";
                });

                Navigator.pop(context);

                ScaffoldMessenger.of(
                        context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Expense Added",
                    ),
                  ),
                );
              },

              icon: const Icon(
                Icons.arrow_upward,
              ),

              label:
                  const Text("Expense"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness ==
            Brightness.dark;

    final bgColor = isDark
        ? const Color(0xFF121212)
        : const Color(0xFFF5F6FA);

    final cardColor = isDark
        ? const Color(0xFF1E1E1E)
        : Colors.white;

    final textColor =
        isDark
            ? Colors.white
            : Colors.black;

    final subText = isDark
        ? Colors.grey[400]!
        : Colors.grey[700]!;

    return Scaffold(
      backgroundColor: bgColor,

      ////////////////////////////////////////////////////
      // APP BAR
      ////////////////////////////////////////////////////

      appBar: AppBar(
        title:
            const Text("Recent SMS"),

        centerTitle: true,

        backgroundColor:
            Colors.teal,
      ),

      ////////////////////////////////////////////////////
      // BODY
      ////////////////////////////////////////////////////

      body: loading

          ? const Center(
              child:
                  CircularProgressIndicator(),
            )

          : smsList.isEmpty

              ? const Center(
                  child: Text(
                    "No SMS Found",
                  ),
                )

              : ListView.builder(
                  padding:
                      const EdgeInsets
                          .all(12),

                  itemCount:
                      smsList.length,

                  itemBuilder:
                      (context, index) {

                    final sms =
                        smsList[index];

                    final type =
                        sms['type'];

                    return Container(
                      margin:
                          const EdgeInsets
                              .only(
                        bottom: 12,
                      ),

                      decoration:
                          BoxDecoration(
                        color:
                            cardColor,

                        borderRadius:
                            BorderRadius
                                .circular(
                                    18),

                        boxShadow: [
                          if (!isDark)
                            BoxShadow(
                              color: Colors
                                  .black
                                  .withOpacity(
                                      0.05),

                              blurRadius:
                                  6,

                              offset:
                                  const Offset(
                                      0,
                                      3),
                            ),
                        ],
                      ),

                      child: ListTile(
                        contentPadding:
                            const EdgeInsets
                                .symmetric(
                          horizontal:
                              16,

                          vertical:
                              12,
                        ),

                        //////////////////////////////////////////////////
                        // ICON
                        //////////////////////////////////////////////////

                        leading:
                            CircleAvatar(
                          backgroundColor:

                              type ==
                                      "Income"

                                  ? Colors
                                      .green
                                      .withOpacity(
                                          0.15)

                                  : type ==
                                          "Expense"

                                      ? Colors
                                          .red
                                          .withOpacity(
                                              0.15)

                                      : Colors
                                          .grey
                                          .withOpacity(
                                              0.15),

                          child: Icon(

                            type ==
                                    "Income"

                                ? Icons
                                    .arrow_downward

                                : type ==
                                        "Expense"

                                    ? Icons
                                        .arrow_upward

                                    : Icons
                                        .message,

                            color:

                                type ==
                                        "Income"

                                    ? Colors
                                        .green

                                    : type ==
                                            "Expense"

                                        ? Colors
                                            .red

                                        : Colors
                                            .grey,
                          ),
                        ),

                        //////////////////////////////////////////////////
                        // TITLE
                        //////////////////////////////////////////////////

                        title: Text(
                          sms['address'],

                          style:
                              TextStyle(
                            fontWeight:
                                FontWeight
                                    .bold,

                            color:
                                textColor,

                            fontSize:
                                15,
                          ),
                        ),

                        //////////////////////////////////////////////////
                        // SUBTITLE
                        //////////////////////////////////////////////////

                        subtitle: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [

                            const SizedBox(
                                height: 8),

                            //////////////////////////////////////////////////
                            // BODY
                            //////////////////////////////////////////////////

                            Text(
                              sms['body'],

                              style:
                                  TextStyle(
                                color:
                                    subText,

                                fontSize:
                                    14,

                                height:
                                    1.5,
                              ),
                            ),

                            const SizedBox(
                                height: 10),

                            //////////////////////////////////////////////////
                            // AMOUNT
                            //////////////////////////////////////////////////

                            Text(
                              "$currencySymbol ${sms['amount']}",

                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight
                                        .bold,

                                fontSize: 15,
                              ),
                            ),

                            const SizedBox(
                                height: 10),

                            //////////////////////////////////////////////////
                            // STATUS
                            //////////////////////////////////////////////////

                            Container(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal:
                                    10,

                                vertical:
                                    5,
                              ),

                              decoration:
                                  BoxDecoration(
                                color:

                                    type ==
                                            "Income"

                                        ? Colors
                                            .green
                                            .withOpacity(
                                                0.12)

                                        : type ==
                                                "Expense"

                                            ? Colors
                                                .red
                                                .withOpacity(
                                                    0.12)

                                            : Colors
                                                .grey
                                                .withOpacity(
                                                    0.12),

                                borderRadius:
                                    BorderRadius
                                        .circular(
                                            20),
                              ),

                              child: Text(
                                type,

                                style:
                                    TextStyle(
                                  fontWeight:
                                      FontWeight
                                          .bold,

                                  color:

                                      type ==
                                              "Income"

                                          ? Colors
                                              .green

                                          : type ==
                                                  "Expense"

                                              ? Colors
                                                  .red

                                              : Colors
                                                  .grey,
                                ),
                              ),
                            ),

                            const SizedBox(
                                height: 10),

                            //////////////////////////////////////////////////
                            // DATE
                            //////////////////////////////////////////////////

                            Align(
                              alignment:
                                  Alignment
                                      .bottomRight,

                              child: Text(
                                formatDate(
                                    sms[
                                        'date']),

                                style:
                                    TextStyle(
                                  color:
                                      subText,

                                  fontSize:
                                      11,
                                ),
                              ),
                            ),
                          ],
                        ),

                        //////////////////////////////////////////////////
                        // SAVE BUTTON
                        //////////////////////////////////////////////////

                        trailing:
                            ElevatedButton(
                          style:
                              ElevatedButton
                                  .styleFrom(
                            backgroundColor:
                                Colors.teal,
                          ),

                          onPressed: () {
                            selectType(
                                index);
                          },

                          child: const Text(
                            "Save",
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}