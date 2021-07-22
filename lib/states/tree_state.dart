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

import 'dart:convert';
import 'dart:typed_data';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blossom/constants/colors.dart';
import 'package:flutter_blossom/constants/shapes.dart';
import 'package:flutter_blossom/models/console_message.dart';
import 'package:flutter_blossom/states/app_state.dart';
import 'package:flutter_blossom/states/console_state.dart';
import 'package:flutter_blossom/states/model_state.dart';
import 'package:flutter_blossom/states/property_state.dart';
import 'package:flutter_blossom/states/storage_state.dart';
import 'package:flutter_widget_model/flutter_widget_model.dart' hide MyList;
import 'package:path/path.dart' show basename;

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:blossom_canvas/blossom_canvas.dart';
import 'package:flutter_blossom/helpers/extensions.dart';
import 'package:flutter_blossom/helpers/tree_icon_handler.dart';
import 'package:flutter_blossom/views/sub_views/part_views/property_view.dart';
import 'package:flutter_blossom/views/sub_views/part_views/tree_view.dart';
import 'package:flutter_blossom/views/editor_view.dart';
import 'package:flutter_blossom/states/canvas_state.dart';
// import 'package:flutter_blossom/states/context_menu_state.dart';
// import 'package:flutter_blossom/states/model_state.dart';
// import 'package:flutter_blossom/states/property_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tree_view/tree_view.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:better_print/better_print.dart';
import 'package:uuid/uuid.dart';

final treeShadowKey = StateProvider<String?>((_) => null);

final typeGroup = XTypeGroup(label: 'json', extensions: ['json']);

class TreeViewHistory {
  String? activeTree;
  final Map<String, String> treeInfo;
  final Map<String, String> trees;
  TreeViewHistory({
    this.activeTree,
    required this.treeInfo,
    required this.trees,
  });
}

class TreeInfo {
  String name;
  String? selectId;
  String? selectIndicatorId;
  List<String> notificationKeys;
  List<String> warningKeys;
  TreeInfo({
    required this.name,
    required this.selectId,
    this.selectIndicatorId,
    required this.notificationKeys,
    required this.warningKeys,
  });

  factory TreeInfo.fromMap(map) {
    return TreeInfo(
      name: map["name"],
      selectId: map["selectId"],
      selectIndicatorId: map["indicatorId"],
      notificationKeys: List<String>.from(map["notifications"]),
      warningKeys: List<String>.from(map["warnings"]),
    );
  }

  Map toMap() {
    return {
      "name": name,
      "selectId": selectId,
      "indicatorId": selectIndicatorId,
      "notifications": notificationKeys,
      "warnings": warningKeys
    };
  }
}

final treeState = ChangeNotifierProvider((ref) => TreeViewNotifier(ref));

class TreeViewNotifier extends ChangeNotifier {
  final ProviderReference _ref;
  TreeViewNotifier(ref) : _ref = ref;
  final uuid = Uuid();
  TreeViewController _controller = TreeViewController();
  String? _activeTree;
  String? _lockKey;
  Map<String, TreeViewController> _trees = {};
  Map<String, TreeInfo> _treeInfo = {};
  List<TreeViewHistory> _history = [];
  int _currentHistoryIndex = 0;
  XFile? _file;
  List<XFile> _recents = [];
  bool isFileEdited = false;
  Map<String, TreeViewController> get trees => _trees;
  Map<String, TreeInfo> get treesInfo => _treeInfo;
  String? get activeTree => _activeTree;
  String? get lockKey => _lockKey;
  TreeViewController get controller => _controller;
  bool get isUndoAble => _currentHistoryIndex != 0;
  bool get isRedoAble => _currentHistoryIndex != _history.length - 1;
  XFile? get file => _file;
  List<XFile> get recents => _recents;
  int get maxOnRecentsList => 12;

  bool _selectedOnce = false;

