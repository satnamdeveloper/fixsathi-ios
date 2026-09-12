import 'dart:async';
import 'dart:convert' as convert;
import 'package:fixsathi/classPack/sessions_file.dart';
import 'package:fixsathi/clients/dashboard_user.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

// ignore: must_be_immutable
class SuccessScreen extends StatefulWidget {
  Map<String, dynamic> datas;
  SuccessScreen({super.key, required this.datas});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  Map<String, dynamic> userData = {};
  Map<String, dynamic> getdata = {};
  List cartlist = [];

  @override
  void initState() {
    super.initState();
    _getSessions();
    _getSessionCart();
    // _timer = Timer.periodic(Duration(seconds: 2), (timer) {
    //   _getSessionCart();
    // });

    Future.delayed(const Duration(milliseconds: 500), () {
      postBooked();
    });
  }

  Future<void> _getSessions() async {
    try {
      var sharedPreferences = await SessionUrl().getUserdata();
      Map<String, dynamic> usersAll = convert.jsonDecode(sharedPreferences!);
      if (usersAll.isNotEmpty) {
        setState(() {
          userData = usersAll;
        });
      } else {
        // debugPrint('not print');
      }
    } catch (e) {
      // ignore: avoid_print
      // print('$e');
    }
  }

  Future<void> _getSessionCart() async {
    try {
      var sharedPreferences = await SessionUrl().getUserAcc();
      List cartAll = convert.jsonDecode(sharedPreferences!);
      if (cartAll.isNotEmpty) {
        setState(() {
          cartlist = cartAll;
        });
      } else {
        // debugPrint('not print');
      }
    } catch (e) {
      // debugPrint('$e');
    }
  }

  Future<void> postBooked() async {
    try {
      var url = Uri.https(SessionUrl().baseUrl, 'notification/postBooked');
      var response = await http.post(
        url,
        body: {
          'mobileno': widget.datas['mobileno'].toString(),
          'subcate': widget.datas['subcate'].toString(),
          'remarks': widget.datas['remarks'].toString(),
          'listdata': widget.datas['listdata'],
          'setdates': widget.datas['setdates'].toString(),
          'settimes': widget.datas['settimes'].toString(),
          'orderid': widget.datas['orderid'].toString(),
          'schdule': widget.datas['schdule'].toString(),
          'payMode': widget.datas['payMode'].toString(),
          'totals': widget.datas['totals'].toString(),
          'keyset': 'pass_key@satnam9041110310',
        },
      );

      if (response.statusCode == 200) {
        var getres = convert.jsonDecode(response.body);
        if (getres['status'] == 'success') {
          if (!mounted) return;
          setState(() {
            getdata = getres['data'];
          });
          SessionUrl().removeUserAcc();
          Future.delayed(const Duration(seconds: 5), () {
            // ignore: use_build_context_synchronously
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (BuildContext context) => MainDashboard(),
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
            content: Text('Error? Weak Internet'),
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
    super.dispose();
    // _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    // print(getdata);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 5, 36, 122),
        foregroundColor: Colors.white54,
        title: Text('Booking List'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
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
                            Text('', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Time Slot', style: TextStyle(fontSize: 16)),
                            Text(
                              (getdata['schdule'] == 'Now')
                                  ? 'Now'
                                  : '${getdata['setdates']} ${getdata['settimes']}',
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
                              getdata['totals'],
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
                ElevatedButton(
                  onPressed: () {
                    // ignore: use_build_context_synchronously
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (BuildContext context) => MainDashboard(),
                      ),
                    );
                  },
                  child: Text('Back to Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
