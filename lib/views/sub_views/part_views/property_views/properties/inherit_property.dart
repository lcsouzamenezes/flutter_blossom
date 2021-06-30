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
import 'package:flutter_widget_model/flutter_widget_model.dart';

class InheritProperty extends StatelessWidget {
  const InheritProperty({
    Key? key,
    required this.valueKey,
    required this.property,
  }) : super(key: key);
  final String valueKey;
  final Property property;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$valueKey',
            style: TextStyle(color: Colors.grey),
          ),
          Text(
            '${property.inherit?.key}',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
