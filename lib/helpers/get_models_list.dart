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
import 'package:flutter_widget_model/flutter_widget_model.dart';

List<NodeType> getNodeModelList(List<NodeType> filter) {
  final list = List<NodeType>.from(NodeType.values);
  final _filter = [NodeType.Root, ...filter];
  list.removeWhere((e) => _filter.contains(e));
  list.sort((a, b) => EnumToString.convertToString(a)
      .compareTo(EnumToString.convertToString(b)));
  return list;
}
