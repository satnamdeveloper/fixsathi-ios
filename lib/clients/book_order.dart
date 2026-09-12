import 'dart:async';
import 'dart:convert' as convert;
import 'dart:math';
import 'package:fixsathi/classPack/sessions_file.dart';
import 'package:fixsathi/clients/dashboard_user.dart';
import 'package:fixsathi/clients/notification_dash.dart';
// import 'package:fixsathi/clients/success_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:translator/translator.dart';

// ignore: must_be_immutable
class SetSchdule extends StatefulWidget {
  final String title;
  Map<String, dynamic> details;
  SetSchdule({super.key, required this.title, required this.details});

  @override
  State<SetSchdule> createState() => _SetSchduleState();
}

class _SetSchduleState extends State<SetSchdule> {
  List cartlist = [];
  int totalval = 0;
  int counters = 0;
  int? _selectSch = 1;
  // Location location = Location();
  Timer? _timer;

  final _chars = '1234567890';
  final _rnd = Random();
  String getRandomString(int length) => String.fromCharCodes(
    Iterable.generate(
      length,
      (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length)),
    ),
  );
  Map<String, dynamic> getdata = {};
  Map<String, dynamic> userData = {};
  late Razorpay _razorpay;
  final translator = GoogleTranslator();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _remarks = TextEditingController();
  final TextEditingController _setDate = TextEditingController();
  final TextEditingController _fromTime = TextEditingController();
  String orderid = '';
  bool isPaymentSuccessful = false;
  bool _isLoading = true;
  String balanceAmt = '0';

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    _getSessions();
    _getSessionCart();
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        translate();
        getAmount();
      }
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    // ignore: avoid_print
    print(response.paymentId);
    postBooked(response.paymentId.toString(), response.signature.toString());
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('message:= $response');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Do something when an external wallet was selected
  }

  Future<void> _getSessions() async {
    try {
      var sharedPreferences = await SessionUrl().getUserdata();
      Map<String, dynamic> usersAll = convert.jsonDecode(sharedPreferences!);
      if (usersAll.isNotEmpty) {
        if (mounted) {
          setState(() {
            userData = usersAll;
          });
        }
      }
    } catch (e) {
      // ignore: avoid_print
      // print('$e');
    }
  }

  Future<void> getWallet() async {
    try {
      var url = Uri.https(SessionUrl().baseUrl, 'home/getWallet');
      var response = await http.post(
        url,
        body: {
          'mobileno': userData['mobileno'].toString(),
          'amount': widget.details['totals'],
          'keyset': 'pass_key@satnam9041110310',
        },
      );
      // print(response.statusCode);
      if (response.statusCode == 200) {
        var getres = convert.jsonDecode(response.body);
        // print(getres);

        if (getres['status'] == 'success') {
          // ignore: use_build_context_synchronously
          debugPrint('Successful updated amount.');
        } else {
          debugPrint('Error: Not update the amount.');
        }
      }
    } catch (e) {
      debugPrint('error $e');
    }
  }

  Future<void> getAmount() async {
    try {
      var url = Uri.https(SessionUrl().baseUrl, 'home/getAmount');
      var response = await http.post(
        url,
        body: {
          'mobileno': userData['mobileno'].toString(),
          'amount': widget.details['totals'],
          'keyset': 'pass_key@satnam9041110310',
        },
      );
      // print(response.statusCode);
      if (response.statusCode == 200) {
        var getres = convert.jsonDecode(response.body);
        // print(getres);

        if (getres['status'] == 'success') {
          // ignore: use_build_context_synchronously
          if (mounted) {
            setState(() {
              balanceAmt = getres['total'].toString();
            });
          }
        } else {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: Not get data?'),
              backgroundColor: Color.fromARGB(255, 243, 25, 25),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('error $e');
    }
  }

  List getlangs = [
    'Set Order Schdule',
    'Any Remarks',
    'Now',
    'Set Schdule',
    'Order Submit',
  ];
  void translate() async {
    try {
      List languages = [
        'Set Order Schdule',
        'Any Remarks',
        'Now',
        'Set Schdule',
        'Order Submit',
      ];
      if (widget.details['lang'] == 'punjabi') {
        var futures = languages.map((item) {
          return translator.translate(item.toString(), from: 'en', to: 'pa');
        }).toList();

        // 2. Wait for all of them to complete in parallel
        List<Translation> results = await Future.wait(futures);
        // for (var translation in resurlts) {
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

  String generateRandomString(int len) {
    var r = Random();
    // ignore: no_leading_underscores_for_local_identifiers
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(
      len,
      (index) => _chars[r.nextInt(_chars.length)],
    ).join();
  }

  void payments() {
    // String textcode = generateRandomString(12).toString();
    String amts = (int.parse(balanceAmt) * 100).toString();
    var options = {
      'key': 'rzp_live_SzqZ47rdzGKBCt',
      // 'key': 'rzp_test_Sgp0MCSX9Yj2Lp',
      'amount': amts.toString(),
      'currency': 'INR',
      'name': '${widget.details['username']}',
      // 'order_id': 'order_$textcode',
      'description': 'home-services',
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
      'prefill': {
        'contact': '+91${widget.details['phoneno']}',
        'email': '${widget.details['phoneno']}@fixsathi.com',
      },
    };
    _razorpay.open(options);
  }

  Future<void> postBooked(String? orderid, String? signatures) async {
    try {
      var url = Uri.https(SessionUrl().baseUrl, 'notification/postBooked');
      var response = await http.post(
        url,
        body: {
          'mobileno': widget.details['phoneno'].toString(),
          'subcate': widget.details['subcate'].toString(),
          'remarks': _remarks.text,
          'listdata': convert.jsonEncode(cartlist),
          'setdates': _setDate.text,
          'settimes': _fromTime.text,
          'orderid': orderid.toString(),
          'schdule': _selectSch.toString(),
          'payMode': widget.details['payMode'].toString(),
          'totals': balanceAmt.toString(),
          'keyset': 'pass_key@satnam9041110310',
          'signature': signatures.toString(),
        },
      );

      if (response.statusCode == 200) {
        var getres = convert.jsonDecode(response.body);
        if (getres['status'] == 'success') {
          getWallet();
          SessionUrl().removeUserAcc();
          // ignore: use_build_context_synchronously
          alertPopUps(context, getres['data']);
          await Future.delayed(const Duration(seconds: 4));
          Navigator.pushAndRemoveUntil(
            // ignore: use_build_context_synchronously
            context,
            MaterialPageRoute(builder: (context) => MainDashboard()),
            (Route<dynamic> route) => false,
          );
        } else {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: Not get data?'),
              backgroundColor: Color.fromARGB(255, 243, 18, 18),
            ),
          );
        }
      } else {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error? Weak Internet'),
            backgroundColor: Color.fromARGB(255, 243, 18, 18),
          ),
        );
      }
    } catch (e) {
      // debugPrint('error $e');
    }
  }

  Future<void> _getSessionCart() async {
    try {
      var sharedPreferences = await SessionUrl().getUserAcc();
      List cartAll = convert.jsonDecode(sharedPreferences!);
      if (cartAll.isNotEmpty) {
        if (mounted) {
          setState(() {
            cartlist = cartAll;
          });
        }
      } else {
        debugPrint('not print');
      }
    } catch (e) {
      debugPrint('$e');
    }
  }

  // ignore: unused_element
  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      if (mounted) {
        setState(() {
          _fromTime.text = picked.format(context);
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _remarks.dispose();
    _setDate.dispose();
    _fromTime.dispose();
    _razorpay.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ignore: avoid_print
    // print(details['phoneno'].toString());
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 5, 36, 122),
        foregroundColor: Colors.white54,
        title: Text(getlangs[0].toString()),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 4,
                color: Colors.blue,
              ),
            )
          : SafeArea(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
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
                              labelText: getlangs[1].toString(),
                              fillColor: Colors.white,
                            ),
                            onTap: () async {},
                            // validator: (value) {
                            //   if (value!.length.isNaN) {
                            //     return 'Required remarks';
                            //   } else {
                            //     return null;
                            //   }
                            // },
                          ),
                        ),
                        RadioGroup<int>(
                          groupValue: _selectSch,
                          onChanged: (int? value) {
                            setState(() {
                              _selectSch = value;
                            });
                          },
                          child: Row(
                            children: [
                              Radio<int>(value: 1),
                              Text(getlangs[2].toString()),
                              Radio<int>(value: 2),
                              Text(getlangs[3].toString()),
                            ],
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          child: TextFormField(
                            controller: _setDate,
                            decoration: InputDecoration(
                              enabled: (_selectSch == 2) ? true : false,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 10.0,
                                vertical: 10.0,
                              ),
                              labelText: 'DD-MM-YYYY',
                              fillColor: Colors.white,
                            ),
                            onTap: () async {
                              DateTime? pickdate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2050),
                                // barrierColor: Colors.white,
                              );
                              if (pickdate != null) {
                                setState(() {
                                  _setDate.text = DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(pickdate);
                                });
                              }
                            },
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          child: TextFormField(
                            controller: _fromTime,
                            decoration: InputDecoration(
                              enabled: (_selectSch == 2) ? true : false,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 10.0,
                                vertical: 10.0,
                              ),
                              labelText: 'HH:MM:SS',
                              fillColor: Colors.white,
                            ),
                            onTap: () => _selectTime(context),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo.shade800,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () async {
                            // if (_formKey.currentState!.validate()) {
                            if (userData['category'] == 'customer') {
                              if (balanceAmt == '0') {
                                postBooked('', '');
                              } else {
                                if (widget.details['payMode'] == '1') {
                                  payments();
                                } else {
                                  postBooked('', '');
                                }
                              }
                            }
                            // else {
                            //   if (userData['service'].toString() !=
                            //       details['subcate'].toString()) {
                            //     if (widget.details['payMode'] == '1') {
                            //       payments();
                            //     } else {
                            //       postBooked('');
                            //     }
                            //   } else {
                            //     // ignore: use_build_context_synchronously
                            //     ScaffoldMessenger.of(context).showSnackBar(
                            //       const SnackBar(
                            //         content: Text(
                            //           'Error: Same person booking service.',
                            //         ),
                            //         backgroundColor: Color.fromARGB(
                            //           255,
                            //           243,
                            //           18,
                            //           18,
                            //         ),
                            //       ),
                            //     );
                            //   }
                            // }

                            // }
                          },
                          child: Text(getlangs[4].toString()),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  // ignore: strict_top_level_inference
  void alertPopUps(context, data1) async {
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.indigo,
          contentPadding: EdgeInsets.all(20),

          // titlePadding: EdgeInsets.all(12),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          content: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width - 10,
              padding: const EdgeInsets.all(0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 1.0,
                      vertical: 5.0,
                    ),
                    padding: const EdgeInsets.all(15),
                    width: 180,
                    height: 180,
                    child: Lottie.asset(
                      'assets/jsons/done-work.json',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 1.0,
                        vertical: 7.0,
                      ),
                      child: FittedBox(
                        child: Text(
                          'Booking Confirmed!',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 24.0,
                            color: const Color.fromARGB(255, 236, 245, 238),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 1.0,
                      vertical: 5.0,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 10.0,
                    ),
                    child: Text(
                      'Your Service has been booked successfully.',
                      style: TextStyle(
                        fontSize: 14.0,
                        color: const Color.fromARGB(255, 236, 245, 238),
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 1.0,
                      vertical: 10.0,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 10.0,
                    ),
                    child: Card(
                      color: Colors.white,
                      elevation: 0,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Date:', style: TextStyle(fontSize: 16)),
                              Text(
                                data1['online_date'],
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Time Slot', style: TextStyle(fontSize: 16)),
                              Text(
                                (data1['schdule_status'] == 'Now')
                                    ? 'Now'
                                    : '${data1['dated']} ${data1['times']}',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Amount',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.green,
                                ),
                              ),
                              Text(
                                data1['total_amt'],
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // ignore: use_build_context_synchronously
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => MainDashboard()),
                  (Route<dynamic> route) => false,
                );
              },
              child: Text('Back to Home'),
            ),
          ],
        );
      },
    );
  }
}

