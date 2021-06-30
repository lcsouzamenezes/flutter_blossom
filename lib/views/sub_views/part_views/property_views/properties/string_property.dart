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
import 'package:flutter/services.dart';
import 'package:flutter_blossom/helpers/rich_text_controller.dart';
import 'package:flutter_blossom/states/context_menu_state.dart';
import 'package:flutter_blossom/states/property_state.dart';
import 'package:flutter_blossom/utils/handle_keys.dart';
import 'package:flutter_blossom/helpers/extensions.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_widget_model/flutter_widget_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class StringField extends HookWidget {
  StringField({
    Key? key,
    required this.valueKey,
    required this.property,
    required this.onSubmitted,
    this.formatter = const [],
  }) : super(key: key);
  final String valueKey;
  final Property property;
  final List<TextInputFormatter> formatter;
  final Function(String value) onSubmitted;

  @override
  Widget build(BuildContext context) {
    final _propertyState = useProvider(propertyState);

    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 2,
          child: Opacity(
            opacity: property.isInitialized ||
                    _propertyState.model!.type == NodeType.Root
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
                    child: TextField(
                      controller: RichTextController(
                        patternMap: {
                          RegExp(r"\B\$[a-zA-Z0-9]+\b"): TextStyle(
                            color:
                                Theme.of(context).accentColor.withOpacity(0.8),
                            // fontWeight: FontWeight.w800,
                            // fontStyle: FontStyle.italic,
                          ),
                        },
                        onMatch: (List<String> matches) {
                          // betterPrint(matches);
                          return matches.join();
                        },
                        text: property.value == null
                            ? ''
                            : property.value.toString(),
                      ),
                      autofocus: false,
                      inputFormatters: formatter,
                      style: TextStyle(
                        color: Colors.grey.withOpacity(0.7),
                      ),
                      onSubmitted: onSubmitted,
                      decoration: InputDecoration(
                        hintText: property.value.toString(),
                        contentPadding: const EdgeInsets.all(4.0),
                        isDense: true,
                        border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.blue, width: 1.0),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.red, width: 1.0),
                        ),
                      ),
                    ),
                  )
              ],
            ),
          ),
        )
      ],
    );
  }
}