  var alreadyLoadedRecents = false;
  loadRecents() {
    _recents = _ref
            .read(storageState)
            .sharedPreferences
            .getStringList('recent-files')
            ?.map((e) => XFile(e))
            .toList() ??
        [];
    alreadyLoadedRecents = true;
  }

  initTree([XFile? file]) {
    if (file != null || _recents.isNotEmpty)
      loadFromFile(file ?? _recents.first);
  }

  setEditStatus(bool val) {
    isFileEdited = val;
    notifyListeners();
  }

  setLock(String? key) {
    _lockKey = key == _lockKey ? null : key;
    _ref
        .read(propertyState)
        .setPropertyView(_lockKey ?? _treeInfo[_activeTree]?.selectId);
  }

  _addToHistory([bool setEditToFalse = false]) {
    if (setEditToFalse) _history.clear();
    if (_trees.containsKey(_activeTree)) {
      if (_history.length != 0 && _currentHistoryIndex != _history.length - 1)
        _history.removeRange(_currentHistoryIndex + 1, _history.length);
      _trees[_activeTree!] = _controller;
      _history.add(
        TreeViewHistory(
            activeTree: _activeTree,
            treeInfo: _treeInfo
                .map((key, value) => MapEntry(key, jsonEncode(value.toMap()))),
            trees: _trees.map((key, value) => MapEntry(key, value.toString()))),
      );
      _ref.read(modelState).getModels();
      _currentHistoryIndex = _history.length - 1;
    } else
      betterPrint("[activeTree] does not exit.");
    if (setEditToFalse)
      isFileEdited = false;
    else
      isFileEdited = true;
    notifyListeners();
  }

  undo() {
    final index = _currentHistoryIndex > 0 ? _currentHistoryIndex - 1 : 0;
    _currentHistoryIndex = index;
    _moveHistory(index);
  }

  redo() {
    final index = _currentHistoryIndex == _history.length - 1
        ? _history.length - 1
        : _currentHistoryIndex + 1;
    _currentHistoryIndex = index;
    _moveHistory(index);
  }

  _moveHistory(int index) {
    _activeTree = _history[index].activeTree ?? _activeTree;
    if (_activeTree != null) {
      _treeInfo = _history[index].treeInfo.map(
          (key, value) => MapEntry(key, TreeInfo.fromMap(jsonDecode(value))));
      _trees = _history[index].trees.map((key, value) => MapEntry(
          key,
          _controller.loadJSON(
              json: value, selectKey: _treeInfo[_activeTree]!.selectId ?? '')));
      _controller = _trees[_activeTree]!;
      _ref.read(modelState).getModels();
    } else
      betterPrint('error');
    _ref
        .read(propertyState)
        .setPropertyView(_lockKey ?? _treeInfo[_activeTree]?.selectId);
    notifyListeners();
  }

  void switchTree(String tree) {
    if (_trees.containsKey(tree) && _activeTree != tree) {
      if (_activeTree != null) _trees[_activeTree!] = _controller;
      _activeTree = tree;
      _controller = _trees[_activeTree]!;
      _addToHistory();
    }
    // notifyListeners();
  }

  void addTree(String key, String name) {
    if (key != '' && !_trees.containsKey(key)) {
      _trees[key] = TreeViewController();
      _treeInfo[key] = TreeInfo(
          name: name, notificationKeys: [], warningKeys: [], selectId: null);
    }
    // if (_activeTree == null) {
    _activeTree = key;
    _controller = _trees[key]!;
    // }

    _addToHistory();
  }

  moveTreeUp(String key) {
    if (!treesInfo.containsKey(key)) return;
    _treeInfo.moveUp(key);
    _trees.moveUp(key);
    notifyListeners();
  }

  void removeTree(String key) {
    if (_treeInfo.containsKey(key)) _treeInfo.remove(key);
    if (_trees.containsKey(key)) _trees.remove(key);
    _activeTree = _treeInfo.length > 0 ? _treeInfo.keys.first : null;
    if (_activeTree != null && _trees.containsKey(_activeTree))
      _controller = _trees[_activeTree]!;
    else
      _controller = TreeViewController();
    _addToHistory();
  }

