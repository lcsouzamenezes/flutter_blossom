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

import 'package:better_print/better_print.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blossom/states/canvas_state.dart';
import 'package:flutter_blossom/states/tree_state.dart';
import 'package:flutter_blossom/utils/handle_keys.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:keybinder/keybinder.dart';

class ModelWidgetWrapper extends HookWidget {
  ModelWidgetWrapper(
      {Key? key,
      required this.modelKey,
      required this.child,
      this.isSelected = true})
      : super(key: key);
  final gKey = GlobalKey();
  final String modelKey;
  final Widget child;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final enableControls = useProvider(enableCanvasControl);
    final _modelOnHover = useProvider(modelOnHover);

    Rect _getSelectedBoxSize(GlobalKey k) {
      return (getPositionFromKey(k) ?? Offset.zero) - Offset(2, 46) &
          (getSizeFromKey(k) ?? Size.zero) *
                  context.read(canvasState).controller.zoom +
              Offset(4, 4);
    }

    useEffect(() {
      if (isSelected) {
        Future.delayed(Duration(milliseconds: 0))
            .then((value) => context.read(canvasState).setSelectedBoxKey(gKey));
      }
      return;
    }, [isSelected]);

    return enableControls.state
        ? InkWell(
            mouseCursor: MouseCursor.defer,
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            hoverColor: Colors.transparent,
            overlayColor: null,
            onHover: (value) {
              if (!value)
                _modelOnHover.remove(gKey);
              else
                _modelOnHover.add(gKey);
              Future.delayed(Duration(milliseconds: 0)).then((value) {
                if (_modelOnHover.isNotEmpty)
                  context
                      .read(canvasState)
                      .setSelectBox(_getSelectedBoxSize(_modelOnHover.last));
                else
                  context.read(canvasState).setSelectBox(null);
              });
            },
            onTap: () {
              final _isControlPressed = RawKeyboard.instance.keysPressed
                  .any((e) => e.keyId == 0x1000700e0 || e.keyId == 0x1000700e4);
              final _isShiftPressed = RawKeyboard.instance.keysPressed
                  .any((e) => e.keyId == 0x1000700e1 || e.keyId == 0x1000700e5);
              final _isAltPressed = RawKeyboard.instance.keysPressed
                  .any((e) => e.keyId == 0x1000700e2 || e.keyId == 0x1000700e6);
              // betterPrint('cntrl: $_isControlPressed, shift: $_isShiftPressed, alt: $_isAltPressed');
              final tree = context.read(treeState);
              final parentKey = tree.controller.selectedKey != null
                  ? tree.controller.getParent(tree.controller.selectedKey!)?.key
                  : null;
              final children = parentKey != null
                  ? tree.controller.getNode(parentKey)?.children ?? []
                  : tree.controller.children;
              final i = children.indexWhere(
                  (element) => element.key == tree.controller.selectedKey);
              if (_isControlPressed && _isShiftPressed && children.isNotEmpty) {
                if (i >= 0) {
                  final j = i < children.length - 1 ? i + 1 : 0;
                  tree.selectNode(children[j].key);
                }
              } else if (_isAltPressed &&
                  _isShiftPressed &&
                  children.isNotEmpty) {
                if (i > 0) tree.selectNode(children[i - 1].key);
              } else if (_isAltPressed &&
                  _isControlPressed &&
                  children.isNotEmpty) {
                if (i < children.length - 1)
                  tree.selectNode(children[i + 1].key);
              } else if (_isShiftPressed) {
                if (parentKey != null) tree.selectNode(parentKey);
              } else if (_isControlPressed) {
                final directChildren = tree.controller.selectedNode?.children;
                if (directChildren != null && directChildren.isNotEmpty)
                  tree.selectNode(directChildren.first.key);
              } else if (_isAltPressed) {
                final node = tree.controller.selectedNode;
                if (node?.inheritKey != null)
                  tree.selectNodeInTrees(node!.inheritKey!);
              } else {
                tree.selectNodeInTrees(modelKey);
              }
            },
            child: SizedBox(
              key: gKey,
              child: child,
            ),
          )
        : child;
  }
}

class SelectBoxPainter extends CustomPainter {
  SelectBoxPainter(this.rect, [this.color = Colors.red]);
  final Rect rect;
  final Color color;
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
