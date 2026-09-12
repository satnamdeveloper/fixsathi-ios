import 'dart:async';
import 'dart:convert' as convert;

import 'package:fixsathi/classPack/notification_service.dart';
import 'package:fixsathi/classPack/sessions_file.dart';
import 'package:fixsathi/clients/contact_dash.dart';
import 'package:fixsathi/clients/home_dash.dart';
import 'package:fixsathi/clients/notification_dash.dart';
import 'package:fixsathi/clients/profile_dash.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:translator/translator.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  double? lat, lng;
  final NotificationService _notificationService = NotificationService();
  final ValueNotifier<List<dynamic>> _itemsList1 = ValueNotifier<List<dynamic>>(
    [],
  );
  // File? _selectedFile;
  final translator = GoogleTranslator();
  String? userLang, appids;
  Map<String, dynamic>? getupdate;
  Map<String, dynamic> userData = {
    'userid': 'no',
    'mobileno': 'no',
    'language': 'no',
    'client_name': 'no',
    'contact2': 'no',
    'pincode': 'no',
    'city': 'no',
    'address': 'no',
    'appid': 'no',
    'category': 'not',
  };
  String userCate = 'not';
  Timer? _timer;
  int _selectedIndex = 0;
  // ignore: prefer_final_fields
  List<int> _navigationHistory = [0];

  @override
  void initState() {
    super.initState();
    _notificationService.requestNotificationPermission();
    updateAppid();
    _initDashboard();
    _timer = Timer.periodic(Duration(seconds: 25), (timer) async {
      if (!mounted) return;
      _notification();
    });
  }

  Future<void> _initDashboard() async {
    await _getSessions(); // Session ka wait karein
    _notificationService.getDeviceToken().then((onValue) {
      if (!mounted) return;
      setState(() {
        appids = onValue;
      });
    });
    _notification();
    translate();
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      updateAppid();
    });
  }

  Future<void> _notification() async {
    if (userData['mobileno'] == 'no') return;
    try {
      final url = Uri.https(
        SessionUrl().baseUrl,
        '/home/myNotification/passkeysatnam9041110310/${userData['mobileno']}/${userData['pincode']}/${userData['service']}',
        // {'q': '{http}'},
      );

      var response = await http.get(url);
      if (!mounted) return;
      if (response.statusCode == 200) {
        final getdata = convert.jsonDecode(response.body);

        // Hamesha check karein ki 'data' null toh nahi hai aur woh List hai ya nahi
        if (getdata['data'] != null && getdata['data'] is List) {
          _itemsList1.value = getdata['data'] as List;
        } else {
          _itemsList1.value = []; // Agar data key khali ho
        }
      } else {
        debugPrint('Bad error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('notification error: $e');
    }
  }

  Future<void> updateAppid() async {
    if (userData['mobileno'] == 'no' || appids == null) return;
    try {
      var url = Uri.https(SessionUrl().baseUrl, 'home/updateApp');
      var response = await http.post(
        url,
        body: {
          'mobileno': userData['mobileno'],
          'appid': appids,
          'keyset': 'pass_key@satnam9041110310',
        },
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        final getres = convert.jsonDecode(response.body);
        return getres;
      }
    } catch (e) {
      debugPrint('Update token error: $e');
    }
  }

  List getlangs = ['Home', 'Notifications', 'Contact Us', 'Profile'];
  void translate() async {
    try {
      List languages = ['Home', 'Notifications', 'Contact Us', 'Profile'];
      if (userLang.toString() == 'punjabi') {
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
          getlangs = getlangs;
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _getSessions() async {
    try {
      var sharedPreferences = await SessionUrl().getUserdata();
      if (sharedPreferences == null) return;
      if (!mounted) return;
      Map<String, dynamic> usersAll = convert.jsonDecode(sharedPreferences!);
      if (usersAll.isNotEmpty) {
        setState(() {
          userLang = usersAll['language'];
          userCate = usersAll['category'];
          userData = usersAll;
        });
      } else {
        debugPrint('not print');
      }
    } catch (e) {
      debugPrint('$e');
    }
  }

  @override
  void dispose() {
    _itemsList1.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;

      // ⭐ Rule 2: Agar yeh tab history me pehle se kahin hai, toh purani entry delete karo
      _navigationHistory.remove(index);

      // Naya tab hamesha list ke aakhiri (latest) me add hoga
      _navigationHistory.add(index);
    });
  }

  final List<Widget> _screens = [
    HomeDashboard(),
    NotificationDashboard(),
    ContactDashboard(),
    ProfileDashboard(),
  ];

  @override
  Widget build(BuildContext context) {
    _notificationService.init(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        // Agar history me sirf 1 hi tab bacha hai (yani user Home par hai)
        if (_selectedIndex == 0 || _navigationHistory.length <= 1) {
          // Android me app ko background me bhejne ya exit karne ka sabse safe tarika
          await SystemNavigator.pop();
        } else {
          // Pichle tab par wapas bhejein
          setState(() {
            if (_navigationHistory.isNotEmpty) {
              _navigationHistory.removeLast(); // Current tab ko hatayein
            }

            // 3. Agar ab history me items hain, toh pichle tab par jayein, nahi toh Home (0) par set karein
            _selectedIndex = _navigationHistory.isNotEmpty
                ? _navigationHistory.last
                : 0;
            // _navigationHistory.removeLast();
            // _selectedIndex =
            //     _navigationHistory.last;
          });
        }
      },
      child: Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: const Color.fromARGB(255, 231, 242, 254),
          elevation: 0.7,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color.fromARGB(255, 31, 32, 32),
          unselectedItemColor: Colors.grey,
          unselectedLabelStyle: const TextStyle(
            color: Color.fromARGB(255, 89, 88, 88),
            fontWeight: FontWeight.normal,
          ),
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: [
            BottomNavigationBarItem(
              activeIcon: Icon(Icons.home, size: 32.0, color: Colors.blueGrey),
              icon: Icon(Icons.home_outlined, size: 32.0),
              label: getlangs[0].toString(),
            ),
            BottomNavigationBarItem(
              activeIcon: Icon(Icons.notifications, size: 32.0),
              icon: Badge(
                // ignore: sort_child_properties_last
                child: Icon(Icons.notifications_none_outlined, size: 32.0),
                label: ValueListenableBuilder(
                  valueListenable: _itemsList1,
                  builder: (context, items, _) {
                    return Text('${_itemsList1.value.length}');
                  },
                ),
              ),
              label: getlangs[1].toString(),
            ),
            BottomNavigationBarItem(
              activeIcon: Icon(Icons.phone, size: 32.0),
              icon: Icon(Icons.phone, size: 32.0),
              label: getlangs[2].toString(),
            ),
            BottomNavigationBarItem(
              activeIcon: Icon(Icons.person, size: 32.0),
              icon: Icon(Icons.person_outline, size: 32.0),
              label: getlangs[3].toString(),
            ),
          ],
        ),
      ),
    );
  }
}
