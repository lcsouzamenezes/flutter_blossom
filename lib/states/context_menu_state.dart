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
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_blossom/models/context_menu.dart';
import 'package:flutter_blossom/states/app_state.dart';
import 'package:flutter_blossom/states/tree_state.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final contextMenuState =
    ChangeNotifierProvider((ref) => ContextMenuNotifier(ref));

class ContextMenuNotifier extends ChangeNotifier {
  // ignore: unused_field
  ProviderReference _ref;
  ContextMenuNotifier(this._ref);
  Offset _offset = Offset.zero;
  ContextMenu? _menu;
  List<ContextMenu> _subMenus = [];
  ContextMenu? get menu => _menu;
  List<ContextMenu> get subMenus => _subMenus;

  show({
    required String id,
    required Widget menu,
    required Offset? offset,
    double width = 180,
    double height = 260,
    Size? constraints,
    bool fixOffsetY = false,
  }) {
    height += 1;
    if (offset != null) _offset = offset;
    offset = _offset;
    if (constraints == null)
      constraints = MediaQuery.of(_ref.read(appState).context).size;
    final isHeightOverflowing = offset.dy + height > constraints.height;
    offset = Offset(
      offset.dx + width > constraints.width
          ? constraints.width - width
          : offset.dx,
      isHeightOverflowing && !fixOffsetY
          ? constraints.height - height < 0
              ? 0
              : constraints.height - height
          : offset.dy,
    );
    height = isHeightOverflowing
        ? constraints.height - (fixOffsetY ? offset.dy : 0)
        : height;
    _menu = ContextMenu(
      id: id,
      child: SizedBox(
        width: width,
        height: height,
        child: SingleChildScrollView(
          child: menu,
        ),
      ),
      offset: offset,
      width: width,
      height: height,
    );
    notifyListeners();
  }

  double _getTotalSubMenuWidth() {
    double w = 0;
    _subMenus.forEach((e) {
      w += e.width;
    });
    return w;
  }

  addSubMenu({
    required String id,
    required Widget menu,
    double width = 180,
    double height = 260,
    double paddingTop = 0,
    Size? constraints,
  }) {
    if (_menu != null) {
      if (constraints == null)
        constraints = MediaQuery.of(_ref.read(appState).context).size;
      final isHeightOverflowing =
          _menu!.offset.dy + height > constraints.height;
      final tw = _getTotalSubMenuWidth();
      final offset = Offset(
        _menu!.offset.dx + (_menu!.width * 2) + tw > constraints.width
            ? constraints.width - ((_menu!.width * 2) + tw)
            : _menu!.offset.dx + _menu!.width + tw,
        isHeightOverflowing
            ? constraints.height - height < 0
                ? 0
                : constraints.height - height
            : _menu!.offset.dy + paddingTop,
      );
      height = isHeightOverflowing ? constraints.height : height;
      final m = ContextMenu(
        id: id,
        child: SizedBox(
          width: width,
          height: height,
          child: SingleChildScrollView(
            child: menu,
          ),
        ),
        offset: offset,
        width: width,
        height: height,
      );
      _subMenus.add(m);
      notifyListeners();
    }
  }

  clear() {
    if (_menu?.id == 'tree-node') _ref.read(treeShadowKey).state = null;
    _menu = null;
    _ref.read(treeShadowKey).state = null;
    notifyListeners();
  }

  clearSubMenus() {
    _subMenus.clear();
    notifyListeners();
  }

  removeLastSubMenu() {
    _subMenus.removeLast();
    notifyListeners();
  }
}
