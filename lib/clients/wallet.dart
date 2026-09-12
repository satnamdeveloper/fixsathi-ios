import 'dart:async';
import 'dart:convert' as convert;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:fixsathi/classPack/sessions_file.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

// ignore: must_be_immutable
class WalletList extends StatefulWidget {
  final String title;
  Map<String, dynamic> details;
  WalletList({super.key, required this.title, required this.details});

  @override
  State<WalletList> createState() => _WalletListState();
}

class _WalletListState extends State<WalletList> {
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
      var url = Uri.https(
        SessionUrl().baseUrl,
        '/home/walletList/passkeysatnam9041110310/${widget.details['phoneno']}',
        {'q': '{http}'},
      );
      var response = await http.get(url);
      if (response.statusCode == 200) {
        // List<String> items = [];
        var getlist = convert.jsonDecode(response.body);
        // print(getlist);
        return getlist['data'] as List;
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      // ignore: avoid_print
      print(e);
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
                  return Column(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height - 150,
                        child: ListView.builder(
                          itemCount: getress.length,
                          itemBuilder: (context, index) {
                            return Card(
                              elevation: 2.0,
                              child: ListTile(
                                title: AutoSizeText(
                                  'Order Cancel (Rs.${getress[index]['amount']})',
                                  minFontSize: 12,
                                  maxFontSize: 15,
                                  maxLines: 1,
                                ),
                                subtitle: AutoSizeText(
                                  '${getress[index]['dateTime']}',
                                  minFontSize: 11,
                                  maxFontSize: 13,
                                  maxLines: 2,
                                ),
                                trailing: SizedBox(
                                  width: 50,
                                  child: Row(
                                    children: [
                                      Icon(Icons.currency_rupee, size: 17),
                                      Text(
                                        '${getress[index]['total']}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
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
