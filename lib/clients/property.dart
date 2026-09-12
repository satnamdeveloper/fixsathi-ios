import 'dart:async';
import 'dart:convert' as convert;
import 'dart:io';
import 'package:fixsathi/classPack/notification_service.dart';
import 'package:fixsathi/classPack/sessions_file.dart';
import 'package:fixsathi/clients/dashboard_user.dart';
import 'package:fixsathi/widgets/component.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' hide Location;
import 'package:translator/translator.dart';

class AddProperty extends StatefulWidget {
  final String title;
  final Map<String, dynamic> users;
  const AddProperty({super.key, required this.title, required this.users});

  @override
  State<AddProperty> createState() => _AddPropertyState();
}

class _AddPropertyState extends State<AddProperty> {
  static const Color _primaryBlue = Color(0xFF3333CC);
  static const Color _lightBlue = Color(0xFFEEEEFF);
  static const Color _borderColor = Color(0xFFDDDDEE);
  static const Color _iconColor = Color(0xFF6666CC);

  String? _propertyType;
  String? _propertyFor;

  final _areaController = TextEditingController();
  final _titleController = TextEditingController();
  final _addressController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contactController = TextEditingController();

  String? userLang, appids, other2;
  String locality = '';
  String street = '';
  String country = '';
  String states = '';
  String pincode = '';
  String others = '';

  NotificationService notificationService = NotificationService();
  final translator = GoogleTranslator();
  // ignore: unused_field
  File? _selectedFile1, _selectedFile2, _selectedFile3, _selectedFile4;
  String imag1 = '0';
  String imag2 = '0';
  String imag3 = '0';
  String imag4 = '0';
  String? types, status;
  Location location = Location();
  // ignore: unused_field
  bool _isLoading = true;

  @override
  void initState() {
    // _timer = Timer.periodic(Duration(seconds: 2), (timer) {
    //   notificationView();
    // });
    super.initState();
    requestLocationPermission();
    notificationService.getDeviceToken().then((onValue) {
      if (mounted) {
        setState(() {
          appids = onValue;
        });
      }
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      translate();
    });
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  List getlangs = [
    'Upload Property Photos',
    ' (Max 4)',
    'Photo',
    'Area (Sq. Ft/Marla/Kanal) *',
    'Property Type',
    'Property Title',
    'Address',
    'Price',
    'Property For *',
    'Description',
    'Contact Number',
    'Post Property',
  ];
  void translate() async {
    try {
      List languages = [
        'Upload Property Photos',
        ' Max (4)',
        'Photo',
        'Area (Sq. Ft/Marla/Kanal) *',
        'Property Type',
        'Property Title',
        'Address',
        'Price',
        'Property For *',
        'Description',
        'Contact Number',
        'Post Property',
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
        if (mounted) {
          setState(() {
            getlangs = results;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            getlangs = languages;
          });
        }
      }
    } catch (e) {
      debugPrint('$e');
    }
  }

  final ImagePicker _picker = ImagePicker();
  // PlatformFile? _pickedFile;
  Future<void> getPickFile() async {
    final XFile? result = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 75,
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
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 75,
    );
    if (result2 != null && mounted) {
      setState(() {
        _selectedFile2 = File(result2.path);
        imag2 = '1';
        // _pickedFile = result.files.first;
      });
    }
  }

