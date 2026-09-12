import 'dart:async';
import 'dart:convert' as convert;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fixsathi/classPack/sessions_file.dart';
import 'package:fixsathi/clients/book_order.dart';
import 'package:fixsathi/clients/dashboard_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:translator/translator.dart';

// ignore: must_be_immutable
class AddtoCart extends StatefulWidget {
  final String title;
  Map<String, dynamic> category;
  AddtoCart({super.key, required this.title, required this.category});

  @override
  State<AddtoCart> createState() => _AddtoCartState();
}

class _AddtoCartState extends State<AddtoCart> {
  List cartlist = [];
  Timer? _timer;
  final translator = GoogleTranslator();

  @override
  void initState() {
    super.initState();
    _getSessionCart();
    getSubCate();
    Future.delayed(const Duration(milliseconds: 90), () {
      translate();
    });
    // _timer = Timer.periodic(Duration(seconds: 5), (timer) async {
    //   _getSessionCart();
    // });
  }

  Future<List<dynamic>> getSubCate() async {
    try {
      var url = Uri.https(
        SessionUrl().baseUrl,
        '/home/getSubCategory/pass_key@satnam9041110310/${widget.category['subcate']}',
        {'q': '{http}'},
      );
      final response = await http.get(url);
      if (response.statusCode == 200) {
        return convert.jsonDecode(response.body) as List;
      } else {
        throw Exception("Failed to load data:?");
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error: $e');
      return [];
    }
  }

  late List getlangs = [
    'Back',
    'All type of ${(widget.category['subcate'] == 'Car-Washing') ? 'Car' : widget.category['subcate']} Service',
    'Instant Service within 30 mins',
    'Verified Professional',
    'Transparent Pricing',
  ];
  void translate() async {
    try {
      List languages = [
        'Back',
        'All type of ${widget.category['subcate']} Service',
        'Instant Service within 30 mins',
        'Verified Professional',
        'Transparent Pricing',
      ];
      if (widget.category['lang'] == 'punjabi') {
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
      debugPrint('$e');
    }
  }

  Future<void> _getSessionCart() async {
    try {
      final sharedPreferences = await SessionUrl().getUserAcc();
      if (sharedPreferences == null) return;
      if (!mounted) return;
      List cartAll = convert.jsonDecode(sharedPreferences!);
      if (cartAll.isNotEmpty) {
        setState(() {
          cartlist = cartAll;
        });
      }
    } catch (e) {
      debugPrint('Error back: $e');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // postBooking();

    return Scaffold(
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
          child: FutureBuilder<List<dynamic>>(
            future: getSubCate(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Lottie.asset(
                    'assets/jsons/loading.json',
                    fit: BoxFit.contain,
                    height: 100.0,
                    width: 100.0,
                  ),
                );
              } else if (snapshot.hasError) {
                return Center(child: Text("Network issue!"));
              } else {
                final subcate = snapshot.data!;

                return CustomScrollView(
                  slivers: [
                    SliverAppBar(
                      // backgroundColor: Colors.white,
                      expandedHeight: 450,
                      title: Text(getlangs[0].toString()),
                      flexibleSpace: FlexibleSpaceBar(
                        background: Column(
                          children: [
                            if (widget.category['subcate'] == 'AC-Technician')
                              Image.asset(
                                'assets/images/ac.jpg',
                                fit: BoxFit.fitWidth,
                                height: 320,
                              ),
                            if (widget.category['subcate'] == 'Cleaner')
                              Image.asset(
                                'assets/images/cleaner.jpg',
                                fit: BoxFit.fitWidth,
                                height: 320,
                              ),
                            if (widget.category['subcate'] == 'Furniture')
                              Image.asset(
                                'assets/images/furniture.jpg',
                                fit: BoxFit.fitWidth,
                                height: 320,
                              ),
                            if (widget.category['subcate'] == 'Plumber')
                              Image.asset(
                                'assets/images/plumber.jpg',
                                fit: BoxFit.fitWidth,
                                height: 320,
                              ),
                            if (widget.category['subcate'] == 'PVC')
                              Image.asset(
                                'assets/images/pvcpipe.jpg',
                                fit: BoxFit.fitWidth,
                                height: 320,
                              ),
                            if (widget.category['subcate'] == 'Aluminium')
                              Image.asset(
                                'assets/images/aluminium.jpg',
                                fit: BoxFit.fitWidth,
                                height: 320,
                              ),
                            if (widget.category['subcate'] == 'Laundry')
                              Image.asset(
                                'assets/images/laundry.jpg',
                                fit: BoxFit.fitWidth,
                                height: 320,
                              ),
                            if (widget.category['subcate'] == 'Painter')
                              Image.asset(
                                'assets/images/painter.jpg',
                                fit: BoxFit.fitWidth,
                                height: 320,
                              ),
                            if (widget.category['subcate'] == 'Car-Washing')
                              Image.asset(
                                'assets/images/car-repair.jpeg',
                                fit: BoxFit.fitWidth,
                                height: 320,
                              ),
                            if (widget.category['subcate'] == 'Glass')
                              Image.asset(
                                'assets/images/glass.jpg',
                                fit: BoxFit.fitWidth,
                                height: 320,
                              ),
                            if (widget.category['subcate'] == 'Mason')
                              Image.asset(
                                'assets/images/mistry.jpg',
                                fit: BoxFit.fitWidth,
                                height: 320,
                              ),
                            if (widget.category['subcate'] ==
                                'Computer-Hardware')
                              Image.asset(
                                'assets/images/computer-hardware.jpg',
                                fit: BoxFit.fitWidth,
                                height: 320,
                              ),
                            if (widget.category['subcate'] == 'Care-Taker')
                              Image.asset(
                                'assets/images/care-taker.jpg',
                                fit: BoxFit.fitWidth,
                                height: 320,
                              ),
                            if (widget.category['subcate'] == 'Beauty-Salon')
                              Image.asset(
                                'assets/images/beauty-salon.jpg',
                                fit: BoxFit.fitWidth,
                                height: 320,
                              ),
                            if (widget.category['subcate'] == 'Barber-Haircut')
                              Image.asset(
                                'assets/images/barber.jpg',
                                fit: BoxFit.fitWidth,
                                height: 320,
                              ),
                            if (widget.category['subcate'] ==
                                'Security-Manpower')
                              Image.asset(
                                'assets/images/Security-Mainpower.jpg',
                                fit: BoxFit.fitWidth,
                                height: 320,
                              ),
                            if (widget.category['subcate'] == 'Electric')
                              Image.asset(
                                'assets/images/electricians.jpg',
                                fit: BoxFit.fitWidth,
                                height: 320,
                              ),
                            Container(
                              height: 110,
                              margin: EdgeInsets.symmetric(
                                horizontal: 10.0,
                                vertical: 5.0,
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.0,
                                vertical: 5.0,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white70,
                                border: BoxBorder.all(color: Colors.black38),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FittedBox(
                                    child: Text(
                                      '${getlangs[1]}',
                                      style: TextStyle(
                                        fontSize: 18.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),

                                  SizedBox(height: 4.0),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 17.0,
                                        height: 17.0,
                                        child: CircleAvatar(
                                          backgroundColor:
                                              Colors.green.shade400,
                                          child: Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 15,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 5.0,
                                          vertical: 4.0,
                                        ),
                                        child: AutoSizeText(
                                          getlangs[2].toString(),
                                          style: TextStyle(fontSize: 15.0),
                                          maxLines: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4.0),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: 17.0,
                                              height: 17.0,
                                              child: CircleAvatar(
                                                backgroundColor:
                                                    Colors.green.shade400,
                                                child: Icon(
                                                  Icons.check,
                                                  color: Colors.white,
                                                  size: 15,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 3.0,
                                                vertical: 3.0,
                                              ),
                                              child: AutoSizeText(
                                                getlangs[3].toString(),
                                                overflow: TextOverflow.ellipsis,
                                                minFontSize: 10,
                                                maxFontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: 17.0,
                                              height: 17.0,
                                              child: CircleAvatar(
                                                backgroundColor:
                                                    Colors.green.shade400,
                                                child: Icon(
                                                  Icons.check,
                                                  color: Colors.white,
                                                  size: 15,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 3.0,
                                                vertical: 4.0,
                                              ),
                                              child: AutoSizeText(
                                                getlangs[4].toString(),
                                                overflow: TextOverflow.ellipsis,
                                                minFontSize: 10,
                                                maxFontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        GestureDetector(
                          onTap: () {
                            if (widget.category['category'] != 'not') {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (BuildContext context) => CartList(
                                    title: 'Booking List',
                                    details: {
                                      'phoneno': widget.category['phoneno']
                                          .toString(),
                                      'subcate': widget.category['subcate']
                                          .toString(),
                                      'lang': widget.category['lang']
                                          .toString(),
                                      'category': widget.category['subcate']
                                          .toString(),
                                      'images': widget.category['images']
                                          .toString(),
                                      'username': widget.category['username']
                                          .toString(),
                                    },
                                  ),
                                ),
                              );
                              // _getSessionCart();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'First Update your registration then working fine?',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Color.fromARGB(
                                    255,
                                    239,
                                    33,
                                    18,
                                  ),
                                ),
                              );
                            }
                          },
                          child: Container(
                            margin: EdgeInsets.only(right: 20.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5),
                            ),

                            child: Badge(
                              label: Text(
                                cartlist.length.toString(),
                                style: TextStyle(fontSize: 14.0),
                              ),
                              child: Icon(
                                Icons.shopping_cart_outlined,
                                size: 30.0,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                      pinned: true,
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            Card(
                                  elevation: 0.7,
                                  color: Colors.white,
                                  child: GestureDetector(
                                    onTap: () {
                                      if (widget.category['category'] !=
                                          'not') {
                                        setState(() {
                                          if (widget.category['category'] !=
                                              'not') {
                                            if (!cartlist.contains(
                                              subcate[index]['id'],
                                            )) {
                                              cartlist.add(
                                                subcate[index]['id'],
                                              );
                                              SessionUrl().setUserAcc(
                                                convert.jsonEncode(cartlist),
                                              );
                                            }
                                          }
                                        });
                                        Navigator.of(context)
                                            .push(
                                              MaterialPageRoute(
                                                builder:
                                                    (
                                                      BuildContext context,
                                                    ) => CartList(
                                                      title: 'Booking List',
                                                      details: {
                                                        'phoneno': widget
                                                            .category['phoneno']
                                                            .toString(),
                                                        'lang': widget
                                                            .category['lang']
                                                            .toString(),
                                                        'category': widget
                                                            .category['subcate']
                                                            .toString(),
                                                        'images': widget
                                                            .category['images']
                                                            .toString(),
                                                        'username': widget
                                                            .category['username']
                                                            .toString(),
                                                        'subcate': widget
                                                            .category['subcate']
                                                            .toString(),
                                                      },
                                                    ),
                                              ),
                                            )
                                            .then((value) {
                                              _getSessionCart();
                                            });
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'First Update your registration then working fine?',
                                            ),
                                            backgroundColor: Color.fromARGB(
                                              255,
                                              248,
                                              241,
                                              241,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0,
                                        vertical: 5.0,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(2.0),
                                            width: 105.0,
                                            height: 105.0,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                              child: CachedNetworkImage(
                                                imageUrl:
                                                    SessionUrl().imgProfile +
                                                    subcate[index]['image']
                                                        .toString(),
                                                fit: BoxFit.fill,
                                                placeholder: (context, url) =>
                                                    CircularProgressIndicator(
                                                      strokeWidth: 4,
                                                      color: Color.fromARGB(
                                                        255,
                                                        2,
                                                        36,
                                                        171,
                                                      ),
                                                    ),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(Icons.error),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10.0,
                                                    vertical: 5.0,
                                                  ),
                                              margin: const EdgeInsets.only(
                                                top: 7.0,
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  AutoSizeText(
                                                    subcate[index]['sub_cate']
                                                        .toString(),
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 15.0,
                                                    ),
                                                    maxLines: 2,
                                                    minFontSize: 13,
                                                    maxFontSize: 15,
                                                    textAlign: TextAlign.left,
                                                  ),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.currency_rupee,
                                                        size: 15.0,
                                                      ),
                                                      AutoSizeText(
                                                        '${(subcate[index]['price'] == '0') ? subcate[index]['remarks'] : subcate[index]['price']}',
                                                        maxLines: 1,
                                                        minFontSize: 12,
                                                        maxFontSize: 14,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 70.0,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 7.0,
                                                  ),
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  elevation: 1.5,
                                                  foregroundColor: Colors.black,
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 0,
                                                        vertical: 10,
                                                      ),
                                                  shape:
                                                      const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.all(
                                                              Radius.circular(
                                                                9.0,
                                                              ),
                                                            ),
                                                      ),
                                                ),
                                                onPressed: () {
                                                  setState(() {
                                                    if (widget
                                                            .category['category'] !=
                                                        'not') {
                                                      if (cartlist.contains(
                                                        subcate[index]['id'],
                                                      )) {
                                                        cartlist.remove(
                                                          subcate[index]['id'],
                                                        );
                                                        SessionUrl().setUserAcc(
                                                          convert.jsonEncode(
                                                            cartlist,
                                                          ),
                                                        );
                                                      } else {
                                                        cartlist.add(
                                                          subcate[index]['id'],
                                                        );
                                                        SessionUrl().setUserAcc(
                                                          convert.jsonEncode(
                                                            cartlist,
                                                          ),
                                                        );
                                                      }
                                                    }
                                                  });
                                                },
                                                child: Icon(
                                                  (cartlist.contains(
                                                        subcate[index]['id'],
                                                      ))
                                                      ? Icons.remove
                                                      : Icons.add,
                                                  size: 25.0,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                                .animate()
                                .fadeIn(
                                  duration: 200.ms,
                                  delay: (index * 10).ms,
                                )
                                .slideX(
                                  begin: -0.2, // Slide in from slightly left
                                  end: 0,
                                  curve: Curves.easeOutQuad,
                                ),
                        childCount: subcate.length,
                      ),
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

// CART LIST VIEW

// ignore: must_be_immutable
class CartList extends StatefulWidget {
  final String title;
  Map<String, dynamic> details;
  CartList({super.key, required this.title, required this.details});

  @override
  State<CartList> createState() => _CartListState();
}

class _CartListState extends State<CartList> {
  final translator = GoogleTranslator();
  double incTax = 0.0;
  bool _loader = true;
  Timer? _timer;
  final ValueNotifier<List<dynamic>> _itemsList = ValueNotifier<List<dynamic>>(
    [],
  );

  @override
  void initState() {
    super.initState();
    postBooking('');
    // _timer = Timer.periodic(Duration(seconds: 5), (timer) {
    //   postBooking('');
    // });
    Future.delayed(const Duration(milliseconds: 400), () {
      translate();
      postBooking('');
    });
    Future.delayed(const Duration(milliseconds: 1500), () {
      setState(() {
        _loader = false;
      });
    });
  }

  late List getlangs = [
    'Order List',
    'Total Amount',
    'Discount',
    'GST 18%',
    'Grand Total',
    'Pay: Online',
    'Cash',
    'You have nothing service in cart list.',
  ];
  void translate() async {
    try {
      List languages = [
        'Order List',
        'Total Amount',
        'Discount',
        'GST 18%',
        'Grand Total',
        'Pay: Online',
        'Cash',
        'You have nothing service in cart list.',
      ];
      if (widget.details['lang'] == 'punjabi') {
        var futures = languages.map((item) {
          return translator.translate(item.toString(), from: 'en', to: 'pa');
        }).toList();

        List<Translation> results = await Future.wait(futures);

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

  void removeFromCart(String? id) async {
    var sharedPreferences = await SessionUrl().getUserAcc();
    List cartAll = convert.jsonDecode(sharedPreferences!);
    cartAll.remove(id);
    SessionUrl().setUserAcc(convert.jsonEncode(cartAll));
    if (cartAll.isEmpty) {
      SessionUrl().removeUserAcc();
    }
  }

  Future<void> postBooking(String id) async {
    try {
      // print(id);
      final sharedPreferences = await SessionUrl().getUserAcc();
      if (sharedPreferences == null) return;
      if (!mounted) return;
      final List cartAll = convert.jsonDecode(sharedPreferences!);
      cartAll.remove(id);
      SessionUrl().setUserAcc(convert.jsonEncode(cartAll));
      if (cartAll.isEmpty) {
        SessionUrl().removeUserAcc();
      }
      final carts = cartAll;
      final url = Uri.https(SessionUrl().baseUrl, 'home/postBooking');
      final response = await http.post(
        url,
        body: {
          'mobileno': widget.details['phoneno'].toString(),
          'language': widget.details['lang'].toString(),
          'listdata': convert.jsonEncode(carts),
          'keyset': 'pass_key@satnam9041110310',
        },
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        final getres = convert.jsonDecode(response.body);
        if (getres['status'] == 'success') {
          if (getres['data'] != null) {
            _itemsList.value = getres['data'] as List;
          } else {
            _itemsList.value = []; // Agar data key khali ho
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You have nothing in cart list'),
              backgroundColor: Color.fromARGB(255, 243, 18, 18),
            ),
          );
        }
      } else {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (BuildContext context) => MainDashboard()),
        );
      }
    } catch (e) {
      debugPrint('Remove session $e');
      // EasyLoading.showToast("You have nothing in cart item. $e");
      await SessionUrl().removeUserAcc();
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 5, 36, 122),
        foregroundColor: Colors.white54,
        title: AutoSizeText(getlangs[0].toString(), maxLines: 1),
      ),
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          child: SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 5.0, vertical: 0),
              child: ValueListenableBuilder<List<dynamic>>(
                valueListenable: _itemsList, // your async function
                builder: (context, list, child) {
                  if (list.isNotEmpty) {
                    incTax = (_itemsList.value[0]['totals'] != 0)
                        ? (((_itemsList.value[0]['totals'] ?? 0) * 18) / 100)
                        : 0;
                    return Column(
                      children: [
                        SizedBox(
                          height: 320,
                          child: ListView.builder(
                            itemCount: list.length,
                            itemBuilder: (context, index) {
                              return Card(
                                    margin: EdgeInsets.symmetric(
                                      horizontal: 1.0,
                                      vertical: 3.0,
                                    ),
                                    color: Colors.white,
                                    elevation: 1,
                                    child: ListTile(
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 7.0,
                                        vertical: 0,
                                      ),
                                      leading: SizedBox(
                                        width: 90.0,
                                        height: 90.0,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadiusGeometry.circular(
                                                500.0,
                                              ),
                                          child: (list[index]['image'] == null)
                                              ? Icon(Icons.image, size: 32.0)
                                              : CachedNetworkImage(
                                                  imageUrl:
                                                      SessionUrl().imgProfile +
                                                      list[index]['image']
                                                          .toString(),
                                                  placeholder: (context, url) =>
                                                      CircularProgressIndicator(
                                                        backgroundColor:
                                                            Colors.blue[800],
                                                        strokeWidth: 4.0,
                                                      ),
                                                  errorWidget:
                                                      (context, url, error) =>
                                                          Icon(Icons.error),
                                                ),
                                        ),
                                      ),
                                      title: AutoSizeText(
                                        list[index]['sub_cate'].toString(),
                                        minFontSize: 12,
                                        maxFontSize: 16,
                                        maxLines: 1,
                                      ),
                                      subtitle: AutoSizeText(
                                        '${list[index]['main_cate']} Service',
                                        maxLines: 1,
                                        minFontSize: 10,
                                        maxFontSize: 13,
                                      ),
                                      trailing: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          SizedBox(
                                            width: 60.0,
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.currency_rupee,
                                                  size: 14.0,
                                                ),
                                                AutoSizeText(
                                                  '${list[index]['price']}',
                                                  style: TextStyle(
                                                    fontSize: 15.0,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  maxLines: 1,
                                                  minFontSize: 11,
                                                  maxFontSize: 14,
                                                ),
                                              ],
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                width: 1.0,
                                                color: Colors.black45,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(50),
                                            ),
                                            child: InkWell(
                                              onTap: () async {
                                                postBooking(
                                                  list[index]['id'].toString(),
                                                );
                                              },

                                              child: Icon(
                                                Icons.close,
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                  .animate()
                                  .fadeIn(
                                    duration: 400.ms,
                                    delay: (index * 100).ms,
                                  )
                                  .slideX(
                                    begin: -0.2, // Slide in from slightly left
                                    end: 0,
                                    curve: Curves.easeOutQuad,
                                  );
                            },
                          ),
                        ),
                        Card(
                          elevation: 3.0,
                          color: Colors.white,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 10,
                            ),
                            height: 190.0,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      getlangs[1].toString(),
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      '${_itemsList.value[0]['totals'] ?? 0}.00',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      getlangs[2].toString(),
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      '0%',
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      getlangs[3].toString(),
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      incTax.toString(),
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      getlangs[4].toString(),
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      (_itemsList.value[0]['totals'] + incTax)
                                          .toStringAsFixed(2),
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.0,
                            vertical: 10.0,
                          ),
                          margin: EdgeInsets.symmetric(
                            horizontal: 7.0,
                            vertical: 10.0,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            // border: Border.all(width: 1.0),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Row(
                            children: [Text(''), Text(getlangs[5].toString())],
                          ),
                        ),

                        Container(
                          width: MediaQuery.of(context).size.width - 30,
                          margin: EdgeInsets.symmetric(
                            horizontal: 10.0,
                            vertical: 5.0,
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                horizontal: 7.0,
                                vertical: 10.0,
                              ),
                              backgroundColor: Colors.indigo.shade800,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (BuildContext context) => SetSchdule(
                                    title: 'Set Schdule',
                                    details: {
                                      'phoneno': widget.details['phoneno']
                                          .toString(),
                                      'lang': widget.details['lang'].toString(),
                                      'subcate': widget.details['subcate']
                                          .toString(),
                                      'username': widget.details['username']
                                          .toString(),
                                      'totals':
                                          (_itemsList.value[0]['totals'] +
                                                  incTax)
                                              .toStringAsFixed(0),
                                      'payMode': '1',
                                    },
                                  ),
                                ),
                              );
                            },
                            child: Text(
                              'Continue..',
                              style: TextStyle(fontSize: 18.0),
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Center(
                      child: (_loader == true)
                          ? Center(
                              child: Lottie.asset(
                                'assets/jsons/loading.json',
                                fit: BoxFit.contain,
                                height: 100.0,
                                width: 100.0,
                              ),
                            )
                          : Column(
                              children: [
                                Container(
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
                                Container(
                                  margin: EdgeInsets.symmetric(
                                    horizontal: 20.0,
                                    vertical: 30.0,
                                  ),
                                  child: Text(getlangs[7].toString()),
                                ),
                              ],
                            ),
                    );
                  }
                  // return Center(
                  //   child: CircularProgressIndicator(
                  //     color: Color.fromARGB(255, 2, 36, 171),
                  //   ),
                  // );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
