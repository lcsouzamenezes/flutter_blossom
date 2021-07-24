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
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blossom/components/model_widget_wrapper.dart';
import 'package:flutter_blossom/states/model_state.dart';
import 'package:flutter_blossom/states/tree_state.dart';
import 'package:flutter_blossom/utils/handle_keys.dart';
import 'package:flutter_blossom/helpers/extensions.dart';
import 'package:blossom_canvas/blossom_canvas.dart';
import 'package:flutter_widget_model/flutter_widget_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tree_view/node_model.dart';
import 'package:uuid/uuid.dart';

final modelOnHover = Provider<List<GlobalKey>>((ref) => []);

final enableCanvasControl = StateProvider((red) => false);

final canvasState = ChangeNotifierProvider((ref) => CanvasViewNotifier(ref));

class CanvasViewNotifier extends ChangeNotifier {
  final ProviderReference _ref;
  CanvasViewNotifier(ref) : _ref = ref;
  CanvasController _controller = CanvasController(notifier: ([bool? b]) {});
  CanvasItem? _selected;
  Rect? _selectBox;
  Rect? _selectedBox;
  GlobalKey? _selectedBoxKey;
  String? _selectedKey;
  List<CanvasItem> _viewList = [];
  CanvasController get controller => _controller;
  CanvasItem? get selected => _selected;
  Rect? get selectBox => _selectBox;
  Rect? get selectedBox => _selectedBox;
  String? get selectedKey => _selectedKey;
  double get minZoom => 0.5;
  double get maxZoom => 2.0;

  final uuid = Uuid();

  resetViewList() {
    _viewList = [];
    _controller = CanvasController(notifier: ([bool? b]) {});
  }

  setSelectBox(Rect? box) {
    _selectBox = box;
    notifyListeners();
  }

  setSelectedBoxKey(GlobalKey? boxKey) {
    _selectedBoxKey = boxKey;
    setSelectedBox();
  }

  setSelectedBox([double? zoom]) {
    if (_selectedBoxKey != null) {
      _selectedBox = (getPositionFromKey(_selectedBoxKey!) ?? Offset.zero) -
              Offset(0, 44) &
          (getSizeFromKey(_selectedBoxKey!) ?? Size.zero) *
              (zoom ?? _controller.zoom);
    } else {
      _selectedBox = null;
    }
    notifyListeners();
  }

  shiftSelectedBox(Offset delta) {
    _selectedBox = _selectedBox?.shift(delta);
    notifyListeners();
  }

  selectItem(CanvasItem? item) {
    _selected = item;
    if (item != null && _ref.read(modelOnHover).isEmpty)
      _ref.read(treeState).selectNode(item.key);
    notifyListeners();
  }

  setView(CanvasItem item) {
    if (!_viewList.any((e) => e.key == item.key)) _viewList.add(item);
    notifyListeners();
  }

  loadCanvas() {
    if (_ref.read(treeState).controller.selectedKey != null)
      _selectedKey = _ref
          .read(treeState)
          .getRoot(_ref
              .read(treeState)
              .controller
              .getNode(_ref.read(treeState).controller.selectedKey!))
          ?.key;
    _selectedBox = null;

    final children = _viewList
        .map(
          (e) => CanvasItem(
            e.key,
            e.rootKey,
            e.label,
            getWidgetFromModel(_ref
                .read(modelState)
                .controller
                .children
                .firstWhereOrNull((el) => el.key == e.rootKey)),
            e.size,
            e.sizeProfile,
            e.rotate,
            e.offset,
          ),
        )
        .toList();
    _controller.children.forEach((e) {
      if (children.any((el) => el.key == e.key))
        children.firstWhere((elm) => elm.key == e.key)
          ..setOffset(e.offset)
          ..setSize(e.sizeProfile, e.size);
    });
    _controller = CanvasController(children: children, notifier: notify);
    notifyListeners();
  }

  Widget? getWidgetFromModel(WidgetModel? model) {
    try {
      return model?.toWidget(
            (key, {required Widget child}) => ModelWidgetWrapper(
              modelKey: key,
              child: child,
              isSelected: key == _ref.read(treeState).controller.selectedKey,
            ),
            _ref.read(enableCanvasControl).state,
          ) ??
          null;
    } catch (e) {
      return null;
    }
  }

  centerOrAdd(Node node) {
    if (_controller.children.any((e) => e.rootKey == node.key)) {
      final items =
          _controller.children.where((e) => e.rootKey == node.key).toList();
      final off = items[items.first.focusCount < items.length
                  ? items.first.focusCount
                  : items.length - 1]
              .offset -
          Offset.zero;
      items.first.focusCount = items.first.focusCount == items.length - 1
          ? 0
          : items.first.focusCount + 1;
      _controller.children.forEach((e) => e.setOffset(e.offset - off));
      notifyListeners();
    } else {
      _viewList.add(CanvasItem(uuid.v4(), node.key, node.name, null));
      loadCanvas();
    }
  }

  addNewFromItem(CanvasItem item) {
    _viewList.add(CanvasItem(uuid.v4(), item.rootKey, item.label, null));
    loadCanvas();
  }

  remove(CanvasItem item) {
    _viewList.removeWhere((e) => e.key == item.key);
    loadCanvas();
  }

  reorder(Restack mode) {
    if (_selected != null)
      _controller = CanvasController(
          children: _controller.restack(_selected!, mode), notifier: notify);
    notifyListeners();
  }

  void notify([notify = false]) {
    if (notify && !_ref.read(treeState).isFileEdited)
      _ref.read(treeState).setEditStatus(true);
    notifyListeners();
  }
}
