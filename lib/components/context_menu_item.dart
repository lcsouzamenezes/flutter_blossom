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
import 'package:flutter_blossom/constants/colors.dart';
import 'package:flutter_blossom/helpers/extensions.dart';
import 'package:flutter_blossom/helpers/extensions.dart';
import 'package:flutter_blossom/states/context_menu_state.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// ignore: must_be_immutable
class ContextMenuItem extends HookWidget {
  ContextMenuItem(
    this.label, {
    Key? key,
    this.info,
    this.height,
    this.isDense = false,
    this.onTap,
    this.onHover,
    this.isOnHover = false,
  }) : super(key: key);
  final String label;
  final Widget? info;
  final double? height;
  final bool isDense;
  final Function()? onTap;
  final void Function(bool isOnHover)? onHover;
  bool isOnHover;

  @override
  Widget build(BuildContext context) {
    final _isOnHover = useState(false);
    return InkWell(
      onTap: onTap != null
          ? () {
              onTap!();
              context.read(contextMenuState).clear();
              context.read(contextMenuState).clearSubMenus();
            }
          : null,
      onHover: (val) {
        isOnHover = val;
        _isOnHover.value = val;
        if (onHover != null) onHover!(val);
      },
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: _isOnHover.value
              ? Theme.of(context).canvasColor.reverseBy(1)
              : null,
        ),
        child: Padding(
          padding:
              EdgeInsets.symmetric(horizontal: 8.0, vertical: isDense ? 2 : 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.button!.copyWith(
                      color:
                          Theme.of(context).textTheme.button!.color!.reverseBy(
                                onTap != null
                                    ? contextMenuLabelBy
                                    : contextMenuLabelBy * 3,
                              )),
                ),
              ),
              if (info != null) info!,
            ],
          ),
        ),
      ),
    );
  }
}
