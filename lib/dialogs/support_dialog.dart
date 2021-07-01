import 'package:flutter/material.dart';
import 'package:flutter_blossom/constants/colors.dart';
import 'package:flutter_blossom/constants/shapes.dart';
import 'package:flutter_blossom/helpers/extensions.dart';
import 'package:url_launcher/url_launcher.dart';

Widget getSupportDialog(BuildContext context) {
  return Dialog(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(contextMenuRadius.x),
    ),
    backgroundColor: Theme.of(context).canvasColor.by(darken2),
    child: Container(
      width: 300,
      decoration: BoxDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 20.0),
          Text(
            'Support!!',
            style:
                TextStyle(fontSize: 22, color: Colors.amber.withOpacity(0.6)),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
            child: Text(
              '"Flutter blossom" is created with the hope to help all developers. But, our journey is only beginning. There is a long road ahead. Please join us and help bring it to life. Thank You.',
              style: TextStyle(fontSize: 14, color: Colors.white54),
              textAlign: TextAlign.center,
            ),
          ),
          InkWell(
            onTap: () => launch('https://liberapay.com/sanihaq/donate'),
            child: SizedBox(
              width: 150,
              child: Image.network(
                'https://liberapay.com/assets/liberapay/logo-v2_black-on-yellow.1024.png?save_as=liberapay_logo_black-on-yellow_1024px.png',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: InkWell(
              onTap: () => launch('https://ko-fi.com/sanihaq'),
              child: SizedBox(
                width: 150,
                child: Image.network(
                  'https://cdn.ko-fi.com/cdn/kofi3.png?v=2',
                ),
              ),
            ),
          )
        ],
      ),
    ),
  );
}
