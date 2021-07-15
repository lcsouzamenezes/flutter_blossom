import 'package:flutter/widgets.dart';

precacheImageFromAll(BuildContext context) {
  List list = [
    AssetImage('assets/icon/blossom.png'),
    NetworkImage(
      'https://liberapay.com/assets/liberapay/logo-v2_black-on-yellow.1024.png?save_as=liberapay_logo_black-on-yellow_1024px.png',
    ),
    NetworkImage(
      'https://cdn.ko-fi.com/cdn/kofi3.png?v=2',
    ),
  ];
  try {
    list.forEach((e) {
      precacheImage(e, context);
    });
  } catch (e) {}
}
