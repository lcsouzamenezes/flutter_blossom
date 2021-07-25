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
import 'package:flutter_blossom/helpers/rich_text_controller.dart';
import 'package:flutter_blossom/states/context_menu_state.dart';
import 'package:flutter_blossom/states/property_state.dart';
import 'package:flutter_blossom/utils/handle_keys.dart';
import 'package:flutter_blossom/helpers/extensions.dart';
import 'package:flutter_blossom/utils/tap_watcher.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_widget_model/flutter_widget_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:line_icons/line_icons.dart';

class StringField extends HookWidget {
  StringField({
    Key? key,
    required this.value,
    required this.onSubmitted,
    this.onEscaped,
    this.focusNode,
    this.onFocusChange,
    this.autofocus = false,
    this.isDouble = false,
    this.isInt = false,
    this.allowNegative = true,
    this.formatter = const [],
  }) : super(key: key);

  final String value;

  final bool isDouble;
  final bool isInt;
  final bool allowNegative;

  final List<TextInputFormatter> formatter;
  final void Function(String value) onSubmitted;
  final void Function()? onEscaped;
  final FocusNode? focusNode;
  final void Function(FocusNode node)? onFocusChange;
  final bool autofocus;
  @override
  Widget build(BuildContext context) {
    final _value = useState<dynamic>(null);
    final _focusNode = focusNode ?? FocusNode();
    var _text = value;
    useEffect(() {
      if (autofocus) {
        Future.delayed(Duration(milliseconds: 0))
            .then((value) => _focusNode.requestFocus());
      }
      if (FocusManager.instance.primaryFocus != _focusNode) {
        FocusManager.instance.primaryFocus?.unfocus();
      }
      _focusNode.addListener(() {
        onFocusChange?.call(_focusNode);
      });
    }, const []);
    var textField = TextField(
      focusNode: _focusNode,
      controller: RichTextController(
        patternMap: {
          RegExp(r"\B\$[a-zA-Z0-9]+\b"): TextStyle(
            color: Theme.of(context).accentColor.withOpacity(0.8),
            // fontWeight: FontWeight.w800,
            // fontStyle: FontStyle.italic,
          ),
        },
        onMatch: (List<String> matches) {
          // betterPrint(matches);
          return matches.join();
        },
        text: _value.value?.toString() ?? value,
      )..selection = TextSelection(
          baseOffset:
              autofocus ? 0 : _value.value?.toString().length ?? value.length,
          extentOffset: _value.value?.toString().length ?? value.length,
        ),
      onChanged: (v) => _text = v,
      inputFormatters: formatter,
      style: TextStyle(
        color: Colors.grey.withOpacity(0.7),
      ),
      decoration: InputDecoration(
        prefix: isDouble || isInt
            ? Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: MouseRegion(
                  cursor: SystemMouseCursors.resizeColumn,
                  child: GestureDetector(
                    onHorizontalDragDown: (_) {
                      if (value != '')
                        _value.value =
                            isDouble ? double.parse(value) : int.parse(value);
                    },
                    onHorizontalDragUpdate: (d) {
                      if (d.delta.dx.abs() < 2) return;
                      if (_value.value != null) {
                        if (isDouble) {
                          if (d.delta.dx > 0)
                            _value.value += 0.5;
                          else
                            _value.value -=
                                !allowNegative && _value.value - 0.5 <= 0
                                    ? 0
                                    : 0.5;
                        } else {
                          if (d.delta.dx > 0)
                            _value.value++;
                          else
                            _value.value -=
                                !allowNegative && _value.value - 1 <= 0 ? 0 : 1;
                        }
                      }
                    },
                    onHorizontalDragEnd: (_) {
                      onSubmitted(_value.value.toString());
                      _value.value = null;
                    },
                    child: Container(
                      height: 20,
                      decoration: BoxDecoration(
                          border: Border(
                        right: BorderSide(
                          color: Colors.grey.withOpacity(0.7),
                          width: 1,
                        ),
                      )),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Transform.rotate(
                          angle: 1.6,
                          child: Icon(
                            LineIcons.sort,
                            size: 14,
                            color: Colors.grey.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : null,
        hintText: '',
        contentPadding: EdgeInsets.only(
            left: isDouble || isInt ? 2.0 : 4.0,
            right: 4.0,
            top: 4.0,
            bottom: 4.0),
        isDense: true,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.blue, width: 1.0),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 1.0),
        ),
      ),
      cursorWidth: 2,
      cursorHeight: 24,
    );
    return RawKeyboardListener(
      focusNode: FocusNode(
        onKey: (FocusNode node, RawKeyEvent event) {
          if (event.logicalKey == LogicalKeyboardKey.enter) {
            onSubmitted(_text);
          } else if (event.logicalKey == LogicalKeyboardKey.escape) {
            onEscaped?.call();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
      ),
      child: autofocus ? IgnoreTapWatcher(child: textField) : textField,
    );
  }
}
