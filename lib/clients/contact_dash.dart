import 'dart:async';
import 'dart:convert' as convert;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:fixsathi/classPack/mysearch_delegate.dart';
import 'package:fixsathi/classPack/sessions_file.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:translator/translator.dart';
// ignore: depend_on_referenced_packages
import 'package:url_launcher/url_launcher.dart';

class ContactDashboard extends StatefulWidget {
  const ContactDashboard({super.key});

  @override
  State<ContactDashboard> createState() => _ContactDashboardState();
}

class _ContactDashboardState extends State<ContactDashboard> {
  // File? _selectedFile;
  final translator = GoogleTranslator();
  String? serviceValue, userLang, appids;
  Timer? _timer;

  Map<String, dynamic> userData = {
    'userid': 'no',
    'mobileno': 'no',
    'language': 'no',
    'client_name': 'no',
    'contact2': 'no',
    'district': 'no',
    'city': 'no',
    'address': 'no',
    'appid': 'no',
    'category': 'no',
    'user_img': 'no',
  };
  List<dynamic> getcate = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getSessions();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      translate();
    });
    getCategories('');
    Future.delayed(const Duration(milliseconds: 700), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  Future<void> _getSessions() async {
    try {
      var sharedPreferences = await SessionUrl().getUserdata();
      Map<String, dynamic> usersAll = convert.jsonDecode(sharedPreferences!);
      if (usersAll.isNotEmpty) {
        if (!mounted) return;
        setState(() {
          userLang = usersAll['language'];
          userData = usersAll;
        });
      } else {
        debugPrint('not print');
      }
    } catch (e) {
      // ignore: avoid_print
      debugPrint('$e');
    }
  }

  List getlangs = ['Search by keywords or Service', 'Contact Us'];
  void translate() async {
    try {
      var sharedPreferences = await SessionUrl().getUserdata();
      Map<String, dynamic> usersAll = convert.jsonDecode(sharedPreferences!);
      List languages = ['Search by keywords or Service', 'Contact Us'];
      if (usersAll['language'].toString() == 'punjabi') {
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
            getlangs = getlangs;
          });
        }
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<void> makeCall(String number) async {
    // Number bina kisi space ya special character ke hona chahiye
    final Uri telUri = Uri(scheme: 'tel', path: number);

    if (await canLaunchUrl(telUri)) {
      await launchUrl(telUri);
    } else {
      debugPrint("Call fail ho gayi ya device support nahi karta");
    }
  }

  Future<void> getCategories(String abc) async {
    try {
      var url = Uri.https(
        SessionUrl().baseUrl,
        '/home/searchCategories/passkeysatnam9041110310/$abc',
        {'q': '{http}'},
      );
      var response = await http.get(url);
      if (!mounted) return;
      if (response.statusCode == 200) {
        // List<String> items = [];
        final getlist = convert.jsonDecode(response.body);
        setState(() {
          getcate = getlist['data'];
        });
      }
    } catch (e) {
      // debugPrint(e.toString());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(
            child: Lottie.asset(
              'assets/jsons/loading.json',
              fit: BoxFit.contain,
              height: 100.0,
              width: 100.0,
            ),
          )
        : Scaffold(
            appBar: AppBar(
              backgroundColor: const Color.fromARGB(255, 238, 245, 250),
              foregroundColor: const Color.fromARGB(136, 17, 16, 16),
              titleSpacing: 1.0,
              title: Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 10.0,
                ),
                margin: const EdgeInsets.only(left: 15.0),
                decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.black45),
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: InkWell(
                  onTap: () {
                    if (userData['category'] == 'customer') {
                      showSearch(
                        context: context,
                        delegate: MySearchDelegate(getcate, userData),
                      );
                    }
                  },
                  child: AutoSizeText(
                    getlangs[0].toString(),
                    maxLines: 1,
                    minFontSize: 14,
                    maxFontSize: 16,
                  ),
                ),
              ),
              actions: [
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 7.0, vertical: 4.0),
                  child: IconButton(
                    onPressed: () {
                      if (userData['category'] == 'customer') {
                        showSearch(
                          context: context,
                          delegate: MySearchDelegate(getcate, userData),
                        );
                      }
                    },
                    icon: Icon(Icons.search, size: 28.0),
                  ),
                ),
              ],
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                        top: 10.0,
                        left: 15.0,
                        right: 15.0,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadiusGeometry.circular(10.0),
                        child: Image.asset(
                          (userData['language'] == 'english')
                              ? 'assets/images/pic-eng.jpeg'
                              : 'assets/images/pic-pun.jpeg',
                          fit: BoxFit.fitHeight,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(
                        vertical: 7.0,
                        horizontal: 10.0,
                      ),
                      child: Card(
                        color: Colors.white,
                        child: ListTile(
                          onTap: () => makeCall('+919803652267'),
                          title: Text(
                            getlangs[1].toString(),
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                          trailing: Icon(Icons.phone, size: 30.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
