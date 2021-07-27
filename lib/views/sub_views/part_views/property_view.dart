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
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter_blossom/components/draggable_area.dart';
import 'package:flutter_blossom/components/draggable_target.dart';
import 'package:flutter_blossom/components/micro_components/context_menu_container.dart';
import 'package:flutter_blossom/components/search_list.dart';
import 'package:flutter_blossom/components/tree_icon_button.dart';
import 'package:flutter_blossom/constants/colors.dart';
import 'package:flutter_blossom/generated/l10n.dart';
import 'package:flutter_blossom/helpers/extensions.dart'; // ignore: unused_import
import 'package:flutter/material.dart';
import 'package:flutter_blossom/components/drag_vertical_line.dart';
import 'package:flutter_blossom/states/context_menu_state.dart';
import 'package:flutter_blossom/states/editor_state.dart';
import 'package:flutter_blossom/states/property_state.dart';
import 'package:flutter_blossom/states/storage_state.dart';
import 'package:flutter_blossom/states/tree_state.dart';
import 'package:flutter_blossom/utils/handle_keys.dart';
import 'package:flutter_blossom/views/sub_views/part_views/property_views/properties.dart';
import 'package:flutter_blossom/views/sub_views/part_views/tree_view.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_widget_model/flutter_widget_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:line_icons/line_icons.dart';

class PropertyTitle extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final _activeLayout = useProvider(activeLayout).state;
    final _width = useProvider(propertyViewAreaSize);

    return EditorLayoutDragArea(
      onTap: (_) {},
      width: _width,
      title: S.of(context).propertyView,
      id: PropertyViewArea.id,
      isActive: _activeLayout == PropertyViewArea.id,
    );
  }
}

/// responsible for rendering all property in list view for a given `Node`.
///
/// only used for quick value change. for complex operation
/// use dedicated `view` designed specifically for a property.
class PropertyViewArea extends HookWidget {
  static const id = "property-view-area";
  PropertyViewArea({required this.key}) : super(key: key);
  final GlobalKey key;
  final GlobalKey newBtnKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final _editorLayout = useProvider(editorLayout);
    final _width = useProvider(propertyViewAreaSize);
    final _propertyState = useProvider(propertyState);
    final _contextMenu = useProvider(contextMenuState);
    final length = _editorLayout.list.length;
    final treeIndex = _editorLayout.getIndex(TreeViewArea.id);
    final propertyIndex = _editorLayout.getIndex(id);
    final showAll = useState(true);

    useEffect(() {
      final w =
          context.read(storageState).sharedPreferences.getDouble('property-view-size');
      if (w != null && w != _width)
        Future.delayed(Duration(milliseconds: 100))
            .then((value) => context.read(treeViewNotifier.notifier).set(w));
      return;
    }, const []);

    final _sortedProperties = _propertyState.model?.properties.entries.toList()
      ?..sort((a, b) => a.key.compareTo(b.key));
    if (_sortedProperties != null &&
        _sortedProperties.any((e) => e.key == 'preferredSize')) {
      final p = _sortedProperties.firstWhere((e) => e.key == 'preferredSize');
      _sortedProperties.removeWhere((e) => e.key == 'preferredSize');
      _sortedProperties.insert(0, p);
    }