  void renameTree(String key, String name) {
    _treeInfo[key]?.name = name;
    _addToHistory();
  }

  /// turn text into json >> json into map >> map into [TreeViewController] >> attach to [_controller]
  void _setStringToController(String jsonText, [String? tree]) {
    // try {
    final jsonMap = jsonDecode(jsonText);
    if (isMapValid(jsonMap)) {
      final trees = Map<String, dynamic>.from(jsonMap['trees']);
      if (tree == null)
        (jsonMap['treeInfo']).forEach((key, value) {
          _treeInfo[key] = TreeInfo.fromMap(value);
        });
      if (trees.isNotEmpty) {
        if (tree == null)
          _activeTree = trees.keys.contains(jsonMap['activeTree'])
              ? jsonMap['activeTree']
              : trees.keys.first;
        trees.forEach((key, value) {
          if (tree == null || tree == key)
            _trees[key] = TreeViewController().loadMap(
              map: List<Map<String, dynamic>>.from(trees[key]),
              selectKey: _treeInfo[_activeTree]?.selectId,
            );
        });
        if (_trees.containsKey(_activeTree)) {
          _controller = _trees[_activeTree]!;
          Future.delayed(Duration(milliseconds: 0)).then((value) => _ref
              .read(propertyState)
              .setPropertyView(_controller.selectedKey));
        }
        if (jsonMap['canvasInfo'] != null) {
          (jsonMap['canvasInfo'] as List).forEach((el) {
            if (_trees.values.any(
                (element) => element.children.any((e) => e.key == el['root'])))
              _ref.read(canvasState).setView(
                    CanvasItem(
                      el['key'],
                      el['root'],
                      el['label'],
                      null,
                      Size(el['size']['width'], el['size']['height']),
                      el['sizeProfile'],
                      el['rotate'] ?? false,
                      Offset(el['offset']['x'], el['offset']['y']),
                    ),
                  );
            else
              betterPrint('not found: ${el['root']}');
          });
        }
      }
    } else {
      betterPrint('File is not correctly formatted.');
    }
    _addToHistory(tree == null);
    // } catch (e) {
    //   betterPrint('Not a valid JSON text.');
    // }
  }

  /// check the map contains all the necessary data
  bool isMapValid(Map map) {
    final isActiveTreeNameOk =
        map.containsKey('activeTree') && map['activeTree'] == null ||
            map['activeTree'] is String;
    final isTreeNamesOk = map.containsKey('treeInfo') && map['treeInfo'] is Map;
    final isTreesOk =
        map.containsKey('trees') && map['trees'] != null && map['trees'] is Map;
    return isActiveTreeNameOk && isTreeNamesOk && isTreesOk;
  }

  Map _treesAsMap() {
    final Map map = {};
    _trees.forEach((key, value) {
      map[key] = value.asMap;
    });
    return map;
  }

  clearRecentList([bool keepLast = false]) {
    final first = _recents.firstOrNull;
    _recents.clear();
    if (keepLast && first != null) _recents.add(first);
    _ref.read(storageState).sharedPreferences.setStringList('recent-files', []);
  }

  saveToRecentList(XFile file) {
    if (_recents.length > maxOnRecentsList)
      _recents.removeAt(_recents.length - 1);
    _recents.removeWhere((e) => e.path == file.path);
    _recents.insert(0, file);
    _ref
        .read(storageState)
        .sharedPreferences
        .setStringList('recent-files', _recents.map((e) => e.path).toList());
  }

  removeFromRecentList(XFile file) {
    _recents.removeWhere((e) => e.path == file.path);
    _ref
        .read(storageState)
        .sharedPreferences
        .setStringList('recent-files', _recents.map((e) => e.path).toList());
    notifyListeners();
  }

