import 'dart:async';
import 'dart:convert' as convert;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fixsathi/classPack/sessions_file.dart';
import 'package:fixsathi/clients/dashboard_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:translator/translator.dart';
import 'package:fixsathi/classPack/notification_service.dart';

// ignore: must_be_immutable
class CustomerReview extends StatefulWidget {
  String? title;
  Map<String, dynamic> notityData;
  CustomerReview({super.key, required this.title, required this.notityData});

  @override
  State<CustomerReview> createState() => _CustomerReviewState();
}

class _CustomerReviewState extends State<CustomerReview> {
  final NotificationService _notificationService = NotificationService();
  final translator = GoogleTranslator();
  String? userLang, appids;
  Timer? _timer;
  double rated = 3.0;
  bool _isLoading = true;
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

  final TextEditingController _remarks = TextEditingController();
  String? remarks;
  @override
  void initState() {
    super.initState();

    _getSessions();
    Future.delayed(const Duration(milliseconds: 100), () {
      translate();
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  late List getlangs = [
    'Review regarding your service',
    'Wow Very Good & Fast Servic',
    'Very Nice Service',
    'Not Like Service',
    'Good Service but more improve',
    'Submit',
  ];
  void translate() async {
    try {
      List languages = [
        'Review regarding your service',
        'Wow Very Good & Fast Servic',
        'Very Nice Service',
        'Not Like Service',
        'Good Service but more improve',
        'Submit',
      ];
      if (userLang.toString() == 'punjabi') {
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
    } catch (e) {
      debugPrint('$e');
    }
  }

  Future<void> _getSessions() async {
    try {
      var sharedPreferences = await SessionUrl().getUserdata();
      Map<String, dynamic> usersAll = convert.jsonDecode(sharedPreferences!);
      if (usersAll.isNotEmpty) {
        if (mounted) {
          setState(() {
            userLang = usersAll['language'];
            userData = usersAll;
          });
        }
      } else {
        debugPrint('not print');
      }
    } catch (e) {
      // ignore: avoid_print
      print('$e');
    }
  }

  Future<void> postReviews() async {
    try {
      var url = Uri.https(SessionUrl().baseUrl, 'home/postReviews');
      var response = await http.post(
        url,
        body: {
          'mobileno': userData['mobileno'].toString(),
          'review': rated.toString(),
          'remarks': _remarks.text,
          'ids': widget.notityData['id'],
          'keyset': 'pass_key@satnam9041110310',
        },
      );

      if (response.statusCode == 200) {
        var getres = convert.jsonDecode(response.body);
        if (getres['status'] == 'success') {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Get success data'),
              backgroundColor: Color.fromARGB(255, 8, 142, 4),
            ),
          );
          Future.delayed(const Duration(milliseconds: 1000), () {
            // ignore: use_build_context_synchronously
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (BuildContext context) => const MainDashboard(),
              ),
            );
          });
        } else {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: Not get data?'),
              backgroundColor: Color.fromARGB(255, 205, 6, 6),
            ),
          );
        }
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You have not in Cart List service'),
            backgroundColor: Color.fromARGB(255, 205, 6, 6),
          ),
        );
      }
    } catch (e) {
      // debugPrint('error $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _notificationService.init(context);
    _remarks.value = _remarks.value.copyWith(text: remarks);
    // print(notityData);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white70,
        title: Text('Submit Review', style: TextStyle(color: Colors.white)),
      ),

      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  color: Colors.blue,
                ),
              )
            : SingleChildScrollView(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 5.0,
                  ),
                  color: Colors.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 25),
                        child: RatingBar.builder(
                          initialRating: 3,
                          minRating: 1,
                          direction: Axis.horizontal,
                          allowHalfRating: true,
                          itemCount: 5,
                          itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                          itemBuilder: (context, _) =>
                              Icon(Icons.star, color: Colors.amber),
                          onRatingUpdate: (rating) {
                            setState(() {
                              rated = rating;
                            });
                          },
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        child: TextFormField(
                          maxLines: 2,
                          controller: _remarks,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 10.0,
                              vertical: 10.0,
                            ),
                            labelText: getlangs[0].toString(),
                            fillColor: Colors.white,
                          ),
                          onTap: () async {},
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 1,
                          vertical: 10,
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsetsGeometry.symmetric(
                                      horizontal: 3.0,
                                      vertical: 5.0,
                                    ),
                                    padding: EdgeInsetsGeometry.symmetric(
                                      horizontal: 10.0,
                                      vertical: 7.0,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 1.0,
                                        color: Colors.black45,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          remarks =
                                              'Wow Very Good & Fast Service';
                                        });
                                      },
                                      child: AutoSizeText(
                                        getlangs[1].toString(),
                                        textAlign: TextAlign.center,
                                        minFontSize: 9,
                                        maxFontSize: 11,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsetsGeometry.symmetric(
                                      horizontal: 3.0,
                                      vertical: 5.0,
                                    ),
                                    padding: EdgeInsetsGeometry.symmetric(
                                      horizontal: 10.0,
                                      vertical: 7.0,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 1.0,
                                        color: Colors.black45,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          remarks = 'Very Nice Service';
                                        });
                                      },
                                      child: AutoSizeText(
                                        getlangs[2].toString(),
                                        textAlign: TextAlign.center,
                                        minFontSize: 9,
                                        maxFontSize: 11,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsetsGeometry.symmetric(
                                      horizontal: 3.0,
                                      vertical: 5.0,
                                    ),
                                    padding: EdgeInsetsGeometry.symmetric(
                                      horizontal: 10.0,
                                      vertical: 7.0,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 1.0,
                                        color: Colors.black45,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          remarks = 'Not Like Service';
                                        });
                                      },
                                      child: AutoSizeText(
                                        getlangs[3].toString(),
                                        textAlign: TextAlign.center,
                                        minFontSize: 9,
                                        maxFontSize: 11,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsetsGeometry.symmetric(
                                      horizontal: 1.0,
                                      vertical: 5.0,
                                    ),
                                    padding: EdgeInsetsGeometry.symmetric(
                                      horizontal: 10.0,
                                      vertical: 7.0,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        width: 1.0,
                                        color: Colors.black45,
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          remarks =
                                              'Good Service but more improve';
                                        });
                                      },
                                      child: AutoSizeText(
                                        getlangs[4].toString(),
                                        textAlign: TextAlign.center,
                                        minFontSize: 9,
                                        maxFontSize: 11,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        width: MediaQuery.of(context).size.width - 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo.shade800,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 12,
                            ),
                          ),
                          onPressed: () {
                            // Components().alertPopUp(context);
                            postReviews();
                          },
                          child: Text(getlangs[5].toString()),
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

