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

import 'package:flutter/widgets.dart';

class ContextMenu {
  final String id;
  final Widget child;
  final Offset offset;
  final double width;
  final double height;
  ContextMenu({
    required this.id,
    required this.child,
    required this.offset,
    required this.width,
    required this.height,
  });

  ContextMenu copyWith(
    String? id,
    Widget? child,
    Offset? offset,
    double? width,
    double? height,
  ) =>
      ContextMenu(
        id: id ?? this.id,
        child: child ?? this.child,
        offset: offset ?? this.offset,
        width: width ?? this.width,
        height: height ?? this.height,
      );
}
