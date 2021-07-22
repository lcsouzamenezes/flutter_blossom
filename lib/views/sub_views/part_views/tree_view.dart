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
import 'package:flutter/services.dart';
import 'package:flutter_blossom/components/context_menu_item.dart';
import 'package:flutter_blossom/components/micro_components/context_menu_container.dart';
import 'package:flutter_blossom/components/micro_components/context_menu_hint_text.dart';
import 'package:flutter_blossom/components/node_group_list.dart';
import 'package:flutter_blossom/components/node_model_list.dart';
import 'package:flutter_blossom/constants/colors.dart';
import 'package:flutter_blossom/constants/lengths.dart';
import 'package:flutter_blossom/constants/shapes.dart';
import 'package:flutter_blossom/generated/l10n.dart';
import 'package:flutter_blossom/helpers/extensions.dart';
import 'package:flutter_blossom/components/tree_icon_button.dart';
import 'package:flutter_blossom/components/draggable_area.dart';
import 'package:flutter_blossom/components/draggable_target.dart';
import 'package:flutter_blossom/components/drag_vertical_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blossom/helpers/extensions.dart';
import 'package:flutter_blossom/helpers/tree_icon_handler.dart';
import 'package:flutter_blossom/helpers/tree_notification_icon_handler.dart';
import 'package:flutter_blossom/models/app_clipboard.dart';
import 'package:flutter_blossom/states/canvas_state.dart';
import 'package:flutter_blossom/states/context_menu_state.dart';
import 'package:flutter_blossom/states/editor_state.dart';
import 'package:flutter_blossom/states/model_state.dart';
import 'package:flutter_blossom/states/property_state.dart';
import 'package:flutter_blossom/states/storage_state.dart';
import 'package:flutter_blossom/states/tree_state.dart';
import 'package:flutter_blossom/utils/double_tap.dart';
import 'package:flutter_blossom/utils/handle_keys.dart';
import 'package:flutter_blossom/views/sub_views/part_views/property_view.dart';
import 'package:flutter_blossom/views/sub_views/part_views/property_views/properties/string_property.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_widget_model/flutter_widget_model.dart' hide MyList;
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:keyboard_shortcuts/keyboard_shortcuts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:tree_view/tree_view.dart';
import 'package:uuid/uuid.dart';

bool _isTreeSelectAreaActive = false;

final isNodeDragging = StateProvider((_) => false);

_getFilterValues(Node node, [bool returnAll = false]) {
  List<ModelType> filterValues = [];
  if (node.children.isNotEmpty || returnAll) {
    filterValues = List<ModelType>.from(ModelType.values)
        .where((el) => endTypeList.contains(el))
        .toList();
  }
  return filterValues;
}

class TreeViewArea extends HookWidget {
  static const id = "tree-view-area";
  TreeViewArea({required this.key}) : super(key: key);
  final GlobalKey key;
  final selectNodeKey = GlobalKey();
  final uuid = Uuid();

  final newBtnKey = GlobalKey();
  final parentBtnKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    useProvider(activeLayout);
    final _width = useProvider(treeViewAreaSize);
    final _editorLayout = useProvider(editorLayout);
    final _treeState = useProvider(treeState);
    final _contextMenu = useProvider(contextMenuState);
    final _shadowKey = useProvider(treeShadowKey);
    final _isNodeDragging = useProvider(isNodeDragging);

    final length = _editorLayout.list.length;
    final treeIndex = _editorLayout.getIndex(id);
    final propertyIndex = _editorLayout.getIndex(PropertyViewArea.id);

    useEffect(() {
      final w = context
          .read(storageState)
          .sharedPreferences
          .getDouble('tree-view-size');
      if (w != null && w != _width)
        Future.delayed(Duration(milliseconds: 100))
            .then((value) => context.read(treeViewNotifier.notifier).set(w));
      return;
    }, const []);

    _changeGroup(Node node, [Offset? offset]) {
      final parent = _treeState.controller.getParent(node.key);
      if (parent != null) {
        final _model =
            EnumToString.fromString(ModelType.values, parent.type)!.getModel(
          uuid.v4(),
          parent.group,
        );
        Future.delayed(Duration(milliseconds: 0)).then(
          (value) => _contextMenu.show(
            id: 'tree-node-model-group-list',
            offset: offset,
            menu: ContextMenuContainer(
              applyRadius: true,
              child: NodeGroupList(
                _model,
                node,
                (n, g) {
                  _treeState.changeNode(
                    node.key,
                    node.copyWith(group: g),
                  );
                },
              ),
            ),
          ),
        );
      }
    }

    _toggleReplaceable(Node node) => _treeState.changeNode(
        node.key, node.copyWith(isReplaceable: !node.isReplaceable));

    _replaceNode(Node node, Offset pos) {
      Future.delayed(Duration(milliseconds: 0)).then(
        (value) {
          double hSize = MediaQuery.of(context).size.height - pos.dy;
          hSize = hSize > 300 ? hSize : MediaQuery.of(context).size.height;
          _shadowKey.state = node.key;
          // final filterValues =
          //     _getFilterValues(node);
          _contextMenu.show(
            id: 'tree-node-model-list',
            width: 300,
            height: hSize,
            offset: pos,
            menu: ContextMenuContainer(
              applyRadius: true,
              child: NodeModelList(
                node.group!,
                node,
                height: hSize,
                onTap: (n, m) {
                  _treeState.replaceNode(
                    n.key,
                    m.asMap,
                  );
                },
              ),
            ),
          );
        },
      );
    }

