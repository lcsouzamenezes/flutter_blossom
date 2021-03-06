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

import 'package:better_print/better_print.dart'; // ignore: unused_import
import 'package:code_blocks/code_blocks.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flex_color_picker/flex_color_picker.dart'
    hide FlexPickerNoNullStringExtensions;
import 'package:flutter/services.dart';
import 'package:flutter_blossom/components/context_menu_item.dart';
import 'package:flutter_blossom/components/draggable_area.dart';
import 'package:flutter_blossom/components/draggable_target.dart';
import 'package:flutter_blossom/components/micro_components/context_menu_container.dart';
import 'package:flutter_blossom/components/tree_icon_button.dart';
import 'package:flutter_blossom/constants/colors.dart';
import 'package:flutter_blossom/constants/lengths.dart';
import 'package:flutter_blossom/generated/l10n.dart';
import 'package:flutter_blossom/helpers/extensions.dart'; // ignore: unused_import
import 'package:flutter/material.dart';
import 'package:flutter_blossom/components/drag_vertical_line.dart';
import 'package:flutter_blossom/helpers/formatter.dart';
import 'package:flutter_blossom/helpers/rich_text_controller.dart';
import 'package:flutter_blossom/states/context_menu_state.dart';
import 'package:flutter_blossom/states/editor_state.dart';
import 'package:flutter_blossom/states/model_state.dart';
import 'package:flutter_blossom/states/property_state.dart';
import 'package:flutter_blossom/states/storage_state.dart';
import 'package:flutter_blossom/states/tree_state.dart';
import 'package:flutter_blossom/utils/double_tap.dart';
import 'package:flutter_blossom/utils/handle_keys.dart';
import 'package:flutter_blossom/views/sub_views/part_views/property_view.dart';
import 'package:flutter_blossom/views/sub_views/part_views/property_views/get_property_widget.dart';
import 'package:flutter_blossom/views/sub_views/part_views/property_views/properties/color_property.dart';
import 'package:flutter_blossom/views/sub_views/part_views/property_views/properties/function_property.dart';
import 'package:flutter_blossom/views/sub_views/part_views/property_views/properties/inherit_property.dart';
import 'package:flutter_blossom/views/sub_views/part_views/property_views/properties/opacity_property.dart';
import 'package:flutter_blossom/views/sub_views/part_views/property_views/property_change_button.dart';
import 'package:flutter_blossom/views/sub_views/part_views/property_views/properties/select_data_property.dart';
import 'package:flutter_blossom/views/sub_views/part_views/property_views/properties/string_property.dart';
import 'package:flutter_blossom/views/sub_views/part_views/tree_view.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_widget_model/flutter_widget_model.dart';
import 'package:flutter_widget_model/property_helpers/icons_helper.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:keyboard_shortcuts/keyboard_shortcuts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:uuid/uuid.dart';

class PropertyName extends HookWidget {
  PropertyName(
    this.propertyKey, {
    required this.onTap,
    this.onEdit,
  }) : super(key: ValueKey(propertyKey));

  final String propertyKey;
  final void Function(bool)? onEdit;
  final void Function() onTap;

