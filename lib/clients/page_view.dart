import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

// ignore: must_be_immutable
class PageViews extends StatefulWidget {
  String? title;
  String? img;
  PageViews({super.key, required this.title, required this.img});

  @override
  State<PageViews> createState() => _PageViewsState();
}

class _PageViewsState extends State<PageViews> {
  @override
  Widget build(BuildContext context) {
    // print(_lastOptions);
    return Scaffold(
      body: SafeArea(
        child: PhotoViewGestureDetectorScope(
          // axis: Axis.horizontal,
          child: PhotoView(
            minScale: 0.1,
            maxScale: 2.0,
            imageProvider: (widget.title == 'net')
                ? NetworkImage(widget.img.toString())
                : AssetImage(widget.img.toString()),
          ),
        ),
      ),
    );
  }
}
