import 'dart:async';
import 'dart:convert' as convert;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fixsathi/classPack/notification_service.dart';
import 'package:fixsathi/classPack/sessions_file.dart';
import 'package:fixsathi/clients/dashboard_user.dart';
import 'package:fixsathi/clients/review.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:lottie/lottie.dart';
import 'package:translator/translator.dart';

class NotificationDashboard extends StatefulWidget {
  const NotificationDashboard({super.key});

  @override
  State<NotificationDashboard> createState() => _NotificationDashboardState();
}

class _NotificationDashboardState extends State<NotificationDashboard> {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  final NotificationService _notificationService = NotificationService();

  final StreamController<List<dynamic>> _streamController =
      StreamController.broadcast();
  // File? _selectedFile;
  final translator = GoogleTranslator();
  Location location = Location();
  String? userLang;
  List cartlist = [];
  Timer? _timer;
  Map<String, dynamic> userData = {
    'userid': 'no',
    'mobileno': 'no',
    'language': 'no',
    'client_name': 'name',
    'contact2': 'no',
    'district': 'no',
    'pincode': 'no',
    'address': 'no',
    'appid': 'no',
    'category': 'not',
  };
  List<dynamic> notifys = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _notificationService.requestNotificationPermission();
    _initStart();

    _timer = Timer.periodic(const Duration(seconds: 20), (timer) {
      if (!mounted) return;
      mynotify();
    });
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      mynotify();
    });
  }

  Future<void> _initStart() async {
    await _getSessions();
    Future.delayed(const Duration(milliseconds: 150), () {
      if (!mounted) return;
      translate();
    });
    mynotify();
  }

  Future<void> _getSessions() async {
    try {
      final sharedPreferences = await SessionUrl().getUserdata();
      if (sharedPreferences == null) return;
      if (!mounted) return;
      Map<String, dynamic> usersAll = convert.jsonDecode(sharedPreferences!);
      if (usersAll.isNotEmpty) {
        setState(() {
          userLang = usersAll['language'];
          userData = usersAll;
        });
      } else {
        debugPrint('not print');
      }
    } catch (e) {
      debugPrint('$e');
    }
  }

  late List getlangs = ['Notification'];
  void translate() async {
    try {
      List languages = ['Notification'];
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
      debugPrint('$e');
    }
  }

  Future<void> mynotify() async {
    try {
      final response = await http.get(
        Uri.parse(
          "${SessionUrl().httpUrl}/home/myNotification/passkeysatnam9041110310/${userData['mobileno']}/${userData['pincode']}/${userData['service']}",
        ),
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        final getdata = await compute(convert.jsonDecode, response.body);
        if (getdata['status'] == 'success') {
          // Case A: Agar data direct List '[' se shuru ho raha hai
          if ((getdata['data'] != null) && (getdata['data'] is List)) {
            _streamController.add(getdata['data']);
          } else {
            _streamController.addError('Server Error:');
          }
        } else {
          _streamController.addError('Server Error: ${response.statusCode}');
        }
      } else {
        _streamController.addError('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      _streamController.addError('Network Error: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _streamController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _notificationService.init(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white70,
        title: Text(
          getlangs[0].toString(),
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: SafeArea(
        child: _isLoading
            ? Center(
                child: Lottie.asset(
                  'assets/jsons/loading.json',
                  fit: BoxFit.contain,
                  height: 100.0,
                  width: 100.0,
                ),
              )
            : Container(
                margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                height: MediaQuery.of(context).size.height - 150,
                child: StreamBuilder<List<dynamic>>(
                  stream: _streamController.stream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Lottie.asset(
                          'assets/jsons/search-area.json',
                          fit: BoxFit.cover,
                          width: 200,
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Lottie.asset(
                          'assets/jsons/search-area.json',
                          fit: BoxFit.cover,
                          width: 200,
                        ),
                      );
                    }
                    final list = snapshot.data!;
                    // print(list);
                    return ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        var item = list[index];
                        return Card(
                          elevation: 1.0,
                          color: (item['seen'] == '0')
                              ? Colors.orange[200]
                              : Colors.green[100],
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadiusGeometry.circular(50),
                              child: CachedNetworkImage(
                                width: 60,
                                height: 60,
                                imageUrl: item['photo'].toString(),
                                placeholder: (context, url) =>
                                    CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              ),
                            ),
                            title: AutoSizeText(
                              item['cname'].toString(),
                              maxLines: 1,
                              minFontSize: 13,
                              maxFontSize: 15,
                            ),
                            subtitle: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AutoSizeText(
                                  'Mb:${item['contact1']}',
                                  maxLines: 1,
                                  minFontSize: 10,
                                  maxFontSize: 13,
                                ),
                                AutoSizeText(
                                  'Service: ${item['sub_cate']}',
                                  maxLines: 1,
                                  minFontSize: 10,
                                  maxFontSize: 13,
                                ),
                              ],
                            ),
                            trailing: Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      CheckNotification(
                                        title: 'Check Notification',
                                        notityData: list[index],
                                      ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
      ),
    );
  }
}

// ignore: must_be_immutable
class CheckNotification extends StatefulWidget {
  String? title;
  Map<String, dynamic> notityData = {};
  CheckNotification({super.key, required this.title, required this.notityData});

  @override
  State<CheckNotification> createState() => _CheckNotificationState();
}

class _CheckNotificationState extends State<CheckNotification> {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  final NotificationService _notificationService = NotificationService();
  final ValueNotifier<List<dynamic>> _itemsList = ValueNotifier<List<dynamic>>(
    [],
  );
  final translator = GoogleTranslator();
  Location location = Location();
  String? userLang, appids;
  Timer? _timer;
  bool _isLoading = true;

  Map<String, dynamic> userData = {
    'userid': 'no',
    'mobileno': 'no',
    'language': 'no',
    'client_name': 'name',
    'contact2': 'no',
    'city': 'no',
    'pincode': 'no',
    'address': 'no',
    'appid': 'no',
    'category': 'not',
  };

  @override
  void initState() {
    super.initState();
    _notificationService.requestNotificationPermission();

    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      translate();
    });
    _getSessions();
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    });
  }

  Future<void> _getSessions() async {
    try {
      final sharedPreferences = await SessionUrl().getUserdata();
      if (sharedPreferences == null) return;
      if (!mounted) return;
      final Map<String, dynamic> usersAll = convert.jsonDecode(
        sharedPreferences!,
      );
      if (usersAll.isNotEmpty) {
        setState(() {
          userLang = usersAll['language'];
          userData = usersAll;
        });
      } else {
        debugPrint('not print');
      }
    } catch (e) {
      debugPrint('$e');
    }
  }

  late List<String> getlangs = [
    'SERVICE: ${widget.notityData['sub_cate'].toString().toUpperCase()}',
    'Name: ${(widget.notityData['cname'] == 'Pending') ? '' : widget.notityData['cname'].toString().toUpperCase()}',
    'Address: ${(widget.notityData['address'] == 'noAddress') ? '' : widget.notityData['address'].toString()}',
    'City: ${(widget.notityData['city'] == 'noCity') ? '' : widget.notityData['city'] ?? 'empty'}',
    'Status: ${widget.notityData['status']}',
    'Contact No: 9803652267',
    'Schdule: ${widget.notityData['schdule_status']}',
    'Schdule Date: ${widget.notityData['dated']}',
    'Schdule Time: ${widget.notityData['times']}',
    'Check Notification',
    'Submited',
    'Our worker will be reach you within 30 minutes.',
  ];
  void translate() async {
    try {
      // print(widget.notityData);
      List<String> languages = [
        'SERVICE: ${widget.notityData['sub_cate'].toString().toUpperCase()}',
        'Name: ${(widget.notityData['cname'] == 'Pending') ? '' : widget.notityData['cname'].toString().toUpperCase()}',
        'Address: ${(widget.notityData['address'] == 'noAddress') ? '' : widget.notityData['address'].toString()}',
        'City: ${(widget.notityData['city'] == 'noCity') ? '' : widget.notityData['city'] ?? 'empty'}',
        'Status: ${widget.notityData['status']}',
        'Contact No: 9803652267',
        'Schdule: ${widget.notityData['schdule_status']}',
        'Schdule Date: ${widget.notityData['dated']}',
        'Schdule Time: ${widget.notityData['times']}',
        'Check Notification',
        'Submited',
        'Our worker will be reach you within 30 minutes.',
      ];
      if (userLang.toString() == 'punjabi') {
        var futures = languages.map((item) async {
          if (item.trim().isEmpty) return item;

          try {
            var translation = await translator.translate(
              item,
              from: 'en',
              to: 'pa',
            );
            return translation.text; // सिर्फ़ टेक्स्ट रिटर्न करें
          } catch (innerError) {
            debugPrint("Skipping translation for '$item' due to error.");
            return item;
          }
        }).toList();

        List<dynamic> results = await Future.wait(futures);
        _itemsList.value = results.cast<String>();
      } else {
        _itemsList.value = getlangs;
      }
    } catch (e) {
      debugPrint('$e');
    }
  }

  Future<void> postPartnerBid() async {
    try {
      final url = Uri.https(
        SessionUrl().baseUrl,
        'notification/postPartnerOrder',
      );
      final response = await http.post(
        url,
        body: {
          'mobileno': userData['mobileno'].toString(),
          'orderid': widget.notityData['id'].toString(),
          'keyset': 'pass_key@satnam9041110310',
        },
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        final getres = convert.jsonDecode(response.body);
        if (getres['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Congrats! Success get work.'),
              backgroundColor: Color.fromARGB(255, 3, 128, 11),
            ),
          );
          Future.delayed(const Duration(milliseconds: 1000));
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (BuildContext context) => const MainDashboard(),
            ),
          );
        } else if (getres['status'] == 'error') {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Service Already accepted'),
              backgroundColor: Color.fromARGB(255, 244, 19, 19),
            ),
          );
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Service Already accepted'),
              backgroundColor: Color.fromARGB(255, 244, 19, 19),
            ),
          );
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Some errors from server side'),
            backgroundColor: Color.fromARGB(255, 243, 25, 25),
          ),
        );
      }
    } catch (e) {
      debugPrint('error $e');
    }
  }

  Future<void> completeTask() async {
    try {
      final url = Uri.https(
        SessionUrl().baseUrl,
        'notification/postCompleteTask',
      );
      final response = await http.post(
        url,
        body: {
          'mobileno': userData['mobileno'].toString(),
          'orderid': widget.notityData['id'].toString(),
          'keyset': 'pass_key@satnam9041110310',
        },
      );

      if (response.statusCode == 200) {
        final getres = convert.jsonDecode(response.body);
        if (getres['status'] == 'success') {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Successful! Completed task.'),
              backgroundColor: Color.fromARGB(255, 3, 150, 5),
            ),
          );
          Future.delayed(const Duration(milliseconds: 1500));
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (BuildContext context) => const MainDashboard(),
            ),
          );
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: Not get data?'),
              backgroundColor: Color.fromARGB(255, 243, 25, 25),
            ),
          );
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Some errors from server side'),
            backgroundColor: Color.fromARGB(255, 243, 25, 25),
          ),
        );
      }
    } catch (e) {
      debugPrint('error $e');
    }
  }

  Future<void> cancelOrder() async {
    try {
      final url = Uri.https(SessionUrl().baseUrl, 'home/cancelOrder');
      final response = await http.post(
        url,
        body: {
          'mobileno': userData['mobileno'].toString(),
          'orderid': widget.notityData['id'].toString(),
          'keyset': 'pass_key@satnam9041110310',
        },
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        final getres = convert.jsonDecode(response.body);
        if (getres['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Canceled your order!'),
              backgroundColor: Color.fromARGB(255, 3, 150, 5),
            ),
          );
          Future.delayed(const Duration(milliseconds: 1500));
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (BuildContext context) => const MainDashboard(),
            ),
          );
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: Not get data?'),
              backgroundColor: Color.fromARGB(255, 243, 25, 25),
            ),
          );
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Some errors from server side'),
            backgroundColor: Color.fromARGB(255, 243, 25, 25),
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
    _itemsList.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _notificationService.init(context);
    String formattedDate = DateFormat(
      'dd-MM-yyyy – kk:mm',
    ).format(DateTime.parse(widget.notityData['dateTime']));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        title: Text('', style: TextStyle(color: Colors.white)),
      ),

      body: _isLoading
          ? Center(
              child: Lottie.asset(
                'assets/jsons/loading.json',
                fit: BoxFit.contain,
                height: 100.0,
                width: 100.0,
              ),
            )
          : SafeArea(
              child: SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 5.0,
                  ),
                  color: Colors.white,
                  child: ValueListenableBuilder<List<dynamic>>(
                    valueListenable: _itemsList,
                    builder: (context, list, child) {
                      if (list.isNotEmpty) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            DrawerHeader(
                              curve: Curves.easeInToLinear,
                              child: ClipRRect(
                                borderRadius: BorderRadiusGeometry.circular(
                                  10.0,
                                ),
                                child: CachedNetworkImage(
                                  imageUrl: widget.notityData['photo']
                                      .toString(),
                                  width: 150,
                                  height: 150,
                                  placeholder: (context, url) =>
                                      CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                ),
                              ),
                            ),
                            Container(
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Color.fromARGB(
                                      115,
                                      236,
                                      234,
                                      234,
                                    ), // Set your color
                                    width: 1.0, // Set border thickness
                                  ),
                                ),
                              ),
                              height: 45,
                              child: ListTile(
                                title: AutoSizeText(
                                  list[0].toString(),
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  minFontSize: 11,
                                  maxFontSize: 15,
                                ),
                              ),
                            ),
                            if (widget.notityData['status'] != 'completed')
                              Container(
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Color.fromARGB(
                                        115,
                                        236,
                                        234,
                                        234,
                                      ), // Set your color
                                      width: 1.0, // Set border thickness
                                    ),
                                  ),
                                ),
                                height: 45,
                                child: ListTile(
                                  title: AutoSizeText(
                                    list[11].toString(),
                                    style: TextStyle(
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 2,
                                    minFontSize: 11,
                                    maxFontSize: 15,
                                  ),
                                ),
                              ),
                            Container(
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Color.fromARGB(115, 236, 234, 234),
                                    width: 1.0, // Set border thickness
                                  ),
                                ),
                              ),
                              height: 40.0,
                              child: ListTile(
                                title: AutoSizeText(
                                  '${list[10]}: $formattedDate',
                                  maxLines: 1,
                                  minFontSize: 12,
                                  maxFontSize: 15,
                                ),
                              ),
                            ),
                            Container(
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Color.fromARGB(115, 236, 234, 234),
                                    width: 1.0, // Set border thickness
                                  ),
                                ),
                              ),
                              height: 40.0,
                              child: ListTile(
                                title: AutoSizeText(
                                  list[1].toString(),
                                  style: TextStyle(fontWeight: FontWeight.w500),
                                  maxLines: 1,
                                  minFontSize: 12,
                                  maxFontSize: 15,
                                ),
                              ),
                            ),

                            Container(
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Color.fromARGB(115, 236, 234, 234),
                                    width: 1.0, // Set border thickness
                                  ),
                                ),
                              ),
                              child: ListTile(
                                title: AutoSizeText(
                                  list[2].toString(),
                                  maxLines: 2,
                                  minFontSize: 12,
                                  maxFontSize: 14,
                                ),
                              ),
                            ),
                            Container(
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Color.fromARGB(115, 236, 234, 234),
                                    width: 1.0, // Set border thickness
                                  ),
                                ),
                              ),
                              height: 40.0,
                              child: ListTile(
                                title: AutoSizeText(
                                  list[3].toString(),
                                  maxLines: 1,
                                  minFontSize: 12,
                                  maxFontSize: 15,
                                ),
                              ),
                            ),
                            Container(
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Color.fromARGB(115, 236, 234, 234),
                                    width: 1.0, // Set border thickness
                                  ),
                                ),
                              ),
                              height: 40.0,
                              child: ListTile(title: Text(list[5].toString())),
                            ),
                            // ${widget.notityData['contact1']}
                            Container(
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Color.fromARGB(115, 236, 234, 234),
                                    width: 1.0, // Set border thickness
                                  ),
                                ),
                              ),
                              height: 40.0,
                              child: ListTile(
                                title: AutoSizeText(
                                  list[4].toString(),
                                  maxLines: 1,
                                  minFontSize: 12,
                                  maxFontSize: 15,
                                ),
                              ),
                            ),

                            if (widget.notityData['otp'] != 'noOTP')
                              Container(
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Color.fromARGB(115, 236, 234, 234),
                                      width: 1.0, // Set border thickness
                                    ),
                                  ),
                                ),
                                height: 40.0,
                                child: ListTile(
                                  title: Text(
                                    'OTP: ${widget.notityData['otp']}',
                                  ),
                                ),
                              ),
                            if (widget.notityData['schdule_status'] != 'Now')
                              Container(
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Color.fromARGB(115, 236, 234, 234),
                                      width: 1.0, // Set border thickness
                                    ),
                                  ),
                                ),
                                height: 40.0,
                                child: ListTile(
                                  title: AutoSizeText(
                                    list[6].toString(),
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                            if (widget.notityData['schdule_status'] != 'Now')
                              Container(
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Color.fromARGB(115, 236, 234, 234),
                                      width: 1.0, // Set border thickness
                                    ),
                                  ),
                                ),
                                height: 40.0,
                                child: ListTile(
                                  title: AutoSizeText(
                                    list[7].toString(),
                                    maxLines: 1,
                                  ),
                                ),
                              ),
                            SizedBox(height: 10.0),
                            if (widget.notityData['whos'] == 'partner' &&
                                widget.notityData['seen'] == '0')
                              Container(
                                width: MediaQuery.of(context).size.width - 10,
                                margin: EdgeInsets.symmetric(horizontal: 20),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo,
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

                                  onPressed: () async {
                                    postPartnerBid();
                                  },
                                  child: Text('Confirm'),
                                ),
                              ),
                            if ((widget.notityData['whos'] == 'partner') &&
                                ((widget.notityData['seen'] == '1') ||
                                    (widget.notityData['status_work'] ==
                                        'under_process')))
                              Container(
                                width: MediaQuery.of(context).size.width - 10,
                                margin: EdgeInsets.symmetric(horizontal: 20),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo,
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
                                    completeTask();
                                  },
                                  child: Text('Complete Task'),
                                ),
                              ),
                            if ((widget.notityData['whos'] == 'customer') &&
                                ((widget.notityData['seen'] == '2') &&
                                    (widget.notityData['status'] ==
                                        'completed')))
                              Container(
                                width: MediaQuery.of(context).size.width - 10,
                                margin: EdgeInsets.symmetric(horizontal: 20),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo,
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
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            CustomerReview(
                                              title: 'Check Notification',
                                              notityData: widget.notityData,
                                            ),
                                      ),
                                    );
                                  },
                                  child: Text('Submit Review'),
                                ),
                              ),
                            if ((widget.notityData['whos'] == 'customer') &&
                                ((widget.notityData['seen'] == '0') &&
                                    (widget.notityData['status'] ==
                                        'under_process')))
                              Container(
                                width: MediaQuery.of(context).size.width - 10,
                                margin: EdgeInsets.symmetric(horizontal: 20),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.indigo,
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
                                    cancelOrder();
                                  },
                                  child: Text('Cancel'),
                                ),
                              ),
                            SizedBox(height: 70.0),
                          ],
                        );
                      }
                      return Center(
                        child: Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 50.0,
                          ),
                          width: 190.0,
                          child: Lottie.asset(
                            'assets/jsons/cart.json',
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
    );
  }
}