    return Listener(
      onPointerDown: (_) {
        if (context.read(activeLayout).state != PropertyViewArea.id)
          context.read(activeLayout).state = PropertyViewArea.id;
      },
      child: Stack(
        children: [
          Row(
            children: [
              if (propertyIndex == length - 1 && propertyIndex != 0 ||
                  propertyIndex == treeIndex - 1 && propertyIndex != 0)
                DragVerticalLine(
                  areaKey: key,
                  position: RelativePosition.start,
                  onDrag: (dx) {
                    context.read(propertyViewNotifier.notifier).set(dx);
                  },
                  onTap: () {
                    context.read(propertyViewNotifier.notifier).reset();
                  },
                ),
              Container(
                width: _width,
                color: Theme.of(context).canvasColor.by(panelsBy),
                child: Column(
                  children: [
                    PropertyTitle(),
                    Expanded(
                      child: Container(
                        width: _width,
                        child: Column(
                          children: [
                            if (_propertyState.model != null)
                              Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Row(
                                        children: [
                                          Flexible(
                                            child: Padding(
                                              padding: const EdgeInsets.only(top: 5.0),
                                              child: Text(
                                                _propertyState.model?.name ?? '',
                                                softWrap: false,
                                                overflow: TextOverflow.fade,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyText1!
                                                    .copyWith(
                                                        fontSize: 15,
                                                        color: Theme.of(context)
                                                            .textTheme
                                                            .bodyText1!
                                                            .color!
                                                            .reverseBy(panelBodyBy)),
                                              ),
                                            ),
                                          ),
                                          if (_propertyState.model!.name !=
                                              EnumToString.convertToString(
                                                  _propertyState.model!.type))
                                            Flexible(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 5.0, left: 5.0),
                                                child: Text(
                                                  EnumToString.convertToString(
                                                      _propertyState.model!.type),
                                                  softWrap: false,
                                                  overflow: TextOverflow.fade,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .headline5
                                                      ?.copyWith(
                                                        color: Colors.grey.shade600,
                                                        fontSize: 12,
                                                      ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Row(
                                      children: [
                                        if (!showAll.value)
                                          Text(
                                            '${_sortedProperties?.where((e) => !e.value.isInitialized).toList().length} hidden',
                                            style: Theme.of(context)
                                                .textTheme
                                                .headline5
                                                ?.copyWith(
                                                  color: Colors.grey.shade600,
                                                  fontSize: 13,
                                                ),
                                          ),
                                        if (_propertyState.model?.type == ModelType.Root)
                                          TreeIconButton(
                                            key: newBtnKey,
                                            icon: LineIcons.plus,
                                            size: 18,
                                            tooltip: 'Add Property',
                                            onTap: () {
                                              final offset =
                                                  getCenterOffsetFromKey(newBtnKey);
                                              double hSize =
                                                  MediaQuery.of(context).size.height -
                                                      offset.dy;
                                              hSize = hSize >= 400
                                                  ? hSize
                                                  : MediaQuery.of(context).size.height;
                                              _contextMenu.show(
                                                id: 'property-list',
                                                width: 300,
                                                height: hSize,
                                                offset: offset,
                                                menu: ContextMenuContainer(
                                                  applyRadius: true,
                                                  child: SearchList(
                                                    list: EnumToString.toList(
                                                        PropertyType.values),
                                                    height: hSize,
                                                    onTap: (value) {
                                                      String key =
                                                          'key${(context.read(propertyState).model!.properties.length + 1).toString()}';
                                                      key = key == 'key1' ? 'key' : key;
                                                      final p = EnumToString.fromString(
                                                              PropertyType.values, value)!
                                                          .property;
                                                      context
                                                          .read(propertyState)
                                                          .addProperty({key: p});
                                                    },
                                                  ),
                                                ),
                                              );
                                            },
                                          )
                                        else
                                          TreeIconButton(
                                            icon: _propertyState.model!.isReplaceable
                                                ? LineIcons.starAlt
                                                : LineIcons.star,
                                            size: 16,
                                            tooltip: 'replaceable',
                                            onTap: () {
                                              _propertyState.updateModel(
                                                  _propertyState.model!.coptWith(
                                                      isReplaceable: !_propertyState
                                                          .model!.isReplaceable));
                                            },
                                          ),
                                        TreeIconButton(
                                          icon: showAll.value
                                              ? LineIcons.toggleOff
                                              : LineIcons.toggleOn,
                                          size: 18,
                                          tooltip: showAll.value
                                              ? 'Show with value'
                                              : 'Show all',
                                          onTap: () {
                                            showAll.value = !showAll.value;
                                          },
                                        ),
                                        TreeIconButton(
                                          icon: context.read(treeState).lockKey ==
                                                  _propertyState.model!.key
                                              ? LineIcons.lock
                                              : LineIcons.lockOpen,
                                          size: 18,
                                          tooltip: 'Lock View',
                                          onTap: () {
                                            context
                                                .read(treeState)
                                                .setLock(_propertyState.model!.key);
                                          },
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            Expanded(
                              child: ListView(
                                children: [
                                  if (_propertyState.model != null &&
                                      _sortedProperties != null)
                                    ..._sortedProperties
                                        .map(
                                          (e) => !showAll.value && !e.value.isInitialized
                                              ? SizedBox()
                                              : Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    PropertyEditWidget(e.key, e.value),
                                                    Divider(
                                                        // thickness: 0.8,
                                                        // color: Colors.grey
                                                        //     .withOpacity(0.2),
                                                        ),
                                                  ],
                                                ),
                                        )
                                        .toList(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (propertyIndex == 0 && propertyIndex != length - 1 ||
                  propertyIndex != treeIndex - 1 && propertyIndex != length - 1)
                DragVerticalLine(
                  areaKey: key,
                  onDrag: (dx) {
                    context.read(propertyViewNotifier.notifier).set(dx);
                  },
                  onTap: () {
                    context.read(propertyViewNotifier.notifier).reset();
                  },
                ),
            ],
          ),
          Container(
            width: _width,
            child: EditorLayoutDragTarget(
              id: id,
              acceptId: [TreeViewArea.id],
            ),
          ),
        ],
      ),
    );
  }
}
