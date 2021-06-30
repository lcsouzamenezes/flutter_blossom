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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class RichTextController extends TextEditingController {
  final Map<RegExp, TextStyle>? patternMap;
  final Map<String, TextStyle>? stringMap;
  final Function(List<String> match)? onMatch;
  RichTextController(
      {String? text, this.patternMap, this.stringMap, this.onMatch})
      : assert(patternMap == null || stringMap == null),
        super(text: text);

  RichTextController.fromValue(TextEditingValue? value,
      {this.patternMap, this.stringMap, this.onMatch})
      : assert(
          value == null ||
              !value.composing.isValid ||
              value.isComposingRangeValid,
          'New TextEditingValue $value has an invalid non-empty composing range '
          '${value.composing}. It is recommended to use a valid composing range, '
          'even for readonly text fields',
        ),
        assert(patternMap == null || stringMap == null),
        super.fromValue(value ?? TextEditingValue.empty);
  @override
  TextSpan buildTextSpan(
      {required context, TextStyle? style, required bool withComposing}) {
    List<TextSpan> children = [];
    List<String> matches = [];
    // Validating with REGEX
    RegExp? allRegex;
    allRegex = (patternMap != null
        ? RegExp(patternMap!.keys.map((e) => e.pattern).join('|'))
        : null);
    // Validating with Strings
    RegExp? stringRegex;
    stringRegex = stringMap != null
        ? RegExp(r'\b' + stringMap!.keys.join('|').toString() + r'+\b')
        : null;
    ////
    text.splitMapJoin(
      stringMap == null ? allRegex! : stringRegex!,
      onMatch: (Match m) {
        if (!matches.contains(m[0])) matches.add(m[0]!);

        RegExp? k = patternMap?.entries.firstWhere((element) {
          return element.key.allMatches(m[0]!).isNotEmpty;
        }).key;
        String? ks = stringMap?.entries.firstWhere((element) {
          return element.key.allMatches(m[0]!).isNotEmpty;
        }).key;

        children.add(
          TextSpan(
            text: m[0],
            style: stringMap == null ? patternMap![k] : stringMap![ks],
          ),
        );

        return (this.onMatch != null ? this.onMatch!(matches) : '');
      },
      onNonMatch: (String span) {
        children.add(TextSpan(text: span, style: style));
        return span.toString();
      },
    );

    return TextSpan(style: style, children: children);
  }
}
