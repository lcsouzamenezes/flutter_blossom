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

import 'package:flutter/material.dart';
import 'package:flutter_blossom/helpers/extensions.dart'; // ignore: unused_import
import 'package:flutter_blossom/components/draggable_target.dart';
import 'package:flutter_blossom/states/canvas_state.dart';
import 'package:flutter_blossom/views/sub_views/part_views/property_view.dart';
import 'package:flutter_blossom/views/sub_views/part_views/tree_view.dart';
import 'package:blossom_canvas/blossom_canvas.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class CanvasOverlayViewArea extends HookWidget {
  static const id = "canvas-overlay-view-area";
  CanvasOverlayViewArea({required GlobalKey key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final _canvasState = useProvider(canvasState);
    final _enableControls = useProvider(enableCanvasControl);

    return Expanded(
      child: Container(
        child: Stack(
          children: [
            if (_enableControls.state)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    color: Theme.of(context).canvasColor.withOpacity(0.2),
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Row(
                      children: [
                        // CanvasControls(),
                        Text(
                          'Zoom: ${_canvasState.controller.zoom.toStringAsFixed(1)}',
                          style: TextStyle(
                              color: Theme.of(context).canvasColor.lighten(25)),
                        ),
                        TextButton(
                          onPressed: () {
                            _canvasState.controller.setZoom(1.0);
                            _canvasState.notify();
                            Future.delayed(Duration(milliseconds: 20))
                                .then((value) => _canvasState.setSelectedBox());
                          },
                          child: Text('Reset'),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            EditorLayoutDragTarget(
              id: id,
              acceptId: [TreeViewArea.id, PropertyViewArea.id],
            ),
          ],
        ),
      ),
    );
  }
}

class CanvasControls extends HookWidget {
  const CanvasControls({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final enableControls = useProvider(enableCanvasControl);
    final _canvasState = useProvider(canvasState);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.filter_2),
          onPressed: enableControls.state && _canvasState.selected != null
              ? () => _canvasState.reorder(Restack.top)
              : null,
        ),
        IconButton(
          icon: Icon(Icons.filter_1),
          onPressed: enableControls.state && _canvasState.selected != null
              ? () => _canvasState.reorder(Restack.up)
              : null,
        ),
        IconButton(
          icon: Icon(Icons.filter_8),
          onPressed: enableControls.state && _canvasState.selected != null
              ? () => _canvasState.reorder(Restack.down)
              : null,
        ),
        IconButton(
          icon: Icon(Icons.filter_9),
          onPressed: enableControls.state && _canvasState.selected != null
              ? () => _canvasState.reorder(Restack.bottom)
              : null,
        )
      ],
    );
  }
}
