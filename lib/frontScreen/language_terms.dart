import 'dart:async';
import 'dart:convert' as convert;

import 'package:fixsathi/classPack/sessions_file.dart';
import 'package:fixsathi/clients/dashboard_user.dart';
import 'package:fixsathi/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:translator/translator.dart';

enum SingingCharacter { english, punjabi }

class Language extends StatefulWidget {
  final String title;
  final String phoneno;
  const Language({super.key, required this.title, required this.phoneno});

  @override
  State<Language> createState() => _LanguageState();
}

class _LanguageState extends State<Language> {
  // Timer? _timer;
  SingingCharacter? _character = SingingCharacter.english;

  final translator = GoogleTranslator();
  String transt = 'Punjabi';
  String? appids;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    translates(transt);
  }

  // ignore: body_might_complete_normally_nullable
  Future<String?> translates(String texts) async {
    var translation = await translator.translate(texts, from: 'en', to: 'pa');
    setState(() {
      transt = translation.text;
    });
  }

  Future<void> regDirect() async {
    try {
      var url = Uri.https(SessionUrl().baseUrl, 'home/regDirect');
      final response = await http.post(
        url,
        body: {
          'mobileno': widget.phoneno.toString(),
          'language': _character.toString(),
          'appid': appids.toString(),
          'keyset': 'pass_key@satnam9041110310',
        },
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        final getlist = convert.jsonDecode(response.body);
        // print(getlist);
        if (getlist['status'] == 'success') {
          // EasyLoading.showToast("Registered & redirect to Dashbaord");

          Map<String, dynamic>? userall = {
            'userid': getlist['data']['id'].toString(),
            'mobileno': getlist['data']['contactno'].toString(),
            'language': getlist['data']['language'].toString(),
            'category': 'not',
          };
          final userstring = convert.jsonEncode(userall);
          await SessionUrl().setUsername(userstring);
          if (!mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MainDashboard()),
            (Route<dynamic> route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: Not get data?'),
              backgroundColor: Color.fromARGB(255, 205, 6, 6),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Required all input fields !'),
            backgroundColor: Color.fromARGB(255, 205, 6, 6),
          ),
        );
      }
    } catch (e) {
      debugPrint('error $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // _userName.value = _userName.value.copyWith(text: simnumber.toString());
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.indigo.shade800,
        title: Text('Choose Language'),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 30.0,
                vertical: 5.0,
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 2.0,
                    ),
                    margin: const EdgeInsets.symmetric(
                      vertical: 25.0,
                      horizontal: 10.0,
                    ),

                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'assets/images/icon.png',
                        width: 160.0,
                      ),
                    ),
                  ),
                  RadioListTile<SingingCharacter>(
                    title: const Text('English'),
                    subtitle: const Text('Eng-IN'),
                    value: SingingCharacter.english,
                    // ignore: deprecated_member_use
                    groupValue: _character,
                    // ignore: deprecated_member_use
                    onChanged: (SingingCharacter? value) {
                      setState(() {
                        _character = value;
                      });
                    },
                  ),
                  RadioListTile<SingingCharacter>(
                    title: Text(transt),
                    subtitle: const Text('Gurmukhi-IN'),
                    value: SingingCharacter.punjabi,
                    // ignore: deprecated_member_use
                    groupValue: _character,
                    // ignore: deprecated_member_use
                    onChanged: (SingingCharacter? value) {
                      setState(() {
                        _character = value;
                      });
                    },
                  ),

                  const Padding(padding: EdgeInsets.all(5.0)),
                  mainButton(
                    Text('Next >>', style: TextStyle(fontSize: 17)),
                    () {
                      regDirect();
                    },
                    Colors.white,
                    Colors.amber.shade800,
                  ),
                ],
              ),
            ),
            // ClipRRect(
            //   // borderRadius: BorderRadius.circular(75),
            //   child: Image.asset(
            //     'assets/images/rounded2.png',
            //     fit: BoxFit.cover,
            //     width: MediaQuery.of(context).size.width,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

class TermCond extends StatefulWidget {
  final String title;
  final Map<String, dynamic> users;
  const TermCond({super.key, required this.title, required this.users});

  @override
  State<TermCond> createState() => _TermCondState();
}