  /// load from a valid system file
  Future<void> loadFromFile([XFile? file, String? tree]) async {
    if (file == null)
      file = await openFile(
        acceptedTypeGroups: [typeGroup],
      );
    if (file == null) return;
    _file = file;
    try {
      final json = await file.readAsString();
      if (tree == null) resetTree();
      _setStringToController(json, tree);
      saveToRecentList(file);
    } catch (e) {
      betterPrint('file doesn\'t exits');
      _recents.removeWhere((e) => e.path == file?.path);
    }
    return;
  }

  resetTree() {
    _activeTree = null;
    _treeInfo = {};
    _trees = {};
    _history = [];
    _currentHistoryIndex = 0;
    _controller = TreeViewController();
    _ref.read(canvasState).resetViewList();
    _ref.read(treeShadowKey).state = null;
    _ref.read(propertyState).setPropertyView(null);
  }

  newProject(
      [noFile = false,
      Map<String, dynamic>? content,
      String? suggestedFileName]) async {
    content = content ??
        {
          "activeTree": null,
          "treeInfo": {},
          "canvasInfo": {},
          "trees": {},
        };
    String? path;
    if (!noFile)
      path = await getSavePath(
          acceptedTypeGroups: [typeGroup], confirmButtonText: 'create');
    else
      path = suggestedFileName ?? '.';
    if (path == null) return;
    if (path != '.' && !path.endsWith('.json')) path = '$path.json';
    final data = Uint8List.fromList(jsonEncode(content).codeUnits);
    final mimeType = "text/plain";
    _file = XFile.fromData(data,
        name: basename(path), path: path, mimeType: mimeType);
    if (!noFile) {
      saveToRecentList(_file!);
      await _file!.saveTo(path);
    }
    resetTree();
    _setStringToController(jsonEncode(content));
    isFileEdited = true;
    notifyListeners();
  }

  /// save to a system file
  Future<bool> saveToFile({bool saveAs = false, String? name}) async {
    final content = {
      "activeTree": _activeTree,
      "treeInfo": _treeInfo.map((key, value) => MapEntry(key, value.toMap())),
      "canvasInfo": _ref.read(canvasState).controller.asMap,
      "trees": _treesAsMap(),
    };
    String? path = file?.path;
    bool isNew = false;
    if (saveAs || path == null) {
      path = await getSavePath(
          acceptedTypeGroups: [typeGroup], suggestedName: name);
      if (path != null && path.split('.').lastOrNull != 'json')
        path = '$path.json';
      isNew = true;
    }
    if (path == null) return false;
    if (isNew) {
      _file = XFile(path);
      saveToRecentList(_file!);
    }
    name = name ?? file?.name ?? basename(path);
    final data = Uint8List.fromList(jsonEncode(content).codeUnits);
    final mimeType = "text/plain";
    final _f = XFile.fromData(data, name: name, mimeType: mimeType);
    await _f.saveTo(path);
    isFileEdited = false;
    notifyListeners();
    return true;
  }

  void addToNotification(String key) {
    _treeInfo[_activeTree]?.notificationKeys.add(key);
    _addToHistory();
  }

  void removeFromNotification(String key) {
    _treeInfo[_activeTree]?.notificationKeys.removeWhere((k) => k == key);
    _addToHistory();
  }

  void _setNotificationIndicator(Node node, [onlyCollapsing = false]) {
    List<Node> _children = _controller.getAllChildren(node);
    Iterator iter = _children.iterator;
    if (node.expanded)
      while (iter.moveNext()) {
        Node child = iter.current;
        if (_treeInfo.containsKey(_activeTree) &&
            _treeInfo[_activeTree]!.notificationKeys.contains(child.key)) {
          _treeInfo[_activeTree]?.warningKeys.add(node.key);
          break;
        }
      }
    else if (!onlyCollapsing)
      _treeInfo[_activeTree]?.warningKeys.removeWhere((key) => key == node.key);
  }

