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
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blossom/states/color_state.dart';
import 'package:flutter_blossom/states/property_state.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_widget_model/flutter_widget_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ColorPropertyView extends HookWidget {
  const ColorPropertyView({
    Key? key,
    required this.valueKey,
    required this.value,
  }) : super(key: key);
  final String valueKey;
  final Property value;

  @override
  Widget build(BuildContext context) {
    final _propertyState = useProvider(propertyState);
    final _colorState = useProvider(colorState);
    final color = useState<Color>(Colors.blue);

    useEffect(() {
      Future.delayed(Duration(milliseconds: 0))
          .then((v) => color.value = value.value ?? Colors.blue);
      return;
    }, const []);

    return Tooltip(
      message: valueKey,
      waitDuration: Duration(milliseconds: 500),
      child: Builder(builder: (context) {
        try {
          return ColorPicker(
            color: color.value,
            onColorChanged: (Color c) {
              color.value = c;
            },
            onColorChangeEnd: (c) {
              _propertyState.updatePropertyValue(value, value.encodeValue(c));

              _colorState.addToRecent(c);
            },
            padding: EdgeInsets.all(2.0),
            enableShadesSelection: false,
            enableOpacity: false,
            showRecentColors: false,
            opacityTrackHeight: 16,
            opacityThumbRadius: 12,
            width: 30,
            height: 30,
            borderRadius: 6,
            spacing: 6,
            runSpacing: 6,
            columnSpacing: 10,
            maxRecentColors: _colorState.recentLimit,
            colorCodeTextStyle: TextStyle(color: Colors.grey),
            colorNameTextStyle: TextStyle(color: Colors.grey.withOpacity(0.7)),
            heading: null,
            subheading: SizedBox(
              height: 10,
            ),
            recentColorsSubheading: _colorState.recents.isNotEmpty
                ? Text(
                    'Recent Colors',
                    style: TextStyle(color: Colors.grey),
                  )
                : null,
            recentColors: _colorState.recents,
            pickersEnabled: {
              ColorPickerType.wheel: true,
              ColorPickerType.custom: true,
              ColorPickerType.both: false,
              ColorPickerType.primary: false,
              ColorPickerType.accent: false,
              ColorPickerType.bw: false,
            },
            pickerTypeLabels: {ColorPickerType.custom: 'Bucket'},
            customColorSwatchesAndNames: <ColorSwatch<Object>, String>{
              ColorTools.createPrimarySwatch(Color(0xFF6200EE)): 'Purple',
              ColorTools.createAccentSwatch(Color(0xFF03DAC6)): 'Teal',
              ColorTools.createPrimarySwatch(Color(0xFFB00020)): 'Red',
            },
          );
        } catch (e) {
          betterPrint('Color Error');
          return Text(
            'Color Error',
            style: TextStyle(color: Colors.red),
          );
        }
      }),
    );
  }
}
