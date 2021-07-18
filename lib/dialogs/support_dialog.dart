// Copyright (C) 2021 Sani Haq <work.sanihaq@gmail.com>
//
// This file is part of Flutter Blossom.
//
// Flutter Blossom is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Flutter Blossom is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Flutter Blossom.  If not, see <http://www.gnu.org/licenses/>.

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
                errorBuilder: (BuildContext context, Object exception,
                    StackTrace? stackTrace) {
                  return const Text(
                    '😢',
                    textAlign: TextAlign.center,
                  );
                },
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
                  errorBuilder: (BuildContext context, Object exception,
                      StackTrace? stackTrace) {
                    return const Text(
                      '😢',
                      textAlign: TextAlign.center,
                    );
                  },
                ),
              ),
            ),
          )
        ],
      ),
    ),
  );
}