  void selectNodeInTrees(String key) {
    _trees.forEach((k, value) {
      if (value.getNode(key) != null) {
        if (_activeTree != k) switchTree(k);
        selectNode(key);
      }
    });
  }

  void selectNode(String key) {
    if (key != _treeInfo[_activeTree]?.selectId) {
      _treeInfo[_activeTree]?.selectIndicatorId = null;
      _treeInfo[_activeTree]?.selectId = key;
      _controller = _controller.copyWith(selectedKey: key);
      _selectedOnce = true;
      _ref.read(propertyState).setPropertyView(_lockKey ?? key);
      // need to be called here because selected box indicator on canvas need repaint on every new select
      _ref.read(canvasState).loadCanvas();
      notifyListeners();
    }
  }

  Node? getRoot(Node? node) {
    if (node == null || _controller.getParent(node.key) == null)
      return node;
    else
      return getRoot(_controller.getParent(node.key));
  }

  void collapseChildren([Node? node]) {
    final _children = node?.children ?? controller.children;
    _children.forEach((child) {
      _controller = TreeViewController(
        children:
            _controller.updateNode(child.key, child.copyWith(expanded: false)),
        selectedKey: _treeInfo[_activeTree]?.selectId,
      );
      _selectIndictorNode(child, true);
      _setNotificationIndicator(child, true);
    });
    _addToHistory();
  }

  void reOrderChildren(String key, int index) {
    _controller = TreeViewController(
      children: _controller.reorderNode(key, index),
      selectedKey: _treeInfo[_activeTree]?.selectId,
    );
    _addToHistory();
  }

  void _selectIndictorNode(Node node, [onlyCollapsing = false]) {
    if (_controller.getNode(_treeInfo[_activeTree]?.selectId ?? '',
            parent: node) !=
        null) if (node.expanded)
      _treeInfo[_activeTree]?.selectIndicatorId = node.key;
    else {
      var _found = false;
      final children = _controller.getAllChildren(node);
      Iterator iter = children.iterator;
      while (iter.moveNext()) {
        Node child = iter.current;
        if (_controller.getNode(_treeInfo[_activeTree]?.selectId ?? '',
                    parent: child) !=
                null &&
            !onlyCollapsing) {
          _treeInfo[_activeTree]?.selectIndicatorId = child.key;
          _found = true;
          break;
        }
      }
      if (!_found && !onlyCollapsing)
        _treeInfo[_activeTree]?.selectIndicatorId = null;
    }
  }

  void addNodeToRoot(Node node, {int? index, String? treeKey}) {
    if (_trees.keys.isEmpty) return;
    if (treeKey == null || treeKey == _activeTree) {
      _controller = _controller.copyWith(
          children: [..._controller.children]..insert(
              index == null || index > _controller.children.length
                  ? _controller.children.length
                  : index,
              node));
      if (_controller.children.length == 1)
        _treeInfo[_activeTree]?.selectId = node.key;
    } else if (_trees.containsKey(treeKey)) {
      _trees[treeKey] = _trees[treeKey]!.copyWith(
          children: [..._trees[treeKey]!.children]..insert(
              index == null || index > _trees[treeKey]!.children.length
                  ? _trees[treeKey]!.children.length
                  : index,
              node));
      if (_trees[treeKey]!.children.length == 1)
        _treeInfo[treeKey]?.selectId = node.key;
    }
    notifyListeners();
  }

  /// change its and all of its children key to a new key
  Node copyWithNewKey(Node node) {
    Node _node = node;
    _controller.getAllChildren(node).forEach((child) {
      _node = _node.copyWith(
          children: _controller.updateNode(
        child.key,
        child.copyWith(key: uuid.v4()),
        parent: _node,
      ));
    });
    return _node.copyWith(key: uuid.v4());
  }

  void addNodeWithChildren(String key, Node node,
      {InsertMode mode = InsertMode.insert, int? index, String? group}) {
    node = copyWithNewKey(node);
    addNode(key, node.asMap, mode: mode, index: index, group: group);
  }

