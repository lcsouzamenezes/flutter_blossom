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
import 'package:flutter/foundation.dart';
import 'package:flutter_blossom/helpers/widget_wrapper.dart';
import 'package:flutter_blossom/states/storage_state.dart';
import 'package:flutter_blossom/views/sub_views/part_views/overlay_view.dart';
import 'package:flutter_blossom/views/sub_views/part_views/property_view.dart';
import 'package:flutter_blossom/views/sub_views/part_views/tree_view.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final treeViewAreaSize = Provider<double>((ref) {
  final width = ref.watch(treeViewNotifier);
  ref.read(storageState).sharedPreferences.setDouble('tree-view-size', width);
  return width;
});

final propertyViewAreaSize = Provider<double>((ref) {
  final width = ref.watch(propertyViewNotifier);
  ref
      .read(storageState)
      .sharedPreferences
      .setDouble('property-view-size', width);
  return width;
});

final activeLayout = StateProvider<String?>((_) => null);

final editorLayout = ChangeNotifierProvider((ref) => EditorLayout(ref));

class EditorLayout with ChangeNotifier {
  ProviderReference _ref;
  EditorLayout(this._ref);
  final List<WidgetWrapper> _list = [];
  final Map map = {};
  bool _isChanged = false;
  List<WidgetWrapper> get list => _list;
  bool get isChanged => _isChanged;

  int get treeLocation => _list.indexWhere((e) => e.id == TreeViewArea.id);
  int get canvasLocation =>
      _list.indexWhere((e) => e.id == CanvasOverlayViewArea.id);
  int get propertyLocation =>
      _list.indexWhere((e) => e.id == PropertyViewArea.id);

  void initializeList(List<WidgetWrapper> list) {
    final List<WidgetWrapper> _sorted = [];
    final data = _ref
        .read(storageState)
        .sharedPreferences
        .getStringList('editor-layout--position-list');
    if (data != null)
      data.forEach((e) => _sorted.add(list.firstWhere((el) => el.id == e)));
    else
      _sorted.addAll(list);
    _list.addAll(_sorted);
    Future.delayed(Duration(milliseconds: 0))
        .then((value) => notifyListeners());
  }

  int getIndex(String id) {
    return _list.indexWhere((element) => element.id == id);
  }

  void updateLayout(String moveId, String posId, int i) {
    final moveIndex = getIndex(moveId);
    final dependIndex = getIndex(posId);
    int newIndex = i == 0
        ? moveIndex < dependIndex
            ? dependIndex - 1
            : dependIndex
        : moveIndex > dependIndex
            ? dependIndex + 1
            : dependIndex;
    newIndex = newIndex < 0
        ? 0
        : newIndex > _list.length - 1
            ? _list.length - 1
            : newIndex;
    map['$moveId'] = {'$posId': '$newIndex'};
    _isChanged = moveIndex != newIndex;
    _list.insert(newIndex, _list.removeAt(moveIndex));
    if (moveIndex != newIndex)
      _ref.read(storageState).sharedPreferences.setStringList(
          'editor-layout--position-list', _list.map((e) => e.id).toList());
    notifyListeners();
  }
}

final treeViewNotifier = StateNotifierProvider<TreeViewNotifier, double>(
    (ref) => TreeViewNotifier());

final propertyViewNotifier =
    StateNotifierProvider<PropertyViewNotifier, double>(
        (ref) => PropertyViewNotifier());

class TreeViewNotifier extends StateNotifier<double> {
  TreeViewNotifier() : super(300.0);
  final maxWidth = 500.0;
  final minWidth = 300.0;
  void set(double newWidth) {
    if (newWidth < 50)
      hide();
    else {
      if (newWidth >= minWidth && newWidth <= maxWidth) {
        state = newWidth;
      } else {
        if (newWidth < minWidth)
          state = minWidth;
        else if (newWidth > maxWidth) state = maxWidth;
      }
    }
  }

  void reset() {
    state = 250;
  }

  void hide() {
    state = 0;
  }
}

class PropertyViewNotifier extends StateNotifier<double> {
  PropertyViewNotifier() : super(300.0);
  final maxWidth = 500.0;
  final minWidth = 300.0;
  void set(double newWidth) {
    if (newWidth < 50)
      hide();
    else {
      if (newWidth >= minWidth && newWidth <= maxWidth) {
        state = newWidth;
      } else {
        if (newWidth < minWidth)
          state = minWidth;
        else if (newWidth > maxWidth) state = maxWidth;
      }
    }
  }

  void reset() {
    state = 400;
  }

  void hide() {
    state = 0;
  }
}
