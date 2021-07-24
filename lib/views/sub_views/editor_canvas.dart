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
import 'package:flutter_blossom/components/context_menu_item.dart';
import 'package:flutter_blossom/components/micro_components/context_menu_container.dart';
import 'package:flutter_blossom/components/micro_components/context_menu_hint_text.dart';
import 'package:flutter_blossom/components/model_widget_wrapper.dart';
import 'package:flutter_blossom/constants/device_sizes.dart';
import 'package:flutter_blossom/constants/lengths.dart';
import 'package:flutter_blossom/helpers/extensions.dart'; // ignore: unused_import
import 'package:flutter/material.dart';
import 'package:flutter_blossom/models/console_message.dart';
import 'package:flutter_blossom/models/context_menu.dart';
import 'package:flutter_blossom/states/canvas_state.dart';
import 'package:flutter_blossom/states/console_state.dart';
import 'package:flutter_blossom/states/context_menu_state.dart';
import 'package:flutter_blossom/states/editor_state.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:blossom_canvas/blossom_canvas.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';

class EditorCanvas extends HookWidget {
  static const id = "canvas-view-area";

  @override
  Widget build(BuildContext context) {
    final _canvasState = useProvider(canvasState);
    final _enableControls = useProvider(enableCanvasControl);
    final _showSelectBox = useState(true);
    final _editorLayout = useProvider(editorLayout);
    final _propertyWidth = useProvider(propertyViewAreaSize);
    final _treeWidth = useProvider(treeViewAreaSize);
    final _canvasPos = _editorLayout.list
        .indexWhere((e) => e.id == "canvas-overlay-view-area");
    bool _skip = false;

    useEffect(() {
      Future.delayed(Duration(milliseconds: 100)).then((value) {
        if (context.read(enableCanvasControl).state)
          context.read(canvasState).setSelectedBox();
      });
      return;
    }, [_canvasPos]);

    return Padding(
      padding: EdgeInsets.only(
          right: _canvasPos == 0 ? _treeWidth + _propertyWidth : 0,
          left: _canvasPos == 2 ? _treeWidth + _propertyWidth : 0),
      child: Listener(
        onPointerDown: (_) {
          context.read(activeLayout).state = EditorCanvas.id;
        },
        child: Stack(
          children: [
            // don't add key. problem with auto focusing outside text field.
            CanvasView(
              controller: _canvasState.controller,
              enableControls: _enableControls.state,
              backgroundColor: Theme.of(context).canvasColor,
              maxZoom: _canvasState.maxZoom,
              minZoom: _canvasState.minZoom,
              onSelect: (selected) {
                _canvasState.setSelectBox(null);
                _canvasState.selectItem(selected);
              },
              onDrag: (value, delta, item, overlaps) {
                _showSelectBox.value = !value;
                if (overlaps.isNotEmpty) _canvasState.setSelectBox(null);
                if (context.read(contextMenuState).menu != null)
                  context.read(contextMenuState).clear();
                if (value && item != null) {
                  _skip = item.rootKey != _canvasState.selectedKey;
                  _canvasState
                      .setSelectBox(_canvasState.selectBox?.shift(delta));
                }
                if (value && item == null && !_skip)
                  _canvasState.shiftSelectedBox(delta);
              },
              onZoom: (value) {
                _canvasState.setSelectBox(null);
                _canvasState.setSelectedBox(value);
              },
              onError: (details) {
                Future.delayed(Duration(milliseconds: 0)).then(
                  (value) => context.read(consoleState).addMessage(
                        ConsoleMessage(
                          id: Uuid().v4(),
                          message: details.summary.toString(),
                          type: ConsoleMessageType.error,
                        ),
                      ),
                );
              },
              onDeviceChange: (item, pos) {
                final _menu = context.read(contextMenuState);
                final height =
                    contextMenuItemHeight * deviceSizeTemplate.length;
                Future.delayed(Duration(milliseconds: 150)).then(
                  (value) => _menu.show(
                    id: 'canvas-device-list',
                    offset: pos,
                    width: 250,
                    height: height > MediaQuery.of(context).size.height
                        ? MediaQuery.of(context).size.height
                        : height,
                    menu: ContextMenuContainer(
                      applyRadius: true,
                      child: Column(
                        children: deviceSizeTemplate.entries
                            .map(
                              (e) => ContextMenuItem(
                                e.key,
                                info: ContextMenuHintText(
                                    '${e.value.width.toStringAsFixed(0)}x${e.value.height.toStringAsFixed(0)}'),
                                onTap: () {
                                  item.setSize(e.key, e.value);
                                  _canvasState.notify();
                                  Future.delayed(Duration(milliseconds: 100))
                                      .then(
                                    (value) => _canvasState.setSelectedBox(),
                                  );
                                },
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                );
              },
              onRotate: (item) {
                _canvasState.notify();
              },
              onRemove: (item) {
                _canvasState.remove(item);
              },
              onAdd: (item) {
                _canvasState.addNewFromItem(item);
              },
            ),
            if (_enableControls.state)
              Transform.translate(
                offset: Offset(
                    _canvasPos == 2 ? -(_treeWidth + _propertyWidth) : 0, 0),
                child: CustomPaint(
                    painter: _canvasState.selectedBox != null
                        ? SelectBoxPainter(
                            _canvasState.selectedBox!, Colors.orange)
                        : null),
              ),
            if (_enableControls.state)
              Transform.translate(
                offset: Offset(
                    _canvasPos == 2 ? -(_treeWidth + _propertyWidth) : 0, 0),
                child: CustomPaint(
                  painter:
                      _canvasState.selectBox != null && _showSelectBox.value
                          ? SelectBoxPainter(_canvasState.selectBox!)
                          : null,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
