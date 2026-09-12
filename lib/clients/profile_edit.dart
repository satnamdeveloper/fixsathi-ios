import 'dart:async';
import 'dart:convert' as convert;
import 'dart:io';
import 'package:fixsathi/classPack/notification_service.dart';
import 'package:fixsathi/classPack/sessions_file.dart';
import 'package:fixsathi/clients/dashboard_user.dart';
import 'package:fixsathi/widgets/button_widget.dart';
import 'package:fixsathi/widgets/component.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:translator/translator.dart';
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' hide Location;

class EditClient extends StatefulWidget {
  final String title;
  final Map<String, dynamic> users;
  const EditClient({super.key, required this.title, required this.users});

  @override
  State<EditClient> createState() => _EditClientState();
}

class _EditClientState extends State<EditClient> {
  NotificationService notificationService = NotificationService();
  File? _selectedFile;
  String selectedFil = '0';
  final translator = GoogleTranslator();
  Location location = Location();

  final ValueNotifier<Placemark?> selectedAddressNotifier =
      ValueNotifier<Placemark?>(null);
  final ValueNotifier<bool> isLocationLoading = ValueNotifier<bool>(false);

  final GlobalKey<FormState> _formKeyL = GlobalKey<FormState>();
  final TextEditingController _client = TextEditingController();
  final TextEditingController _contact = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _pinCode = TextEditingController();
  final TextEditingController _service = TextEditingController();
  final TextEditingController _bank = TextEditingController();
  final TextEditingController _ifsc = TextEditingController();
  final TextEditingController _bname = TextEditingController();
  final TextEditingController _bankPerson = TextEditingController();

