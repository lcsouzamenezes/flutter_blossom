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

class TreeIconButton extends HookWidget {
  TreeIconButton(
      {Key? key,
      required this.icon,
      required this.onTap,
      this.size = 16.0,
      this.tooltip})
      : super(key: key);
  final IconData icon;
  final void Function()? onTap;
  final double size;
  final String? tooltip;
  @override
  Widget build(BuildContext context) {
    final isOnHover = useState(false);
    final btn = Container(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: InkWell(
        onTap: onTap,
        onHover: (_) => isOnHover.value = !isOnHover.value,
        child: Opacity(
          opacity: onTap == null
              ? 0.5
              : isOnHover.value
                  ? 1
                  : 0.8,
          child: Icon(
            icon,
            size: size,
          ),
        ),
      ),
    );
    return tooltip != null && onTap != null
        ? Tooltip(
            message: tooltip!,
            waitDuration: Duration(milliseconds: 600),
            preferBelow: true,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.6),
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
            textStyle: TextStyle(color: Colors.black54),
            child: btn,
          )
        : btn;
  }
}
