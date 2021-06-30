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
import 'package:flutter_blossom/helpers/widget_wrapper.dart';
import 'package:flutter_blossom/states/context_menu_state.dart';
import 'package:flutter_blossom/states/editor_state.dart';
import 'package:flutter_blossom/views/sub_views/part_views/overlay_view.dart';
import 'package:flutter_blossom/views/sub_views/part_views/property_view.dart';
import 'package:flutter_blossom/views/sub_views/part_views/tree_view.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class EditorPanels extends HookWidget {
  final treeAreaKey = GlobalKey();
  final canvasAreaKey = GlobalKey();
  final propertyAreaKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    final _editorLayout = useProvider(editorLayout);

    useEffect(() {
      final areaViewList = [
        WidgetWrapper(
          id: TreeViewArea.id,
          child: TreeViewArea(
            key: treeAreaKey,
          ),
        ),
        WidgetWrapper(
          id: CanvasOverlayViewArea.id,
          child: CanvasOverlayViewArea(key: canvasAreaKey),
        ),
        WidgetWrapper(
          id: PropertyViewArea.id,
          child: PropertyViewArea(
            key: propertyAreaKey,
          ),
        ),
      ];
      if (_editorLayout.list.isEmpty)
        _editorLayout.initializeList(areaViewList);
      else {
        Future.delayed(Duration(milliseconds: 0)).then((value) {
          context.read(contextMenuState).clear();
          context.read(contextMenuState).clearSubMenus();
        });
      }
      return;
    }, const []);
    return Container(
      child: Stack(
        children: [
          Row(
            children: [..._editorLayout.list.map((widget) => widget.child)],
          ),
        ],
      ),
    );
  }
}
