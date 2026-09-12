import 'dart:async';
import 'dart:convert' as convert;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:fixsathi/classPack/mysearch_delegate.dart';
// import 'package:chewie/chewie.dart';
import 'package:fixsathi/classPack/sessions_file.dart';
import 'package:fixsathi/clients/add_cart.dart';
import 'package:fixsathi/clients/check_property.dart';
import 'package:fixsathi/clients/order_list.dart';
import 'package:fixsathi/clients/page_view.dart';
import 'package:fixsathi/clients/property.dart';
import 'package:fixsathi/clients/review.dart';
import 'package:fixsathi/frontScreen/client_reg.dart';
import 'package:fixsathi/frontScreen/shopk_reg.dart';
import 'package:location/location.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:translator/translator.dart';
// import 'package:video_player/video_player.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  final translator = GoogleTranslator();
  Location location = Location();
  String? serviceValue,
      userLang,
      appids,
      category,
      locality,
      jobToday,
      jobEarn,
      rating,
      totalJob,
      totalEarn;
  List cartLength = [];
  Timer? _timer;
  // Map<String, dynamic> videolink = {};
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
    'user_img': 'no',
  };

  List<dynamic> getcate = [];

  final ValueNotifier<List<dynamic>> _itemsList3 = ValueNotifier<List<dynamic>>(
    [],
  );
  final ValueNotifier<bool> _isLoad3 = ValueNotifier<bool>(true);
  // late VideoPlayerController _controller;
  // bool _isInitialized = false;
  // ChewieController? _chewieController;
  Map<String, dynamic> getupdate = {};
  bool _isLoading = true;
  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await _getSessions();
    await _getSessionCart();
    propertyGet();
    Future.delayed(const Duration(milliseconds: 150), () {
      translate();
      getSliders();
      ServiceStatus();
    });

    getCategories('');
    // _timer = Timer.periodic(Duration(seconds: 10), (timer) async {
    //   updateAppid();
    // });

    // _determinePosition();
    // videoPlayer();
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  Future<void> propertyGet() async {
    try {
      _isLoad3.value = true;

      final url = Uri.https(
        SessionUrl().baseUrl,
        '/home/propertyFetch/passkeysatnam9041110310/${userData['mobileno']}',
      );

      final response = await http.get(url);
      if (!mounted) return;
      if (response.statusCode == 200) {
        // FIX: Force a new list reference so ValueListenableBuilder triggers UI update
        var decodedData = convert.jsonDecode(response.body);
        if (decodedData is List) {
          _itemsList3.value = List<dynamic>.from(decodedData);
        }
      } else {
        throw Exception("Failed to load data: Status ${response.statusCode}");
      }
    } catch (e) {
      debugPrint('Property Fetch Error: $e');
    } finally {
      _isLoad3.value = false; // Stop loading spinner in any condition
    }
  }

  // ignore: non_constant_identifier_names
  Future<void> ServiceStatus() async {
    try {
      final url = Uri.https(
        SessionUrl().baseUrl,
        '/home/homeCounting/passkeysatnam9041110310/${userData['mobileno']}',
        // {'q': '{http}'},
      );
      final response = await http.get(url);
      if (!mounted) return;
      if (response.statusCode == 200) {
        final getlist = convert.jsonDecode(response.body);

        setState(() {
          jobToday = getlist['todayJob'].toString();
          jobEarn = getlist['todayEarning'].toString();
          totalJob = getlist['totalJob'].toString();
          totalEarn = getlist['totalEarn'].toString();
          rating = getlist['rating'].toString();
        });
      } else {
        debugPrint('Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  List getlangs = [
    'Main Dashboard',
    'Search Box',
    'AC Service &\nRepair',
    'Electric\nService',
    'Cleaner\nService',
    'Furniture\nService',
    'Plumber\nService',
    'PVC\nService',
    'Aluminium\nService',
    'Laundry & Ironing\nService',
    'Painter\nService',
    'Car Washing\n& Repair',
    'Glass\nService',
    'Mason\nService',
    'Computer &\nHardware',
    'Care Taker\nService',
    'Beauty &\nSalon',
    'Security\nMan Power',
    'Property\n Market',
    'Information\n Hub',
    '* Available for all services *',
    'Register as a Customer',
    'Need Home Services\nBook Trusted',
    'Register as a Fix Sathi Partner',
    'Get Jobs Near You\nGrow Your Business',
    'Continue',
    'Search by keywords or Service',
    'Barber\nHaircut',
  ];
  void translate() async {
    try {
      var sharedPreferences = await SessionUrl().getUserdata();
      if (sharedPreferences == null) return;
      if (!mounted) return;
      final Map<String, dynamic> usersAll = convert.jsonDecode(
        sharedPreferences!,
      );
      List languages = [
        'Main Dashboard',
        'Search Box',
        'AC Service &\nRepair',
        'Electric\nService',
        'Cleaner\nService',
        'Furniture\nService',
        'Plumber\nService',
        'PVC\nService',
        'Aluminium\nService',
        'Laundry & Ironing\nService',
        'Painter\nService',
        'Car Washing\n& Repair',
        'Glass\nService',
        'Mason\nService',
        'Computer\nHardware',
        'Care\nTaker Service',
        'Beauty\n& Salon',
        'Security\nMan Power',
        'Property\n Market',
        'Information\n Hub',
        '* Available for all services *',
        'Register as a Customer',
        'Need Home Services\nBook Trusted',
        'Register as a Partner with Fix-Sathi',
        'Get Jobs Near You\nGrow Your Business',
        'Register Now',
        'Search by keywords or Service',
        'Barber\nHaircut',
      ];
      if (usersAll['language'] == 'punjabi') {
        var futures = languages.map((item) {
          return translator.translate(item.toString(), from: 'en', to: 'pa');
        }).toList();

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
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<void> _getSessions() async {
    try {
      var sharedPreferences = await SessionUrl().getUserdata();
      if (sharedPreferences == null) return;
      if (!mounted) return;
      final Map<String, dynamic> usersAll = convert.jsonDecode(
        sharedPreferences!,
      );
      if (usersAll.isNotEmpty) {
        setState(() {
          category = usersAll['category'];
          userLang = usersAll['language'];
          userData = usersAll;
        });
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  // void _showAlert(BuildContext context) {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text("Alert"),
  //         content: const Text("This is a Flutter alert popup."),
  //         actions: [
  //           TextButton(
  //             child: const Text("Cancel"),
  //             onPressed: () {
  //               Navigator.of(context).pop(); // Close the dialog
  //             },
  //           ),
  //           TextButton(
  //             child: const Text("OK"),
  //             onPressed: () {
  //               Navigator.of(context).pop(); // Close the dialog
  //               // Add your logic here
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  Future<void> _getSessionCart() async {
    try {
      var sharedPreferences = await SessionUrl().getUserAcc();
      if (sharedPreferences == null) return;
      if (!mounted) return;
      final List cartAll = convert.jsonDecode(sharedPreferences!);

      setState(() {
        cartLength = cartAll;
      });
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  Future<void> getCategories(String abc) async {
    try {
      var url = Uri.https(
        SessionUrl().baseUrl,
        '/home/searchCategories/passkeysatnam9041110310/$abc',
      );
      final response = await http.get(url);
      if (!mounted) return;
      if (response.statusCode == 200) {
        // List<String> items = [];
        final getlist = convert.jsonDecode(response.body);
        if (getlist != null && getlist['data'] != null) {
          setState(() {
            getcate = getlist['data'];
          });
        }
      } else {
        debugPrint('Error Category ?');
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  List imgList = [];
  Future<void> getSliders() async {
    try {
      var url = Uri.https(
        SessionUrl().baseUrl,
        '/home/getSliders/passkeysatnam9041110310',
        {'q': '{http}'},
      );
      final response = await http.get(url);
      if (!mounted) return;
      if (response.statusCode == 200) {
        // List<String> items = [];
        final getlist = convert.jsonDecode(response.body);
        if (getlist != null) {
          setState(() {
            imgList = getlist;
          });
        }
      } else {
        debugPrint('Error Category ?');
      }
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  // Future<void> getVideo() async {
  //   try {
  //     var url = Uri.https(
  //       SessionUrl().baseUrl,
  //       '/home/getVideo/passkeysatnam9041110310',
  //       {'q': '{http}'},
  //     );
  //     var response = await http.get(url);
  //     if (response.statusCode == 200) {
  //       // List<String> items = [];
  //       var getlist = convert.jsonDecode(response.body);
  //       if (mounted) {
  //         setState(() {
  //           videolink = getlist;
  //         });
  //       }
  //     } else {
  //       debugPrint('Error Category ?');
  //     }
  //   } catch (e) {
  //     debugPrint('Error: $e');
  //   }
  // }

  @override
  void dispose() {
    _timer?.cancel();
    _itemsList3.dispose();
    _isLoad3.dispose();
    // _controller.dispose();
    // _chewieController?.dispose();
    super.dispose();
  }

  final List<String> serviceList = [
    'ac-eng.jpeg',
    'ac-pun.jpeg',
    'carwash-eng.jpeg',
    'pic-eng.jpeg',
    'pic-pun.jpeg',
    // 'As a Worker-Partner Register',
  ];
  int atIndex = 0;
  int atIndex1 = 0;
  dynamic result = '';

  // Future<bool> _onBackDblClick(BuildContext context) async {
  //   bool? exitApp = await showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: const Text('Really?'),
  //         content: const Text('Do you want to exit Application?'),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop(false);
  //             },
  //             child: const Text('No'),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop(true);
  //             },
  //             child: const Text('Yes'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  //   return exitApp ?? false;
  // }

  @override
  Widget build(BuildContext context) {
    // print(imgList);
    // Future.delayed(const Duration(seconds: 2), () {
    //   EasyLoading.dismiss();
    // });
    // print(userData['pincode']);
    // onWillPop: () => _onBackDblClick(context),
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 233, 240, 245),
        foregroundColor: const Color.fromARGB(214, 46, 45, 45),
        titleSpacing: 1.0,
        title: Container(
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          margin: const EdgeInsets.only(left: 15.0),
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.black45),
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: InkWell(
            onTap: () {
              if (userData['category'] == 'customer') {
                showSearch<String?>(
                  context: context,
                  delegate: MySearchDelegate(getcate, userData),
                );
              }
            },
            child: AutoSizeText(
              getlangs[26].toString(),
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
          InkWell(
            onTap: () {
              if (category != 'not') {
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (BuildContext context) => CartList(
                          title: 'Booking List',
                          details: {
                            'phoneno': userData['mobileno'].toString(),
                            'lang': userData['language'].toString(),
                            'category': userData['category'].toString(),
                            'images': userData['user_img'].toString(),
                            'username': userData['client_name'].toString(),
                            'subcate': userData['service'].toString(),
                          },
                        ),
                      ),
                    )
                    .then((value) {
                      _getSessionCart();
                    });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'First Update your registration then working fine?',
                    ),
                    backgroundColor: Color.fromARGB(255, 243, 18, 18),
                  ),
                );
              }
            },
            child: Container(
              margin: EdgeInsets.only(right: 19.0),
              child: Badge(
                label: Text(
                  cartLength.length.toString(),
                  style: TextStyle(fontSize: 14.0),
                ),
                child: Icon(
                  Icons.shopping_cart_outlined,
                  size: 30.0,
                  color: Colors.indigo,
                ),
              ),
            ),
          ),
        ],
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
                child: Column(
                  children: [
                    if (category == 'not')
                      Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 7.0,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(35.0),
                          border: Border.all(color: Colors.black),
                          color: Colors.white70,
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.0,
                            vertical: 9.0,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 3,
                                ),

                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,

                                      children: [
                                        SizedBox(
                                          width: 80.0,
                                          height: 80.0,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadiusGeometry.circular(
                                                  100,
                                                ),
                                            child: Image.asset(
                                              'assets/images/male.png',
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 7,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 7.0,
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                AutoSizeText(
                                                  getlangs[21].toString(),
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 17.0,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  maxLines: 1,
                                                ),
                                                AutoSizeText(
                                                  getlangs[22].toString(),
                                                  style: TextStyle(
                                                    color: Colors.black87,
                                                    fontSize: 12.0,
                                                  ),
                                                  maxLines: 1,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Divider(
                                      color: Colors.black87,
                                      thickness: 1,
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 7.0,
                                      ),
                                      alignment: AlignmentGeometry.bottomRight,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          foregroundColor: Colors.black,
                                          backgroundColor: Colors.white,
                                          minimumSize: Size(88, 36),
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 26,
                                          ),
                                          shape: const RoundedRectangleBorder(
                                            side: BorderSide(
                                              width: 1.0,
                                              color: Colors.black54,
                                            ),
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(20),
                                            ),
                                          ),
                                        ),
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  AddClient(
                                                    title:
                                                        'Customer Registration',
                                                    users: {
                                                      'phoneno':
                                                          userData['mobileno'],
                                                      'lang':
                                                          userData['language'],
                                                      'category': 'customer',
                                                    },
                                                  ),
                                            ),
                                          );
                                        },
                                        child: AutoSizeText(
                                          getlangs[25].toString(),
                                          maxLines: 1,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (category == 'not')
                      Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 7.0,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(35.0),
                          border: Border.all(color: Colors.black),
                          color: Colors.white70,
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.0,
                            vertical: 9.0,
                          ),

                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,

                                children: [
                                  Container(
                                    margin: EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 3,
                                    ),
                                    child: SizedBox(
                                      width: 80.0,
                                      height: 80.0,
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadiusGeometry.circular(50),
                                        child: Image.asset(
                                          'assets/images/partner.jpeg',
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 8,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 7.0,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          AutoSizeText(
                                            getlangs[23].toString(),
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 17.0,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            maxLines: 1,
                                          ),
                                          AutoSizeText(
                                            getlangs[24].toString(),
                                            style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 12.0,
                                            ),
                                            maxLines: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Divider(color: Colors.black87, thickness: 1),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 7.0),
                                alignment: AlignmentGeometry.bottomRight,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.black,
                                    backgroundColor: Colors.white,
                                    minimumSize: Size(88, 36),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 26,
                                    ),
                                    shape: const RoundedRectangleBorder(
                                      side: BorderSide(
                                        width: 1.0,
                                        color: Colors.black54,
                                      ),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(20),
                                      ),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            AddFirm(
                                              title: 'Partner Registration',
                                              users: {
                                                'phoneno': userData['mobileno'],
                                                'lang': userData['language'],
                                                'category': 'shopkeeper',
                                              },
                                            ),
                                      ),
                                    );
                                  },
                                  child: Text(getlangs[25].toString()),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 5.0,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black38, width: 1.0),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: Lottie.asset(
                        'assets/jsons/Ads1.json',
                        fit: BoxFit.contain,
                        height: 200.0,
                        width: MediaQuery.of(context).size.width - 25,
                      ),
                    ),

                    Container(
                      margin: EdgeInsets.symmetric(
                        vertical: 5.0,
                        horizontal: 10.0,
                      ),
                      child: CarouselSlider(
                        options: CarouselOptions(
                          autoPlay: true,
                          viewportFraction: 1,
                          autoPlayInterval: Duration(seconds: 5),
                          autoPlayAnimationDuration: Duration(seconds: 5),
                          enlargeCenterPage: true,
                          onPageChanged: ((index, reason) {
                            setState(() {
                              atIndex = index;
                            });
                          }),
                        ),
                        items: imgList.map((name) {
                          // var map = value as Map<String, dynamic>;
                          return Builder(
                            builder: (BuildContext context) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (BuildContext context) => PageViews(
                                        title: 'net',
                                        img:
                                            '${SessionUrl().imgProfile}${name['sliders']}',
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin: EdgeInsets.symmetric(horizontal: 2.0),
                                  width: MediaQuery.of(context).size.width,

                                  child: ClipRRect(
                                    borderRadius: BorderRadiusGeometry.circular(
                                      10.0,
                                    ),
                                    child: CachedNetworkImage(
                                      height: 200.0,
                                      fit: BoxFit.fill,
                                      imageUrl:
                                          '${SessionUrl().imgProfile}${name['sliders']}',
                                      placeholder: (context, url) => Center(
                                        child: CircularProgressIndicator(
                                          color: Color.fromARGB(
                                            255,
                                            2,
                                            36,
                                            171,
                                          ),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    // DotsIndicator(
                    //   dotsCount: imgList.length,
                    //   position: atIndex.toDouble(),
                    //   decorator: DotsDecorator(
                    //     color: Colors.black87, // Inactive color
                    //     activeColor: Colors.redAccent,
                    //   ),
                    // ),
                    Divider(height: 10.0),
                    if (category == 'workerPartner' || category == 'shopkeeper')
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 14.0,
                          vertical: 3.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,

                          children: [
                            Expanded(
                              child: _partnerBox(
                                colors: Colors.blue.shade100,
                                heading: 'Today Jobs',
                                numbers: jobToday.toString(),
                                icons: Icon(
                                  Icons.calendar_month,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),

                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          TodayEarning(
                                            title: 'Today Earning',
                                            details: {
                                              'phoneno': userData['mobileno'],
                                              'lang': userData['language'],
                                              'category': userData['category'],
                                            },
                                          ),
                                    ),
                                  );
                                },
                                child: _partnerBox(
                                  colors: Colors.green.shade100,
                                  heading: 'Today Earning',
                                  numbers: jobEarn.toString(),
                                  icons: Icon(
                                    Icons.wallet,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),

                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          ReviewPartner(
                                            title: 'Partner Rating',
                                          ),
                                    ),
                                  );
                                },
                                child: _partnerBox(
                                  colors: Colors.orange.shade100,
                                  heading: 'Rating',
                                  numbers: rating.toString(),
                                  icons: Icon(
                                    Icons.star,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    if (category == 'workerPartner' || category == 'shopkeeper')
                      Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 14.0,
                          vertical: 3.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          ServiceHistory(
                                            title: 'Total Jobs & Earning',
                                            details: {
                                              'phoneno': userData['mobileno'],
                                              'lang': userData['language'],
                                              'category': userData['category'],
                                            },
                                          ),
                                    ),
                                  );
                                },
                                child: _partnerBox(
                                  colors: Colors.blueGrey.shade50,
                                  heading: 'Total Jobs',
                                  numbers: totalJob.toString(),
                                  icons: Icon(
                                    Icons.calculate,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          ServiceHistory(
                                            title: 'Total Earning',
                                            details: {
                                              'phoneno': userData['mobileno'],
                                              'lang': userData['language'],
                                              'category': userData['category'],
                                            },
                                          ),
                                    ),
                                  );
                                },
                                child: _partnerBox(
                                  colors: Colors.brown.shade50,
                                  heading: 'Total Earning',
                                  numbers: totalEarn.toString(),
                                  icons: Icon(
                                    Icons.wallet,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (category == 'customer')
                      Container(
                        color: Colors.white,
                        margin: EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 5.0,
                        ),
                        child: AutoSizeText(
                          getlangs[20].toString(),
                          style: TextStyle(fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          minFontSize: 13,
                          maxFontSize: 16,
                        ),
                      ),

                    Container(
                      margin: EdgeInsets.symmetric(
                        vertical: 1.0,
                        horizontal: 7.0,
                      ),
                      child: Row(
                        children: [
                          _buildService(
                            getlangs[2].toString(),
                            'assets/images/ac.jpg',
                            {
                              'subcate': 'AC-Technician',
                              'images': 'ac.jpg',
                              'phoneno': userData['mobileno'].toString(),
                              'lang': userData['language'].toString(),
                              'category': userData['category'],
                              'username': userData['client_name'],
                            },
                          ),
                          _buildService(
                            getlangs[3].toString(),
                            'assets/images/electricians.jpg',
                            {
                              'subcate': 'Electric',
                              'images': 'electricians.jpg',
                              'phoneno': userData['mobileno'].toString(),
                              'lang': userData['language'].toString(),
                              'category': userData['category'],
                              'username': userData['client_name'],
                            },
                          ),
                          _buildService(
                            getlangs[4].toString(),
                            'assets/images/cleaner.jpg',
                            {
                              'subcate': 'Cleaner',
                              'images': 'cleaner.jpg',
                              'phoneno': userData['mobileno'].toString(),
                              'lang': userData['language'].toString(),
                              'category': userData['category'],
                              'username': userData['client_name'],
                            },
                          ),
                        ],
                      ),
                    ),

                    Container(
                      margin: EdgeInsets.symmetric(
                        vertical: 1.0,
                        horizontal: 7.0,
                      ),
                      child: Row(
                        children:
                            [
                              _buildService(
                                getlangs[5].toString(),
                                'assets/images/furniture.jpg',
                                {
                                  'subcate': 'Furniture',
                                  'images': 'furniture.jpg',
                                  'phoneno': userData['mobileno'].toString(),
                                  'lang': userData['language'].toString(),
                                  'category': userData['category'],
                                  'username': userData['client_name'],
                                },
                              ),
                              _buildService(
                                getlangs[6].toString(),
                                'assets/images/plumber.jpg',
                                {
                                  'subcate': 'Plumber',
                                  'images': 'plumber.jpg',
                                  'phoneno': userData['mobileno'].toString(),
                                  'lang': userData['language'].toString(),
                                  'category': userData['category'],
                                  'username': userData['client_name'],
                                },
                              ),
                              _buildService(
                                getlangs[7].toString(),
                                'assets/images/pvcpipe.jpg',
                                {
                                  'subcate': 'PVC',
                                  'images': 'pvcpipe.jpg',
                                  'phoneno': userData['mobileno'].toString(),
                                  'lang': userData['language'].toString(),
                                  'category': userData['category'],
                                  'username': userData['client_name'],
                                },
                              ),
                            ],
                      ),
                    ),

                    Container(
                      margin: EdgeInsets.symmetric(
                        vertical: 1.0,
                        horizontal: 7.0,
                      ),
                      child: Row(
                        children:
                            [
                              _buildService(
                                getlangs[8].toString(),
                                'assets/images/aluminium.jpg',
                                {
                                  'subcate': 'Aluminium',
                                  'images': 'aluminium.jpg',
                                  'phoneno': userData['mobileno'].toString(),
                                  'lang': userData['language'].toString(),
                                  'category': userData['category'],
                                  'username': userData['client_name'],
                                },
                              ),
                              _buildService(
                                getlangs[9].toString(),
                                'assets/images/laundry.jpg',
                                {
                                  'subcate': 'Laundry',
                                  'images': 'laundry.jpg',
                                  'phoneno': userData['mobileno'].toString(),
                                  'lang': userData['language'].toString(),
                                  'category': userData['category'],
                                  'username': userData['client_name'],
                                },
                              ),
                              _buildService(
                                getlangs[10].toString(),
                                'assets/images/painter.jpg',
                                {
                                  'subcate': 'Painter',
                                  'images': 'painter.jpg',
                                  'phoneno': userData['mobileno'].toString(),
                                  'lang': userData['language'].toString(),
                                  'category': userData['category'],
                                  'username': userData['client_name'],
                                },
                              ),
                            ],
                      ),
                    ),

                    Container(
                      margin: EdgeInsets.symmetric(
                        vertical: 1.0,
                        horizontal: 7.0,
                      ),
                      child: Row(
                        children:
                            [
                              _buildService(
                                getlangs[11].toString(),
                                'assets/images/car-repair.jpeg',
                                {
                                  'subcate': 'Car-Washing',
                                  'images': 'car-repair.jpeg',
                                  'phoneno': userData['mobileno'].toString(),
                                  'lang': userData['language'].toString(),
                                  'category': userData['category'],
                                  'username': userData['client_name'],
                                },
                              ),
                              _buildService(
                                getlangs[12].toString(),
                                'assets/images/glass.jpg',
                                {
                                  'subcate': 'Glass',
                                  'images': 'glass.jpg',
                                  'phoneno': userData['mobileno'].toString(),
                                  'lang': userData['language'].toString(),
                                  'category': userData['category'],
                                  'username': userData['client_name'],
                                },
                              ),
                              _buildService(
                                getlangs[13].toString(),
                                'assets/images/mistry.jpg',
                                {
                                  'subcate': 'Mason',
                                  'images': 'mistry.jpg',
                                  'phoneno': userData['mobileno'].toString(),
                                  'lang': userData['language'].toString(),
                                  'category': userData['category'],
                                  'username': userData['client_name'],
                                },
                              ),
                            ],
                      ),
                    ),

                    Container(
                      margin: EdgeInsets.symmetric(
                        vertical: 1.0,
                        horizontal: 7.0,
                      ),
                      child: Row(
                        children: [
                          _buildService(
                            getlangs[14].toString(),
                            'assets/images/computer-hardware.jpg',
                            {
                              'subcate': 'Computer-Hardware',
                              'images': 'computer-hardware.jpg',
                              'phoneno': userData['mobileno'].toString(),
                              'lang': userData['language'].toString(),
                              'category': userData['category'],
                              'username': userData['client_name'],
                            },
                          ),
                          _buildService(
                            getlangs[15].toString(),
                            'assets/images/care-taker.jpg',
                            {
                              'subcate': 'Care-Taker',
                              'images': 'care-taker.jpg',
                              'phoneno': userData['mobileno'].toString(),
                              'lang': userData['language'].toString(),
                              'category': userData['category'],
                              'username': userData['client_name'],
                            },
                          ),
                          _buildService(
                            getlangs[16].toString(),
                            'assets/images/beauty-salon.jpg',
                            {
                              'subcate': 'Beauty-Salon',
                              'images': 'beauty-salon.jpg',
                              'phoneno': userData['mobileno'].toString(),
                              'lang': userData['language'].toString(),
                              'category': userData['category'],
                              'username': userData['client_name'],
                            },
                          ),
                        ],
                      ),
                    ),

                    Container(
                      margin: EdgeInsets.symmetric(
                        vertical: 1.0,
                        horizontal: 7.0,
                      ),
                      child: Row(
                        children: [
                          _buildService(
                            getlangs[17].toString(),
                            'assets/images/Security-Mainpower.jpg',
                            {
                              'subcate': 'Security-Manpower',
                              'images': 'Security-Mainpower.jpg',
                              'phoneno': userData['mobileno'].toString(),
                              'lang': userData['language'].toString(),
                              'category': userData['category'],
                              'username': userData['client_name'],
                            },
                          ),
                          _buildService(
                            getlangs[27].toString(),
                            'assets/images/barber.jpg',
                            {
                              'subcate': 'Barber-Haircut',
                              'images': 'barber.jpg',
                              'phoneno': userData['mobileno'].toString(),
                              'lang': userData['language'].toString(),
                              'category': userData['category'],
                              'username': userData['client_name'],
                            },
                          ),

                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        AddProperty(
                                          title: 'Property Sale & Purchase',
                                          users: {
                                            'about': 'PropertyAcc',
                                            'images': 'sale-purch.jpg',
                                            'mobileno': userData['mobileno'],
                                            'language': userData['language'],
                                            'category': userData['category'],
                                            'username': userData['client_name'],
                                          },
                                        ),
                                  ),
                                );
                              },
                              child: Card(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadiusGeometry.circular(
                                    7,
                                  ),
                                ),
                                elevation: 3.0,
                                color: Colors.white,
                                child: Column(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 4.0,
                                        vertical: 5.0,
                                      ),
                                      child: Image.asset(
                                        'assets/images/sale-purch.jpg',
                                        frameBuilder:
                                            (
                                              context,
                                              child,
                                              frame,
                                              wasSynchronouslyLoaded,
                                            ) {
                                              if (wasSynchronouslyLoaded) {
                                                return child; // Agar image pehle se memory mein hai to turant dikhao
                                              }
                                              return frame != null
                                                  ? child // Image load hone ke baad child (image) dikhao
                                                  : const Center(
                                                      child: CircularProgressIndicator(
                                                        color: Color.fromARGB(
                                                          255,
                                                          2,
                                                          63,
                                                          167,
                                                        ),
                                                      ), // Load hote waqt spinner dikhao
                                                    );
                                            },
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: Text(
                                        getlangs[18].toString(),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 11.0,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    buildCarousel(),
                    SizedBox(height: 30.0),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildService(
    String title,
    String img,
    Map<String, dynamic> categories,
  ) {
    return Expanded(
      child: InkWell(
        onTap: () {
          if (category == 'customer' || category == 'not') {
            Navigator.of(context)
                .push(
                  MaterialPageRoute(
                    builder: (BuildContext context) =>
                        AddtoCart(title: 'Add to Cart', category: categories),
                  ),
                )
                .then((value) {
                  _getSessionCart();
                });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("You'r a partner so access denied;"),
                backgroundColor: Color.fromARGB(255, 236, 2, 2),
              ),
            );
          }
        },
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadiusGeometry.circular(4),
          ),
          elevation: 3.0,
          color: Colors.white,
          child: Column(
            children: [
              Image.asset(
                img.toString(),
                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                  if (wasSynchronouslyLoaded) {
                    return child; // Agar image pehle se memory mein hai to turant dikhao
                  }
                  return frame != null
                      ? child // Image load hone ke baad child (image) dikhao
                      : const Center(
                          child: CircularProgressIndicator(
                            color: Color.fromARGB(255, 2, 36, 171),
                          ), // Load hote waqt spinner dikhao
                        );
                },
                fit: BoxFit.fill,
              ),
              SizedBox(height: 5.0),
              Padding(
                padding: const EdgeInsets.all(3.0),
                child: Text(
                  title.toString(),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11.0, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCarousel() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
      child: ValueListenableBuilder<bool>(
        valueListenable: _isLoad3,
        builder: (context, isLoading, child) {
          if (isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 2, 36, 171),
              ),
            );
          }

          return ValueListenableBuilder<List<dynamic>>(
            valueListenable: _itemsList3,
            builder: (context, list, child) {
              if (list.isEmpty) {
                return const Center(
                  child: Text(
                    "No Properties Available",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                );
              }

              return Container(
                margin: const EdgeInsets.symmetric(
                  vertical: 2.0,
                  horizontal: 2.0,
                ),
                child: CarouselSlider(
                  options: CarouselOptions(
                    autoPlay: true,
                    viewportFraction: 0.4,
                    enlargeFactor: 0,
                    autoPlayInterval: Duration(seconds: 4),
                    autoPlayAnimationDuration: Duration(seconds: 4),
                    enlargeCenterPage: true,
                  ),
                  // --- APKI IMAGES YAHAN MAP HO RAHI HAIN ---
                  items: list.map((item) {
                    // NOTE: 'imageUrl' ki jagah apni API ki image key ka naam likhein (e.g., item['property_img'])
                    String imageUrl =
                        '${SessionUrl().imgProfile}/${item['img1']}';

                    return Builder(
                      builder: (BuildContext context) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(
                            12.0,
                          ), // Rounded corners for premium look
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 5.0,
                              vertical: 0,
                            ),
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1.0,
                                color: Colors.black45,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Stack(
                              children: [
                                // 1. Network Image with Loader & Error State
                                GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            CheckProperty2(
                                              title: 'Property View',
                                              propertyGet: item,
                                            ),
                                      ),
                                    );
                                  },
                                  child: CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    placeholder: (context, url) => Container(
                                      color: Colors.grey[200],
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                          color: Colors.grey[300],
                                          child: const Icon(
                                            Icons.broken_image,
                                            size: 40,
                                            color: Colors.grey,
                                          ),
                                        ),
                                  ),
                                ),

                                // 2. Optional: Image ke upar property ka naam dikhane ke liye (Gradient overlay)
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: 90,
                                    width: MediaQuery.of(context).size.width,
                                    decoration: BoxDecoration(
                                      color: const Color.fromARGB(
                                        114,
                                        10,
                                        10,
                                        10,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 5,
                                      vertical: 2,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          '${item['prop_type']} for ${item['status']}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.white,
                                          ),
                                        ),
                                        Text(
                                          'City: ${item['city']}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.white,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        Text(
                                          'Price: ${item['price']}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _partnerBox({
    required Color colors,
    required String heading,
    required String numbers,
    required Widget icons,
  }) {
    return Container(
      height: 90.0,
      decoration: BoxDecoration(
        color: colors,
        border: Border.all(width: 1.0, color: Colors.black26),
        borderRadius: BorderRadius.circular(7.0),
      ),
      margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 2.0),
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 7.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                margin: const EdgeInsets.only(right: 2.0),
                child: CircleAvatar(
                  minRadius: 15.0,
                  backgroundColor: Colors.black54,
                  child: icons,
                ),
              ),
              SizedBox(
                width: 65,
                child: AutoSizeText(
                  heading,
                  style: TextStyle(fontSize: 12.0, fontWeight: FontWeight.w500),
                  maxFontSize: 12,
                  minFontSize: 9,
                  maxLines: 2,
                ),
              ),
            ],
          ),
          Text(
            numbers,
            style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