  Future<void> getPickFile3() async {
    final XFile? result3 = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 75,
    );
    if (result3 != null && mounted) {
      setState(() {
        _selectedFile3 = File(result3.path);
        imag3 = '1';
        // _pickedFile = result.files.first;
      });
    }
  }

  Future<void> getPickFile4() async {
    final XFile? result4 = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 75,
    );
    if (result4 != null && mounted) {
      setState(() {
        _selectedFile4 = File(result4.path);
        imag4 = '1';
        // _pickedFile = result.files.first;
      });
    }
  }

  // Future<XFile?> takePicture() async {
  //   final XFile? paths = await _picker.pickImage(source: ImageSource.camera);
  //   setState(() {
  //     _selectedFile = File(paths!.path);
  //   });
  //   return null;
  // }

  Future<LocationData?> requestLocationPermission() async {
    try {
      bool serviceEnabled;
      PermissionStatus permissionGranted;

      // Check if location services are enabled
      serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          return null; // Services still not enabled
        }
      }

      // Check location permission status
      permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        // Request permission
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          return null; // Permission denied
        }
      }

      // Permission granted and service enabled, now get location
      LocationData locationData = await location.getLocation();
      getAddressFromLatLng([locationData.latitude, locationData.longitude]);
      return locationData;
    } catch (e) {
      debugPrint('Error $e');
      return null;
    }

    // EasyLoading.showToast(
    //   "Location: ${locationData.latitude}, ${locationData.longitude}",
    // );
  }

  Future<void> getAddressFromLatLng(List<dynamic> lat) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat[0], lat[1]);
    Placemark place = placemarks[0];
    if (mounted) {
      setState(() {
        street = place.street.toString();
        locality = place.locality.toString();
        country = place.country.toString();
        states = place.administrativeArea.toString();
        pincode = place.postalCode.toString();
        others = place.thoroughfare.toString();
        other2 = place.subAdministrativeArea;
      });
    }
    // return "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
  }

  Future<void> postPropertyData() async {
    if (_selectedFile1 == null || _selectedFile2 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload 1st 2 photos required')),
      );
      return;
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    try {
      final uri = Uri.parse("${SessionUrl().httpUrl}/home/propertyData");
      var request = http.MultipartRequest('POST', uri);
      request.fields.addAll({
        'mobileno': widget.users['mobileno'],
        'contactno': _contactController.text,
        'pincode': pincode.toString(),
        'states': states.toString(),
        'city': locality.toString(),
        'address': _addressController.text,
        'appid': appids.toString(),
        'prop_type': _propertyType.toString(),
        'prop_area': _areaController.text, //_proparea.text,
        'price': _priceController.text, //_price.text,
        'status': _propertyFor.toString(), //_status.text,
      });

      request.files.add(
        await http.MultipartFile.fromPath('photo1', _selectedFile1!.path),
      );
      request.files.add(
        await http.MultipartFile.fromPath('photo2', _selectedFile2!.path),
      );

      if (_selectedFile3 != null) {
        request.files.add(
          await http.MultipartFile.fromPath('photo3', _selectedFile3!.path),
        );
      }
      if (_selectedFile4 != null) {
        request.files.add(
          await http.MultipartFile.fromPath('photo4', _selectedFile4!.path),
        );
      }
      // request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var getres = convert.jsonDecode(await response.stream.bytesToString());
        if (getres['status'] == 'success') {
          // ignore: use_build_context_synchronously
          Components().alertPopUp(context);
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
        } else if (getres['status'] == 'error') {
          if (mounted) {
            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Required all input fields !'),
                backgroundColor: Color.fromARGB(255, 204, 51, 51),
              ),
            );
          }
        } else {
          if (mounted) {
            // ignore: use_build_context_synchronously
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Required all input fields !'),
                backgroundColor: Color.fromARGB(255, 243, 18, 18),
              ),
            );
          }
        }
      } else {
        if (mounted) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Required all input fields !'),
              backgroundColor: Color.fromARGB(255, 243, 18, 18),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('error $e');
    }
  }

  @override
  void dispose() {
    _areaController.dispose();
    _titleController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // print('$locality, $street, $namea, $states, $country');
    // _address.value = _address.value.copyWith(
    //   text: (country != null)
    //       ? '$street, $others, $other2, $locality-$pincode, $states, $country'
    //       : '',
    // );
    // print(getpincode.toString());
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Regarding your Property',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Photo Upload Section
                  _buildPhotoUploadSection(),
                  SizedBox(height: 10.0),
                  if (pincode == '')
                    TextButton(
                      onPressed: () {
                        requestLocationPermission();
                      },
                      child: Text('Request Enable the Location.'),
                    ),
                  SizedBox(height: 10.0),

                  // Area Field
                  _buildTextField(
                    icon: Icons.crop_square_outlined,
                    label: '${getlangs[3]}',
                    hint: 'Enter area',
                    controller: _areaController,
                    required: true,
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 12),

                  // Property Type Dropdown
                  _buildDropdownField(
                    icon: Icons.business_outlined,
                    label: '${getlangs[4]}',
                    hint: 'Select property type',
                    value: _propertyType,
                    items: const [
                      'House',
                      'Apartment',
                      'Plot',
                      'Commercial',
                      'Flat',
                      'Land',
                      'Shop',
                      'Kothi',
                      'Show-Room',
                    ],
                    required: true,
                    onChanged: (val) => setState(() => _propertyType = val),
                  ),
                  const SizedBox(height: 12),

                  // Address
                  _buildTextField(
                    icon: Icons.location_on_outlined,
                    label: '${getlangs[6]}',
                    hint: 'Enter complete address',
                    controller: _addressController,
                    required: true,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),

                  // Price + Property For (side by side)
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          icon: Icons.currency_rupee,
                          label: '${getlangs[7]} (₹)',
                          hint: 'Enter price',
                          controller: _priceController,
                          required: true,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDropdownField(
                          icon: Icons.home_outlined,
                          label: '${getlangs[8]}',
                          hint: 'Select option',
                          value: _propertyFor,
                          items: const ['Sale', 'Rent', 'Lease'],
                          required: true,
                          onChanged: (val) =>
                              setState(() => _propertyFor = val),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Description
                  _buildTextField(
                    icon: Icons.description_outlined,
                    label: '${getlangs[9]}',
                    hint: 'Describe your property...',
                    controller: _descriptionController,
                    required: false,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 12),

                  // Contact Number
                  _buildTextField(
                    icon: Icons.phone_outlined,
                    label: '${getlangs[10]}',
                    hint: 'Enter contact number',
                    controller: _contactController,
                    required: true,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Post Property Button
          _buildPostButton(),
        ],
      ),
    );
  }

  // ─── Photo Upload Section ────────────────────────────────────────────────────
  Widget _buildPhotoUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: getlangs[0].toString(),
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextSpan(
                text: getlangs[1].toString(),
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 13,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    getPickFile();
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
                                  borderRadius: BorderRadiusGeometry.circular(
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
                                        decoration: const BoxDecoration(
                                          color: _primaryBlue,
                                          shape: BoxShape.circle,
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
                        '${getlangs[2]} 1',
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
                                  borderRadius: BorderRadiusGeometry.circular(
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
                                        decoration: const BoxDecoration(
                                          color: _primaryBlue,
                                          shape: BoxShape.circle,
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
                        '${getlangs[2]} 2',
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
                    getPickFile3();
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
                        child: (_selectedFile3 != null)
                            ? SizedBox(
                                width: 82.0,
                                height: 82.0,
                                child: ClipRRect(
                                  borderRadius: BorderRadiusGeometry.circular(
                                    5,
                                  ),
                                  child: Image.file(
                                    _selectedFile3!,
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
                                        decoration: const BoxDecoration(
                                          color: _primaryBlue,
                                          shape: BoxShape.circle,
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
                        '${getlangs[2]} 3',
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
                    getPickFile4();
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
                        child: (_selectedFile4 != null)
                            ? SizedBox(
                                width: 82.0,
                                height: 82.0,
                                child: ClipRRect(
                                  borderRadius: BorderRadiusGeometry.circular(
                                    5,
                                  ),
                                  child: Image.file(
                                    _selectedFile4!,
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
                                        decoration: const BoxDecoration(
                                          color: _primaryBlue,
                                          shape: BoxShape.circle,
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
                        '${getlangs[2]} 4',
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
      ],
    );
  }

  // Widget _buildPhotoSlot(int index) {
  //   return Expanded(
  //     child: Padding(
  //       padding: EdgeInsets.only(right: index < 3 ? 8 : 0),
  //       child: GestureDetector(
  //         onTap: () {
  //           // Photo picker would go here
  //         },
  //         child: Column(
  //           children: [
  //             Container(
  //               height: 72,
  //               decoration: BoxDecoration(
  //                 color: _lightBlue.withOpacity(0.5),
  //                 border: Border.all(
  //                   color: _primaryBlue.withOpacity(0.35),
  //                   width: 1.5,
  //                   // Dashed border via CustomPainter if needed; using solid for simplicity
  //                 ),
  //                 borderRadius: BorderRadius.circular(10),
  //               ),
  //               child: Center(
  //                 child: Stack(
  //                   clipBehavior: Clip.none,
  //                   children: [
  //                     Icon(
  //                       Icons.camera_alt_outlined,
  //                       color: _iconColor,
  //                       size: 32,
  //                     ),
  //                     Positioned(
  //                       right: -6,
  //                       bottom: -4,
  //                       child: Container(
  //                         width: 16,
  //                         height: 16,
  //                         decoration: const BoxDecoration(
  //                           color: _primaryBlue,
  //                           shape: BoxShape.circle,
  //                         ),
  //                         child: const Icon(
  //                           Icons.add,
  //                           color: Colors.white,
  //                           size: 12,
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //             const SizedBox(height: 5),
  //             Text(
  //               '${getlangs[2]} ${index + 1}',
  //               style: const TextStyle(
  //                 fontWeight: FontWeight.bold,
  //                 fontSize: 11,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // ─── Text Field ─────────────────────────────────────────────────────────────
  Widget _buildTextField({
    required IconData icon,
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool required,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: maxLines > 1
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.center,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 12, top: maxLines > 1 ? 14 : 0),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: _lightBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: _iconColor, size: 18),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  RichText(
                    text: TextSpan(
                      text: label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                      children: required
                          ? const [
                              TextSpan(
                                text: ' *',
                                style: TextStyle(color: Colors.red),
                              ),
                            ]
                          : null,
                    ),
                  ),
                  TextField(
                    controller: controller,
                    keyboardType: keyboardType,
                    maxLines: maxLines,
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 13,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.only(bottom: 10),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Dropdown Field ──────────────────────────────────────────────────────────
  Widget _buildDropdownField({
    required IconData icon,
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required bool required,
    required ValueChanged<String?> onChanged,
    bool compact = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor, width: 1.2),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Container(
              width: compact ? 28 : 34,
              height: compact ? 28 : 34,
              decoration: BoxDecoration(
                color: _lightBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: _iconColor, size: compact ? 15 : 18),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: compact ? 6 : 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      text: label,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: compact ? 11 : 13,
                        color: Colors.black87,
                      ),
                      children: required
                          ? const [
                              TextSpan(
                                text: ' *',
                                style: TextStyle(color: Colors.red),
                              ),
                            ]
                          : null,
                    ),
                  ),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: value,
                      hint: Text(
                        hint,
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: compact ? 11 : 13,
                        ),
                      ),
                      isExpanded: true,
                      iconSize: 18,
                      icon: const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.black54,
                      ),
                      style: TextStyle(
                        fontSize: compact ? 11 : 13,
                        color: Colors.black87,
                      ),
                      isDense: true,
                      onChanged: onChanged,
                      items: items
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Post Button ─────────────────────────────────────────────────────────────
  Widget _buildPostButton() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(
        16,
        10,
        16,
        MediaQuery.of(context).padding.bottom + 10,
      ),
      child: ElevatedButton.icon(
        onPressed: _handlePost,
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 2,
        ),
        icon: const Icon(Icons.send, size: 20),
        label: Text(
          '${getlangs[11]}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.4,
          ),
        ),
      ),
    );
  }

  void _handlePost() {
    // Validate required fields
    if (_areaController.text.isEmpty ||
        _propertyType == null ||
        _addressController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _propertyFor == null ||
        _contactController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    } else {
      postPropertyData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait loading the data.'),
          backgroundColor: Color(0xFF3333CC),
        ),
      );
    }
  }
}
