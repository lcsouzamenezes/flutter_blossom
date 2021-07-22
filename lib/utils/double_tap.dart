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

import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

class DoubleTap extends StatefulWidget {
  DoubleTap({
    required this.child,
    required this.onDoubleTap,
    this.onTap,
    this.onSecondaryTap,
    this.doubleDelay = 250,
    this.bypassTapEventOnDoubleTap = true,
    this.behavior = HitTestBehavior.deferToChild,
  });

  final Widget child;

  final int doubleDelay;

  final void Function() onDoubleTap;

  final void Function()? onTap;

  final void Function()? onSecondaryTap;

  final bool bypassTapEventOnDoubleTap;

  final HitTestBehavior behavior;

  @override
  _DoubleTapState createState() => _DoubleTapState();
}

enum _GestureState { PointerDown, Unknown }

class _DoubleTapState extends State<DoubleTap> {
  List<_Touch> touches = [];
  double initialScaleDistance = 1.0;
  _GestureState state = _GestureState.Unknown;
  Timer? doubleTapTimer;
  Timer? longPressTimer;
  Offset lastTouchUpPos = Offset(0, 0);

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: widget.behavior,
      child: widget.child,
      onPointerDown: onPointerDown,
      onPointerUp: onPointerUp,
    );
  }

  void onPointerDown(PointerDownEvent event) {
    touches.add(_Touch(event.pointer, event.localPosition));
    if (event.buttons != kSecondaryMouseButton) {
      if (touchCount == 1) {
        state = _GestureState.PointerDown;
      } else {
        state = _GestureState.Unknown;
      }
    }
  }

  void onPointerUp(PointerEvent event) {
    if (event.buttons != kSecondaryMouseButton) {
      touches.removeWhere((touch) => touch.id == event.pointer);

      if (state == _GestureState.PointerDown) {
        if (doubleTapTimer == null) {
          startDoubleTapTimer();
        } else {
          cleanupTimer();
          if ((event.localPosition - lastTouchUpPos).distanceSquared < 200) {
            widget.onDoubleTap();
          } else {
            startDoubleTapTimer();
          }
        }
      } else {
        state = _GestureState.Unknown;
      }

      lastTouchUpPos = event.localPosition;
    } else if (event.buttons == kSecondaryMouseButton) {
      if (state == _GestureState.PointerDown) {
        widget.onSecondaryTap?.call();
      } else {
        state = _GestureState.Unknown;
      }
    }
  }

  void startDoubleTapTimer() {
    doubleTapTimer = Timer(Duration(milliseconds: widget.doubleDelay), () {
      state = _GestureState.Unknown;
      cleanupTimer();
      if (widget.bypassTapEventOnDoubleTap) {
        callOnTap();
      }
    });
  }

  void callOnTap() {
    if (widget.onTap != null) {
      widget.onTap!();
    }
  }

  void cleanupTimer() {
    if (doubleTapTimer != null) {
      doubleTapTimer!.cancel();
      doubleTapTimer = null;
    }
    if (longPressTimer != null) {
      longPressTimer!.cancel();
      longPressTimer = null;
    }
  }

  get touchCount => touches.length;
}

class _Touch {
  int id;
  Offset startOffset;
  late Offset currentOffset;

  _Touch(this.id, this.startOffset) {
    this.currentOffset = startOffset;
  }
}
