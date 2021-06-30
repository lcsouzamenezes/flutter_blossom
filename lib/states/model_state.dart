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
import 'package:flutter_blossom/states/canvas_state.dart';
import 'package:flutter_blossom/states/tree_state.dart';
import 'package:flutter_widget_model/flutter_widget_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tree_view/node_model.dart';

final modelState = ChangeNotifierProvider((ref) => WidgetModelNotifier(ref));

class WidgetModelNotifier extends ChangeNotifier {
  final ProviderReference _ref;
  WidgetModelNotifier(ref) : _ref = ref;
  WidgetModelController _controller = WidgetModelController();
  WidgetModelController get controller => _controller;

  getModels() {
    // try {
    final List<Node> nodes = [];
    _ref.read(treeState).trees.values.forEach((e) => nodes.addAll(e.children));
    _controller = _controller.loadNodes(
      (block) {
        block.calculate(_controller);
        _ref.read(canvasState).loadCanvas();
      },
      nodes,
    );
    _ref.read(canvasState).loadCanvas();
    // } catch (e) {
    //   betterPrint('Not a valid model map');
    //   betterPrint(e);
    // }
  }
}
