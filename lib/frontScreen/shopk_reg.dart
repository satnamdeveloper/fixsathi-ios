import 'dart:async';
import 'dart:convert' as convert;
import 'dart:io';

import 'package:fixsathi/classPack/notification_service.dart';
import 'package:fixsathi/classPack/sessions_file.dart';
import 'package:fixsathi/clients/dashboard_user.dart';
import 'package:fixsathi/frontScreen/language_terms.dart';
import 'package:fixsathi/widgets/button_widget.dart';
import 'package:fixsathi/widgets/component.dart';
import 'package:fixsathi/widgets/extra_widgets.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' hide Location;
import 'package:translator/translator.dart';

class AddFirm extends StatefulWidget {
  final String title;
  final Map<String, dynamic> users;
  const AddFirm({super.key, required this.title, required this.users});

  @override
  State<AddFirm> createState() => _AddFirmState();
}

class _AddFirmState extends State<AddFirm> {
  final GlobalKey<FormState> _formKeyL = GlobalKey<FormState>();
  final TextEditingController _client = TextEditingController();
  final TextEditingController _adhaarcard = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _pinCode = TextEditingController();
  final TextEditingController _pancard = TextEditingController();
  final TextEditingController _shop = TextEditingController();
  final TextEditingController _gstno = TextEditingController();
  final TextEditingController _runing = TextEditingController();

  Timer? _timer;
  String? userLang, appids, other2, imag1, imag2;

  NotificationService notificationService = NotificationService();
  final translator = GoogleTranslator();
  File? _selectedFile;
  String selectedFil = '0';
  String? serviceValue;
  String genderVal = 'Male';
  Location location = Location();
  final ValueNotifier<Placemark?> selectedAddressNotifier =
      ValueNotifier<Placemark?>(null);
  final ValueNotifier<bool> isLocationLoading = ValueNotifier<bool>(false);

