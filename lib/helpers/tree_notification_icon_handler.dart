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

import 'package:flutter/material.dart';
import 'package:flutter_blossom/states/tree_state.dart';
import 'package:tree_view/node_model.dart';
// ignore_for_file: import_of_legacy_library_into_null_safe, unused_import
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:better_print/better_print.dart';

Widget? getNotificationIcon(Node node, double size, BuildContext context) {
  final info =
      context.read(treeState).treesInfo[context.read(treeState).activeTree];
  final _list = info?.notificationKeys ?? [];
  final _tmp = info?.warningKeys ?? [];
  return _list.contains(node.key) || _tmp.contains(node.key)
      ? Container(
          width: (size) * 0.4,
          height: (size) * 0.4,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _list.contains(node.key) ? Colors.red : Colors.orange,
          ),
        )
      : null;
}
