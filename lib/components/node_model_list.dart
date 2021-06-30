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
import 'package:flutter_blossom/components/micro_components/context_menu_container.dart';
import 'package:flutter_blossom/constants/lengths.dart';
import 'package:flutter_blossom/helpers/get_models_list.dart';
import 'package:flutter_blossom/helpers/extensions.dart';
import 'package:flutter_blossom/states/context_menu_state.dart';
import 'package:flutter_blossom/views/sub_views/part_views/tree_view.dart';
import 'package:flutter_blossom/states/model_state.dart';
import 'package:flutter_blossom/states/tree_state.dart';
// ignore_for_file: import_of_legacy_library_into_null_safe, unused_import
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:keyboard_shortcuts/keyboard_shortcuts.dart';
import 'package:tree_view/tree_view.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_widget_model/flutter_widget_model.dart';

final modelListSelectIndex = StateProvider((_) => -1);
final modelTypeList = StateProvider<List<NodeType>>((_) => []);

class NodeModelList extends HookWidget {
  static const id = 'tree-node-model-list';
  NodeModelList(
    this.group,
    this.node, {
    required this.onTap,
    this.filter = const [],
    this.isInherit = false,
    this.height = 300.0,
  });
  final String group;
  final Node node;
  final List<NodeType> filter;
  final uuid = Uuid();
  final void Function(Node node, WidgetModel model) onTap;
  final bool isInherit;
  final double height;
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final _contextMenu = useProvider(contextMenuState);
    final _selectIndex = useProvider(modelListSelectIndex);
    final _searchLock = useState(true);
    final types = useProvider(modelTypeList);
    useEffect(() {
      Future.delayed(Duration(milliseconds: 0)).then((value) {
        types.state = getNodeModelList(filter);
        _selectIndex.state = -1;
      });
      return;
    }, const []);
    _search(String searchTerm) {
      _selectIndex.state = -1;
      final list = getNodeModelList(filter);
      types.state = [];
      list.forEach((type) {
        if (_searchLock.value) {
          // betterPrint('${type.toString().toLowerCase()}');
          if (EnumToString.convertToString(type)
              .toString()
              .toLowerCase()
              .startsWith(searchTerm.toLowerCase())) {
            types.state = [...types.state, type];
          }
        } else {
          if (EnumToString.convertToString(type)
              .toString()
              .toLowerCase()
              .contains(searchTerm.toLowerCase())) {
            types.state = [...types.state, type];
          }
        }
      });
    }

    _onTap(
      String key,
      NodeType type, [
      String? label,
      String? inheritKey,
    ]) {
      if (type == NodeType.Inherit && !isInherit)
        _contextMenu.show(
          id: 'tree-node-inherit-list',
          menu: ContextMenuContainer(
            child: NodeModelList(
              group,
              node,
              onTap: onTap,
              filter: filter,
              isInherit: true,
              height: height,
            ),
          ),
          offset: null,
        );
      else {
        final model = getWidgetModel(key, group, type, label, inheritKey);
        if (model != null) onTap(node, model);
        context.read(editNodeName).state = null;
        _contextMenu.clear();
      }
    }

    Widget getRow(
      int i,
      String key,
      NodeType type, [
      String? label,
      String? inheritKey,
    ]) {
      return KeyBoardShortcuts(
        keysToPress: {LogicalKeyboardKey.enter},
        onKeysPressed: () {
          if ((context.read(contextMenuState).menu?.id ==
                      'tree-node-model-list-filtered' ||
                  context.read(contextMenuState).menu?.id ==
                      'tree-node-model-list') &&
              _selectIndex.state == i)
            _onTap(
              key,
              type,
              label,
              inheritKey,
            );
        },
        child: Container(
          decoration: _selectIndex.state == i
              ? BoxDecoration(
                  border: Border.all(
                      color: Theme.of(context).canvasColor, width: 1.5))
              : null,
          child: ContextMenuItem(
            label ?? EnumToString.convertToString(type),
            height: contextMenuItemHeightDense,
            isDense: true,
            onTap: () => _onTap(
              key,
              type,
              label,
              inheritKey,
            ),
          ),
        ),
      );
    }

    return Stack(
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: isInherit
              ? context.read(treeState).treesInfo.entries.map((e) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          e.value.name,
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                      if (context.read(treeState).trees.containsKey(e.key))
                        ...context
                            .read(treeState)
                            .trees[e.key]!
                            .children
                            .map((n) {
                          if (context.read(treeState).getRoot(node)?.key ==
                              n.key) return SizedBox();
                          return getRow(
                              -1, uuid.v4(), NodeType.Inherit, n.name, n.key);
                        }).toList()
                    ],
                  );
                }).toList()
              : [
                  SizedBox(
                    height: 44,
                  ),
                  SizedBox(
                    height: height - 50,
                    child: ListView.builder(
                      itemCount: types.state.length,
                      itemBuilder: (ctx, i) =>
                          getRow(i, uuid.v4(), types.state[i]),
                    ),
                  ),
                ],
        ),
        if (!isInherit)
          Padding(
            padding: const EdgeInsets.only(
                left: 4.0, right: 4.0, top: 12.0, bottom: 2.0),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: (value) {
                _search(value);
              },
              decoration: InputDecoration(
                hintText: 'Search',
                isDense: true,
                suffix: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      color: Theme.of(context).canvasColor.darken(5),
                      padding: const EdgeInsets.all(1.0),
                      child: Text(
                        '${types.state.length}',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      width: 2,
                    ),
                    InkWell(
                      onTap: () {
                        _searchLock.value = !_searchLock.value;
                        _search(_searchController.text);
                      },
                      child: Container(
                        color: _searchLock.value
                            ? Theme.of(context).canvasColor.darken(5)
                            : null,
                        child: Icon(
                          Icons.text_rotation_none_outlined,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
