// Copyright (C) 2019 Serov Konstantin.
// Licensed under the MIT license:
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

import 'package:better_print/better_print.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class TapWatcherIgnoreRenderBox extends RenderPointerListener {}

class TapWatcherForceRenderBox extends RenderPointerListener {}

class IgnoreTapWatcher extends SingleChildRenderObjectWidget {
  final Widget child;

  IgnoreTapWatcher({
    required this.child,
  }) : super(
          child: child,
        );

  @override
  TapWatcherIgnoreRenderBox createRenderObject(
    BuildContext context,
  ) {
    return TapWatcherIgnoreRenderBox();
  }
}

class TapWatcher extends StatelessWidget {
  const TapWatcher({Key? key, required this.child}) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext c, BoxConstraints viewportConstraints) {
        return ConstrainedBox(
          constraints: BoxConstraints(
              maxWidth: viewportConstraints.maxWidth,
              maxHeight: viewportConstraints.maxHeight),
          child: Listener(
            onPointerDown: (e) {
              var rb = context.findRenderObject() as RenderBox;
              var result = BoxHitTestResult();
              rb.hitTest(result, position: e.position);

              // if there any widget in the path that must ignore taps,
              // stop it right here
              if (result.path.any((entry) =>
                  entry.target.runtimeType == TapWatcherIgnoreRenderBox)) {
                return;
              }
              var isEditable = result.path.any((entry) =>
                  entry.target.runtimeType == RenderEditable ||
                  entry.target.runtimeType == RenderParagraph ||
                  entry.target.runtimeType == TapWatcherForceRenderBox);

              var currentFocus = FocusScope.of(context);
              if (!currentFocus.hasPrimaryFocus) {
                currentFocus.unfocus();
              }
              if (!isEditable) {
              } else {
                // for (var entry in result.path) {
                // var isEditable = entry.target.runtimeType == RenderEditable ||
                //     entry.target.runtimeType == RenderParagraph ||
                //     entry.target.runtimeType == TapWatcherForceRenderBox;
                // }
              }
            },
            child: child,
          ),
        );
      },
    );
  }
}