  Timer? _timer;
  String photoselect = '0';
  Map<String, dynamic> getuserdata = {};
  String? appids;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 10), () {
      if (!mounted) return;
      _initData();
    });
    _initData();
  }

  Future<void> _initData() async {
    await requestLocationPermission();
    await userList();
    notificationService.getDeviceToken().then((onValue) {
      if (mounted) {
        setState(() {
          appids = onValue;
        });
      }
    });

    translate();
  }

  List getlangs = [
    'Customer Modification',
    'Add Selfi',
    'Your Name *',
    'Address?',
    'Bank Account No',
    'Bank Name',
    'I.F.S.C.Code',
    'Bank Person Name',
    'Update',
    'Contact No:',
    'Home',
    'Service',
  ];
  void translate() async {
    try {
      List languages = [
        'Customer Modification',
        'Add Selfi',
        'Your Name *',
        'Address',
        'Bank Account No',
        'Bank Name',
        'I.F.S.C.Code',
        'Bank Person Name',
        'Update',
        'Contact Number',
        'Back',
        'Service',
      ];
      if (widget.users['language'] == 'punjabi') {
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
          getlangs = getlangs;
        });
      }
    } catch (e) {
      debugPrint('$e');
    }
  }

  Future<void> userList() async {
    try {
      var url = Uri.https(
        SessionUrl().baseUrl,
        '/home/userList/pass_key@satnam9041110310/${widget.users['users']}',
        // {'q': '{http}'},
      );
      final response = await http.get(url);
      if (!mounted) return;
      if (response.statusCode == 200) {
        final getlist = convert.jsonDecode(response.body);

        setState(() {
          getuserdata = getlist;
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  final ImagePicker _picker = ImagePicker();

  Future<XFile?> pickImageFromCamera() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 75,
    );
    if (image != null && mounted) {
      setState(() {
        _selectedFile = File(image.path);
        photoselect = '1';
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

      // LocationData locationData = await location.getLocation();
      LocationData locationData = await location.getLocation().timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw TimeoutException('Location request timed out'),
      );
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
      final uri = Uri.parse("${SessionUrl().httpUrl}/home/editClientData");
      var request = http.MultipartRequest('POST', uri);
      request.fields.addAll({
        'mobileno': widget.users['users'],
        'state': states.toString(),
        'pincode': pincode.toString(),
        'city': locality.toString(),
        'client_name': _client.text,
        'bank_acc': _bank.text,
        'bank_name': _bname.text,
        'bank_ifsc': _ifsc.text,
        'bank_person': _bankPerson.text,
        'address': _address.text,
      });
      if (photoselect == '1') {
        request.files.add(
          await http.MultipartFile.fromPath('photo', _selectedFile!.path),
        );
      }
      // request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var getres = convert.jsonDecode(await response.stream.bytesToString());
        if (getres['status'] == 'success') {
          SessionUrl().removeUserData();
          Map<String, dynamic>? userall = {
            'userid': getres['data']['id'].toString(),
            'mobileno': widget.users['users'],
            'category': widget.users['category'],
            'client_name': _client.text,
            'user_img': getres['data']['user_img'].toString(),
            'address': _address.text,
            'pincode': pincode.toString(),
            'city': locality.toString(),
            'states': states.toString(),
            'language': getres['data']['language'].toString(),
            'appid': appids.toString(),
            'service': getres['data']['services'].toString(),
            'gender': getres['data']['gender'].toString(),
            'is_active': getres['data']['is_active'].toString(),
          };
          var userstring = convert.jsonEncode(userall);
          SessionUrl().setUsername(userstring);
          // ignore: use_build_context_synchronously
          Components().alertPopUp(context);
          // SessionUrl().setUsername(getres['data']);
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              // ignore: use_build_context_synchronously
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (BuildContext context) => MainDashboard(),
                ),
              );
            }
          });
        } else {
          if (mounted) {
            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Required all input fields !'),
                backgroundColor: Color.fromARGB(255, 243, 25, 25),
              ),
            );
          }
        }
        // setState(() {
        //   getress = getres;
        // });
      } else {
        if (mounted) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Weak Internet'),
              backgroundColor: Color.fromARGB(255, 243, 25, 25),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error $e'),
            backgroundColor: Color.fromARGB(255, 243, 25, 25),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _client.dispose();
    _bank.dispose();
    _service.dispose();
    _address.dispose();
    _bankPerson.dispose();
    _ifsc.dispose();
    _bname.dispose();
    _contact.dispose();
    _pinCode.dispose();
    selectedAddressNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // print(distValue);
    _contact.value = _contact.value.copyWith(
      text: getuserdata['contactno'] ?? '',
    );
    _client.value = _client.value.copyWith(
      text: getuserdata['firstname'] ?? '',
    );
    _service.value = _service.value.copyWith(
      text: getuserdata['services'] ?? '',
    );
    _bank.value = _bank.value.copyWith(text: getuserdata['bank_ac'] ?? '');
    _bname.value = _bname.value.copyWith(text: getuserdata['bank_name'] ?? '');
    _ifsc.value = _ifsc.value.copyWith(text: getuserdata['bank_ifsc'] ?? '');
    _bankPerson.value = _bankPerson.value.copyWith(
      text: getuserdata['bank_address'] ?? '',
    );

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
                            child: GestureDetector(
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

                  // if (selectedAddressNotifier.value?.postalCode == null)
                  //   Center(
                  //     child: TextButton(
                  //       onPressed: () {
                  //         requestLocationPermission();
                  //       },
                  //       child: Text(
                  //         'Fetch the Location Now.\n (Double Tap)',
                  //         style: TextStyle(color: Colors.red),
                  //         textAlign: TextAlign.center,
                  //       ),
                  //     ),
                  //   ),
                  // SizedBox(height: 10.0),
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 6,
                    ),
                    child: TextFormField(
                      controller: _contact,
                      decoration: InputDecoration(
                        enabled: false,
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 1.0,
                          horizontal: 5.0,
                        ),
                        labelText: getlangs[9].toString(),
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
                        labelText: getlangs[2].toString(),
                        fillColor: Colors.white,
                      ),
                      onTap: () async {},
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter your name..';
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
                  if ((widget.users['category'] == 'shopkeeper') ||
                      (widget.users['category'] == 'workerPartner'))
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 6,
                      ),
                      child: TextFormField(
                        controller: _service,
                        decoration: InputDecoration(
                          enabled: false,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 1.0,
                            horizontal: 5.0,
                          ),
                          labelText: getlangs[11].toString(),
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                  if ((widget.users['category'] == 'shopkeeper') ||
                      (widget.users['category'] == 'workerPartner'))
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 6,
                      ),
                      child: TextFormField(
                        controller: _bank,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 1.0,
                            horizontal: 5.0,
                          ),
                          labelText: getlangs[4].toString(),
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                  if ((widget.users['category'] == 'shopkeeper') ||
                      (widget.users['category'] == 'workerPartner'))
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 6,
                      ),
                      child: TextFormField(
                        controller: _bname,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 1.0,
                            horizontal: 5.0,
                          ),
                          labelText: getlangs[5].toString(),
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                  if ((widget.users['category'] == 'shopkeeper') ||
                      (widget.users['category'] == 'workerPartner'))
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 6,
                      ),
                      child: TextFormField(
                        controller: _ifsc,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 1.0,
                            horizontal: 5.0,
                          ),
                          labelText: getlangs[6].toString(),
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                  if ((widget.users['category'] == 'shopkeeper') ||
                      (widget.users['category'] == 'workerPartner'))
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 6,
                      ),
                      child: TextFormField(
                        controller: _bankPerson,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 1.0,
                            horizontal: 5.0,
                          ),
                          labelText: getlangs[7].toString(),
                          fillColor: Colors.white,
                        ),
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
