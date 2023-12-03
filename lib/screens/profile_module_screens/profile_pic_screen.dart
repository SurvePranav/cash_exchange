import 'package:flutter/material.dart';

class ImageFullScreen extends StatelessWidget {
  final String url;
  final String heroTag;
  const ImageFullScreen({
    super.key,
    required this.url,
    this.heroTag = 'hero_image',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: InteractiveViewer(
        child: Container(
          color: Colors.black,
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Center(
            child: Hero(
              tag: heroTag,
              child: Image.network(url),
            ),
          ),
        ),
      ),
    );
  }
}
