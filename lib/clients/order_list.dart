import 'dart:async';
import 'dart:convert' as convert;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fixsathi/classPack/sessions_file.dart';
import 'package:fixsathi/clients/notification_dash.dart';
// import 'package:fixsathi/widgets/extra_widgets.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

// ignore: must_be_immutable
class OrderList extends StatefulWidget {
  final String title;
  Map<String, dynamic> details;
  OrderList({super.key, required this.title, required this.details});

  @override
  State<OrderList> createState() => _OrderListState();
}

class _OrderListState extends State<OrderList> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    postOrder();
  }

  List<dynamic> getress = [];

  @override
  void dispose() {
    super.dispose();
    _timer?.cancel();
  }

  Future<List<dynamic>> postOrder() async {
    try {
      final url = Uri.https(
        SessionUrl().baseUrl,
        '/home/bookingList/passkeysatnam9041110310/${widget.details['phoneno']}',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final getlist = convert.jsonDecode(response.body);

        if (getlist != null && getlist['data'] is List) {
          return getlist['data'];
        } else {
          return [];
        }
      } else {
        debugPrint('Server Error Code: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('postOrder Error: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    // print(details['phoneno']);
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white70,
        backgroundColor: const Color.fromARGB(255, 5, 36, 122),
        title: Text('My Order List'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
            height: MediaQuery.of(context).size.height - 150,
            child: FutureBuilder<List<dynamic>>(
              future: postOrder(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
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
                } else {
                  final getress = snapshot.data!;
                  // print(getress);
                  return ListView.builder(
                    itemCount: getress.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 2.0,
                        color: (getress[index]['seen'] == '0')
                            ? Colors.orange[200]
                            : (getress[index]['seen'] == '4')
                            ? Colors.red[100]
                            : Colors.green[100],
                        child: GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    CheckNotification(
                                      title: 'Check Notification',
                                      notityData: getress[index],
                                    ),
                              ),
                            );
                          },
                          child: ListTile(
                            leading: SizedBox(
                              width: 70,
                              child: ClipRRect(
                                borderRadius: BorderRadiusGeometry.circular(10),
                                child: CachedNetworkImage(
                                  imageUrl:
                                      SessionUrl().imgProfile +
                                      getress[index]['photo'].toString(),
                                  placeholder: (context, url) =>
                                      CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                ),
                              ),
                            ),
                            title: AutoSizeText(
                              getress[index]['sub_cate'].toString(),
                              minFontSize: 12,
                              maxFontSize: 15,
                              maxLines: 1,
                            ),
                            subtitle: AutoSizeText(
                              ((getress[index]['seen'] == '0') ||
                                      (getress[index]['seen'] == '1'))
                                  ? 'Order is Under Process \n Date: ${getress[index]['online_date']}'
                                  : (getress[index]['seen'] == '4')
                                  ? 'Order is Cancel \n ${getress[index]['online_date']}'
                                  : '${getress[index]['cname']}, Mb: 98036 52267 \n Date: ${getress[index]['online_date']}',
                              minFontSize: 11,
                              maxFontSize: 13,
                              maxLines: 2,
                            ),
                            trailing: AutoSizeText(
                              '${getress[index]['total_amt']}',
                              style: TextStyle(fontWeight: FontWeight.w600),
                              minFontSize: 11,
                              maxFontSize: 13,
                              maxLines: 2,
                            ),
                          ),
                        ),
                      );
                    },
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
class ServiceHistory extends StatefulWidget {
  final String title;
  Map<String, dynamic> details;
  ServiceHistory({super.key, required this.title, required this.details});

  @override
  State<ServiceHistory> createState() => _ServiceHistoryState();
}

class _ServiceHistoryState extends State<ServiceHistory> {
  Timer? _timer;
  String formattedDate = '';

  @override
  void initState() {
    super.initState();
    serviceOrder();
  }

  List<dynamic> getress = [];
  double totalval = 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> serviceOrder() async {
    try {
      final url = Uri.https(
        SessionUrl().baseUrl,
        '/home/serviceHistory/passkeysatnam9041110310/${widget.details['phoneno']}',
        // {'q': '{http}'},
      );
      final response = await http.get(url);
      if (!mounted) return;
      if (response.statusCode == 200) {
        double totl = 0.0;
        // List<String> items = [];
        final getlist = convert.jsonDecode(response.body);
        if (getlist != null &&
            getlist['data'] != null &&
            getlist['data'] is List) {
          for (var tt in getlist['data']) {
            totl += double.tryParse(tt['total_amt']) ?? 0.0;
          }
        }
        setState(() {
          getress = getlist['data'];
          totalval = totl;
        });
      } else {
        debugPrint('Error: ${response.statusCode}');
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
        foregroundColor: Colors.white70,
        backgroundColor: const Color.fromARGB(255, 5, 36, 122),
        title: Text('Earning List'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                height: MediaQuery.of(context).size.height - 210,
                child: ListView.builder(
                  itemCount: (getress.isNotEmpty) ? getress.length : 1,
                  itemBuilder: (context, index) {
                    if (getress.isNotEmpty) {
                      if (getress[index]['online_date'] != null) {
                        DateTime parsedDate = DateTime.parse(
                          getress[index]['online_date'],
                        );
                        formattedDate = DateFormat(
                          'dd-MM-yyyy hh:mm a',
                        ).format(parsedDate);
                      } else {
                        formattedDate = '';
                      }
                      return Card(
                        elevation: 2.0,
                        color: Colors.white,
                        child: ListTile(
                          leading: (getress[index]['image'] != null)
                              ? SizedBox(
                                  width: 60,
                                  child: ClipRRect(
                                    borderRadius: BorderRadiusGeometry.circular(
                                      10,
                                    ),
                                    child: CachedNetworkImage(
                                      imageUrl:
                                          SessionUrl().imgProfile +
                                          getress[index]['image'].toString(),
                                      placeholder: (context, url) =>
                                          CircularProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    ),
                                  ),
                                )
                              : Icon(Icons.image, size: 32.0),
                          title: AutoSizeText(
                            getress[index]['sub_cate'].toString(),
                            minFontSize: 12,
                            maxFontSize: 15,
                            maxLines: 1,
                          ),
                          subtitle: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AutoSizeText(
                                '${getress[index]['cname']}',
                                minFontSize: 11,
                                maxFontSize: 13,
                                maxLines: 3,
                              ),
                              AutoSizeText(
                                '${getress[index]['pay_mode']} & Date: $formattedDate',
                                minFontSize: 11,
                                maxFontSize: 13,
                                maxLines: 3,
                              ),
                              if (getress[index]['pay_mode'] == 'online')
                                AutoSizeText(
                                  'Order ID: ${getress[index]['orderid']}',
                                  minFontSize: 11,
                                  maxFontSize: 13,
                                  maxLines: 3,
                                ),
                            ],
                          ),
                          trailing: AutoSizeText(
                            '${getress[index]['total_amt']}',
                            style: TextStyle(fontWeight: FontWeight.w600),
                            minFontSize: 12,
                            maxFontSize: 14,
                            maxLines: 1,
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

              // Spacer(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 7),
          decoration: BoxDecoration(
            border: Border.all(width: 1.0, color: Colors.black38),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total:',
                style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500),
              ),
              Text(
                '$totalval',
                style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class TodayEarning extends StatefulWidget {
  final String title;
  Map<String, dynamic> details;
  TodayEarning({super.key, required this.title, required this.details});

  @override
  State<TodayEarning> createState() => _TodayEarningState();
}

class _TodayEarningState extends State<TodayEarning> {
  Timer? _timer;
  String formattedDate = '';

  @override
  void initState() {
    super.initState();
    serviceOrder();
  }

  List<dynamic> getress = [];
  double totalval = 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> serviceOrder() async {
    try {
      final url = Uri.https(
        SessionUrl().baseUrl,
        '/home/todayEarning/passkeysatnam9041110310/${widget.details['phoneno']}',
        // {'q': '{http}'},
      );
      final response = await http.get(url);
      if (!mounted) return;
      if (response.statusCode == 200) {
        double totl = 0.0;
        // List<String> items = [];
        final getlist = convert.jsonDecode(response.body);
        if (getlist != null &&
            getlist['data'] != null &&
            getlist['data'] is List) {
          for (var tt in getlist['data']) {
            totl += double.tryParse(tt['total_amt']) ?? 0.0;
          }
        }
        setState(() {
          getress = getlist['data'];
          totalval = totl;
        });
      } else {
        debugPrint('Error: ${response.statusCode}');
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
        foregroundColor: Colors.white70,
        backgroundColor: const Color.fromARGB(255, 5, 36, 122),
        title: Text('Today Earning'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                height: MediaQuery.of(context).size.height - 210,
                child: ListView.builder(
                  itemCount: (getress.isNotEmpty) ? getress.length : 1,
                  itemBuilder: (context, index) {
                    if (getress.isNotEmpty) {
                      if (getress[index]['online_date'] != null) {
                        DateTime parsedDate = DateTime.parse(
                          getress[index]['online_date'],
                        );
                        formattedDate = DateFormat(
                          'dd-MM-yyyy hh:mm a',
                        ).format(parsedDate);
                      } else {
                        formattedDate = '';
                      }
                      return Card(
                        elevation: 2.0,
                        color: Colors.white,
                        child: ListTile(
                          leading: (getress[index]['image'] != null)
                              ? SizedBox(
                                  width: 60,
                                  child: ClipRRect(
                                    borderRadius: BorderRadiusGeometry.circular(
                                      10,
                                    ),
                                    child: CachedNetworkImage(
                                      imageUrl:
                                          SessionUrl().imgProfile +
                                          getress[index]['image'].toString(),
                                      placeholder: (context, url) =>
                                          CircularProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    ),
                                  ),
                                )
                              : Icon(Icons.image, size: 32.0),
                          title: AutoSizeText(
                            getress[index]['sub_cate'].toString(),
                            minFontSize: 12,
                            maxFontSize: 15,
                            maxLines: 1,
                          ),
                          subtitle: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AutoSizeText(
                                '${getress[index]['cname']}',
                                minFontSize: 11,
                                maxFontSize: 13,
                                maxLines: 3,
                              ),
                              AutoSizeText(
                                '${getress[index]['pay_mode']} & Date: $formattedDate',
                                minFontSize: 11,
                                maxFontSize: 13,
                                maxLines: 3,
                              ),
                              if (getress[index]['pay_mode'] == 'online')
                                AutoSizeText(
                                  'Order ID: ${getress[index]['orderid']}',
                                  minFontSize: 11,
                                  maxFontSize: 13,
                                  maxLines: 3,
                                ),
                            ],
                          ),
                          trailing: AutoSizeText(
                            '${getress[index]['total_amt']}',
                            style: TextStyle(fontWeight: FontWeight.w600),
                            minFontSize: 12,
                            maxFontSize: 14,
                            maxLines: 1,
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

              // Spacer(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 7),
          decoration: BoxDecoration(
            border: Border.all(width: 1.0, color: Colors.black38),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total:',
                style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500),
              ),
              Text(
                '$totalval',
                style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
