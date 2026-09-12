import 'dart:async';
import 'dart:convert' as convert;
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fixsathi/classPack/sessions_file.dart';
import 'package:fixsathi/clients/dashboard_user.dart';
import 'package:fixsathi/frontScreen/language_terms.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class SelectMobile extends StatefulWidget {
  const SelectMobile({super.key, required this.title});

  final String title;

  @override
  State<SelectMobile> createState() => _SelectMobileState();
}

class _SelectMobileState extends State<SelectMobile> {
  // Timer? _timer;
  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  String verificationId = '';
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController phoneController = TextEditingController();
  // final NotificationService _notificationService = NotificationService();
  // final FirebaseAuth _auth = FirebaseAuth.instance;
  String? user, appids;
  Map<dynamic, dynamic> userData = {};

  String signature = "{{ app signature }}";
  String? getcode = '91';

  @override
  void initState() {
    super.initState();
    _getSessions();
  }

  Future<void> openWebLink(String urlString) async {
    // 1. String ko Uri object mein convert karein
    final Uri url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('URL open nahi ho saka: $urlString');
    }
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _getSessions() async {
    try {
      var sharedPreferences = await SessionUrl().getUserdata();
      Map<String, dynamic> usersAll = convert.jsonDecode(sharedPreferences!);
      if (usersAll.isNotEmpty) {
        if (mounted) {
          setState(() {
            user = usersAll['category'];
            userData = usersAll;
          });
        }
      } else {
        // debugPrint('not print');
      }
    } catch (e) {
      // debugPrint('$e');
    }
  }

  // Future<void> _subscribeToTopic() async {
  //   await messaging.subscribeToTopic('All');
  // }
  int generateRandomSixDigitNumber() {
    // Define the minimum and maximum values for a 6-digit number
    int min = 100000;
    int max = 999999;
    // Create a Random object
    var randomizer = Random();
    // The nextInt() method is exclusive of the maximum value, so we use (max - min + 1)
    int randomNumber = min + randomizer.nextInt(max - min + 1);
    return randomNumber;
  }

