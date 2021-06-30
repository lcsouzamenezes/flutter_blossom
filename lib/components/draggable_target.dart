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
import 'package:flutter_blossom/helpers/extensions.dart'; // ignore: unused_import
import 'package:flutter/material.dart';
import 'package:flutter_blossom/states/editor_state.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class EditorLayoutDragTarget extends ConsumerWidget {
  const EditorLayoutDragTarget(
      {Key? key, required this.id, required this.acceptId})
      : super(key: key);

  final String id;
  final List<String> acceptId;

  @override
  Widget build(BuildContext context, _) {
    return Row(
      children: List.generate(
        2,
        (i) => Flexible(
          flex: 2,
          child: Container(
            child: DragTarget(
              builder: (context, List<String?> candidateData, rejectedData) {
                return candidateData.length > 0 &&
                        acceptId.contains(candidateData[0])
                    ? Container(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Theme.of(context)
                                .canvasColor
                                .lighten(5)
                                .withOpacity(0.5)
                            : Theme.of(context)
                                .canvasColor
                                .darken(10)
                                .withOpacity(0.5),
                      )
                    : Container(
                        // color: Colors.red.shade100,
                        );
              },
              onAccept: (String data) {
                if (data == 'tree-view-area' || data == 'property-view-area')
                  context.read(editorLayout).updateLayout(data, id, i);
              },
            ),
          ),
        ),
      ),
    );
  }
}