// ignore: must_be_immutable
class BookedList extends StatefulWidget {
  final String title;
  Map<String, dynamic> details;
  BookedList({super.key, required this.title, required this.details});

  @override
  State<BookedList> createState() => _BookedListState();
}

class _BookedListState extends State<BookedList> {
  List cartlist = [];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      postBooking();
    });
  }

  List<dynamic> getress = [];

  @override
  void dispose() {
    super.dispose();
    // _timer?.cancel();
  }

  Future<void> postBooking() async {
    try {
      var url = Uri.https(
        SessionUrl().baseUrl,
        '/home/bookingList/passkeysatnam9041110310/${widget.details['phoneno']}',
        {'q': '{http}'},
      );
      var response = await http.get(url);
      if (response.statusCode == 200) {
        // List<String> items = [];
        var getlist = convert.jsonDecode(response.body);
        if (mounted) {
          setState(() {
            getress = getlist['data'];
          });
        }
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    // print(getress);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 5, 36, 122),
        foregroundColor: Colors.white54,
        title: Text('Booking List'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                height: MediaQuery.of(context).size.height - 150,
                child: ListView.builder(
                  itemCount: (getress.isNotEmpty) ? getress.length : 1,
                  itemBuilder: (context, index) {
                    if (getress.isNotEmpty) {
                      return Card(
                        elevation: 2.0,
                        color: Colors.white,
                        child: ListTile(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    CheckNotification(
                                      title: 'Check Notification',
                                      notityData: {
                                        'photo':
                                            (getress[index]['image'] != null)
                                            ? (SessionUrl().imgProfile +
                                                  getress[index]['image'])
                                            : 'https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_640.png',
                                        'dateTime':
                                            getress[index]['order_date'],
                                        'cname': getress[index]['firstname'],
                                        'address': getress[index]['address'],
                                        'city': getress[index]['city'],
                                        'contact1': getress[index]['contactno'],
                                        'contact2': getress[index]['contact2'],
                                        'sub_cate': getress[index]['sub_cate'],
                                        'status': getress[index]['status_work'],
                                        'otp': getress[index]['otp_remarks'],
                                        'seen': getress[index]['seen'],
                                        'schdule_status':
                                            getress[index]['schdule_status'],
                                        'dated': getress[index]['dated'],
                                        'times': getress[index]['times'],
                                        'whos': 'customer',
                                        'id': getress[index]['id'],
                                      },
                                    ),
                              ),
                            );
                          },
                          leading: (getress[index]['image'] == null)
                              ? Icon(Icons.image, size: 32.0)
                              : Image.network(
                                  SessionUrl().imgProfile +
                                      getress[index]['image'].toString(),
                                  width: 60.0,
                                ),
                          title: Text(getress[index]['firstname'].toString()),
                          subtitle: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${getress[index]['sub_cate']} Service'),
                              Text('Date: ${getress[index]['order_date']}'),
                            ],
                          ),
                          trailing: Text(
                            'Rs. ${getress[index]['price']}',
                            style: TextStyle(fontSize: 14.0),
                          ),
                        ),
                      );
                    } else {
                      return Center(
                        child: Container(
                          margin: EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 25.0,
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 15.0,
                            vertical: 15.0,
                          ),
                          child: Lottie.asset(
                            'assets/jsons/blank.json',
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
