import 'package:fixsathi/clients/add_cart.dart';
import 'package:flutter/material.dart';

class MySearchDelegate extends SearchDelegate<String?> {
  final List<dynamic> getcate;
  Map<String, dynamic> userData = {};
  MySearchDelegate(this.getcate, this.userData);
  String? selectd, image;
  String mms = '';
  String img1 = 'electricians.jpg';

  @override
  Widget buildSuggestions(BuildContext context) {
    // var subcat = getcate.map((e) => e['sub_cate']).toList();
    final matchs = getcate.where((element) {
      return element["sub_cate"].toLowerCase().contains(query.toLowerCase()) ||
          element["main_cate"].toLowerCase().contains(query.toLowerCase());
    }).toList();

    if (matchs.isEmpty) {
      return Center(child: Text('Search not available.'));
    }

    return ListView.builder(
      itemCount: matchs.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Icon(Icons.image, size: 20.0),
          title: Text('${matchs[index]['sub_cate']}'),
          onTap: () {
            selectd = matchs[index]['main_cate'];
            showResults(context);
          },
        );
      },
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          close(context, '');
        },
        icon: Icon(Icons.clear, size: 25),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () => close(context, null),
      icon: Icon(Icons.arrow_back, size: 25),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List match1 = getcate.where((element) {
      return element["sub_cate"].toLowerCase().contains(query.toLowerCase()) ||
          element["main_cate"].toLowerCase().contains(query.toLowerCase());
    }).toList();

    if (match1.isEmpty) {
      // Handle wrong text safely
      return Center(child: Text("No results found for '$query'"));
    }

    // Return AddtoCart widget with safe data
    return AddtoCart(
      title: 'Add to Cart',
      category: {
        'subcate': match1[0]['main_cate'].toString(),
        'phoneno': userData['mobileno'].toString(),
        'lang': userData['language'].toString(),
        'category': userData['category'],
        'username': userData['client_name'],
      },
    );
  }
}