  Widget build(BuildContext context) {
    final _isRenameActive = useState(false);

    _activateEditMode() {
      _isRenameActive.value = true;
      Future.delayed(Duration(milliseconds: 0)).then((value) {
        onEdit?.call(true);
      });
    }

    _deactivateEditMode() {
      onEdit?.call(false);
      _isRenameActive.value = false;
    }

    useEffect(() {}, const []);

    return _isRenameActive.value
        ? StringField(
            autofocus: true,
            onSubmitted: (newValue) {
              _deactivateEditMode();
              if (newValue != '') {
                context.read(propertyState).updatePropertyKey(propertyKey, newValue);
              }
            },
            onFocusChange: (node) {
              if (!node.hasFocus) {
                _deactivateEditMode();
              }
            },
            onEscaped: _deactivateEditMode,
            value: propertyKey,
          )
        : DoubleTap(
            onDoubleTap: _activateEditMode,
            onTap: onTap,
            doubleDelay: 250,
            child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: Tooltip(
                message: propertyKey,
                waitDuration: Duration(milliseconds: 600),
                child: Text(
                  propertyKey.separate.capitalize,
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(
                        color: Theme.of(context)
                            .textTheme
                            .bodyText1!
                            .color!
                            .reverseBy(panelBodyBy + 5),
                      ),
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          );
  }
}

class PropertyEditWidget extends HookWidget {
  PropertyEditWidget(this.propertyKey, this.property);
  final String propertyKey;
  final Property property;

  @override
  Widget build(BuildContext context) {
    final editValue = useState(property.isInitialized);
    final isKeyEditMode = useState(false);
    // final _width = useProvider(propertyViewAreaSize);
    final _isRenameOnHover = useState<String?>(null);
    final _isDeleteOnHover = useState<String?>(null);
    final _isNullOnHover = useState<String?>(null);
    final _isFinalOnHover = useState<String?>(null);
    final _isStarOnHover = useState<String?>(null);
    final _propertyState = useProvider(propertyState);
    final _contextMenuState = useProvider(contextMenuState);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: isKeyEditMode.value
                          ? null
                          : () {
                              editValue.value = !editValue.value;
                            },
                      child: Icon(
                        editValue.value
                            ? Icons.keyboard_arrow_down
                            : Icons.keyboard_arrow_right,
                        size: 14,
                        color: Theme.of(context)
                            .textTheme
                            .bodyText1!
                            .color!
                            .reverseBy(panelBodyBy),
                      ),
                    ),
                    Flexible(
                      child: PropertyName(
                        propertyKey,
                        onTap: () => editValue.value = !editValue.value,
                        onEdit: (value) {
                          isKeyEditMode.value = value;
                          if (!editValue.value) editValue.value = true;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (propertyKey != EnumToString.convertToString(property.type))
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2.0),
                          child: Text(
                            EnumToString.convertToString(property.type),
                            softWrap: false,
                            style: TextStyle(
                              color: Colors.grey.withOpacity(0.5),
                              // backgroundColor:
                              //     Colors.grey.withOpacity(0.4),
                            ),
                          ),
                        ),
                      ),
                    if (editValue.value)
                      if (_propertyState.model!.type == ModelType.Root)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            InkWell(
                              onHover: (val) {
                                _isStarOnHover.value =
                                    _isStarOnHover.value == null ? propertyKey : null;
                              },
                              onTap: () {
                                property.copyWith(replaceable: !property.isReplaceable);
                                _propertyState.attachToTree();
                              },
                              child: Icon(
                                property.isReplaceable
                                    ? LineIcons.starAlt
                                    : LineIcons.star,
                                size: 16,
                                color: Colors.grey.withOpacity(
                                    _isStarOnHover.value == propertyKey ? 0.7 : 0.5),
                              ),
                            ),
                            InkWell(
                              onHover: (val) {
                                _isNullOnHover.value =
                                    _isNullOnHover.value == null ? propertyKey : null;
                              },
                              onTap: () {
                                property.copyWith(nullable: !property.isNullable);
                                _propertyState.attachToTree();
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                    child: Icon(
                                        // e.isNullAccepted
                                        property.isNullable
                                            ? Icons.check_box_outlined
                                            : Icons.check_box_outline_blank,
                                        size: 16,
                                        color: Colors.grey.withOpacity(
                                            _isNullOnHover.value == propertyKey
                                                ? 0.7
                                                : 0.5)),
                                  ),
                                  Text(
                                    'null',
                                    style: TextStyle(
                                        color: Colors.grey.withOpacity(
                                            _isNullOnHover.value == propertyKey
                                                ? 0.7
                                                : 0.5)),
                                  ),
                                ],
                              ),
                            ),
                            InkWell(
                              onHover: (val) {
                                _isFinalOnHover.value =
                                    _isFinalOnHover.value == null ? propertyKey : null;
                              },
                              onTap: () {
                                property.copyWith(finalStatus: !property.isFinal);
                                _propertyState.attachToTree();
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                                    child: Icon(
                                      property.isFinal
                                          ? Icons.check_box_outlined
                                          : Icons.check_box_outline_blank,
                                      size: 16,
                                      color: Colors.grey.withOpacity(
                                        _isFinalOnHover.value == propertyKey ? 0.7 : 0.5,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'final',
                                    style: TextStyle(
                                        color: Colors.grey.withOpacity(
                                            _isFinalOnHover.value == propertyKey
                                                ? 0.7
                                                : 0.5)),
                                  ),
                                ],
                              ),
                            ),
                            InkWell(
                              onHover: (val) {
                                _isDeleteOnHover.value =
                                    _isDeleteOnHover.value == null ? propertyKey : null;
                              },
                              onTap: () {
                                _propertyState.removeProperty(propertyKey);
                              },
                              child: Icon(
                                LineIcons.times,
                                size: 16,
                                color: Colors.grey.withOpacity(
                                    _isDeleteOnHover.value == propertyKey ? 0.7 : 0.5),
                              ),
                            ),
                          ],
                        )
                      else
                        Opacity(
                          opacity: 0.8,
                          child: PropertyChangeButtons(
                              valueKey: propertyKey, value: property),
                        )
                  ],
                ),
              ),
            ],
          ),
        ),
        if (editValue.value)
          if (property.inherit == null)
            // also responsible dor laying out children of property
            property.toWidget(propertyKey, (key, p, children) {
              switch (p.type) {
                // ? properties that are too big to edit in sidebar should have their own area specifically designed to handle them
                case PropertyType.ThemeData:
                case PropertyType.CupertinoThemeData:
                  return SizedBox();
                default:
                  return getPropertyWidget(context, propertyKey, key, p, children);
              }
            })
          else
            InheritProperty(valueKey: propertyKey, property: property),
      ],
    );
  }
}
