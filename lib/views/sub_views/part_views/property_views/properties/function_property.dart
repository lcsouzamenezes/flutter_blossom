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

import 'package:code_blocks/code_blocks.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blossom/states/model_state.dart';
import 'package:flutter_blossom/states/property_state.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_widget_model/flutter_widget_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';

class FunctionProperty extends HookWidget {
  FunctionProperty({
    Key? key,
    required this.valueKey,
    required this.property,
    required this.model,
  }) : super(key: key);

  final String valueKey;
  final Property property;
  final WidgetModel model;
  final uuid = Uuid();

  @override
  Widget build(BuildContext context) {
    final _propertyState = useProvider(propertyState);

    void saveToTree(BlockController controller) {
      _propertyState.updateProperty(
        valueKey,
        property.copyWith(
          value: controller,
          isInitialized: true,
          forceValue: true,
        ),
      );
    }

    WidgetModel _getRoot() {
      WidgetModel root = model;
      final controller = context.read(modelState).controller;
      root = controller.children.firstWhere(
          (e) => controller.getModel(e.key) != null,
          orElse: () => root);
      return root;
    }

    return BlockCanvas(
      controller: property.value is BlockController
          ? property.value
          : BlockController(children: [], root: _getRoot(), resolve: (_) {}),
      onAdd: (key, type) {
        if (key != null && property.value != null)
          saveToTree(BlockController(
              children: property.value
                  .addBlock(key, Block(key: uuid.v4(), data: {}, type: type)),
              root: _getRoot(),
              resolve: property.value.resolve));
        else
          saveToTree(BlockController(children: [
            ...(property.value?.children ?? []),
            Block(key: uuid.v4(), data: {}, type: type)
          ], root: _getRoot(), resolve: (_) {}));
      },
      onUpdate: (key, updated) {
        if (property.value != null)
          saveToTree(BlockController(
              children: property.value.updateBlock(key, updated),
              root: _getRoot(),
              resolve: property.value.resolve));
      },
      onDelete: (key) {
        if (property.value != null)
          saveToTree(BlockController(
              children: property.value.deleteBlock(key, deleteChildren: true),
              root: _getRoot(),
              resolve: property.value.resolve));
      },
      maxHeight: property.value == null ||
              //! fix: fix value should always be [BlockController]
              (property.value is BlockController &&
                  property.value.children.isEmpty)
          ? 120
          : 200,
      // backgroundColor: Colors.blueAccent,
    );
  }
}
