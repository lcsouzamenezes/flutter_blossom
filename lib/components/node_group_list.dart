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
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blossom/components/context_menu_item.dart';
import 'package:flutter_blossom/constants/lengths.dart';
import 'package:flutter_blossom/helpers/get_models_list.dart';
import 'package:flutter_blossom/states/context_menu_state.dart';
import 'package:flutter_blossom/views/sub_views/part_views/tree_view.dart';
import 'package:flutter_blossom/states/tree_state.dart';
// ignore_for_file: import_of_legacy_library_into_null_safe, unused_import
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_widget_model/flutter_widget_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:keyboard_shortcuts/keyboard_shortcuts.dart';
import 'package:tree_view/tree_view.dart';
import 'package:uuid/uuid.dart';

final modelGroupListSelectIndex = StateProvider((_) => -1);
final modelGroupTypeList = StateProvider<List<String>>((_) => []);

class NodeGroupList extends HookWidget {
  static const id = 'node-model-group-list';
  NodeGroupList(this.model, this.node, this.onTap);
  final WidgetModel model;
  final Node node;
  final void Function(Node node, String group) onTap;

  @override
  Widget build(BuildContext context) {
    final _selectIndex = useProvider(modelGroupListSelectIndex);
    final _list = useProvider(modelGroupTypeList);
    useEffect(() {
      Future.delayed(Duration(milliseconds: 0)).then((value) {
        _list.state = model.childGroups.map((e) => e.name).toList();
        if (model.type == ModelType.Inherit)
          _list.state.removeAt(_list.state.length - 1);
        _selectIndex.state = -1;
      });
      return;
    }, const []);
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 31.0 * _list.state.length,
            child: ListView.builder(
              itemCount: _list.state.length,
              itemBuilder: (ctx, i) {
                final isExist = false;
                // node.children.any((el) => el.group == e && e != 'children');
                return KeyBoardShortcuts(
                  keysToPress: {LogicalKeyboardKey.enter},
                  onKeysPressed: () {
                    if (context.read(contextMenuState).menu?.id ==
                            'tree-node-model-group-list' &&
                        _selectIndex.state == i) if (!isExist) {
                      onTap(node, _list.state[i]);
                      context.read(editNodeName).state = null;
                      context.read(contextMenuState).clear();
                    }
                  },
                  child: Container(
                    decoration: _selectIndex.state == i
                        ? BoxDecoration(
                            border: Border.all(
                                color: Theme.of(context).canvasColor,
                                width: 1.5))
                        : null,
                    child: ContextMenuItem(
                      _list.state[i],
                      height: contextMenuItemHeightDense,
                      isDense: true,
                      onTap: isExist
                          ? null
                          : () {
                              onTap(node, _list.state[i]);
                              context.read(editNodeName).state = null;
                              context.read(contextMenuState).clear();
                            },
                    ),
                  ),
                );
              },
            ),
          ),
        ]);
  }
}