  Future<void> loginOtpNumber() async {
    try {
      String smsCode = generateRandomSixDigitNumber().toString();
      var url = Uri.https(SessionUrl().baseUrl, 'home/loginMobileOTP');
      var response = await http.post(
        url,
        body: {
          'mobileno': phoneController.text,
          'smsCode': smsCode.toString(),
          'hashcode': signature.toString(),
          'keyset': 'pass_key@satnam9041110310',
        },
      );
      if (response.statusCode == 200) {
        // List<String> items = [];
        var getlist = convert.jsonDecode(response.body);

        // print(getlist);
        if (getlist['status'] == 'success') {
          Map<String, dynamic>? userall = {
            'userid': getlist['data']['id'].toString(),
            'mobileno': getlist['data']['contactno'].toString(),
            'language': getlist['data']['language'].toString(),
            'category': getlist['data']['category'].toString(),
            'client_name': getlist['data']['firstname'].toString(),
            'user_img': getlist['data']['user_img'].toString(),
            'state': getlist['data']['state'].toString(),
            'city': getlist['data']['city'].toString(),
            'pincode': getlist['data']['pincode'].toString(),
            'address': getlist['data']['address'].toString(),
            'appid': getlist['data']['appid'].toString(),
            'service': getlist['data']['services'].toString(),
            'gender': getlist['data']['gender'].toString(),
            'is_active': getlist['data']['is_active'].toString(),
          };

          // ignore: use_build_context_synchronously
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) => OTPScreen(
                title: 'Get OTP',
                phoneno: phoneController.text,
                smsotp: smsCode.toString(),
                matchotp: getlist['forotp']['otp'].toString(),
                getcode: getcode.toString(),
                status: 'success',
                mapdata: userall,
              ),
            ),
          );

          // } else if (getlist['status'] == 'error') {
          //   EasyLoading.showToast(
          //     'This user already in runing mode Kindly try again later ',
          //   );
        } else if (getlist['status'] == 'false') {
          // ignore: use_build_context_synchronously
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) => OTPScreen(
                title: 'Get OTP',
                phoneno: phoneController.text,
                smsotp: smsCode.toString(),
                matchotp: getlist['data']['otp'].toString(),
                getcode: getcode.toString(),
                status: 'false',
                mapdata: {},
              ),
            ),
          );
        }

        // print(getlist);
      }
    } catch (e) {
      // debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    // print(getcode.toString());
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
            child: Center(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      height: MediaQuery.of(context).size.height - 400,
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.symmetric(vertical: 15.0),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 5, 37, 126),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(45.0),
                          bottomRight: Radius.circular(45.0),
                        ),
                      ),
                      child: Image.asset(
                        'assets/images/icon.png',
                        width: 100.0,
                      ),
                    ),
                    SizedBox(height: 50.0),
                    SizedBox(
                      width: 290.0,
                      child: SizedBox(
                        width: 180.0,
                        child: TextFormField(
                          controller: phoneController,
                          keyboardType: TextInputType.number,
                          maxLength: 10,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 12.0,
                            ),
                            prefixIcon: Icon(Icons.phone),
                            prefixText: '+91',
                            labelText: "Enter phone number",
                          ),
                          onTap: () async {},
                          validator: (value) {
                            if (value!.length != 10) {
                              return 'Required 10 charectors';
                            }
                            return null;
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Container(
                      margin: EdgeInsets.symmetric(
                        vertical: 2.0,
                        horizontal: 20.0,
                      ),
                      // width: MediaQuery.of(context).size.width - 150,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo.shade900,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 11,
                          ),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(18.0),
                            ),
                          ),
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            loginOtpNumber();
                          }
                        },
                        child: const Text("Send OTP >>"),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        openWebLink(
                          "https://fixsathi.com/home/index/privacy-policy",
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 7.0,
                        ),
                        child: Text(
                          'Privacy - Policy',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
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

// ignore: must_be_immutable
class OTPScreen extends StatefulWidget {
  const OTPScreen({
    super.key,
    required this.title,
    required this.phoneno,
    required this.smsotp,
    required this.matchotp,
    required this.getcode,
    required this.status,
    required this.mapdata,
  });

  final String title, phoneno, smsotp, matchotp, getcode, status;
  final Map<String, dynamic> mapdata;

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

// Android ke liye CodeAutoFill mixin ko barkarar rakha hai
class _OTPScreenState extends State<OTPScreen> {
  Timer? _timer;
  int _start = 50;
  String? appSignature;
  String sscode = '';

  // iOS aur Controller optimization ke liye text controller
  final TextEditingController _otpController = TextEditingController();

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void checkSameNumber() {
    if (widget.status == 'success') {
      var userstring = convert.jsonEncode(widget.mapdata);
      SessionUrl().setUsername(userstring);

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainDashboard()),
        (Route<dynamic> route) => false,
      );
    } else {
      Future.delayed(const Duration(milliseconds: 700));
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext context) => Language(
            title: 'Choose Language',
            phoneno: widget.phoneno.toString(),
          ),
        ),
      );
    }
  }

  void startTimer() {
    _timer?.cancel();
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
      if (_start == 0) {
        timer.cancel();
      } else {
        if (mounted) {
          setState(() {
            _start--;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 10.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 10.0,
                  ),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(
                          vertical: 25.0,
                          horizontal: 10.0,
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 15.0,
                          horizontal: 10.0,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.asset(
                            'assets/images/icon.png',
                            width: 160.0,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.lock,
                                  size: 80,
                                  color: Colors.indigo,
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "A 6 digit OTP has been sent to your phone number +${widget.getcode} ${widget.phoneno}",
                        style: const TextStyle(fontSize: 14.0),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // iOS aur Android universal supportive widget call
                      OtpInputField(
                        controller: _otpController,
                        onCompleted: (code) {
                          sscode = code;
                          if (widget.matchotp == sscode) {
                            checkSameNumber();
                          }
                        },
                      ),

                      const SizedBox(height: 24),
                      Text(
                        "Please wait $_start seconds for OTP..",
                        style: const TextStyle(fontSize: 14.0),
                      ),
                      if (widget.matchotp == 'fake')
                        Padding(
                          padding: const EdgeInsets.only(top: 12.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.indigo,
                              side: const BorderSide(color: Colors.indigo),
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (BuildContext context) => Language(
                                    title: 'Choose Language',
                                    phoneno: widget.phoneno.toString(),
                                  ),
                                ),
                              );
                            },
                            child: const Text("Skip"),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// iOS native Autofill trigger karne wala widget
class OtpInputField extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onCompleted;

  const OtpInputField({
    super.key,
    required this.controller,
    required this.onCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240, // Box width restrict karne ke liye
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 26,
          letterSpacing: 12,
          fontWeight: FontWeight.bold,
          color: Colors.indigo,
        ),
        maxLength: 6,

        // --- CRITICAL FOR iOS AUTOFILL ---
        autofillHints: const [AutofillHints.oneTimeCode],

        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          hintText: '000000',
          hintStyle: TextStyle(color: Colors.grey.shade400, letterSpacing: 12),
          counterText: "", // Bottom character text ko hide karne ke liye
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          filled: true,
          fillColor: Colors.indigo.shade50,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.black45, width: 1.5),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.indigo, width: 2.0),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onChanged: (code) {
          if (code.length == 6) {
            FocusScope.of(context).unfocus(); // Keyboard hide karein
            onCompleted(code); // Callback method execute karein
          }
        },
      ),
    );
  }
}