    _duplicateNode(Node node) {
      final parent = _treeState.controller.getParent(node.key);
      if (parent == null)
        _treeState.addNodeToRoot(_treeState.copyWithNewKey(node),
            index: _treeState.controller.children.indexOf(node) + 1);
      else
        _treeState.addNodeWithChildren(
            parent.key, node.copyWith(key: uuid.v4()),
            index: parent.children.indexOf(node) + 1);
    }

    _copyNode(Node node) {
      // Clipboard.setData(ClipboardData(text: jsonEncode(node.asMap)));
      context.read(appClipboardState).state =
          AppClipBoard(data: node, type: AppClipBoardDataType.node);
    }

    _cutNode(Node node) {
      // Clipboard.setData(ClipboardData(text: jsonEncode(node.asMap)));
      context.read(appClipboardState).state =
          AppClipBoard(data: node, type: AppClipBoardDataType.node);
      _treeState.removeNode(node, true);
    }

    _pasteReplaceNode(Node node) {
      // final data =
      //     await Clipboard.getData(
      //         Clipboard
      //             .kTextPlain);
      if (context.read(appClipboardState).state.type ==
              AppClipBoardDataType.node &&
          context.read(appClipboardState).state.data != null &&
          (context.read(appClipboardState).state.data.group == null ||
              node.type != 'Root'))
        _treeState.replaceNode(
          node.key,
          context
              .read(appClipboardState)
              .state
              .data
              .copyWith(key: uuid.v4(), group: node.group)
              .asMap,
        );
    }

    _pasteAsParentNode(Node node, [Offset? pos]) {
      if (node.group != null &&
          context.read(appClipboardState).state.type ==
              AppClipBoardDataType.node &&
          context.read(appClipboardState).state.data != null) return;
      final copyNode = context.read(appClipboardState).state.data;
      if (copyNode != null && node.group != null && copyNode.maxChildren != 0) {
        final _model = EnumToString.fromString(ModelType.values, copyNode.type)!
            .getModel(uuid.v4(), node.group);
        if (copyNode.maxChildren <= 0) {
          _treeState.changeParent(
            node.key,
            _model.asMap,
            _model.childGroups.firstOrNull?.name ?? 'child',
          );
        } else {
          Future.delayed(Duration(milliseconds: 0)).then((value) {
            _contextMenu.show(
              id: 'tree-node-model-group-list',
              offset: pos,
              menu: ContextMenuContainer(
                applyRadius: true,
                child: NodeGroupList(_model, node, (n, g) {
                  _treeState.changeParent(
                    node.key,
                    _model.asMap,
                    g,
                  );
                }),
              ),
            );
          });
        }
      }
    }

    _pasteAsChild(Node node, [Offset? pos]) {
      if (node.maxChildren > 0 &&
          context.read(appClipboardState).state.type ==
              AppClipBoardDataType.node &&
          context.read(appClipboardState).state.data != null &&
          context.read(appClipboardState).state.data.group != null)
        _treeState.addNodeWithChildren(
            node.key, context.read(appClipboardState).state.data);
    }

