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

import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class OpacitySliderProperty extends HookWidget {
  OpacitySliderProperty({
    Key? key,
    required this.color,
    required this.value,
    required this.onChange,
  }) : super(key: key);
  final Color? color;
  final double value;
  final Function(double) onChange;

  @override
  Widget build(BuildContext context) {
    final _value = useState<double>(1);

    useEffect(() {
      _value.value = value;
      return;
    }, const []);

    return Column(
      children: [
        RepaintBoundary(
          child: OpacitySlider(
            color: color ?? Colors.grey,
            opacity: _value.value,
            trackHeight: 15,
            thumbRadius: 12,
            onChangeStart: (double value) {
              _value.value = value;
            },
            onChanged: (double value) {
              _value.value = value;
            },
            onChangeEnd: (double value) {
              onChange(value);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Opacity',
                style: TextStyle(color: Colors.grey),
              ),
              Text(
                '${_value.value.toStringAsFixed(2)}',
                style: TextStyle(color: Colors.grey),
              )
            ],
          ),
        ),
      ],
    );
  }
}
