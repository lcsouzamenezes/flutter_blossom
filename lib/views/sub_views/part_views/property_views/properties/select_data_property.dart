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
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blossom/components/context_menu_item.dart';
import 'package:flutter_blossom/components/micro_components/context_menu_container.dart';
import 'package:flutter_blossom/components/search_list.dart';
import 'package:flutter_blossom/constants/colors.dart';
import 'package:flutter_blossom/constants/lengths.dart';
import 'package:flutter_blossom/helpers/rich_text_controller.dart';
import 'package:flutter_blossom/states/context_menu_state.dart';
import 'package:flutter_blossom/states/editor_state.dart';
import 'package:flutter_blossom/states/property_state.dart';
import 'package:flutter_blossom/utils/handle_keys.dart';
import 'package:flutter_blossom/helpers/extensions.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_widget_model/flutter_widget_model.dart';
import 'package:flutter_widget_model/property_helpers/icons_helper.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SelectProperty extends HookWidget {
  SelectProperty({
    Key? key,
    required this.valueKey,
    required this.property,
    required this.options,
    required this.onSelect,
    this.infoList = const <String, Widget>{},
  }) : super(key: key);
  final String valueKey;

  /// property will not be used directly to generate Select options, set [options].
  final Property property;

  /// options should be first decoded to `List<String>` format from [property.availableValues] for easy access
  final List<String> options;

  /// [infoList] should also be pre defined as per [options] list. use option as [key] for [infoList]
  final Map<String, Widget> infoList;
  final Function(String value) onSelect;
  final gKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final _propertyState = useProvider(propertyState);
    final _contextMenuState = useProvider(contextMenuState);

    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 2,
          child: Opacity(
            opacity: property.isInitialized ||
                    _propertyState.model!.type == ModelType.Root
                ? 1
                : 0.4,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                valueKey.separate.capitalize,
                style: TextStyle(color: Colors.grey.withOpacity(0.8)),
              ),
            ),
          ),
        ),
        Flexible(
          flex: 3,
          fit: FlexFit.tight,
          child: Container(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (property.inherit == null)
                  Expanded(
                      child: InkWell(
                    onTap: options.isEmpty
                        ? null
                        : () {
                            final pos =
                                (getPositionFromKey(gKey) ?? Offset.zero) +
                                    Offset(
                                        context
                                                    .read(editorLayout)
                                                    .propertyLocation ==
                                                context
                                                        .read(editorLayout)
                                                        .list
                                                        .length -
                                                    1
                                            ? -200
                                            : 60,
                                        25);
                            double hSize =
                                MediaQuery.of(context).size.height - pos.dy;
                            hSize = hSize >= 300
                                ? hSize
                                : MediaQuery.of(context).size.height;
                            _contextMenuState.show(
                              id: 'select-property-value',
                              offset: pos,
                              width: 295,
                              height: hSize,
                              menu: ContextMenuContainer(
                                applyRadius: true,
                                child: SearchList(
                                  height: hSize,
                                  list: options,
                                  info: (value) => infoList.containsKey(value)
                                      ? infoList[value]
                                      : null,
                                  onTap: (value) => onSelect(value),
                                ),
                              ),
                            );
                          },
                    child: Container(
                      key: gKey,
                      height: 25,
                      color: Theme.of(context).canvasColor,
                      child: Center(
                        child: Text(
                          options.isEmpty
                              ? 'nothing to select'
                              : property.value == null
                                  ? 'nothing selected'
                                  : property.encodeValue(),
                          style: TextStyle(
                              color: Colors.grey.withOpacity(
                                  property.value == null ? 0.6 : 0.8)),
                        ),
                      ),
                    ),
                  ))
              ],
            ),
          ),
        )
      ],
    );
  }
}