    _addParent(Node node, [Offset? pos]) {
      if (node.group == null) return;
      _shadowKey.state = node.key;
      final List<ModelType> filterValues = _getFilterValues(node, true);
      pos = pos ?? getCenterOffsetFromKey(parentBtnKey);
      double hSize = MediaQuery.of(context).size.height - pos.dy;
      hSize = hSize > 300 ? hSize : MediaQuery.of(context).size.height;
      _contextMenu.show(
        id: 'tree-node-model-list-filtered',
        width: 300,
        height: hSize,
        offset: pos,
        menu: ContextMenuContainer(
          applyRadius: true,
          child: NodeModelList(
            node.group!,
            node,
            height: hSize,
            filter: filterValues,
            onTap: (n, m) {
              if (m.childGroups.length == 1)
                _treeState.changeParent(
                    n.key, m.asMap, m.childGroups.first.name);
              else if (m.childGroups.length > 1) {
                Future.delayed(Duration(milliseconds: 0)).then(
                  (value) {
                    _shadowKey.state = node.key;
                    _contextMenu.show(
                      id: 'tree-node-model-group-list',
                      offset: null,
                      menu: ContextMenuContainer(
                        applyRadius: true,
                        child: NodeGroupList(
                          m,
                          node,
                          (n, g) {
                            _treeState.changeParent(
                              n.key,
                              m.asMap,
                              g,
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              }
            },
          ),
        ),
      );
    }

    _addNode(Node node, [Offset? pos]) {
      if (node.maxChildren == node.children.length) return;
      _shadowKey.state = node.key;
      final _model = context.read(modelState).controller.getModel(node.key);
      pos = pos ?? getCenterOffsetFromKey(newBtnKey);
      double hSize = MediaQuery.of(context).size.height - pos.dy;
      hSize = hSize > 300 ? hSize : MediaQuery.of(context).size.height;
      if (node.group == null ||
          _model != null && _model.childGroups.length == 1)
        _contextMenu.show(
          id: 'tree-node-model-list',
          width: 300,
          height: hSize,
          offset: pos,
          menu: ContextMenuContainer(
            applyRadius: true,
            child: NodeModelList(
              _model?.childGroups.firstOrNull?.name ?? 'child',
              node,
              height: hSize,
              onTap: (n, m) {
                _treeState.addNode(n.key, m.asMap);
              },
            ),
          ),
        );
      else if (_model != null)
        _contextMenu.show(
          id: 'tree-node-model-group-list',
          offset: pos,
          menu: ContextMenuContainer(
            applyRadius: true,
            child: NodeGroupList(
              _model,
              node,
              (n, g) {
                Future.delayed(Duration(milliseconds: 0)).then(
                  (value) {
                    _shadowKey.state = node.key;
                    _contextMenu.show(
                      id: 'tree-node-model-list',
                      width: 300,
                      height: hSize,
                      offset: pos,
                      menu: ContextMenuContainer(
                        applyRadius: true,
                        child: NodeModelList(
                          g,
                          node,
                          height: hSize,
                          onTap: (n, m) {
                            _treeState.addNode(
                              n.key,
                              m.asMap,
                            );
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
    }

    _focus(Node node) {
      if (node.group != null) return;
      context.read(canvasState).centerOrAdd(node);
      Future.delayed(Duration(milliseconds: 20))
          .then((value) => context.read(canvasState).setSelectedBox());
    }

    return Listener(
      onPointerDown: (_) {
        if (context.read(activeLayout).state != TreeViewArea.id)
          context.read(activeLayout).state = TreeViewArea.id;
      },
      child: Stack(
        children: [
          Row(
            children: [
              if (treeIndex == length - 1 && treeIndex != 0 ||
                  treeIndex == propertyIndex - 1 && treeIndex != 0)
                DragVerticalLine(
                  areaKey: key,
                  position: RelativePosition.start,
                  onDrag: (dx) {
                    context.read(treeViewNotifier.notifier).set(dx);
                  },
                  onTap: () {
                    context.read(treeViewNotifier.notifier).reset();
                  },
                ),
              Container(
                width: _width,
                color: Theme.of(context).canvasColor.by(panelsBy),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    EditorLayoutDragArea(
                      onTap: (_) {},
                      width: _width,
                      title: S.of(context).treeView,
                      id: id,
                      isActive:
                          context.read(activeLayout).state == TreeViewArea.id,
                    ),
                    TreeSelectionArea(id: id),
                    Expanded(
                      child: KeyBoardShortcuts(
                        keysToPress: {
                          LogicalKeyboardKey.controlLeft,
                          LogicalKeyboardKey.shiftLeft,
                          LogicalKeyboardKey.keyT,
                        },
                        onKeysPressed: () {
                          if (_treeState.controller.selectedNode != null)
                            _toggleReplaceable(
                                _treeState.controller.selectedNode!);
                        },
                        child: KeyBoardShortcuts(
                          keysToPress: {
                            LogicalKeyboardKey.controlLeft,
                            LogicalKeyboardKey.shiftLeft,
                            LogicalKeyboardKey.keyD,
                          },
                          onKeysPressed: () {
                            if (context.read(activeLayout).state ==
                                    TreeViewArea.id &&
                                _treeState.controller.selectedNode != null) {
                              final pos = getCenterOffsetFromKey(selectNodeKey);
                              _replaceNode(
                                  _treeState.controller.selectedNode!, pos);
                            }
                          },
                          child: KeyBoardShortcuts(
                            keysToPress: {
                              LogicalKeyboardKey.controlLeft,
                              LogicalKeyboardKey.keyD,
                            },
                            onKeysPressed: () {
                              if (context.read(activeLayout).state ==
                                      TreeViewArea.id &&
                                  _treeState.controller.selectedNode != null) {
                                _duplicateNode(
                                    _treeState.controller.selectedNode!);
                              }
                            },
                            child: KeyBoardShortcuts(
                              keysToPress: {
                                LogicalKeyboardKey.controlLeft,
                                LogicalKeyboardKey.keyC,
                              },
                              onKeysPressed: () {
                                if (context.read(activeLayout).state ==
                                        TreeViewArea.id &&
                                    _treeState.controller.selectedNode !=
                                        null) {
                                  _copyNode(
                                      _treeState.controller.selectedNode!);
                                }
                              },
                              child: KeyBoardShortcuts(
                                keysToPress: {
                                  LogicalKeyboardKey.controlLeft,
                                  LogicalKeyboardKey.keyX,
                                },
                                onKeysPressed: () {
                                  if (context.read(activeLayout).state ==
                                          TreeViewArea.id &&
                                      _treeState.controller.selectedNode !=
                                          null) {
                                    _cutNode(
                                        _treeState.controller.selectedNode!);
                                  }
                                },
                                child: KeyBoardShortcuts(
                                  keysToPress: {
                                    LogicalKeyboardKey.controlLeft,
                                    LogicalKeyboardKey.shiftLeft,
                                    LogicalKeyboardKey.keyX,
                                  },
                                  onKeysPressed: () {
                                    if (context.read(activeLayout).state ==
                                            TreeViewArea.id &&
                                        _treeState.controller.selectedNode !=
                                            null) {
                                      _pasteReplaceNode(
                                          _treeState.controller.selectedNode!);
                                    }
                                  },
                                  child: KeyBoardShortcuts(
                                    keysToPress: {
                                      LogicalKeyboardKey.controlLeft,
                                      LogicalKeyboardKey.shiftLeft,
                                      LogicalKeyboardKey.keyV,
                                    },
                                    onKeysPressed: () {
                                      if (context.read(activeLayout).state ==
                                              TreeViewArea.id &&
                                          _treeState.controller.selectedNode !=
                                              null) {
                                        _pasteAsParentNode(
                                            _treeState.controller.selectedNode!,
                                            getCenterOffsetFromKey(
                                                selectNodeKey));
                                      }
                                    },
                                    child: KeyBoardShortcuts(
                                      keysToPress: {
                                        LogicalKeyboardKey.controlLeft,
                                        LogicalKeyboardKey.keyV,
                                      },
                                      onKeysPressed: () {
                                        if (context.read(activeLayout).state ==
                                                TreeViewArea.id &&
                                            _treeState
                                                    .controller.selectedNode !=
                                                null) {
                                          _pasteAsChild(
                                              _treeState
                                                  .controller.selectedNode!,
                                              getCenterOffsetFromKey(
                                                  selectNodeKey));
                                        }
                                      },
                                      child: KeyBoardShortcuts(
                                        keysToPress: {
                                          LogicalKeyboardKey.controlLeft,
                                          LogicalKeyboardKey.space,
                                        },
                                        onKeysPressed: () {
                                          // ? manage focus
                                          if (context
                                                      .read(activeLayout)
                                                      .state ==
                                                  TreeViewArea.id &&
                                              _treeState.controller
                                                      .selectedNode !=
                                                  null &&
                                              _contextMenu.menu?.id !=
                                                  'tree-node-model-list' &&
                                              _contextMenu.menu?.id !=
                                                  'tree-node-model-group-list') {
                                            final pos = getCenterOffsetFromKey(
                                                selectNodeKey);
                                            _addNode(
                                                _treeState
                                                    .controller.selectedNode!,
                                                pos);
                                          }
                                        },
                                        child: KeyBoardShortcuts(
                                          keysToPress: {
                                            LogicalKeyboardKey.shiftLeft,
                                            LogicalKeyboardKey.space,
                                          },
                                          onKeysPressed: () {
                                            if (context
                                                        .read(activeLayout)
                                                        .state ==
                                                    TreeViewArea.id &&
                                                _treeState.controller
                                                        .selectedNode !=
                                                    null &&
                                                _contextMenu.menu?.id !=
                                                    'tree-node-model-list-filtered') {
                                              final pos =
                                                  getCenterOffsetFromKey(
                                                      selectNodeKey);
                                              _addParent(
                                                  _treeState
                                                      .controller.selectedNode!,
                                                  pos);
                                            }
                                          },
                                          child: KeyBoardShortcuts(
                                            keysToPress: {
                                              LogicalKeyboardKey.delete,
                                            },
                                            onKeysPressed: () {
                                              if (context
                                                          .read(activeLayout)
                                                          .state ==
                                                      TreeViewArea.id &&
                                                  _treeState.controller
                                                          .selectedNode !=
                                                      null) {
                                                _treeState.removeNode(
                                                    _treeState.controller
                                                        .selectedNode!,
                                                    false);
                                              }
                                            },
                                            child: KeyBoardShortcuts(
                                              keysToPress: {
                                                LogicalKeyboardKey.controlLeft,
                                                LogicalKeyboardKey.delete,
                                              },
                                              onKeysPressed: () {
                                                if (context
                                                            .read(activeLayout)
                                                            .state ==
                                                        TreeViewArea.id &&
                                                    _treeState.controller
                                                            .selectedNode !=
                                                        null) {
                                                  _treeState.removeNode(
                                                      _treeState.controller
                                                          .selectedNode!,
                                                      true);
                                                }
                                              },
                                              child: KeyBoardShortcuts(
                                                keysToPress: {
                                                  LogicalKeyboardKey.space,
                                                },
                                                onKeysPressed: () {
                                                  if (context
                                                              .read(
                                                                  activeLayout)
                                                              .state ==
                                                          TreeViewArea.id &&
                                                      _treeState.controller
                                                              .selectedNode !=
                                                          null) {
                                                    _focus(
                                                      _treeState.controller
                                                          .selectedNode!,
                                                    );
                                                  }
                                                },
                                                child: KeyBoardShortcuts(
                                                  keysToPress: {
                                                    LogicalKeyboardKey
                                                        .controlLeft,
                                                    LogicalKeyboardKey.keyG,
                                                  },
                                                  onKeysPressed: () {
                                                    if (context
                                                                .read(
                                                                    activeLayout)
                                                                .state ==
                                                            TreeViewArea.id &&
                                                        _treeState.controller
                                                                .selectedNode !=
                                                            null &&
                                                        _treeState
                                                                .controller
                                                                .selectedNode
                                                                ?.group !=
                                                            null) {
                                                      final pos =
                                                          getCenterOffsetFromKey(
                                                              selectNodeKey);
                                                      _changeGroup(
                                                          _treeState.controller
                                                              .selectedNode!,
                                                          pos);
                                                    }
                                                  },
                                                  child: Listener(
                                                    onPointerDown: (_) =>
                                                        _isTreeSelectAreaActive =
                                                            false,
                                                    child: TreeViewPackage(
                                                      newBtnKey: newBtnKey,
                                                      parentBtnKey:
                                                          parentBtnKey,
                                                      selectedKey:
                                                          selectNodeKey,
                                                      changeGroup: _changeGroup,
                                                      toggleReplaceable:
                                                          _toggleReplaceable,
                                                      replaceNode: _replaceNode,
                                                      duplicateNode:
                                                          _duplicateNode,
                                                      copyNode: _copyNode,
                                                      cutNode: _cutNode,
                                                      pasteReplaceNode:
                                                          _pasteReplaceNode,
                                                      pasteAsParentNode:
                                                          _pasteAsParentNode,
                                                      pasteAsChild:
                                                          _pasteAsChild,
                                                      addParent: _addParent,
                                                      addNode: _addNode,
                                                      focus: _focus,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (treeIndex == 0 && treeIndex != length - 1 ||
                  treeIndex != propertyIndex - 1 && treeIndex != length - 1)
                DragVerticalLine(
                  areaKey: key,
                  onDrag: (dx) {
                    context.read(treeViewNotifier.notifier).set(dx);
                  },
                  onTap: () {
                    context.read(treeViewNotifier.notifier).reset();
                  },
                ),
            ],
          ),
          if (!_isNodeDragging.state)
            Container(
              width: _width,
              child: EditorLayoutDragTarget(
                id: id,
                acceptId: [PropertyViewArea.id],
              ),
            ),
        ],
      ),
    );
  }
}

class TreeViewPackage extends HookWidget {
  TreeViewPackage({
    Key? key,
    required this.newBtnKey,
    required this.parentBtnKey,
    required this.selectedKey,
    required this.changeGroup,
    required this.toggleReplaceable,
    required this.replaceNode,
    required this.duplicateNode,
    required this.copyNode,
    required this.cutNode,
    required this.pasteReplaceNode,
    required this.pasteAsParentNode,
    required this.pasteAsChild,
    required this.addParent,
    required this.addNode,
    required this.focus,
  }) : super(key: key);

  final GlobalKey newBtnKey;
  final GlobalKey parentBtnKey;
  final GlobalKey selectedKey;
  final void Function(Node node, [Offset? offset]) changeGroup;
  final void Function(Node node) toggleReplaceable;
  final void Function(Node node, Offset pos) replaceNode;
  final void Function(Node node) duplicateNode;
  final void Function(Node node) copyNode;
  final void Function(Node node) cutNode;
  final void Function(Node node) pasteReplaceNode;
  final void Function(Node node, [Offset? pos]) pasteAsParentNode;
  final void Function(Node node, [Offset? pos]) pasteAsChild;
  final void Function(Node node, [Offset? pos]) addParent;
  final void Function(Node node, [Offset? pos]) addNode;
  final void Function(Node node) focus;

  final _subMenuHeight = contextMenuItemHeight;

  @override
  Widget build(BuildContext context) {
    final _treeState = useProvider(treeState);
    final _shadowKey = useProvider(treeShadowKey);
    final _contextMenu = useProvider(contextMenuState);
    final _isNodeDragging = useProvider(isNodeDragging);
    final editNode = useState<Node?>(null);
    final hoverNode = useState<Node?>(null);

    useEffect(() {
      if (hoverNode.value != null) hoverNode.value = null;
    }, [_contextMenu.menu]);

    return KeyBoardShortcuts(
      keysToPress: {
        LogicalKeyboardKey.f2,
      },
      onKeysPressed: () {
        if (context.read(activeLayout).state == TreeViewArea.id &&
            !_isTreeSelectAreaActive) {
          editNode.value = _treeState.controller.selectedNode;
        }
      },
      child: TreeView(
        controller: _treeState.controller,
        renameKey: editNode.value?.key,
        // physics: _contextMenu.isActive
        //     ? NeverScrollableScrollPhysics()
        //     : null,
        editField: (key, node) => StringField(
          autofocus: true,
          value: node.name,
          onSubmitted: (value) {
            _treeState.changeNode(
              key,
              node.copyWith(name: value),
            );
            editNode.value = null;
            hoverNode.value = null;
          },
          onEscaped: () {
            editNode.value = null;
            hoverNode.value = null;
          },
          onFocusChange: (focus) {
            if (!focus.hasFocus) {
              editNode.value = null;
              hoverNode.value = null;
            }
          },
        ),
        onHover: (node) {
          if (_contextMenu.menu == null) hoverNode.value = node;
        },
        hoverKey: hoverNode.value?.key,
        shadowKey: _shadowKey.state,
        selectedKey:
            _treeState.treesInfo[_treeState.activeTree]?.selectIndicatorId ??
                _treeState.treesInfo[_treeState.activeTree]?.selectId,
        selectedGlobalKey: selectedKey,
        theme: TreeTheme(
          primaryColor: Theme.of(context).accentColor,
          selectColor: Theme.of(context).canvasColor.by(1),
          hoverColor: Theme.of(context).canvasColor.reverseBy(1),
          shadowColor: Theme.of(context).canvasColor.reverseBy(1),
          treeLineColor: Theme.of(context).canvasColor.reverseBy(4),
          textTheme: Theme.of(context).textTheme.bodyText1!.copyWith(
                color: Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .color!
                    .reverseBy(panelBodyBy),
              ),
          leftPadding: 16,
        ),
        doubleTapDelay: 250,
        onNodeDoubleTap: (node) {
          editNode.value = node;
        },
        onNodeTap: (node) {
          editNode.value = null;
          _treeState.selectNode(node.key);
          if (editNode.value != null) {
            if (editNode.value?.key == context.read(propertyState).model?.key)
              context.read(propertyState).setPropertyView(editNode.value?.key);
          }
        },
        onNodeRightClick: (node, pos) {
          _shadowKey.state = node.key;
          _contextMenu.show(
            id: 'tree-node',
            width: 240,
            height: _subMenuHeight * 11,
            menu: ContextMenuContainer(
              applyRadius: true,
              child: Column(
                children: [
                  ContextMenuItem(
                    S.of(context).nodeMenuGroup,
                    info: ContextMenuHintText('Ctrl+G'),
                    height: _subMenuHeight,
                    onTap: node.group != null ? () => changeGroup(node) : null,
                  ),
                  ContextMenuItem(
                    S.of(context).nodeMenuRename,
                    info: ContextMenuHintText('F2'),
                    height: _subMenuHeight,
                    onTap: () {
                      editNode.value = node;
                    },
                  ),
                  ContextMenuItem(
                    S.of(context).nodeMenuReplace,
                    info: ContextMenuHintText('Ctrl+Shift+D'),
                    height: _subMenuHeight,
                    onTap: node.group != null
                        ? () => replaceNode(node, pos)
                        : null,
                  ),
                  ContextMenuItem(
                    S.of(context).nodeMenuDuplicate,
                    info: ContextMenuHintText('Ctrl+D'),
                    height: _subMenuHeight,
                    onTap: () => duplicateNode(node),
                  ),
                  ContextMenuItem(
                    S.of(context).nodeMenuCopy,
                    info: ContextMenuHintText('Ctrl+C'),
                    height: _subMenuHeight,
                    onTap: () => copyNode(node),
                  ),
                  ContextMenuItem(
                    S.of(context).nodeMenuCut,
                    info: ContextMenuHintText('Ctrl+X'),
                    height: _subMenuHeight,
                    onTap: () => cutNode(node),
                  ),
                  ContextMenuItem(
                    S.of(context).nodeMenuPasteReplace,
                    info: ContextMenuHintText('Ctrl+Shift+X'),
                    height: _subMenuHeight,
                    onTap: context.read(appClipboardState).state.type ==
                                AppClipBoardDataType.node &&
                            (context.read(appClipboardState).state.data.group ==
                                    null ||
                                node.type != 'Root')
                        ? () => pasteReplaceNode(node)
                        : null,
                  ),
                  ContextMenuItem(
                    S.of(context).nodeMenuPasteParent,
                    info: ContextMenuHintText('Ctrl+Shift+V'),
                    height: _subMenuHeight,
                    onTap: node.group != null &&
                            context.read(appClipboardState).state.type ==
                                AppClipBoardDataType.node
                        ? () => pasteAsParentNode(node)
                        : null,
                  ),
                  ContextMenuItem(
                    S.of(context).nodeMenuPasteChild,
                    info: ContextMenuHintText('Ctrl+V'),
                    height: _subMenuHeight,
                    onTap: node.maxChildren > 0 &&
                            context.read(appClipboardState).state.type ==
                                AppClipBoardDataType.node &&
                            context.read(appClipboardState).state.data.group !=
                                null
                        ? () => pasteAsChild(node)
                        : null,
                  ),
                  ContextMenuItem(
                    node.isReplaceable
                        ? S.of(context).nodeMenuUnReplaceable
                        : S.of(context).nodeMenuReplaceable,
                    info: ContextMenuHintText('Ctrl+Shift+T'),
                    height: _subMenuHeight,
                    onTap: () => toggleReplaceable(node),
                  ),
                  ContextMenuItem(
                    S.of(context).nodeMenuDeleteAll,
                    info: ContextMenuHintText('Ctrl+Delete'),
                    height: _subMenuHeight,
                    onTap: () => _treeState.removeNode(node, true),
                  ),
                ],
              ),
            ),
            offset: pos,
          );
        },
        getIconForNode: (node, size) => getTreeIcon(node, size),
        getNotificationIconForNode: (node, size) =>
            getNotificationIcon(node, size, context),
        onIconTap: (node) {
          _treeState.expandNode(node);
        },
        isDragging: _isNodeDragging.state,
        onDragStart: () {
          _isNodeDragging.state = true;
        },
        onDragEnd: () {
          _isNodeDragging.state = false;
        },
        onDragSuccess: (start, end) {
          final node = _treeState.controller.getNode(start);
          if (node != null) {
            final sParent = _treeState.controller.getParent(node.key);
            // final eParent = _treeState.controller.getParent(end.key);
            if (sParent != null) {
              if (sParent.key == end.key &&
                      sParent.children.last.key == start ||
                  end.children.length == end.maxChildren)
                betterPrint("skip move!");
              else
                _treeState.moveNode(end, node,
                    keepChildren:
                        _treeState.controller.getNode(end.key, parent: node) !=
                            null);
            }
          }
        },
        onDragSuccessSecondary: (start, end) {
          final node = _treeState.controller.getNode(start);
          if (node != null) {
            final sParent = _treeState.controller.getParent(node.key);
            final eParent = _treeState.controller.getParent(end.key);
            if (sParent != null &&
                eParent != null &&
                sParent.key == eParent.key) {
              _treeState.reOrderChildren(
                start,
                eParent.children.indexWhere((child) => child.key == end.key),
              );
            } else if ((sParent == null && eParent == null)) {
              _treeState.reOrderChildren(
                start,
                _treeState.controller.children
                    .indexWhere((child) => child.key == end.key),
              );
            }
          }
        },
        buildActionsWidgets: (node) {
          return [
            if (node.group == null)
              TreeIconButton(
                icon: LineIcons.eye,
                tooltip: '${S.of(context).tooltipNodeFocus} (Space)',
                onTap: () => focus(node),
              ),
            TreeIconButton(
              key: newBtnKey,
              icon: LineIcons.plus,
              tooltip: '${S.of(context).tooltipNodeAdd} (Ctrl+Space)',
              onTap: node.maxChildren == node.children.length
                  ? null
                  : () => addNode(node),
            ),
            if (node.group != null)
              TreeIconButton(
                  key: parentBtnKey,
                  icon: LineIcons.reply,
                  tooltip:
                      '${S.of(context).tooltipNodeAddParent} (Shift+Space)',
                  onTap: () => addParent(node)),
            TreeIconButton(
              icon: LineIcons.times,
              tooltip: S.of(context).tooltipNodeDelete,
              onTap: () {
                _treeState.removeNode(node);
              },
            ),
            TreeIconButton(
              icon: LineIcons.minusSquare,
              tooltip: S.of(context).tooltipNodeCollapse,
              onTap: () {
                _treeState.collapseChildren(node);
              },
            )
          ];
        },
      ),
    );
  }
}

class TreeSelectionArea extends HookWidget {
  TreeSelectionArea({
    Key? key,
    required this.id,
  }) : super(key: key);

  final String id;
  final uuid = Uuid();

  @override
  Widget build(BuildContext context) {
    final _treeState = useProvider(treeState);
    final showTrees = useState(false);
    _newTree() {
      showTrees.value = true;
      final key = uuid.v4();
      final no = _treeState.treesInfo.length;
      _treeState.addTree(key, 'tree${no == 0 ? '' : no + 1}');
    }

    _newRootNode() {
      final key = uuid.v4();
      final model = ModelType.Root.getModel(key, null);
      final node = Node.fromMap(model.asMap);
      _treeState.addNodeToRoot(node);
      // editNode.value = node;
    }

    _reloadTree() {
      if (_treeState.recents.isNotEmpty &&
          _treeState.file?.name == _treeState.recents.firstOrNull?.name)
        _treeState.loadFromFile(
            _treeState.recents.first, _treeState.activeTree);
    }

    return Listener(
      onPointerDown: (_) => _isTreeSelectAreaActive = true,
      child: Column(
        children: [
          KeyBoardShortcuts(
            keysToPress: {
              LogicalKeyboardKey.controlLeft,
              LogicalKeyboardKey.keyE
            },
            onKeysPressed: () {
              if (context.read(activeLayout).state == TreeViewArea.id)
                _newRootNode();
            },
            child: KeyBoardShortcuts(
              keysToPress: {
                LogicalKeyboardKey.controlLeft,
                LogicalKeyboardKey.keyT
              },
              onKeysPressed: () {
                if (context.read(activeLayout).state == TreeViewArea.id)
                  _newTree();
              },
              child: KeyBoardShortcuts(
                keysToPress: {
                  LogicalKeyboardKey.controlLeft,
                  LogicalKeyboardKey.shiftLeft,
                  LogicalKeyboardKey.keyR
                },
                onKeysPressed: () {
                  if (context.read(activeLayout).state == TreeViewArea.id)
                    _reloadTree();
                },
                child: InkWell(
                  onTap: () {
                    showTrees.value = !showTrees.value;
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 5.0),
                              child: Icon(
                                showTrees.value
                                    ? Icons.keyboard_arrow_down
                                    : Icons.keyboard_arrow_right,
                                size: 16,
                              ),
                            ),
                            SizedBox(
                              width: 2,
                            ),
                            Text(
                              _treeState
                                      .treesInfo[_treeState.activeTree]?.name ??
                                  '',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Row(
                          children: [
                            TreeIconButton(
                              icon: LineIcons.plus,
                              size: 16,
                              tooltip:
                                  '${S.of(context).tooltipNewRoot} (Ctrl+E)',
                              onTap: () => _newRootNode(),
                            ),
                            TreeIconButton(
                              icon: LineIcons.plusSquare,
                              size: 16,
                              tooltip:
                                  '${S.of(context).tooltipNewTree} (Ctrl+T)',
                              onTap: () => _newTree(),
                            ),
                            TreeIconButton(
                              icon: LineIcons.alternateRedo,
                              size: 16,
                              tooltip:
                                  '${S.of(context).tooltipReloadTree} (Ctrl+Shift+R)',
                              onTap: _reloadTree,
                            ),
                            TreeIconButton(
                              icon: LineIcons.minusSquare,
                              size: 16,
                              tooltip: S.of(context).tooltipCollapseTree,
                              onTap: () {
                                _treeState.collapseChildren();
                              },
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (showTrees.value)
            Column(
              children: _treeState.treesInfo.keys
                  .map((e) => TreeItem(
                        treeKey: e,
                      ))
                  .toList(),
            ),
          Divider(
            height: 2,
            thickness: 1,
          ),
        ],
      ),
    );
  }
}

class TreeItem extends HookWidget {
  const TreeItem({
    Key? key,
    required this.treeKey,
  }) : super(key: key);

  final String treeKey;

  @override
  Widget build(BuildContext context) {
    final _treeState = useProvider(treeState);
    final treeNameEdit = useState(false);
    final isOnHover = useState(false);

    _editName() {
      treeNameEdit.value = true;
    }

    return Container(
      color: _treeState.activeTree == treeKey
          ? Theme.of(context).canvasColor.by(1)
          : isOnHover.value
              ? Theme.of(context).canvasColor.reverseBy(1)
              : null,
      height: 28,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        child: treeNameEdit.value
            ? StringField(
                key: ValueKey(treeKey),
                autofocus: true,
                value: _treeState.treesInfo[treeKey]!.name,
                onSubmitted: (name) {
                  _treeState.renameTree(treeKey,
                      name == '' ? _treeState.treesInfo[treeKey]!.name : name);
                  treeNameEdit.value = false;
                },
                onFocusChange: (focus) {
                  if (!focus.hasFocus) {
                    treeNameEdit.value = false;
                    isOnHover.value = false;
                  }
                },
                onEscaped: () {
                  treeNameEdit.value = false;
                },
              )
            : GestureDetector(
                onSecondaryTapDown: (details) {
                  context.read(contextMenuState).show(
                        id: 'tree-item',
                        height: contextMenuItemHeight * 3,
                        offset: details.globalPosition,
                        menu: ContextMenuContainer(
                          applyRadius: true,
                          child: Column(
                            children: [
                              ContextMenuItem(S.of(context).treeMenuRename,
                                  info: ContextMenuHintText('F2'),
                                  height: contextMenuItemHeight,
                                  onTap: _editName),
                              ContextMenuItem(
                                S.of(context).treeMenuMoveUp,
                                height: contextMenuItemHeight,
                                onTap: _treeState.treesInfo.keys
                                            .toList()
                                            .indexWhere((e) => e == treeKey) >
                                        0
                                    ? () {
                                        _treeState.moveTreeUp(treeKey);
                                      }
                                    : null,
                              ),
                              ContextMenuItem(
                                S.of(context).treeMenuPasteRoot,
                                height: contextMenuItemHeight,
                                onTap: context
                                                .read(appClipboardState)
                                                .state
                                                .type ==
                                            AppClipBoardDataType.node &&
                                        (context
                                                    .read(appClipboardState)
                                                    .state
                                                    .data as Node?)
                                                ?.type ==
                                            'Root'
                                    ? () {
                                        final node = _treeState.copyWithNewKey(
                                            context
                                                .read(appClipboardState)
                                                .state
                                                .data); //! fix
                                        _treeState.addNodeToRoot(
                                          node,
                                          treeKey: treeKey,
                                        );
                                      }
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      );
                },
                child: InkWell(
                  mouseCursor: SystemMouseCursors.basic,
                  onHover: (value) {
                    isOnHover.value = value && !treeNameEdit.value;
                  },
                  onTap: () {
                    // if (!treeNameEdit.value)
                    //   _treeState.renameTree(
                    //       treeNameEdit.state ?? '', editController.text);
                    treeNameEdit.value = false;
                    _treeState.switchTree(treeKey);
                  },
                  child: Stack(
                    children: [
                      Row(
                        children: [
                          DoubleTap(
                            onDoubleTap: () {
                              Future.delayed(Duration(milliseconds: 0))
                                  .then((value) => _editName());
                            },
                            doubleDelay: 300,
                            child: Text(
                              _treeState.treesInfo[treeKey]?.name ?? '',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyText1!
                                  .copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText1!
                                        .color!
                                        .reverseBy(panelBodyBy),
                                  ),
                            ),
                          ),
                        ],
                      ),
                      if (isOnHover.value)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TreeIconButton(
                              icon: LineIcons.times,
                              tooltip: S.of(context).tooltipDeleteTree,
                              onTap: () {
                                _treeState.removeTree(treeKey);
                              },
                            )
                          ],
                        ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
