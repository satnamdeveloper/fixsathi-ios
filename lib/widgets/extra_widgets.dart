import 'package:flutter/material.dart';

Widget? bottomNavigation(
  BuildContext context,
  InkWell notification,
  InkWell profile,
) {
  return Container(
    height: 75,
    padding: EdgeInsets.only(top: 5),
    decoration: BoxDecoration(
      border: Border.all(
        color: Colors.black12, // Set border color
        width: 1.0, // Set border width
      ),
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(50),
        topRight: Radius.circular(50),
      ), // Match border radius for the container
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.only(
        topRight: Radius.circular(50),
        topLeft: Radius.circular(50),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            padding: EdgeInsets.all(0),
            child: Column(
              children: [
                ClipOval(
                  child: Material(
                    color: const Color.fromARGB(
                      255,
                      59,
                      15,
                      233,
                    ), // Button color
                    child: InkWell(
                      splashColor: const Color.fromARGB(255, 251, 4, 4), //
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: const SizedBox(
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.home,
                          size: 20.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 3.0),
                  child: textSingleLine(
                    'Dashboard',
                    TextStyle(
                      letterSpacing: 0.01,
                      color: Colors.black87,
                      fontSize: 11.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(0),
            child: Column(
              children: [
                ClipOval(
                  child: Material(
                    color: const Color.fromARGB(255, 2, 228, 6), // Button color
                    child: notification,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 3.0),
                  child: textSingleLine(
                    'Student List',
                    TextStyle(
                      letterSpacing: 0.01,
                      color: Colors.black87,
                      fontSize: 11.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(0),
            child: Column(
              children: [
                ClipOval(
                  child: Material(
                    color: const Color.fromARGB(255, 251, 4, 4), //
                    child: profile,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 3.0),
                  child: textSingleLine(
                    'Profile',
                    TextStyle(
                      letterSpacing: 0.01,
                      color: Colors.black87,
                      fontSize: 11.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget inputText(
  // ignore: strict_top_level_inference
  controlText,
  Color labelColor,
  labelText,
  Color borderColor,
  Icon icon,
  ontap,
  validator,
) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
    ),
    height: 42.0,
    child: TextFormField(
      controller: controlText,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(vertical: 1),
        labelStyle: TextStyle(color: labelColor),
        prefixIcon: icon,
        // prefixIconColor: Colors.green,
        labelText: labelText,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            style: BorderStyle.solid,
            width: 1,
            color: borderColor,
          ),
          borderRadius: BorderRadius.circular(20.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            style: BorderStyle.solid,
            width: 1,
            color: borderColor,
          ),
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
      onTap: ontap,
      validator: validator,
    ),
  );
}

Widget? inputTextArea(
  // ignore: strict_top_level_inference
  controlText,
  int maxline,
  labelText,
  Icon icon,
  ontap,
  validator,
) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
    ),
    child: TextFormField(
      controller: controlText,
      maxLines: maxline,
      // ignore: prefer_const_constructors
      decoration: InputDecoration(
        labelStyle: const TextStyle(color: Colors.black54),
        prefixIcon: icon,
        // prefixIconColor: Colors.green,
        labelText: labelText,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            style: BorderStyle.solid,
            width: 1,
            color: Colors.green,
          ),
          borderRadius: BorderRadius.circular(20.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            style: BorderStyle.solid,
            width: 1,
            color: Colors.green,
          ),
          borderRadius: BorderRadius.circular(20.0),
        ),
      ),
      onTap: ontap,
      validator: validator,
    ),
  );
}

// DROPDOWN LIST
// ignore: strict_top_level_inference
Widget dropdown(dropdownValue, chooseHint, onchange, itemMap) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 9.0, horizontal: 7.0),

    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(9),
    ),
    child: DropdownMenu(
      menuHeight: 300,
      menuStyle: MenuStyle(
        shape: WidgetStateProperty.all<OutlinedBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0), // Adjust the radius
          ),
        ),
      ),
      initialSelection: dropdownValue, // The currently selected value
      dropdownMenuEntries: itemMap, // The list of menu items
      onSelected: onchange,
      hintText: chooseHint.toString(),
      expandedInsets: EdgeInsetsGeometry.symmetric(vertical: 1.0),
      textStyle: TextStyle(
        fontSize: 15,
        color: Colors.blue.shade800,
        fontWeight: FontWeight.w600,
      ),

      trailingIcon: Icon(Icons.keyboard_arrow_down),
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: EdgeInsets.symmetric(horizontal: 1.0),
      ),
      enableSearch: true,
      enableFilter: true,
    ),
  );
}

// Profile Text
// ignore: strict_top_level_inference
Widget profileText(context, titles, content) {
  return Container(
    padding: const EdgeInsets.only(left: 15, right: 15, top: 12),
    width: MediaQuery.of(context).size.width - 50,
    height: 45,
    decoration: const BoxDecoration(
      border: BorderDirectional(
        top: BorderSide.none,
        start: BorderSide.none,
        end: BorderSide.none,
        bottom: BorderSide(color: Color.fromARGB(255, 193, 193, 194)),
      ),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          titles.toString(),
          style: const TextStyle(fontSize: 14.0, fontWeight: FontWeight.w600),
        ),
        Text(
          '$content',
          style: TextStyle(
            color: Colors.blueAccent,
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}

// ignore: strict_top_level_inference
Widget buildCarousel(context, String imgList, int index) {
  return Container(
    padding: const EdgeInsets.all(3),
    width: MediaQuery.of(context).size.width - 50.0,
    decoration: BoxDecoration(border: Border.all(color: Colors.black54)),
    //color: Colors.grey,
    child: Center(
      child: SizedBox(
        width: 320,
        child: Text(
          imgList,
          style: const TextStyle(
            height: 1.2,
            fontSize: 19,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    ),
  );
}

// ignore: strict_top_level_inference
Widget textBold(content) {
  return Container(
    padding: const EdgeInsets.all(2.0),
    child: Text(
      content,
      style: TextStyle(
        letterSpacing: 0.01,
        fontWeight: FontWeight.w700,
        fontSize: 14.5,
      ),
    ),
  );
}

// ignore: strict_top_level_inference
Widget textSample(content) {
  return Container(
    padding: const EdgeInsets.all(2.0),
    child: Text(
      content,
      style: const TextStyle(letterSpacing: 0.01, fontSize: 14.0),

      // maxLines: 1, // Ensures the text stays on a single line
      // overflow: TextOverflow.ellipsis,
    ),
  );
}

// ignore: strict_top_level_inference
Widget textSingleLine(content, textstyle) {
  return Text(
    content,
    maxLines: 1, // Restricts the text to a single line
    overflow: TextOverflow.ellipsis,
  );
}

// Widget softText(content, textstyle, lines) {
//   return Text(
//     HtmlTagsCleaner.clean(content),
//     style: GoogleFonts.poppins(textStyle: textstyle),
//     maxLines: lines,
//   );
// }

// ignore: strict_top_level_inference
Widget spaceText(content) {
  return Container(
    padding: const EdgeInsets.only(bottom: 5.0, top: 5.0),
    child: Text(
      content,
      style: const TextStyle(
        color: Color.fromARGB(255, 1, 20, 36),
        fontSize: 12.0,
        letterSpacing: 2,
      ),

      textAlign: TextAlign.center,
    ),
  );
}
