import 'package:flutter/material.dart';

Widget mainButton(Text content, onpress, Color textColor, Color backColor) {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 7, vertical: 10),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: textColor,
        backgroundColor: backColor,
        minimumSize: const Size.fromHeight(40),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
        ),
      ),
      onPressed: onpress,
      child: content,
    ),
  );
}

Widget middleButton(Text content, onpress, Color textColor, Color backColor) {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 3, vertical: 2),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: textColor,
        backgroundColor: backColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(9.0)),
        ),
      ),
      onPressed: onpress,
      child: content,
    ),
  );
}

Widget smallButton(Text content, onpress, Color textColor, Color backColor) {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: textColor,
        backgroundColor: backColor,
        minimumSize: const Size.fromHeight(35),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15.0)),
        ),
      ),
      onPressed: onpress,
      child: content,
    ),
  );
}

Widget iconButton(
  BuildContext context,
  content,
  onpress,
  Color textColor,
  Color backColor,
) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
    width: MediaQuery.of(context).size.width,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        foregroundColor: textColor,
        backgroundColor: backColor,
        minimumSize: const Size.fromHeight(44),
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5.0)),
        ),
      ),
      onPressed: onpress,
      child: Text.rich(
        TextSpan(
          children: [
            const WidgetSpan(child: Icon(Icons.file_present)),
            TextSpan(
              text: ' $content',
              style: const TextStyle(
                fontSize: 15,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        maxLines: 1,
      ),
    ),
  );
}

Widget fullButton(
  BuildContext context,
  content,
  onpress,
  Color textColor,
  Color backColor,
) {
  return Container(
    margin: EdgeInsets.symmetric(vertical: 2.0),
    width: MediaQuery.of(context).size.width,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        foregroundColor: textColor,
        backgroundColor: backColor,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(7.0)),
        ),
      ),
      onPressed: onpress,
      child: Text(
        content,
        style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w700),
        textAlign: TextAlign.left,
      ),
    ),
  );
}
