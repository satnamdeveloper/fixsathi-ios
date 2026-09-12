// import 'dart:io';
import 'dart:async';
import 'dart:convert' as convert;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fixsathi/classPack/sessions_file.dart';
import 'package:fixsathi/clients/add_cart.dart';
import 'package:fixsathi/clients/dashboard_user.dart';
import 'package:fixsathi/clients/order_list.dart';
import 'package:fixsathi/clients/profile_edit.dart';
import 'package:fixsathi/clients/review.dart';
import 'package:fixsathi/clients/wallet.dart';
import 'package:fixsathi/frontScreen/language_terms.dart';
import 'package:fixsathi/frontScreen/login_number.dart';
import 'package:fixsathi/widgets/component.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:translator/translator.dart';
// ignore: depend_on_referenced_packages
import 'package:url_launcher/url_launcher.dart';

class ProfileDashboard extends StatefulWidget {
  const ProfileDashboard({super.key});

  @override
  State<ProfileDashboard> createState() => _ProfileDashboardState();
}

class _ProfileDashboardState extends State<ProfileDashboard> {
  final translator = GoogleTranslator();
  Timer? _timer;
  Map<String, dynamic> userData = {
    'language': 'not',
    'service': 'not',
    'category': 'not',
  };
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await _getSessions();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      translate();
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    });
  }

  Future<void> _getSessions() async {
    try {
      var sharedPreferences = await SessionUrl().getUserdata();
      if (sharedPreferences == null) return;
      if (!mounted) return;
      Map<String, dynamic> usersAll = convert.jsonDecode(sharedPreferences!);
      if (usersAll.isNotEmpty) {
        setState(() {
          userData = usersAll;
        });
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  late List<String> getlangs = [
    'Help Centre',
    'Change Language',
    'Profile - Information',
    'Order List',
    'Service History',
    'Booked List',
    'My Rating',
    'Cart List',
    'Punjabi',
    'Close',
    'Log Out',
    userData['client_name']?.toString().toUpperCase() ?? '',
    userData['category']?.toString() ?? '',
    'If do you logout then will again fill OTP for login',
    (userData['category'] != 'customer') ? '(${userData['service']})' : '',
    'My Wallet',
    'Terms & Condition',
  ];
  void translate() async {
    try {
      var sharedPreferences = await SessionUrl().getUserdata();
      if (sharedPreferences == null) return;
      Map<String, dynamic> usersAll = convert.jsonDecode(sharedPreferences!);
      List<String> languages = [
        'Help Centre',
        'Change Language',
        'Profile - Information',
        'Order List',
        'Service History',
        'Booked List',
        'My Rating',
        'Cart List',
        'Punjabi',
        'Close',
        'Log Out',
        userData['client_name']?.toString().toUpperCase() ?? '',
        userData['category']?.toString() ?? '',
        'If do you logout then will again fill OTP for login',
        (usersAll['category'] != 'customer')
            ? (usersAll['service']?.toString() ?? '')
            : '',
        'My Wallet',
        'Terms & Condition',
      ];
      if (usersAll['language'] == 'punjabi') {
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
            // ignore: avoid_print
            print("Skipping translation for '$item' due to error.");
            return item;
          }
        }).toList();

        // 2. Wait for all of them to complete in parallel
        List<dynamic> results = await Future.wait(futures);
        // for (var translation in results) {
        //   print(translation.text); // 'pa' translation
        // }
        if (!mounted) return;
        setState(() {
          getlangs = results.cast<String>();
        });
      } else {
        if (!mounted) return;
        setState(() {
          getlangs = languages;
        });
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  int? _selectedLang;
  Future<void> makeCall(String number) async {
    // Number bina kisi space ya special character ke hona chahiye
    final Uri telUri = Uri(scheme: 'tel', path: number);

    if (await canLaunchUrl(telUri)) {
      await launchUrl(telUri);
    } else {
      debugPrint("Call fail ho gayi ya device support nahi karta");
    }
  }

  // ignore: strict_top_level_inference
  Future<void> postLanguage(langs) async {
    try {
      // var headers = {'Authorization': 'Bearer pass_key_satnam@malhotra12345678'};
      final uri = Uri.parse("${SessionUrl().httpUrl}/home/changeLanguage");
      final request = http.MultipartRequest('POST', uri);
      request.fields.addAll({
        'mobileno': userData['mobileno'].toString(),
        'language': (langs == 1) ? 'english' : 'punjabi',
      });
      http.StreamedResponse response = await request.send();
      if (!mounted) return;
      if (response.statusCode == 200) {
        var getres = convert.jsonDecode(await response.stream.bytesToString());
        if (getres['status'] == 'success') {
          SessionUrl().removeUserData();
          Map<String, dynamic>? userall = {
            'userid': getres['data']['id'].toString(),
            'mobileno': getres['data']['contactno'].toString(),
            'language': getres['data']['language'].toString(),
            'category': getres['data']['category'].toString(),
            'client_name': getres['data']['firstname'].toString(),
            'user_img': getres['data']['user_img'].toString(),
            'address': getres['data']['address'].toString(),
            'city': getres['data']['city'].toString(),
            'pincode': getres['data']['pincode'].toString(),
            'states': getres['data']['state'].toString(),
            'service': getres['data']['services'].toString(),
            'gender': getres['data']['gender'].toString(),
            'is_active': getres['data']['is_active'].toString(),
          };
          var userstring = convert.jsonEncode(userall);
          SessionUrl().setUsername(userstring);
          // ignore: use_build_context_synchronously
          Components().alertPopUp(context);
          Future.delayed(const Duration(seconds: 2), () {
            if (!mounted) return;
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => MainDashboard()),
              (Route<dynamic> route) => false,
            );
          });
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Required all input fields !'),
              backgroundColor: Color.fromARGB(255, 243, 25, 25),
            ),
          );
        }
        // setState(() {
        //   getress = getres;
        // });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Required all input fields !'),
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (userData['language'] == 'english') {
      _selectedLang = 1;
    } else {
      _selectedLang = 2;
    }

    return Scaffold(
      backgroundColor: Colors.white,

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
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 5.0),
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7.0,
                      ),
                      child: ListTile(
                        leading: SizedBox(
                          height: 70.0,
                          width: 62.0,
                          child: ClipRRect(
                            borderRadius: BorderRadiusGeometry.circular(50),
                            child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              imageUrl:
                                  SessionUrl().imgProfile +
                                  userData['user_img'].toString(),
                              placeholder: (context, url) =>
                                  CircularProgressIndicator(
                                    color: Color.fromARGB(255, 2, 36, 171),
                                  ),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.image, size: 32),
                            ),
                          ),
                        ),
                        title: AutoSizeText(
                          (userData['client_name'] != 'null')
                              ? getlangs[11].toString()
                              : '+91 ${userData['mobileno']}',
                          style: TextStyle(
                            fontSize: 17.0,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                        ),
                        subtitle: Text(
                          '${getlangs[12]} ${getlangs[14]}',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.black87,
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (BuildContext context) => EditClient(
                                title: 'Edit Profile',
                                users: {
                                  'users': userData['mobileno'].toString(),
                                  'category': userData['category'].toString(),
                                  'language': userData['language'].toString(),
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7.0,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 5.0),
                              height: 100.0,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.blue.shade800,
                                  width: 2.0,
                                ),
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: InkWell(
                                onTap: () => makeCall('+919803652267'),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.phone,
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.bold,
                                      size: 30.0,
                                    ),
                                    SizedBox(height: 7.0),
                                    Text(getlangs[0].toString()),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    ),
                                  ),
                                  builder: (context) {
                                    return Container(
                                      color: Colors.white,
                                      height: 300,
                                      child: RadioGroup<int>(
                                        groupValue: _selectedLang,
                                        onChanged: (int? value) {
                                          setState(() {
                                            _selectedLang = value;
                                          });
                                          postLanguage(_selectedLang);
                                        },
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding:
                                                  EdgeInsetsGeometry.symmetric(
                                                    vertical: 15.0,
                                                  ),
                                              child: Text(
                                                getlangs[1].toString(),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 18.0,
                                                ),
                                              ),
                                            ),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal: 20.0,
                                                          vertical: 10.0,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: Colors.black54,
                                                      ),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Radio<int>(value: 1),
                                                        Text('English'),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal: 20.0,
                                                          vertical: 10.0,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: Colors.black54,
                                                      ),
                                                    ),
                                                    child: Row(
                                                      children: [
                                                        Radio<int>(value: 2),
                                                        Text(
                                                          getlangs[8]
                                                              .toString(),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Container(
                                              margin: EdgeInsets.symmetric(
                                                vertical: 20.0,
                                              ),
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text(
                                                  getlangs[9].toString(),
                                                  style: TextStyle(
                                                    fontSize: 18.0,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 5.0),
                                height: 100.0,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.blue.shade800,
                                    width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.language_outlined,
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                      size: 30.0,
                                    ),
                                    SizedBox(height: 7.0),
                                    Text(getlangs[1].toString()),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 7.0),
                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: 15.0,
                        vertical: 5.0,
                      ),
                      child: Text(
                        getlangs[2].toString(),
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: 15.0,
                        vertical: 5.0,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            width: 1.0,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ),
                      child: ListTile(
                        leading: Icon(
                          Icons.card_travel,
                          color: Colors.teal,
                          fontWeight: FontWeight.bold,
                        ),
                        title: Text(getlangs[16].toString()),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (BuildContext context) => TermCondition(
                                title: getlangs[16].toString(),
                                users: {
                                  'category': userData['category'].toString(),
                                  'phoneno': userData['mobileno'].toString(),
                                  'lang': userData['language'].toString(),
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    if (userData['category'] == 'customer')
                      Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 15.0,
                          vertical: 5.0,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              width: 1.0,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ),
                        child: ListTile(
                          leading: Icon(
                            Icons.card_travel,
                            color: Colors.teal,
                            fontWeight: FontWeight.bold,
                          ),
                          title: Text(getlangs[3].toString()),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (BuildContext context) => OrderList(
                                  title: 'My Order List',
                                  details: {
                                    'phoneno': userData['mobileno'].toString(),
                                    'lang': userData['language'].toString(),
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    if (userData['category'] == 'customer')
                      Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 15.0,
                          vertical: 5.0,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              width: 1.0,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ),
                        child: ListTile(
                          leading: Icon(
                            Icons.card_travel,
                            color: Colors.teal,
                            fontWeight: FontWeight.bold,
                          ),
                          title: Text(getlangs[15].toString()),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (BuildContext context) => WalletList(
                                  title: 'My Wallet',
                                  details: {
                                    'phoneno': userData['mobileno'].toString(),
                                    'lang': userData['language'].toString(),
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    if (userData['category'] == 'shopkeeper' ||
                        userData['category'] == 'workerPartner')
                      Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 15.0,
                          vertical: 5.0,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              width: 1.0,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ),
                        child: ListTile(
                          leading: Icon(
                            Icons.list_alt,
                            color: Colors.deepPurpleAccent,
                            fontWeight: FontWeight.bold,
                          ),
                          title: Text(getlangs[4].toString()),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    ServiceHistory(
                                      title: 'Service List',
                                      details: {
                                        'phoneno': userData['mobileno']
                                            .toString(),
                                        'lang': userData['language'].toString(),
                                      },
                                    ),
                              ),
                            );
                          },
                        ),
                      ),
                    // Container(
                    //   margin: EdgeInsets.symmetric(
                    //     horizontal: 15.0,
                    //     vertical: 5.0,
                    //   ),
                    //   decoration: BoxDecoration(
                    //     border: Border(
                    //       bottom: BorderSide(width: 1.0, color: Colors.black45),
                    //     ),
                    //   ),
                    //   child: ListTile(
                    //     leading: Icon(
                    //       Icons.done_outline,
                    //       color: Colors.indigoAccent,
                    //       fontWeight: FontWeight.bold,
                    //     ),
                    //     title: Text(getlangs[5].toString()),
                    //     onTap: () {
                    //       Navigator.of(context).push(
                    //         MaterialPageRoute(
                    //           builder: (BuildContext context) => BookedList(
                    //             title: 'Booked List',
                    //             details: {
                    //               'phoneno': userData['mobileno'].toString(),
                    //               'lang': userData['language'].toString(),
                    //             },
                    //           ),
                    //         ),
                    //       );
                    //     },
                    //   ),
                    // ),
                    if (userData['category'] == 'customer')
                      Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 15.0,
                          vertical: 5.0,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              width: 1.0,
                              color: Colors.blue.shade800,
                            ),
                          ),
                        ),
                        child: ListTile(
                          leading: Icon(
                            Icons.star,
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                          title: Text(getlangs[6].toString()),
                          onTap: () {
                            if ((userData['category'].toString() != 'null') ||
                                (userData['category'] != null) ||
                                (userData['category'].toString() != 'not')) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      ReviewList(title: 'Review Rating'),
                                ),
                              );
                            } else {
                              // ignore: use_build_context_synchronously
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'First Update your registration then working fine?',
                                  ),
                                  backgroundColor: Color.fromARGB(
                                    255,
                                    243,
                                    25,
                                    25,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: 15.0,
                        vertical: 5.0,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            width: 1.0,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ),
                      child: ListTile(
                        leading: Icon(
                          Icons.shopify,
                          color: Colors.blueAccent,
                          size: 28,
                          fontWeight: FontWeight.bold,
                        ),
                        title: Text(getlangs[7].toString()),
                        onTap: () {
                          if ((userData['category'].toString() != 'null') ||
                              (userData['category'].toString() != 'not')) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (BuildContext context) => CartList(
                                  title: 'Cart List',
                                  details: {
                                    'phoneno': userData['mobileno'].toString(),
                                    'lang': userData['language'].toString(),
                                    'category': userData['category'].toString(),
                                    'username': userData['client_name']
                                        .toString(),
                                    'subcate': userData['service'].toString(),
                                  },
                                ),
                              ),
                            );
                          } else {
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'First Update your registration then working fine?',
                                ),
                                backgroundColor: Color.fromARGB(
                                  255,
                                  243,
                                  25,
                                  25,
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: 15.0,
                        vertical: 5.0,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            width: 1,
                            color: Colors.blue.shade800,
                          ),
                        ),
                      ),
                      child: ListTile(
                        leading: Icon(
                          Icons.logout_sharp,
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                        title: Text(getlangs[10].toString()),
                        onTap: () {
                          _logout(context);
                        },
                      ),
                    ),
                    SizedBox(height: 30.0),
                  ],
                ),
              ),
      ),
    );
  }

  Future<bool> _logout(BuildContext context) async {
    bool? exitApp = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('LogOut!'),
          content: FittedBox(
            child: Text(
              'Are you sure logout After then again fill OTP for login.',
              maxLines: 2,
              textAlign: TextAlign.center,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                SessionUrl().removeSession();
                SessionUrl().removeUserData();
                SessionUrl().removeUserAcc();
                Navigator.of(context).pop(true);
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (BuildContext context) =>
                        SelectMobile(title: 'Login'),
                  ),
                );
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
    return exitApp ?? false;
  }
}