// ignore: must_be_immutable
class ReviewList extends StatefulWidget {
  String? title;
  ReviewList({super.key, required this.title});

  @override
  State<ReviewList> createState() => _ReviewListState();
}

class _ReviewListState extends State<ReviewList> {
  final NotificationService _notificationService = NotificationService();
  final translator = GoogleTranslator();
  String? userLang, appids;

  Timer? _timer;

  Map<String, dynamic> userData = {
    'userid': 'no',
    'mobileno': 'no',
    'language': 'no',
    'client_name': 'no',
    'contact2': 'no',
    'district': 'no',
    'pincode': 'no',
    'address': 'no',
    'appid': 'no',
    'category': 'not',
  };

  final TextEditingController _remarks = TextEditingController();
  String? remarks;
  @override
  void initState() {
    super.initState();
    _notificationService.requestNotificationPermission();
    _getSessions();
  }

  Future<void> _getSessions() async {
    try {
      var sharedPreferences = await SessionUrl().getUserdata();
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
      // ignore: avoid_print
      print('$e');
    }
  }

  Future<List<dynamic>> reviewlist() async {
    var url = Uri.https(
      SessionUrl().baseUrl,
      '/home/reviewlist/passkeysatnam9041110310/${userData['mobileno']}',
      {'q': '{http}'},
    );
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var abc = convert.jsonDecode(response.body);
      return abc['data'] as List;
    } else {
      throw Exception("Failed to load data");
    }
  }

  String formattedDate = '';
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _notificationService.init(context);
    _remarks.value = _remarks.value.copyWith(text: remarks);
    // print(review);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white70,
        title: Text('Submit Review', style: TextStyle(color: Colors.white)),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            // color: Colors.white,
            child: FutureBuilder<List<dynamic>>(
              future: reviewlist(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Color.fromARGB(255, 2, 36, 171),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Color.fromARGB(255, 2, 36, 171),
                    ),
                  );
                } else {
                  final review = snapshot.data!;

                  return SizedBox(
                    height: MediaQuery.of(context).size.height - 50,
                    child: ListView.builder(
                      itemCount: review.length,
                      itemBuilder: (context, index) {
                        if (review[index]['customer_dated'] != null) {
                          DateTime parsedDate = DateTime.parse(
                            review[index]['customer_dated'],
                          );
                          formattedDate = DateFormat(
                            'dd-MM-yyyy hh:mm a',
                          ).format(parsedDate);
                        } else {
                          formattedDate = '';
                        }
                        return Card(
                              elevation: 1.0,
                              color: Colors.white,
                              child: ListTile(
                                leading: CircleAvatar(
                                  child: CachedNetworkImage(
                                    imageUrl:
                                        SessionUrl().imgProfile +
                                        review[index]['image'].toString(),
                                    placeholder: (context, url) =>
                                        CircularProgressIndicator(
                                          color: Color.fromARGB(
                                            255,
                                            2,
                                            36,
                                            171,
                                          ),
                                        ),
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                  ),
                                ),
                                title: AutoSizeText(
                                  review[index]['sub_cate'].toString(),
                                  minFontSize: 12,
                                  maxFontSize: 15,
                                  maxLines: 1,
                                ),
                                subtitle: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AutoSizeText(
                                      'Remark: ${review[index]['customer_remarks']}',
                                      minFontSize: 11,
                                      maxFontSize: 13,
                                      maxLines: 2,
                                    ),
                                    AutoSizeText(
                                      'Review: ${review[index]['customer_review'] ?? ''}, Dated: $formattedDate',
                                      minFontSize: 11,
                                      maxFontSize: 13,
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                                // trailing: Icon(Icons.arrow_forward_ios),
                              ),
                            )
                            .animate()
                            .fadeIn(duration: 400.ms, delay: (index * 100).ms)
                            .slideX(
                              begin: -0.2, // Slide in from slightly left
                              end: 0,
                              curve: Curves.easeOutQuad,
                            );
                      },
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class ReviewPartner extends StatefulWidget {
  String? title;
  ReviewPartner({super.key, required this.title});

  @override
  State<ReviewPartner> createState() => _ReviewPartnerState();
}

class _ReviewPartnerState extends State<ReviewPartner> {
  final NotificationService _notificationService = NotificationService();
  final translator = GoogleTranslator();
  String? userLang, appids;

  Timer? _timer;

  Map<String, dynamic> userData = {
    'userid': 'no',
    'mobileno': 'no',
    'language': 'no',
    'client_name': 'no',
    'contact2': 'no',
    'district': 'no',
    'pincode': 'no',
    'address': 'no',
    'appid': 'no',
    'category': 'not',
  };

  final TextEditingController _remarks = TextEditingController();
  String? remarks;
  @override
  void initState() {
    super.initState();
    _notificationService.requestNotificationPermission();
    _getSessions();
  }

  Future<void> _getSessions() async {
    try {
      var sharedPreferences = await SessionUrl().getUserdata();
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
      // ignore: avoid_print
      print('$e');
    }
  }

  Future<List<dynamic>> reviewlist() async {
    var url = Uri.https(
      SessionUrl().baseUrl,
      '/home/reviewPartner/passkeysatnam9041110310/${userData['mobileno']}',
      {'q': '{http}'},
    );
    var response = await http.get(url);
    if (response.statusCode == 200) {
      var abc = convert.jsonDecode(response.body);
      return abc['data'] as List;
    } else {
      throw Exception("Failed to load data");
    }
  }

  String formattedDate = '';
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _notificationService.init(context);
    _remarks.value = _remarks.value.copyWith(text: remarks);
    // print(review);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white70,
        title: Text('Review List', style: TextStyle(color: Colors.white)),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            // color: Colors.white,
            child: FutureBuilder<List<dynamic>>(
              future: reviewlist(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Color.fromARGB(255, 2, 36, 171),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Color.fromARGB(255, 2, 36, 171),
                    ),
                  );
                } else {
                  final review = snapshot.data!;

                  return SizedBox(
                    height: MediaQuery.of(context).size.height - 50,
                    child: ListView.builder(
                      itemCount: review.length,
                      itemBuilder: (context, index) {
                        if (review[index]['customer_dated'] != null) {
                          DateTime parsedDate = DateTime.parse(
                            review[index]['customer_dated'],
                          );
                          formattedDate = DateFormat(
                            'dd-MM-yyyy hh:mm a',
                          ).format(parsedDate);
                        } else {
                          formattedDate = '';
                        }
                        return Card(
                              elevation: 1.0,
                              color: Colors.white,
                              child: ListTile(
                                leading: CircleAvatar(
                                  child: CachedNetworkImage(
                                    imageUrl:
                                        SessionUrl().imgProfile +
                                        review[index]['image'].toString(),
                                    placeholder: (context, url) =>
                                        CircularProgressIndicator(
                                          color: Color.fromARGB(
                                            255,
                                            2,
                                            36,
                                            171,
                                          ),
                                        ),
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                  ),
                                ),
                                title: AutoSizeText(
                                  review[index]['sub_cate'].toString(),
                                  minFontSize: 12,
                                  maxFontSize: 15,
                                  maxLines: 1,
                                ),
                                subtitle: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AutoSizeText(
                                      'Remark: ${review[index]['customer_remarks']}',
                                      minFontSize: 11,
                                      maxFontSize: 13,
                                      maxLines: 2,
                                    ),
                                    AutoSizeText(
                                      'Review: ${review[index]['customer_review'] ?? ''}, Dated: $formattedDate',
                                      minFontSize: 11,
                                      maxFontSize: 13,
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                                // trailing: Icon(Icons.arrow_forward_ios),
                              ),
                            )
                            .animate()
                            .fadeIn(duration: 400.ms, delay: (index * 100).ms)
                            .slideX(
                              begin: -0.2, // Slide in from slightly left
                              end: 0,
                              curve: Curves.easeOutQuad,
                            );
                      },
                    ),
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
