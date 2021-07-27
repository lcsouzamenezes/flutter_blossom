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
import 'package:flutter/foundation.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter_blossom/states/model_state.dart';
import 'package:flutter_blossom/states/tree_state.dart';
import 'package:flutter_blossom/helpers/extensions.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:tree_view/node_model.dart';
import 'package:flutter_widget_model/flutter_widget_model.dart';

final propertyState = ChangeNotifierProvider((ref) => PropertyViewNotifier(ref));

class PropertyViewNotifier extends ChangeNotifier {
  final ProviderReference _ref;
  PropertyViewNotifier(ref) : _ref = ref;
  WidgetModel? _model;
  WidgetModel? get model => _model;
  bool _justUpdatedModel = false;

  setPropertyView(String? key) {
    if (key != null) {
      _model = _ref.read(modelState).controller.getModel(key);
      _justUpdatedModel = true;
    } else {
      _model = null;
    }
    // betterPrint('$key: ${_propertyList.length}');
    notifyListeners();
  }

  updateModel(WidgetModel model) {
    _ref
        .read(treeState)
        .changeNode(model.key, Node.fromMap(model.asMap), _justUpdatedModel);
    _justUpdatedModel = false;
    notifyListeners();
  }

  updatePropertyKey(String key, String newKey) {
    if (_model != null)
      _ref.read(modelState).controller.updateModel(
          _model!.key,
          _model!.coptWith(
              properties: model!.properties.map((k, value) =>
                  k == key ? MapEntry(newKey, value) : MapEntry(k, value))));
    _attachToTree();
    notifyListeners();
  }

  updatePropertyValue(Property property, dynamic value) {
    property.resolveValue(value?.toString());
    property.copyWith(isInitialized: true);
    _attachToTree();
    notifyListeners();
  }

  addProperty(Map<String, Property> property) {
    if (_model != null)
      _ref.read(modelState).controller.updateModel(
          _model!.key, _model!.coptWith(properties: model!.properties..addAll(property)));
    _attachToTree(true);
    notifyListeners();
  }

  removeProperty(String key) {
    if (_model != null)
      _ref.read(modelState).controller.updateModel(
          _model!.key,
          _model!.coptWith(
              properties: _model!.properties..removeWhere((k, value) => k == key)));
    _attachToTree();
    notifyListeners();
  }

  attachToTree([force = false]) {
    _attachToTree();
    notifyListeners();
  }

  _attachToTree([bool forceAttach = false]) {
    if (_model != null) {
      final Map<String, dynamic> data = {};
      _model!.properties.forEach((key, value) {
        if (forceAttach || value.isInitialized || value.checkChildrenInitialized(value))
          data[key] = value.asMap;
      });
      final node = _ref.read(treeState).controller.getNode(_model!.key);
      if (node != null) {
        _ref
            .read(treeState)
            .changeNode(_model!.key, node.copyWith(data: data), _justUpdatedModel);
        _justUpdatedModel = false;
      } else
        betterPrint('error');
    } else
      betterPrint('error');
  }
}
