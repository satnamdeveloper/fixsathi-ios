import 'dart:async';
import 'dart:convert' as convert;
import 'dart:io';
import 'package:fixsathi/classPack/notification_service.dart';
import 'package:fixsathi/classPack/sessions_file.dart';
import 'package:fixsathi/clients/dashboard_user.dart';
import 'package:fixsathi/widgets/button_widget.dart';
import 'package:fixsathi/widgets/component.dart';
import 'package:fixsathi/widgets/extra_widgets.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' hide Location;
import 'package:translator/translator.dart';

class AddClient extends StatefulWidget {
  final String title;
  final Map<String, dynamic> users;
  const AddClient({super.key, required this.title, required this.users});

  @override
  State<AddClient> createState() => _AddClientState();
}

class _AddClientState extends State<AddClient> {
  NotificationService notificationService = NotificationService();
  File? _selectedFile;
  String selectedFil = '0';
  String genderVal = 'Male';
  final ValueNotifier<Placemark?> selectedAddressNotifier =
      ValueNotifier<Placemark?>(null);
  final ValueNotifier<bool> isLocationLoading = ValueNotifier<bool>(false);

  final translator = GoogleTranslator();
  final GlobalKey<FormState> _formKeyL = GlobalKey<FormState>();
  final TextEditingController _client = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _pinCode = TextEditingController();

  Timer? _timer;
  String? userLang, appids, other2;
  Location location = Location();

  @override
  void initState() {
    super.initState();
    _initData();
    Future.delayed(const Duration(seconds: 10), () {
      if (!mounted) return;
      requestLocationPermission();
    });
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
    'Customer Registration',
    'Your Name *',
    'Other Contact Number',
    'Select District',
    'Select City/Village',
    'Address',
    'Pincode',
    'Add Selfi',
    'Submit',
    'Male',
    'Female',
    'NOTE: Required the location so first choose permission then Registration',
  ];
  void translate() async {
    try {
      List languages = [
        'Customer Registration',
        'Your Name *',
        'Other Contact Number',
        'Select District',
        'Select City/Village',
        'Fill Your Full Address',
        'Pincode',
        'Add Selfi',
        'Submit',
        'Male',
        'Female',
        'NOTE: Required the location so first choose permission then Registration',
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
  final ImagePicker _picker = ImagePicker();

  Future<XFile?> pickImageFromCamera() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 70,
    );
    if (image != null && mounted) {
      setState(() {
        _selectedFile = File(image.path);
        selectedFil = '1';
      });
    }
    return null;
  }

  Future<void> postUserData(
    dynamic states,
    dynamic country,
    dynamic locality,
    dynamic pincode,
  ) async {
    if (!_formKeyL.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kindly fill all required fields')),
      );
      return;
    }
    // showDialog(
    //   context: context,
    //   barrierDismissible: false,
    //   builder: (context) => const Center(child: CircularProgressIndicator()),
    // );
    try {
      // var headers = {'Authorization': 'Bearer pass_key_satnam@malhotra12345678'};
      final uri = Uri.parse("${SessionUrl().httpUrl}/home/postClientData");
      final request = http.MultipartRequest('POST', uri);
      request.fields.addAll({
        'mobileno': widget.users['phoneno'],
        'language': widget.users['lang'],
        'category': widget.users['category'],
        'client_name': _client.text,
        'states': states.toString(),
        'country': country.toString(),
        'city': locality.toString(),
        'pincode': pincode.toString(),
        'address': _address.text,
        'gender': genderVal.toString(),
      });
      if (_selectedFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('photo', _selectedFile!.path),
        );
      }
      // request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      if (!mounted) return;
      if (response.statusCode == 200) {
        var getres = convert.jsonDecode(await response.stream.bytesToString());
        if (getres['status'] == 'success') {
          SessionUrl().removeUserData();
          Map<String, dynamic>? userall = {
            'userid': getres['data']['id'].toString(),
            'mobileno': widget.users['phoneno'],
            'language': getres['data']['language'].toString(),
            'category': getres['data']['category'].toString(),
            'client_name': _client.text,
            'states': states.toString(),
            'user_img': getres['data']['user_img'].toString(),
            'city': locality.toString(),
            'pincode': pincode.toString(),
            'address': _address.text,
            'appid': appids.toString(),
            'service': getres['data']['services'].toString(),
            'gender': getres['data']['gender'].toString(),
            'is_active': getres['data']['is_active'].toString(),
          };
          var userstring = convert.jsonEncode(userall);
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
        } else if (getres['status'] == 'error') {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Required the Location. Kindly enable your location.',
              ),
              backgroundColor: Color.fromARGB(255, 205, 6, 6),
            ),
          );
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Required the Location. Kindly enable your location.',
              ),
              backgroundColor: Color.fromARGB(255, 205, 6, 6),
            ),
          );
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: Weak internet?'),
            backgroundColor: Color.fromARGB(255, 205, 6, 6),
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
    _pinCode.dispose();
    super.dispose();
  }

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
                                pickImageFromCamera();
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
                  SizedBox(height: 10.0),

                  SizedBox(height: 10.0),
                  // if (_address.text == '')
                  //   Center(
                  //     child: Container(
                  //       padding: EdgeInsets.symmetric(
                  //         horizontal: 5,
                  //         vertical: 5,
                  //       ),
                  //       margin: EdgeInsets.symmetric(
                  //         horizontal: 15,
                  //         vertical: 7,
                  //       ),

                  //       child: AutoSizeText(
                  //         getlangs[11].toString(),
                  //         style: TextStyle(
                  //           fontWeight: FontWeight.w500,
                  //           color: Colors.red,
                  //         ),
                  //         maxLines: 2,
                  //         minFontSize: 15,
                  //         maxFontSize: 18,
                  //       ),
                  //     ),
                  //   ),
                  SizedBox(height: 10.0),
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
                          return 'Enter you name';
                        }
                        return null;
                      },
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
                                labelText: getlangs[5].toString(),
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
                    margin: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 4,
                    ),
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
                  SizedBox(height: 20.0),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    child: fullButton(
                      context,
                      getlangs[8].toString(),
                      () async {
                        if (_formKeyL.currentState!.validate()) {
                          postUserData(
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
                  SizedBox(height: 50.0),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
