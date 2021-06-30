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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blossom/components/node_group_list.dart';
import 'package:flutter_blossom/components/node_model_list.dart';
import 'package:flutter_blossom/dialogs/rename_file.dart';
import 'package:flutter_blossom/helpers/extensions.dart';
import 'package:flutter_blossom/states/context_menu_state.dart';
import 'package:flutter_blossom/states/editor_state.dart';
import 'package:flutter_blossom/states/tree_state.dart';
import 'package:flutter_blossom/views/sub_views/part_views/property_view.dart';
import 'package:flutter_blossom/views/sub_views/part_views/tree_view.dart';
import 'package:keybinder/keybinder.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tree_view/node_model.dart';

bindKeys(BuildContext context, bool isNew) {
  Keybinder.bind(
    Keybinding({KeyCode.ctrl, KeyCode.from(LogicalKeyboardKey.keyN)},
        inclusive: false, debugLabel: 'New File'),
    () => Future.delayed(Duration(milliseconds: 500))
        .then((value) => context.read(treeState).newProject()),
  );
  Keybinder.bind(
    Keybinding({KeyCode.ctrl, KeyCode.from(LogicalKeyboardKey.keyO)},
        inclusive: false, debugLabel: 'Open File'),
    () => Future.delayed(Duration(milliseconds: 500))
        .then((value) => context.read(treeState).loadFromFile()),
  );
  Keybinder.bind(
    Keybinding({KeyCode.ctrl, KeyCode.from(LogicalKeyboardKey.keyR)},
        inclusive: false, debugLabel: 'Reload File'),
    () {
      if (context.read(treeState).file?.path ==
          context.read(treeState).recents.firstOrNull?.path)
        context
            .read(treeState)
            .loadFromFile(context.read(treeState).recents.firstOrNull);
    },
  );
  Keybinder.bind(
    Keybinding({KeyCode.ctrl, KeyCode.from(LogicalKeyboardKey.keyS)},
        inclusive: false, debugLabel: 'Save File'),
    () => (kIsWeb && context.read(treeState).file?.name == null)
        ? showDialog(
            context: context,
            barrierColor: Colors.black38,
            builder: (context) => getDownloadDialog(context))
        : context.read(treeState).saveToFile(
            saveAs:
                context.read(treeState).recents.firstOrNull == null || isNew),
  );
  Keybinder.bind(
    Keybinding(
        {KeyCode.ctrl, KeyCode.shift, KeyCode.from(LogicalKeyboardKey.keyS)},
        inclusive: false, debugLabel: 'Save as File'),
    () => Future.delayed(Duration(milliseconds: 500))
        .then((value) => context.read(treeState).saveToFile(saveAs: true)),
  );
  Keybinder.bind(
    Keybinding({KeyCode.ctrl, KeyCode.from(LogicalKeyboardKey.keyQ)},
        inclusive: false, debugLabel: 'Quit File'),
    () => Navigator.maybePop(context),
  );
  Keybinder.bind(
    Keybinding({KeyCode.ctrl, KeyCode.from(LogicalKeyboardKey.backslash)},
        inclusive: false, debugLabel: 'Project settings'),
    () => betterPrint('show setting'),
  );
  Keybinder.bind(
    Keybinding({KeyCode.from(LogicalKeyboardKey.f1)},
        inclusive: false, debugLabel: 'help'),
    () => betterPrint('show help!'),
  );
  Keybinder.bind(
      Keybinding({KeyCode.ctrl, KeyCode.from(LogicalKeyboardKey.keyA)},
          inclusive: false, debugLabel: 'Switch panels'), () {
    context.read(activeLayout).state =
        context.read(activeLayout).state != TreeViewArea.id
            ? TreeViewArea.id
            : PropertyViewArea.id;
  });
  Keybinder.bind(
      Keybinding({KeyCode.from(LogicalKeyboardKey.arrowUp)},
          inclusive: false, debugLabel: 'up'), () {
    if (context.read(contextMenuState).menu != null) {
      if (context.read(contextMenuState).menu!.id == 'tree-node-model-list' ||
          context.read(contextMenuState).menu!.id ==
              'tree-node-model-list-filtered') {
        if (context.read(modelListSelectIndex).state > 0)
          context.read(modelListSelectIndex).state--;
      } else if (context.read(contextMenuState).menu!.id ==
          'tree-node-model-group-list') {
        if (context.read(modelGroupListSelectIndex).state > 0)
          context.read(modelGroupListSelectIndex).state--;
      }
    } else if (context.read(activeLayout).state == TreeViewArea.id) {
      final tree = context.read(treeState);
      final List<Node> list = [];
      tree.controller.children.forEach(
          (e) => list.addAll([e, ...tree.controller.getAllChildren(e)]));
      final i = list.indexWhere((e) => e.key == tree.controller.selectedKey);
      if (i != -1 && i > 0) tree.selectNode(list[i - 1].key);
    }
  });
  Keybinder.bind(
      Keybinding({KeyCode.from(LogicalKeyboardKey.arrowDown)},
          inclusive: false, debugLabel: 'down'), () {
    if (context.read(contextMenuState).menu != null) {
      if (context.read(contextMenuState).menu!.id == 'tree-node-model-list' ||
          context.read(contextMenuState).menu!.id ==
              'tree-node-model-list-filtered') {
        if (context.read(modelListSelectIndex).state <
            context.read(modelTypeList).state.length - 1)
          context.read(modelListSelectIndex).state++;
      } else if (context.read(contextMenuState).menu!.id ==
          'tree-node-model-group-list') {
        if (context.read(modelGroupListSelectIndex).state <
            context.read(modelGroupTypeList).state.length - 1)
          context.read(modelGroupListSelectIndex).state++;
      }
    } else if (context.read(activeLayout).state == TreeViewArea.id) {
      final tree = context.read(treeState);
      final List<Node> list = [];
      tree.controller.children.forEach(
          (e) => list.addAll([e, ...tree.controller.getAllChildren(e)]));
      if (tree.controller.selectedNode == null && list.isNotEmpty)
        tree.selectNode(list.first.key);
      final i = list.indexWhere((e) => e.key == tree.controller.selectedKey);
      if (i != -1 && list.length - 1 > i) tree.selectNode(list[i + 1].key);
    }
  });
}
