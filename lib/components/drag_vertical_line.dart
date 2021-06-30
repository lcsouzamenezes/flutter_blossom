// Copyright (C) 2021 Sani Haq
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

import 'package:better_print/better_print.dart'; // ignore: unused_import
import 'package:flutter_blossom/helpers/extensions.dart'; // ignore: unused_import
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_blossom/utils/handle_keys.dart';

enum RelativePosition { start, end, top, down }

typedef DragCallback<T> = void Function(double dx);

class DragVerticalLine extends StatefulWidget {
  DragVerticalLine({
    required this.areaKey,
    required this.onDrag,
    required this.onTap,
    this.position = RelativePosition.end,
  });
  final GlobalKey areaKey;
  final DragCallback onDrag;
  final void Function() onTap;
  final RelativePosition position;
  @override
  DragVerticalLineState createState() => DragVerticalLineState();
}

class DragVerticalLineState extends State<DragVerticalLine> {
  bool isOnHover = false;
  double _width = 2.0;
  setWidth(double val) {
    setState(() {
      _width = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setWidth(2.0);
        widget.onTap();
      },
      onHorizontalDragUpdate: _width == 2
          ? (dt) {
              final dragPos = (dt.globalPosition.dx).round().toDouble();
              switch (widget.position) {
                case RelativePosition.start:
                  final pos = getPositionFromKey(widget.areaKey);
                  final size = getSizeFromKey(widget.areaKey);
                  final end =
                      pos != null && size != null ? pos.dx + size.width : 0;
                  if (end - dragPos < 50) setWidth(_width * 1.5);
                  widget.onDrag(end - dragPos);
                  break;
                case RelativePosition.end:
                  final pos = getPositionFromKey(widget.areaKey);
                  if (dragPos - (pos?.dx ?? 0) < 50) setWidth(_width * 1.5);
                  widget.onDrag(dragPos - (pos?.dx ?? 0));
                  break;
                default:
              }
              // print('${pos.dx}, $dragPos');
            }
          : null,
      child: MouseRegion(
        cursor: _width == 2
            ? SystemMouseCursors.resizeColumn
            : SystemMouseCursors.basic,
        onEnter: (_) => setState(() => isOnHover = true),
        onExit: (_) => setState(() => isOnHover = false),
        child: Padding(
          padding: EdgeInsets.only(right: _width / 2),
          child: VerticalDivider(
            width: isOnHover ? _width : _width / 2,
            thickness: isOnHover ? _width * 2 : _width,
            color: isOnHover
                ? Theme.of(context).primaryColor.darken(5)
                : _width == 2
                    ? Theme.of(context).canvasColor.lighten(8)
                    : Theme.of(context).canvasColor.lighten(4),
          ),
        ),
      ),
    );
  }
}
