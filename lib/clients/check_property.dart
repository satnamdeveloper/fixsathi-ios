import 'dart:convert' as convert;

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fixsathi/classPack/notification_service.dart';
import 'package:fixsathi/classPack/sessions_file.dart';
import 'package:fixsathi/clients/page_view.dart';
import 'package:flutter/material.dart';
import 'package:translator/translator.dart';
// ignore: depend_on_referenced_packages
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

// ignore: must_be_immutable
class CheckProperty2 extends StatefulWidget {
  String? title;
  Map<String, dynamic> propertyGet = {};
  CheckProperty2({super.key, required this.title, required this.propertyGet});

  @override
  State<CheckProperty2> createState() => _CheckProperty2State();
}

class _CheckProperty2State extends State<CheckProperty2> {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;
  final NotificationService _notificationService = NotificationService();
  final UrlLauncherPlatform launcher = UrlLauncherPlatform.instance;
  final translator = GoogleTranslator();
  // ignore: unused_field
  bool _hasCallSupport = false;
  String? userLang;

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
    'category': 'no',
  };

  @override
  void initState() {
    super.initState();
    _notificationService.requestNotificationPermission();
    _getSessions();
    launcher.canLaunch('tel://123').then((bool result) {
      if (!mounted) {
        return;
      }
      setState(() {
        _hasCallSupport = result;
      });
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      translate();
    });
    // Future.delayed(const Duration(seconds: 1), () {
    //   if (mounted) {
    //     setState(() {
    //       _isLoading = false;
    //     });
    //   }
    // });
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

  Future<void> _makePhoneCall(String url) async {
    final UrlLauncherPlatform launcher = UrlLauncherPlatform.instance;
    if (!await launcher.launchUrl(url, const LaunchOptions())) {
      throw Exception('Could not launch $url');
    }
  }

  late List getlangs = ['Property View'];
  void translate() async {
    try {
      List languages = ['Property View'];
      if (userLang.toString() == 'punjabi') {
        var futures = languages.map((item) {
          return translator.translate(item.toString(), from: 'en', to: 'pa');
        }).toList();

        // 2. Wait for all of them to complete in parallel
        List<Translation> results = await Future.wait(futures);
        // for (var translation in results) {
        //   print(translation.text); // 'pa' translation
        // }
        setState(() {
          if (mounted) {
            getlangs = results;
          }
        });
      } else {
        setState(() {
          if (mounted) {
            getlangs = getlangs;
          }
        });
      }
    } catch (e) {
      debugPrint('$e');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _notificationService.init(context);
    const primaryColor = Color(0xFF26107B);

    return Scaffold(
      // backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: Text(
          getlangs[0].toString(),
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. इमेज गैलरी सेक्शन ---
              Row(
                children: [
                  // बाएँ तरफ की बड़ी इमेज
                  Expanded(
                    flex: 2,
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (BuildContext context) => PageViews(
                                  title: 'net',
                                  img:
                                      SessionUrl().imgProfile +
                                      widget.propertyGet['img1'],
                                ),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              imageUrl:
                                  SessionUrl().imgProfile +
                                  widget.propertyGet['img1'],
                              placeholder: (context, url) => SizedBox(
                                height: 50,
                                width: 50,
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.image, size: 32),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              // ignore: deprecated_member_use
                              color: primaryColor.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "${widget.propertyGet['prop_type']}  for  ${widget.propertyGet['status']}",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // दाएँ तरफ की छोटी इमेजेस
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (BuildContext context) => PageViews(
                                  title: 'net',
                                  img:
                                      SessionUrl().imgProfile +
                                      widget.propertyGet['img1'],
                                ),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              height: 62,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              imageUrl:
                                  SessionUrl().imgProfile +
                                  widget.propertyGet['img2'],
                              placeholder: (context, url) =>
                                  CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.image, size: 32),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (BuildContext context) => PageViews(
                                  title: 'net',
                                  img:
                                      SessionUrl().imgProfile +
                                      widget.propertyGet['img3'],
                                ),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              height: 62,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              imageUrl:
                                  SessionUrl().imgProfile +
                                  widget.propertyGet['img3'],
                              placeholder: (context, url) =>
                                  CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.image, size: 32),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        // +6 वाली इमेज
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (BuildContext context) => PageViews(
                                  title: 'net',
                                  img:
                                      SessionUrl().imgProfile +
                                      widget.propertyGet['img4'],
                                ),
                              ),
                            );
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              height: 62,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              imageUrl:
                                  SessionUrl().imgProfile +
                                  widget.propertyGet['img4'],
                              placeholder: (context, url) =>
                                  CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.image, size: 32),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // --- 2. कांटेक्ट ओनर कार्ड ---
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.phone_android,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Contact Owner',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '98036 52267',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    ElevatedButton.icon(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        side: const BorderSide(color: Colors.white38),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                      ),
                      icon: const Icon(
                        Icons.chat_bubble_outline,
                        color: Colors.white,
                        size: 16,
                      ),
                      label: const Text(
                        'Chat Now',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // --- 3. प्रॉपर्टी डिटेल्स लिस्ट (सफ़ेद कार्ड) ---
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      Icons.local_offer_outlined,
                      'Type',
                      "${widget.propertyGet['prop_type']}  for  ${widget.propertyGet['status']}",
                      primaryColor,
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _buildDetailRow(
                      Icons.location_on_outlined,
                      'Full Address',
                      widget.propertyGet['address'],
                      primaryColor,
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _buildDetailRow(
                      Icons.location_city_outlined,
                      'City',
                      "${widget.propertyGet['city']} - ${widget.propertyGet['pincode']}",
                      primaryColor,
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    _buildDetailRow(
                      Icons.map_outlined,
                      'State',
                      widget.propertyGet['state'],
                      primaryColor,
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),

                    // प्राइस रो (विशेष डिज़ाइन के साथ)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.currency_rupee,
                            color: primaryColor,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Price',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 15,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            widget.propertyGet['price'],
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Negotiable',
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // --- 4. फीचर्स/बैज सेक्शन ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildBadgeItem(Icons.map_outlined, 'Good Location'),
                  _buildBadgeItem(Icons.list_alt_sharp, 'Clear Title'),
                  _buildBadgeItem(Icons.verified_user_outlined, 'Safe Deal'),
                  _buildBadgeItem(Icons.handshake_outlined, 'Direct Owner'),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const EdgeInsets.only(bottom: 10.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _makePhoneCall('+919803652267'),
                style: OutlinedButton.styleFrom(
                  // ignore: deprecated_member_use
                  side: BorderSide(color: primaryColor.withOpacity(0.5)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.phone, color: primaryColor),
                label: const Text(
                  'Call Now',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.send, color: Colors.white),
                label: const Text(
                  'Send Message',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String title,
    String value,
    Color iconColor,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(width: 7),
          Text(
            title,
            style: const TextStyle(color: Colors.black54, fontSize: 11),
          ),
          const Spacer(),
          AutoSizeText(
            value,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeItem(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF3F51B5), size: 22),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
