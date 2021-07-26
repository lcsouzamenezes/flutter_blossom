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
import 'package:flutter_blossom/states/context_menu_state.dart';
import 'package:flutter_blossom/states/property_state.dart';
import 'package:flutter_blossom/utils/handle_keys.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_widget_model/flutter_widget_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PropertyChangeButtons extends HookWidget {
  PropertyChangeButtons({
    Key? key,
    required this.value,
    required this.valueKey,
  }) : super(key: key);

  final Property value;
  final String valueKey;
  final inheritKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final _propertyState = useProvider(propertyState);

    return Row(
      children: [
        // if (e.isNullAccepted)
        if (value.isNullable && value.inherit == null)
          InkWell(
            onTap: () {
              value.setAllToNull();
            },
            child: Icon(
              Icons.block_outlined,
              size: 15,
              color: Colors.grey.withOpacity(0.6),
            ),
          ),
        if (_propertyState.model!.type == ModelType.Root)
          InkWell(
            onTap: () {
              value.copyWith(replaceable: !value.isReplaceable);
              _propertyState.attachToTree();
            },
            child: Icon(
              value.isReplaceable
                  ? Icons.lock_open_outlined
                  : Icons.lock_outline,
              size: 16,
              color: Colors.grey.withOpacity(0.6),
            ),
          )
        else if (valueKey != 'preferredSize')
          InkWell(
            onTap: () {
              if (value.inherit == null) {
                final model = _propertyState.model;
                if (model != null) {
                  final pos =
                      getCenterOffsetFromKey(inheritKey) - Offset(0, 25);
                  context.read(contextMenuState).show(
                      id: 'asdxcs',
                      offset: pos,
                      menu: Container(
                        color: Colors.grey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: model.inheritData.entries
                              .map((e) => TextButton(
                                  onPressed: () {
                                    value.copyWith(
                                        inherit: InheritData(e.key),
                                        forceInherit: true);
                                    _propertyState.attachToTree();
                                    context.read(contextMenuState).clear();
                                  },
                                  child: Text(e.key)))
                              .toList(),
                        ),
                      ));
                }
              } else {
                value.copyWith(inherit: null, forceInherit: true);
                _propertyState.attachToTree();
              }
            },
            child: Icon(
              value.inherit != null ? Icons.link_off_outlined : Icons.link,
              key: inheritKey,
              size: 16,
              color: Colors.grey.withOpacity(0.6),
            ),
          ),
      ],
    );
  }
}
