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

import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blossom/states/property_state.dart';
import 'package:flutter_blossom/views/sub_views/part_views/property_views/properties/property_change_button.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_model/flutter_widget_model.dart';

class PropertiesWithChildren extends HookWidget {
  PropertiesWithChildren({
    required this.kKey,
    required this.propertyKey,
    required this.parent,
    required this.property,
    required this.main,
    required this.children,
  });

  final String kKey;
  final String propertyKey;
  final Property property;
  final Property parent;
  final Widget main;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final editValue = useState(false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (kKey != propertyKey)
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: !property.isInitialized
                      ? () {
                          editValue.value = !editValue.value;
                        }
                      : null,
                  child: Row(
                    children: [
                      if (!property.isInitialized)
                        Icon(
                          editValue.value
                              ? Icons.keyboard_arrow_down
                              : Icons.keyboard_arrow_right,
                          size: 14,
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: (property.isInitialized || editValue.value) &&
                                parent.siblings.isNotEmpty &&
                                parent.siblings.keys.contains(kKey)
                            ? DropdownButton<String>(
                                isDense: true,
                                onTap: () {},
                                onChanged: (value) {
                                  context.read(propertyState).updateProperty(
                                      propertyKey,
                                      parent.copyWith(constructor: value));
                                },
                                value: parent.constructor,
                                items: parent.siblings.entries
                                    .map(
                                      (e) => DropdownMenuItem<String>(
                                        child: Text(e.key,
                                            style: TextStyle(
                                                color: Colors.grey
                                                    .withOpacity(0.6))),
                                        value: e.key,
                                      ),
                                    )
                                    .toList(),
                              )
                            : Text(
                                kKey,
                                style: TextStyle(
                                    color: Colors.grey.withOpacity(0.6)),
                              ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    if (propertyKey !=
                        EnumToString.convertToString(property.type))
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: Text(
                          EnumToString.convertToString(property.type),
                          style: TextStyle(
                            color: Colors.grey.withOpacity(0.5),
                            // backgroundColor:
                            //     Colors.grey.withOpacity(0.4),
                          ),
                        ),
                      ),
                    if (property.isInitialized || editValue.value)
                      PropertyChangeButtons(
                        valueKey: kKey,
                        value: property,
                      ),
                  ],
                )
              ],
            ),
          ),
        if (kKey == propertyKey || property.isInitialized || editValue.value)
          main,
        ...children
            .map(
              (e) => Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: e,
              ),
            )
            .toList(),
      ],
    );
  }
}
