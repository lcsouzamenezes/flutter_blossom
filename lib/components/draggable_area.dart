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
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:line_icons/line_icons.dart';

class EditorLayoutDragArea extends HookWidget {
  const EditorLayoutDragArea({
    Key? key,
    required this.title,
    this.titleOption,
    required this.id,
    required this.width,
    this.actions = const [],
    required this.onTap,
    this.isActive = false,
  }) : super(key: key);

  final String title;
  final List<String>? titleOption;
  final String id;
  final double width;
  final List<Widget> actions;
  final Function(String) onTap;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final isCollapsed = useState(true);
    return Column(
      children: [
        Draggable(
          data: id,
          feedback: Container(
            width: width,
            color: Colors.grey.withOpacity(0.2),
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: Theme.of(context)
                  .textTheme
                  .subtitle1
                  ?.copyWith(color: Colors.grey.shade600),
            ),
          ),
          child: Container(
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 6.0),
                  child: InkWell(
                    onTap: titleOption != null
                        ? () {
                            isCollapsed.value = !isCollapsed.value;
                          }
                        : null,
                    child: Row(
                      children: [
                        Text(
                          title,
                          style:
                              Theme.of(context).textTheme.subtitle1?.copyWith(
                                    color: isActive
                                        ? Colors.grey
                                        : Colors.grey.shade600,
                                  ),
                        ),
                        if (titleOption != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 4.0, top: 4),
                            child: Icon(
                              isCollapsed.value
                                  ? Icons.arrow_downward
                                  : Icons.arrow_upward,
                              size: 15,
                              color: Colors.grey.shade600,
                            ),
                          )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      ...actions,
                      Icon(
                        LineIcons.gripVertical,
                        color: Colors.grey.shade500,
                        size: 18,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          childWhenDragging: SizedBox(
            height: 32,
          ),
        ),
        if (titleOption != null && !isCollapsed.value)
          ListView(
            shrinkWrap: true,
            children: titleOption
                    ?.map((e) => ListTile(
                          title: Text(e),
                          onTap: () => onTap(e),
                          tileColor: e == title
                              ? Colors.grey.withOpacity(0.5)
                              : Colors.white,
                        ))
                    .toList() ??
                [],
          ),
      ],
    );
  }
}
