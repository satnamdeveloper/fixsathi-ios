import 'dart:async';

import 'package:fixsathi/frontScreen/client_reg.dart';
import 'package:fixsathi/frontScreen/shopk_reg.dart';
// import 'package:fixsathi/frontScreen/worker_reg.dart';
import 'package:fixsathi/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:translator/translator.dart';

enum SingingCharacter { customer, partner, workerPartner }

class SelectCategory extends StatefulWidget {
  final String title;
  final String phoneno;
  final String lang;
  const SelectCategory({
    super.key,
    required this.title,
    required this.phoneno,
    required this.lang,
  });

  @override
  State<SelectCategory> createState() => _SelectCategoryState();
}

class _SelectCategoryState extends State<SelectCategory> {
  // Timer? _timer;
  SingingCharacter? _character = SingingCharacter.customer;

  final translator = GoogleTranslator();

  String? appids;

  @override
  void initState() {
    super.initState();
    // Future.delayed(const Duration(milliseconds: 500), () {
    translate();
  }

  List getlangs = [
    'Choose your Category.',
    'Customer',
    'Service Users',
    'Partner Provider',
    'Service Provider',
    'Worker Partner',
    'Executive',
    'Next Step',
    'Who are you? Select your category.',
  ];
  void translate() async {
    List languages = [
      'Choose your Category.',
      'Customer',
      'Service Users',
      'Partner Provider',
      'Service Provider',
      'Worker Partner',
      'Executive',
      'Next Step',
      'Who are you? Select your category.',
    ];
    if (widget.lang == 'SingingCharacter.punjabi') {
      var futures = languages.map((item) {
        return translator.translate(item.toString(), from: 'en', to: 'pa');
      }).toList();

      // 2. Wait for all of them to complete in parallel
      List<Translation> results = await Future.wait(futures);
      // for (var translation in results) {
      //   print(translation.text); // 'pa' translation
      // }
      setState(() {
        getlangs = results;
      });
    } else {
      setState(() {
        getlangs = languages;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // print(widget.lang.toString());
    // _userName.value = _userName.value.copyWith(text: simnumber.toString());
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.indigo.shade800,
        title: Text(getlangs[0].toString()),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ClipRRect(
              // borderRadius: BorderRadius.circular(75),
              child: Image.asset(
                'assets/images/rounded.png',
                fit: BoxFit.cover,
                width: MediaQuery.of(context).size.width,
              ),
            ),
            Divider(height: 25, thickness: 1),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 30.0,
                vertical: 5.0,
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: Padding(
                      padding: EdgeInsetsGeometry.symmetric(
                        horizontal: 7,
                        vertical: 5,
                      ),
                      child: Text(
                        'Who are you. Select your profile category',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsetsGeometry.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    child: Text(
                      'ਤੁਸੀ ਕੌਣ ਹੋ ਆਪਣੀ ਪ੍ਰੋਫਾਈਲ ਕੈਟਾਗਰੀ ਨੂੰ ਚੁਣੋ ',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  RadioListTile<SingingCharacter>(
                    title: Text(getlangs[1].toString()),
                    subtitle: Text(getlangs[2].toString()),
                    value: SingingCharacter.customer,
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
                    title: Text(getlangs[3].toString()),
                    subtitle: Text(getlangs[4].toString()),
                    value: SingingCharacter.partner,
                    // ignore: deprecated_member_use
                    groupValue: _character,
                    // ignore: deprecated_member_use
                    onChanged: (SingingCharacter? value) {
                      setState(() {
                        _character = value;
                      });
                    },
                  ),

                  // RadioListTile<SingingCharacter>(
                  //   title: Text(getlangs[5].toString()),
                  //   subtitle: Text(getlangs[6].toString()),
                  //   value: SingingCharacter.workerPartner,
                  //   // ignore: deprecated_member_use
                  //   groupValue: _character,
                  //   // ignore: deprecated_member_use
                  //   onChanged: (SingingCharacter? value) {
                  //     setState(() {
                  //       _character = value;
                  //     });
                  //   },
                  // ),
                  const Padding(padding: EdgeInsets.all(5.0)),
                  mainButton(
                    Text(
                      getlangs[7].toString(),
                      style: TextStyle(fontSize: 17),
                    ),
                    () {
                      if (_character.toString() ==
                          'SingingCharacter.customer') {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext context) => AddClient(
                              title: 'Register Customer',
                              users: {
                                'phoneno': widget.phoneno,
                                'lang': widget.lang,
                                'category': _character.toString(),
                              },
                            ),
                          ),
                        );
                      }
                      if (_character.toString() == 'SingingCharacter.partner') {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext context) => AddFirm(
                              title: 'Register As a Partner',
                              users: {
                                'phoneno': widget.phoneno,
                                'lang': widget.lang,
                                'category': _character.toString(),
                              },
                            ),
                          ),
                        );
                      }
                    },
                    Colors.white,
                    Colors.amber.shade800,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TermCond extends StatefulWidget {
  final String title;
  final String lang;
  const TermCond({super.key, required this.title, required this.lang});

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

  Future<String?> translates(String texts) async {
    if (widget.lang == 'punjabi') {
      var translation = await translator.translate(texts, from: 'en', to: 'pa');
      return translation.source;
      // return Text(translation);
    } else {
      return texts;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.indigo.shade800,
        title: Text('${translates("Terms & Conditions")}'),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 15.0,
                vertical: 5.0,
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset('assets/images/icon.png', width: 170),
                  ),
                  CheckboxListTile(
                    // Using CheckboxListTile for better usability
                    title: const Text("Required Enable Notifications Alerts"),
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
                  CheckboxListTile(
                    // Using CheckboxListTile for better usability
                    title: const Text(
                      "Enable Location & for Selfi Camra Gallery access",
                    ),
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
                  CheckboxListTile(
                    // Using CheckboxListTile for better usability
                    title: const Text(
                      "After Booked Services any time canceled charges apply",
                    ),
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
                  CheckboxListTile(
                    // Using CheckboxListTile for better usability
                    title: const Text("Our Fixed Rate List for any Services"),
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
                      Text('Next >>', style: TextStyle(fontSize: 17)),
                      () {},
                      Colors.white,
                      Colors.indigo.shade800,
                    ),
                ],
              ),
            ),
            ClipRRect(
              // borderRadius: BorderRadius.circular(75),
              child: Image.asset(
                'assets/images/rounded2.png',
                fit: BoxFit.cover,
                width: MediaQuery.of(context).size.width,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
