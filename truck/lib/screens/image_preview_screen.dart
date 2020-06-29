import 'package:flutter/material.dart';

class ImagePreviewScreen extends StatelessWidget {
  static const routeName = '/imagePreviewScreen';
  @override
  Widget build(BuildContext context) {
    var imageUrl = ModalRoute.of(context).settings.arguments;
    print('Image_URL_PREVIEW' + imageUrl);
    return Scaffold(
      body: (imageUrl != '')
          ? Image.network(imageUrl)
          : Text('No Image was added!'),
    );
  }
}