  void addNode(String key, Map<String, dynamic> map,
      {InsertMode mode = InsertMode.insert, int? index, String? group}) {
    final node = Node.fromMap(map);
    _controller = TreeViewController(
      selectedKey: _treeInfo[_activeTree]?.selectId,
      children: _controller.addNode(key, node,
          mode: mode, index: index, group: group),
    );
    _addToHistory();
  }

  // ?? bug: changing renaming node doesn't reflect tree(new node select)
  void replaceNode(String key, Map<String, dynamic> map) {
    final parent = _controller.getParent(key);
    final i = getChildNodeIndex(key);
    if (parent != null)
      addNode(parent.key, map, mode: InsertMode.replace, index: i);
  }

  void removeNode(Node node, [deleteAll = false]) {
    if (node.type == EnumToString.convertToString(ModelType.Root) &&
        !deleteAll &&
        node.children.isNotEmpty) {
      _ref.read(consoleState).addMessage(
            ConsoleMessage(
                id: uuid.v4(),
                message:
                    'Root with children can\'t be deleted, try deleting all'),
          );
      return;
    }
    if (_treeInfo[_activeTree]?.selectId == node.key)
      _treeInfo[_activeTree]?.selectId = node.children.firstOrNull?.key ??
          _controller.getParent(node.key)?.key ??
          _controller.children.firstOrNull?.key;
    _controller = TreeViewController(
        children: _controller.deleteNode(node.key,
            deleteChildren: deleteAll, group: node.group),
        selectedKey: _treeInfo[_activeTree]?.selectId);
    _ref
        .read(propertyState)
        .setPropertyView(deleteAll ? null : _treeInfo[_activeTree]?.selectId);
    _addToHistory();
  }

  void expandNode(Node node) {
    _controller = TreeViewController(
      selectedKey: _treeInfo[_activeTree]?.selectId,
      children: _controller.updateNode(
          node.key, node.copyWith(expanded: !node.expanded)),
    );
    _selectIndictorNode(node);
    _setNotificationIndicator(node);
    _addToHistory();
  }

  // ?? bug: changing renaming node doesn't reflect tree(new node select)
  /// replace or update Node
  void changeNode(String key, Node node, [bool preAdd = false]) {
    if (preAdd && _selectedOnce) _addToHistory(); // for property view
    _controller = TreeViewController(
      selectedKey: _treeInfo[_activeTree]?.selectId,
      children: _controller.updateNode(key, node),
    );
    if (_activeTree != null) _trees[_activeTree!] = _controller;
    _addToHistory();
  }

  void changeParent(String key, Map<String, dynamic> map,
      [String group = 'child']) {
    final parent = _controller.getParent(key);
    final i = getChildNodeIndex(key);
    if (parent != null)
      addNode(parent.key, map,
          mode: InsertMode.changeParent, index: i, group: group);
  }

  void moveNode(Node parent, Node node, {keepChildren = true}) {
    _controller = TreeViewController(
      selectedKey: _treeInfo[_activeTree]?.selectId,
      children: _controller.deleteNode(node.key, deleteChildren: !keepChildren),
    );
    if (!parent.expanded) {
      _controller = TreeViewController(
        selectedKey: _treeInfo[_activeTree]?.selectId,
        children: _controller.updateNode(
          parent.key,
          parent.copyWith(expanded: true),
        ),
      );
      _selectIndictorNode(parent);
      _setNotificationIndicator(parent);
    }
    _controller = TreeViewController(
      selectedKey: _treeInfo[_activeTree]?.selectId,
      children: _controller.addNode(
          parent.key, keepChildren ? node.copyWith(children: []) : node),
    );
    _addToHistory();
  }

  // ? fix
  int? getChildNodeIndex(
    String key,
  ) {
    final parent = _controller.getParent(key);
    if (parent != null)
      return parent.children.indexWhere((element) => element.key == key);
    else
      return null;
  }
}
