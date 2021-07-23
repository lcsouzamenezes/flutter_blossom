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
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class TapWatcherIgnoreRenderBox extends RenderPointerListener {}

class TapWatcherForceRenderBox extends RenderPointerListener {}

HitTestEntry? _pre;

String? _getId(String s) => (s.contains('#') && s.contains('@'))
    ? s.substring(s.indexOf('#'), s.indexOf('@'))
    : null;

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
              HitTestEntry? editable;
              result.path.forEach((e) {
                if (e.target.runtimeType == RenderEditable ||
                    e.target.runtimeType == RenderParagraph ||
                    e.target.runtimeType == TapWatcherForceRenderBox) {
                  if (editable == null) editable = e;
                }
              });

              var currentFocus = FocusScope.of(context);
              if (editable != null) {
                if (_pre == null) {
                  currentFocus.unfocus();
                } else if (_getId(_pre.toString()) !=
                    _getId(editable.toString())) {
                  currentFocus.unfocus();
                }
              } else {
                currentFocus.unfocus();
              }
              _pre = editable;
            },
            child: child,
          ),
        );
      },
    );
  }
}