  static const Color _primaryBlue = Color(0xFF3333CC);
  static const Color _lightBlue = Color(0xFFEEEEFF);
  // static const Color _borderColor = Color(0xFFDDDDEE);
  static const Color _iconColor = Color(0xFF6666CC);
  File? _selectedFile1, _selectedFile2;
  int? _selectedLang;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 10), () {
      if (!mounted) return;
      requestLocationPermission();
    });
    _initData();
  }

  Future<void> _initData() async {
    await requestLocationPermission();
    notificationService.getDeviceToken().then((onValue) {
      if (!mounted) return;
      setState(() {
        appids = onValue;
      });
    });

    translate();
  }

  List getlangs = [
    'Registration as a Partner',
    'Your Name *',
    'Other Contact Number',
    'Address',
    'Adhaar Card Number',
    'Pan Card Number',
    'Submit',
    'G.S.T. Number',
    'Select your profession',
    'Your experience',
    'If is shop, fill in the name, otherwise skip.',
    'Bank Account No',
    'Bank Name',
    'I.F.S.C.Code',
    'Bank Person Name',
    'Kindly Check our Term & Conditions',
    'Add Selfi',
    'NOTE: Required the location so first choose permission then Registration',
    'Adhaar Card Front Side',
    'Adhaar Card Back Side',
  ];
  void translate() async {
    try {
      List languages = [
        'Registration as a Partner',
        'Your Name *',
        'Other Contact Number',
        'Address',
        'Adhaar Card Number',
        'Pan Card Number',
        'Submit',
        'G.S.T. Number',
        'Select your profession',
        'Your experience',
        'If is shop, fill in the name, otherwise skip.',
        'Bank Account No',
        'Bank Name',
        'I.F.S.C.Code',
        'Bank Person Name',
        'Kindly Check our Term & Conditions',
        'Add Selfi',
        'NOTE: Required the location so first choose permission then Registration',
        'Adhaar Card Front Side',
        'Adhaar Card Back Side',
      ];
      if (widget.users['lang'] == 'punjabi') {
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
          getlangs = languages;
        });
      }
    } catch (e) {
      debugPrint('$e');
    }
  }

  final ImagePicker _picker = ImagePicker();
  Future<XFile?> takePicture() async {
    final XFile? paths = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 70,
    );
    if (paths != null && mounted) {
      setState(() {
        _selectedFile = File(paths.path);
      });
    }
    return null;
  }

  Future<LocationData?> requestLocationPermission() async {
    try {
      isLocationLoading.value = true; // Loading shuru
      bool serviceEnabled;
      PermissionStatus permissionGranted;

      serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          isLocationLoading.value = false;
          return null;
        }
      }

      permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          isLocationLoading.value = false;
          return null;
        }
      }

      LocationData locationData = await location.getLocation();
      // Latitude aur Longitude ko safe check ke sath pass karein
      if (locationData.latitude != null && locationData.longitude != null) {
        await getAddressFromLatLng(
          locationData.latitude!,
          locationData.longitude!,
        );
      }

      isLocationLoading.value = false; // Loading khatam
      return locationData;
    } catch (e) {
      isLocationLoading.value = false;
      debugPrint('Error $e');
      return null;
    }
  }

  Future<void> getAddressFromLatLng(double lat, double lng) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        // FIX 1: Index 1 se crash ho sakta tha, isliye safe format me index 0 (first) kiya
        Placemark place = placemarks.first;
        selectedAddressNotifier.value = place;

        // Form field me address automatically fill karne ke liye:
        _address.text =
            '${place.name}, ${place.thoroughfare}, ${place.locality}-${place.postalCode}, ${place.administrativeArea}, ${place.country}';
        _pinCode.text = place.postalCode ?? '';
      }
    } catch (e) {
      debugPrint('Geocoding error: $e');
    }
  }

  // PlatformFile? _pickedFile;
  Future<void> getPickFile1() async {
    final XFile? result = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 900,
      maxHeight: 900,
      imageQuality: 70,
    );
    if (result != null && mounted) {
      setState(() {
        _selectedFile1 = File(result.path);
        imag1 = '1';
        // _pickedFile = result.files.first;
      });
    }
  }

  Future<void> getPickFile2() async {
    final XFile? result2 = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 900,
      maxHeight: 900,
      imageQuality: 70,
    );
    if (result2 != null && mounted) {
      setState(() {
        _selectedFile2 = File(result2.path);
        imag2 = '1';
        // _pickedFile = result.files.first;
      });
    }
  }

  Future<void> postFirmData(
    dynamic states,
    dynamic country,
    dynamic locality,
    dynamic pincode,
  ) async {
    // 1. Form Validation check karein
    if (!_formKeyL.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kindly fill all required fields')),
      );
      return;
    }

    // 2. iOS Core Check: Check karein ki zaroori documents select hain ya nahi
    if (_selectedFile == null ||
        _selectedFile1 == null ||
        _selectedFile2 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload all required photos & documents'),
        ),
      );
      return;
    }

    // Loading shuru karein (Aap apna custom loading widget bhi dikha sakte hain)
    // showDialog(
    //   context: context,
    //   barrierDismissible: false,
    //   builder: (context) => const Center(child: CircularProgressIndicator()),
    // );
    try {
      final uri = Uri.parse("${SessionUrl().httpUrl}/home/postFirmDatas");
      var request = http.MultipartRequest('POST', uri);
      request.fields.addAll({
        'mobileno': widget.users['phoneno'],
        'client_name': _client.text,
        'adhaarcard': _adhaarcard.text,
        'pincode': pincode.toString(),
        'states': states.toString(),
        'city': locality.toString(),
        'address': _address.text,
        'appid': appids.toString(),
        'firm_name': _shop.text,
        'provider': serviceValue.toString(),
        'pancard': _pancard.text,
        'runing': _selectedLang.toString(),
        'gender': genderVal.toString(),
      });

      request.files.add(
        await http.MultipartFile.fromPath('photo', _selectedFile!.path),
      );
      request.files.add(
        await http.MultipartFile.fromPath('photo2', _selectedFile1!.path),
      );
      request.files.add(
        await http.MultipartFile.fromPath('photo3', _selectedFile2!.path),
      );
      // request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      if (!mounted) return;
      if (response.statusCode == 200) {
        var getres = convert.jsonDecode(await response.stream.bytesToString());
        // print(getres);
        if (getres['status'] == 'success') {
          SessionUrl().removeUserData();
          Map<String, dynamic>? userall = {
            'userid': getres['data']['id'].toString(),
            'mobileno': widget.users['phoneno'],
            'language': getres['data']['language'].toString(),
            'category': getres['data']['category'].toString(),
            'client_name': _client.text,
            'user_img': getres['data']['user_img'].toString(),
            'states': states.toString(),
            'country': country.toString(),
            'city': locality.toString(),
            'pincode': pincode.toString(),
            'address': _address.text,
            'service': getres['data']['services'].toString(),
            'gender': getres['data']['gender'].toString(),
            'is_active': getres['data']['is_active'].toString(),
          };
          final userstring = convert.jsonEncode(userall);
          await SessionUrl().setUsername(userstring);
          // ignore: use_build_context_synchronously
          Components().alertPopUp(context);
          Future.delayed(const Duration(seconds: 2), () {
            if (!mounted) return;
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (BuildContext context) => MainDashboard(),
              ),
            );
          });
        } else if (getres['status'] == 'errors') {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Required Adhaar photo front & backside also?'),
              backgroundColor: Color.fromARGB(255, 218, 5, 5),
            ),
          );
        } else if (getres['status'] == 'error') {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Required Location?'),
              backgroundColor: Color.fromARGB(255, 218, 5, 5),
            ),
          );
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Enable the location then try again!'),
              backgroundColor: Color.fromARGB(255, 218, 5, 5),
            ),
          );
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Required all input fields !'),
            backgroundColor: Color.fromARGB(255, 218, 5, 5),
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
    _client.dispose();
    _address.dispose();
    _adhaarcard.dispose();
    _pancard.dispose();
    _gstno.dispose();
    _shop.dispose();
    _runing.dispose();
    _pinCode.dispose();
    super.dispose();
  }

  bool isChecked = false;
  // int? _selectedValue = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.indigo.shade800,
        title: Text(getlangs[0].toString()),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),

            child: Form(
              key: _formKeyL,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Center(
                    child: SizedBox(
                      width: 110,
                      height: 110,
                      child: Stack(
                        fit: StackFit.loose,
                        children: [
                          Container(
                            padding: EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 3.0,
                                color: Colors.indigo,
                              ),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: SizedBox(
                              width: 90.0,
                              height: 90.0,
                              child: CircleAvatar(
                                backgroundColor: Colors.blue,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (_selectedFile != null)
                                      SizedBox(
                                        width: 82.0,
                                        height: 82.0,
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadiusGeometry.circular(50),
                                          child: Image.file(
                                            _selectedFile!,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                    if (_selectedFile == null)
                                      Icon(
                                        Icons.person,
                                        size: 60,
                                        color: Colors.white,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: AlignmentGeometry.bottomRight,
                            child: InkWell(
                              onTap: () async {
                                takePicture();
                              },
                              child: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(width: 1.0),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  child: Icon(
                                    Icons.camera_alt,
                                    size: 25,
                                    color: Colors.indigo,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 15.0),

                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 6,
                    ),
                    child: TextFormField(
                      controller: _client,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 1.0,
                          horizontal: 5.0,
                        ),
                        labelText: getlangs[1].toString(),
                        fillColor: Colors.white,
                      ),
                      onTap: () async {},
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter remark..';
                        }
                        return null;
                      },
                    ),
                  ),

                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: dropdown(
                      genderVal,
                      getlangs[3].toString(),
                      (value) {
                        setState(() {
                          genderVal = value;
                        });
                      },
                      ['Male', 'Female'].map<DropdownMenuEntry<String>>((
                        value,
                      ) {
                        return DropdownMenuEntry<String>(
                          value: value.toString(),
                          label: value.toString(),
                        );
                      }).toList(), // The list of menu items
                    ),
                  ),
                  ValueListenableBuilder<Placemark?>(
                    valueListenable: selectedAddressNotifier,
                    builder: (context, placemark, child) {
                      if (placemark == null) {
                        return Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 20.0),
                              ElevatedButton(
                                onPressed: () {
                                  requestLocationPermission();
                                },
                                child: Text(
                                  (isLocationLoading.value == false)
                                      ? 'Fetch the Location?'
                                      : 'Fetch once again',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return Column(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 6,
                            ),
                            child: TextFormField(
                              controller: _address,
                              maxLines: 2,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 7.0,
                                  horizontal: 5.0,
                                ),
                                labelText: getlangs[3].toString(),
                                fillColor: Colors.white,
                              ),
                              onTap: () async {},
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Enter your address..';
                                }
                                return null;
                              },
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 6,
                            ),
                            child: TextFormField(
                              controller: _pinCode,
                              readOnly: true,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 7.0,
                                  horizontal: 5.0,
                                ),
                                labelText: 'Pin Code',
                                fillColor: Colors.white,
                              ),
                              onTap: () async {},
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Enter your pincode..';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  Container(
                    margin: const EdgeInsets.only(
                      left: 15.0,
                      right: 15.0,
                      top: 5.0,
                    ),
                    child: TextFormField(
                      controller: _adhaarcard,
                      keyboardType: TextInputType.number,
                      maxLength: 12,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 7.0,
                          horizontal: 5.0,
                        ),
                        labelText: getlangs[4].toString(),
                        fillColor: Colors.white,
                      ),
                      onTap: () async {},
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required Adhaar Card';
                        }
                        return null;
                      },
                    ),
                  ),

                  Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: 10.0,
                      vertical: 4.0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () {
                                getPickFile1();
                              },
                              child: Column(
                                children: [
                                  Container(
                                    height: 72,
                                    decoration: BoxDecoration(
                                      // ignore: deprecated_member_use
                                      color: _lightBlue.withOpacity(0.5),
                                      border: Border.all(
                                        // ignore: deprecated_member_use
                                        color: _primaryBlue.withOpacity(0.35),
                                        width: 1.5,
                                        // Dashed border via CustomPainter if needed; using solid for simplicity
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: (_selectedFile1 != null)
                                        ? SizedBox(
                                            width: 82.0,
                                            height: 82.0,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadiusGeometry.circular(
                                                    5,
                                                  ),
                                              child: Image.file(
                                                _selectedFile1!,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          )
                                        : Center(
                                            child: Stack(
                                              clipBehavior: Clip.none,
                                              children: [
                                                Icon(
                                                  Icons.camera_alt_outlined,
                                                  color: _iconColor,
                                                  size: 32,
                                                ),
                                                Positioned(
                                                  right: -6,
                                                  bottom: -4,
                                                  child: Container(
                                                    width: 16,
                                                    height: 16,
                                                    decoration:
                                                        const BoxDecoration(
                                                          color: _primaryBlue,
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                    child: const Icon(
                                                      Icons.add,
                                                      color: Colors.white,
                                                      size: 12,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    '${getlangs[18]} 1',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () {
                                getPickFile2();
                              },
                              child: Column(
                                children: [
                                  Container(
                                    height: 72,
                                    decoration: BoxDecoration(
                                      // ignore: deprecated_member_use
                                      color: _lightBlue.withOpacity(0.5),
                                      border: Border.all(
                                        // ignore: deprecated_member_use
                                        color: _primaryBlue.withOpacity(0.35),
                                        width: 1.5,
                                        // Dashed border via CustomPainter if needed; using solid for simplicity
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: (_selectedFile2 != null)
                                        ? SizedBox(
                                            width: 82.0,
                                            height: 82.0,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadiusGeometry.circular(
                                                    5,
                                                  ),
                                              child: Image.file(
                                                _selectedFile2!,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          )
                                        : Center(
                                            child: Stack(
                                              clipBehavior: Clip.none,
                                              children: [
                                                Icon(
                                                  Icons.camera_alt_outlined,
                                                  color: _iconColor,
                                                  size: 32,
                                                ),
                                                Positioned(
                                                  right: -6,
                                                  bottom: -4,
                                                  child: Container(
                                                    width: 16,
                                                    height: 16,
                                                    decoration:
                                                        const BoxDecoration(
                                                          color: _primaryBlue,
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                    child: const Icon(
                                                      Icons.add,
                                                      color: Colors.white,
                                                      size: 12,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    '${getlangs[19]} 2',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
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

                  Container(
                    margin: const EdgeInsets.only(
                      left: 15.0,
                      right: 15.0,
                      top: 5.0,
                    ),
                    child: TextFormField(
                      controller: _pancard,
                      maxLength: 10,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 7.0,
                          horizontal: 5.0,
                        ),
                        labelText: getlangs[5].toString(),
                        fillColor: Colors.white,
                      ),
                      onTap: () async {},
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required Pan Card No.?';
                        }
                        return null;
                      },
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 9),
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: dropdown(
                      serviceValue,
                      getlangs[8].toString(),
                      (value) {
                        setState(() {
                          serviceValue = value;
                        });
                      },
                      [
                        'Electric',
                        'Cleaner',
                        'Furniture',
                        'AC-Technician',
                        'Aluminium',
                        'Laundry',
                        'Plumber',
                        'Painter',
                        'Glass',
                        'Car-Washing',
                        'Beauty-Salon',
                        'Barber-Haircut',
                        'PVC',
                        'Computer-Hardware',
                        'Security-Manpower',
                        'Care-Taker',
                        'Mason',
                      ].map((String value) {
                        return DropdownMenuEntry<String>(
                          value: value,
                          label: value,
                        );
                      }).toList(), // The list of menu items
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 18.0),
                    child: RadioGroup<int>(
                      groupValue: _selectedLang,
                      onChanged: (int? value) {
                        setState(() {
                          _selectedLang = value;
                        });
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsetsGeometry.symmetric(
                              vertical: 5.0,
                            ),
                            child: Text(
                              getlangs[9].toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 16.0,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ),
                          Row(
                            children: [
                              Row(
                                children: [Radio<int>(value: 1), Text('Yes')],
                              ),
                              Row(children: [Radio<int>(value: 2), Text('No')]),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // if (_selectedValue == 1)
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 6,
                    ),
                    child: TextFormField(
                      controller: _shop,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 1.0,
                          horizontal: 5.0,
                        ),
                        labelText: getlangs[10].toString(),
                        fillColor: Colors.white,
                      ),
                      onTap: () async {},
                    ),
                  ),

                  CheckboxListTile(
                    // Using CheckboxListTile for better usability
                    title: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext context) =>
                                TermCond(title: 'partner', users: widget.users),
                          ),
                        );
                      },
                      child: Text(
                        getlangs[15].toString(),
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    value:
                        isChecked, // Bind the state variable to the value property
                    onChanged: (bool? newValue) {
                      // The onChanged callback receives the new value
                      setState(() {
                        // Update the state and rebuild the UI
                        isChecked = newValue!;
                      });
                    },
                    controlAffinity: ListTileControlAffinity
                        .leading, // Position checkbox at the start
                  ),
                  SizedBox(height: 5.0),
                  if (isChecked == true)
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 15, vertical: 3),
                      child: fullButton(
                        context,
                        getlangs[6].toString(),
                        () async {
                          if (_formKeyL.currentState!.validate()) {
                            postFirmData(
                              selectedAddressNotifier.value?.administrativeArea,
                              selectedAddressNotifier.value?.country,
                              selectedAddressNotifier.value?.locality,
                              selectedAddressNotifier.value?.postalCode,
                            );
                          }
                        },
                        Colors.white,
                        Colors.indigo,
                      ),
                    ),
                  SizedBox(height: 150.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
