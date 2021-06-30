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
import 'package:flutter_blossom/constants/shapes.dart';
import 'package:flutter_blossom/helpers/extensions.dart';

class ContextMenuContainer extends StatelessWidget {
  const ContextMenuContainer({Key? key, this.child, this.applyRadius = false})
      : super(key: key);
  final Widget? child;
  final bool applyRadius;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).canvasColor.by(3),
      shape: applyRadius
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.all(contextMenuRadius),
            )
          : RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(0)),
            ),
      clipBehavior: Clip.hardEdge,
      elevation: 1,
      margin: const EdgeInsets.all(0.1),
      child: child,
    );
  }
}
