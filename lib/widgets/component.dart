import 'package:fixsathi/clients/dashboard_user.dart';
import 'package:fixsathi/widgets/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class Components {
  void alertPopUp(BuildContext context) async {
    return await showDialog<void>(
      context: context,
      barrierDismissible: false,
      // barrierColor: Colors.indigo.shade600,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.indigo,
          contentPadding: EdgeInsets.all(20),
          title: Center(
            child: Text(
              '',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 19.0,
                color: const Color.fromARGB(255, 236, 245, 238),
              ),
            ),
          ),
          titlePadding: const EdgeInsets.all(12),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          content: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                    padding: const EdgeInsets.all(15),

                    child: Lottie.asset(
                      'assets/jsons/done-work.json',
                      fit: BoxFit.cover,
                    ),
                  ),

                  mainButton(
                    Text('Ok', style: TextStyle(fontSize: 18.0)),
                    () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (BuildContext context) =>
                              const MainDashboard(),
                        ),
                        (route) =>
                            false, // Yeh purani saari screens ko delete kar dega
                      );
                    },
                    Colors.black45,
                    Colors.indigo.shade100,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void showToast(BuildContext context, String message) {
    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: scaffold.hideCurrentSnackBar,
        ),
      ),
    );
  }
}

class CustomBox extends StatelessWidget {
  final String text;
  final String text2;
  final Color? color;
  final Widget? child;
  final double? height;

  const CustomBox({
    super.key,
    required this.text,
    required this.text2,
    this.color,
    this.child,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: height,
        padding: const EdgeInsets.all(4.0),
        margin: const EdgeInsets.all(3.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5.0),
          color: color,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,

              children: <Widget>[
                ?child,
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: Text(
                    text,
                    style: const TextStyle(
                      overflow: TextOverflow.ellipsis,
                      fontSize: 15.0,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  text2,
                  style: const TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Icon(Icons.add, size: 25.0, color: Colors.white),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
