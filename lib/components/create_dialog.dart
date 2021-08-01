import 'package:flutter/material.dart';
import 'package:flutter_blossom/constants/colors.dart';
import 'package:flutter_blossom/helpers/extensions.dart';
import 'package:flutter_blossom/states/app_state.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_blossom/constants/shapes.dart';

Future<T?> createDialog<T>(BuildContext context,
    {required Widget child, double width = 200, double height = 300}) {
  return showDialog<T>(
    context: context,
    barrierColor: Colors.black38,
    builder: (context) {
      return Dialog(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(contextMenuRadius.x),
        ),
        backgroundColor: Theme.of(context).canvasColor.darken(darken2),
        child: Container(width: width, height: height, child: child),
      );
    },
  );
}
