// ignore_for_file: non_constant_identifier_names

class Users {
  Users({
    required this.id,
    required this.datetime,
    required this.firstname,
    required this.appid,
    required this.gender,
    required this.category,
    required this.provide_service,
    required this.firm_name,
    required this.contactno,
    required this.address,
    required this.contact2,
    required this.city,
    required this.state,
    required this.district,
    required this.pincode,
    required this.bank_ac,
    required this.bank_name,
    required this.bank_ifsc,
    required this.bank_address,
    required this.user_img,
    required this.language,
    required this.is_active,
    required this.trash,
  });

  final String? id;
  final DateTime datetime;
  final String? firstname;
  final String? appid;
  final String? gender;
  final String? category;
  final String? provide_service;
  final String? firm_name;
  final String? contactno;
  final String? contact2;
  final String? address;
  final String? city;
  final String? state;
  final String? district;
  final String? pincode;
  final String? bank_ac;
  final String? bank_name;
  final String? bank_ifsc;
  final String? bank_address;
  final String? user_img;
  final String? language;
  final String? is_active;
  final String? trash;

  factory Users.fromJson(Map<String, dynamic> json) {
    return Users(
      id: json['id'],
      datetime: DateTime.parse(json['datetime']),
      firstname: json['firstname'],
      appid: json['appid'],
      gender: json['gender'],
      category: json['category'],
      provide_service: json['provide_service'] ?? '',
      firm_name: json['firm_name'] ?? '',
      contactno: json['contactno'],
      contact2: json['contact2'],
      address: json['address'],
      city: json['city'],
      state: json['state'] ?? '',
      district: json['district'] ?? '',
      pincode: json['pincode'] ?? '',
      bank_ac: json['bank_ac'] ?? '',
      bank_name: json['bank_name'] ?? '',
      bank_ifsc: json['bank_ifsc'] ?? '',
      bank_address: json['bank_address'] ?? '',
      user_img: json['user_img'] ?? '',
      language: json['language'],
      is_active: json['is_active'],
      trash: json['trash'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id.toString(),
    'datetime': datetime.toIso8601String(),
    'firstname': firstname,
    'appid': appid,
    'gender': gender,
    'category': category,
    'provide_service': provide_service,
    'firm_name': firm_name,
    'contactno': contactno.toString(),
    'contact2': contact2.toString(),
    'address': address,
    'city': city,
    'state': state,
    'district': district,
    'pincode': pincode.toString(),
    'bank_ac': bank_ac,
    'bank_name': bank_name,
    'bank_ifsc': bank_ifsc,
    'bank_address': bank_address,
    'user_img': user_img,
    'language': language,
    'is_active': is_active,
    'trash': trash,
  };
}