class _TermCondState extends State<TermCond> {
  // Timer? _timer;
  bool isChecked1 = false;
  bool isChecked2 = false;
  bool isChecked3 = false;
  bool isChecked4 = false;
  final translator = GoogleTranslator();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      translate();
    });
  }

  List getlangs = [
    'Terms & Conditions for Customer',
    'Enable Location & for Selfi Camra Gallery access',
    "If you book any service and cancel it, then the remaining payment will be refunded to the wallet after deducting GST.",
    "If any of your goods are damaged during the service, the responsibility will be the warranty shopkeeper.",
    'The app company will be responsible for repair and service & If the company worker does not come for an hour after booking the service, call the company number and ask.',
    'Terms & Conditions for Partner',
    'You have filled in your profile are correct and you have not filled any false information. If you misbehave with the customer during the task, your profile will be blocked.',
    'The guarantee of the goods you provide to the customer is yours. You have to make sure that the goods are not damaged or expired and the quality is good.',
    'You will earn by becoming a partner of the app and always keep your service reliable.',
    'If the customer has any problem or feedback about your shop, your profile will be blocked.',
  ];
  void translate() async {
    List languages = [
      'Terms & Conditions for Customer',
      'Enable Location & for Selfi Camra Gallery access',
      "If you book any service and cancel it, then the remaining payment will be refunded to the wallet after deducting GST.",
      "If any of your goods are damaged during the service, the responsibility will be the warranty shopkeeper.",
      'The app company will be responsible for repair and service & If the company worker does not come for an hour after booking the service, call the company number and ask.',
      'Terms & Conditions for Partner',
      'You have filled in your profile are correct and you have not filled any false information. If you misbehave with the customer during the task, your profile will be blocked.',
      'The guarantee of the goods you provide to the customer is yours. You have to make sure that the goods are not damaged or expired and the quality is good.',
      'You will earn by becoming a partner of the app and always keep your service reliable.',
      'If the customer has any problem or feedback about your shop, your profile will be blocked.',
    ];
    if (widget.users['lang'].toString() == 'punjabi') {
      var futures = languages.map((item) {
        return translator.translate(item.toString(), from: 'en', to: 'pa');
      }).toList();

      // 2. Wait for all of them to complete in parallel
      List<Translation> results = await Future.wait(futures);
      // for (var translation in results) {
      //   print(translation.text); // 'pa' translation
      // }
      if (mounted) {
        setState(() {
          getlangs = results;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          getlangs = languages;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.indigo.shade800,
        title: Text('Terms & Conditions'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 5.0,
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsetsGeometry.symmetric(vertical: 10.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.asset(
                          'assets/images/icon.png',
                          width: 150,
                        ),
                      ),
                    ),
                    if (widget.title == 'users')
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 4.0,
                        ),
                        child: Text(
                          getlangs[0].toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                    if (widget.title == 'users')
                      CheckboxListTile(
                        // Using CheckboxListTile for better usability
                        title: Text(getlangs[1].toString()),
                        value:
                            isChecked1, // Bind the state variable to the value property
                        onChanged: (bool? newValue) {
                          // The onChanged callback receives the new value
                          setState(() {
                            // Update the state and rebuild the UI
                            isChecked1 = newValue!;
                          });
                        },
                        controlAffinity: ListTileControlAffinity
                            .leading, // Position checkbox at the start
                      ),
                    if (widget.title == 'users')
                      CheckboxListTile(
                        // Using CheckboxListTile for better usability
                        title: Text(getlangs[2].toString()),
                        value:
                            isChecked2, // Bind the state variable to the value property
                        onChanged: (bool? newValue) {
                          // The onChanged callback receives the new value
                          setState(() {
                            // Update the state and rebuild the UI
                            isChecked2 = newValue!;
                          });
                        },
                        controlAffinity: ListTileControlAffinity
                            .leading, // Position checkbox at the start
                      ),
                    if (widget.title == 'users')
                      CheckboxListTile(
                        // Using CheckboxListTile for better usability
                        title: Text(getlangs[3].toString()),
                        value:
                            isChecked3, // Bind the state variable to the value property
                        onChanged: (bool? newValue) {
                          // The onChanged callback receives the new value
                          setState(() {
                            // Update the state and rebuild the UI
                            isChecked3 = newValue!;
                          });
                        },
                        controlAffinity: ListTileControlAffinity
                            .leading, // Position checkbox at the start
                      ),
                    if (widget.title == 'users')
                      CheckboxListTile(
                        // Using CheckboxListTile for better usability
                        title: Text(getlangs[4].toString()),
                        value:
                            isChecked4, // Bind the state variable to the value property
                        onChanged: (bool? newValue) {
                          // The onChanged callback receives the new value
                          setState(() {
                            // Update the state and rebuild the UI
                            isChecked4 = newValue!;
                          });
                        },
                        controlAffinity: ListTileControlAffinity
                            .leading, // Position checkbox at the start
                      ),
                    if (widget.title == 'partner')
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 4.0,
                        ),
                        child: Text(
                          getlangs[5].toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                    if (widget.title == 'partner')
                      CheckboxListTile(
                        // Using CheckboxListTile for better usability
                        title: Text(getlangs[6].toString()),
                        value:
                            isChecked1, // Bind the state variable to the value property
                        onChanged: (bool? newValue) {
                          // The onChanged callback receives the new value
                          setState(() {
                            // Update the state and rebuild the UI
                            isChecked1 = newValue!;
                          });
                        },
                        controlAffinity: ListTileControlAffinity
                            .leading, // Position checkbox at the start
                      ),
                    if (widget.title == 'partner')
                      CheckboxListTile(
                        // Using CheckboxListTile for better usability
                        title: Text(getlangs[7].toString()),
                        value:
                            isChecked2, // Bind the state variable to the value property
                        onChanged: (bool? newValue) {
                          // The onChanged callback receives the new value
                          setState(() {
                            // Update the state and rebuild the UI
                            isChecked2 = newValue!;
                          });
                        },
                        controlAffinity: ListTileControlAffinity
                            .leading, // Position checkbox at the start
                      ),
                    if (widget.title == 'partner')
                      CheckboxListTile(
                        // Using CheckboxListTile for better usability
                        title: Text(getlangs[8].toString()),
                        value:
                            isChecked3, // Bind the state variable to the value property
                        onChanged: (bool? newValue) {
                          // The onChanged callback receives the new value
                          setState(() {
                            // Update the state and rebuild the UI
                            isChecked3 = newValue!;
                          });
                        },
                        controlAffinity: ListTileControlAffinity
                            .leading, // Position checkbox at the start
                      ),
                    if (widget.title == 'partner')
                      CheckboxListTile(
                        // Using CheckboxListTile for better usability
                        title: Text(getlangs[9].toString()),
                        value:
                            isChecked4, // Bind the state variable to the value property
                        onChanged: (bool? newValue) {
                          // The onChanged callback receives the new value
                          setState(() {
                            // Update the state and rebuild the UI
                            isChecked4 = newValue!;
                          });
                        },
                        controlAffinity: ListTileControlAffinity
                            .leading, // Position checkbox at the start
                      ),

                    const Padding(padding: EdgeInsets.all(5.0)),
                    if ((isChecked1 == true) &&
                        (isChecked2 == true) &&
                        (isChecked3 == true) &&
                        (isChecked4 == true))
                      mainButton(
                        Text('Ok', style: TextStyle(fontSize: 17)),
                        () {
                          Navigator.pop(context);
                        },
                        Colors.white,
                        Colors.indigo.shade800,
                      ),
                    SizedBox(height: 50),
                  ],
                ),
              ),
              // ClipRRect(
              //   // borderRadius: BorderRadius.circular(75),
              //   child: Image.asset(
              //     'assets/images/rounded2.png',
              //     fit: BoxFit.cover,
              //     width: MediaQuery.of(context).size.width,
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

class TermCondition extends StatefulWidget {
  final String title;
  final Map<String, dynamic> users;
  const TermCondition({super.key, required this.title, required this.users});

  @override
  State<TermCondition> createState() => _TermConditionState();
}

class _TermConditionState extends State<TermCondition> {
  bool isChecked1 = false;
  bool isChecked2 = false;
  bool isChecked3 = false;
  bool isChecked4 = false;
  final translator = GoogleTranslator();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      translate();
    });
  }

  List getlangs = [
    "Terms & Conditions for Customer",
    'Enable Location & for Selfi Camra Gallery access',
    "If you book any service and cancel it, then the remaining payment will be refunded to the wallet after deducting GST.",
    "If any of your goods are damaged during the service, the responsibility will be the warranty shopkeeper.",
    "The app company will be responsible for repair and service & If the company worker does not come for an hour after booking the service, call the company number and ask.",
    "Terms & Conditions for Partner",
    "The details you have filled in your profile are correct, I hope you have not filled any false information.",
    "During the job, if you misbehave with the customer, your profile will be blocked.",
    "During the job, it is also important to ensure that no valuables of the customer are stolen. If any such complaint comes from you, the company will help the customer and will also file your complaint with the police.",
    "You will not demand more money from the customer than the rate fixed on the app.",
    "You will be given additional bonuses from time to time by the app company after seeing your good behavior and good service.",
    "We hope that you will earn good money by becoming our partner and will provide good service to your customer.",
  ];
  void translate() async {
    List languages = [
      "Terms & Conditions for Customer",
      'Enable Location & for Selfi Camra Gallery access',
      "If you book any service and cancel it, then the remaining payment will be refunded to the wallet after deducting GST.",
      "If any of your goods are damaged during the service, the responsibility will be the warranty shopkeeper.",
      "The app company will be responsible for repair and service & If the company worker does not come for an hour after booking the service, call the company number and ask.",
      "Terms & Conditions for Partner",
      "The details you have filled in your profile are correct, I hope you have not filled any false information.",
      "During the job, if you misbehave with the customer, your profile will be blocked.",
      "During the job, it is also important to ensure that no valuables of the customer are stolen. If any such complaint comes from you, the company will help the customer and will also file your complaint with the police.",
      "You will not demand more money from the customer than the rate fixed on the app.",
      "You will be given additional bonuses from time to time by the app company after seeing your good behavior and good service.",
      "We hope that you will earn good money by becoming our partner and will provide good service to your customer.",
    ];
    if (widget.users['lang'].toString() == 'punjabi') {
      var futures = languages.map((item) {
        return translator.translate(item.toString(), from: 'en', to: 'pa');
      }).toList();

      // 2. Wait for all of them to complete in parallel
      List<Translation> results = await Future.wait(futures);
      // for (var translation in results) {
      //   print(translation.text); // 'pa' translation
      // }
      if (!mounted) return;
      setState(() {
        getlangs = results;
      });
    } else {
      if (!mounted) return;
      setState(() {
        getlangs = languages;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // print(widget.users['category']);
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.indigo.shade800,
        title: Text('Terms & Conditions'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 5.0,
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsetsGeometry.symmetric(vertical: 10.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: Image.asset(
                          'assets/images/icon.png',
                          width: 150,
                        ),
                      ),
                    ),
                    if (widget.users['category'] == 'customer')
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 4.0,
                        ),
                        child: Text(
                          getlangs[0].toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                    if (widget.title == 'users') Text(getlangs[1].toString()),

                    if (widget.users['category'] == 'customer')
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 4.0,
                        ),
                        child: Text(getlangs[2].toString()),
                      ),

                    if (widget.users['category'] == 'customer')
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 4.0,
                        ),
                        child: Text(getlangs[3].toString()),
                      ),

                    if (widget.users['category'] == 'customer')
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 4.0,
                        ),
                        child: Text(getlangs[4].toString()),
                      ),

                    if (widget.users['category'] == 'workerPartner' ||
                        widget.users['category'] == 'shopkeeper')
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 4.0,
                        ),
                        child: Text(
                          getlangs[5].toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18.0,
                          ),
                        ),
                      ),
                    if (widget.users['category'] == 'workerPartner' ||
                        widget.users['category'] == 'shopkeeper')
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 4.0,
                        ),
                        child: Text(getlangs[6].toString()),
                      ),

                    if (widget.users['category'] == 'workerPartner' ||
                        widget.users['category'] == 'shopkeeper')
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 4.0,
                        ),
                        child: Text(getlangs[7].toString()),
                      ),

                    if (widget.users['category'] == 'workerPartner' ||
                        widget.users['category'] == 'shopkeeper')
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 4.0,
                        ),
                        child: Text(getlangs[8].toString()),
                      ),

                    if (widget.users['category'] == 'workerPartner' ||
                        widget.users['category'] == 'shopkeeper')
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 4.0,
                        ),
                        child: Text(getlangs[9].toString()),
                      ),

                    SizedBox(height: 50),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
