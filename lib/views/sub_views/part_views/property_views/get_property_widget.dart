import 'package:better_print/better_print.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blossom/constants/colors.dart';
import 'package:flutter_blossom/helpers/extensions.dart'; // ignore: unused_import
import 'package:flutter_blossom/helpers/formatter.dart';
import 'package:flutter_blossom/states/property_state.dart';
import 'package:flutter_blossom/views/sub_views/part_views/property_views/properties/color_property.dart';
import 'package:flutter_blossom/views/sub_views/part_views/property_views/properties/function_property.dart';
import 'package:flutter_blossom/views/sub_views/part_views/property_views/properties/opacity_property.dart';
import 'package:flutter_blossom/views/sub_views/part_views/property_views/properties/select_data_property.dart';
import 'package:flutter_blossom/views/sub_views/part_views/property_views/properties/string_property.dart';
import 'package:flutter_widget_model/property.dart';
import 'package:flutter_widget_model/property_helpers/icons_helper.dart';
import 'package:flutter_widget_model/types.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// get property editing widget by type
Widget getPropertyWidget(BuildContext context, String parentKey, String key,
    Property property, List<Widget> children) {
  final _propertyState = context.read(propertyState);
  Widget? main;
  _getGenericSelectProperty() => SelectProperty(
        options: property.availableValues,
        selectedValue: property.getValue == null ? null : property.encodeValue(),
        onSelect: (v) {
          _propertyState.updatePropertyValue(property, v);
        },
      );
  switch (property.type) {
    case PropertyType.Action:
      main = _getGenericSelectProperty();
      break;
    case PropertyType.ActionDispatcher:
      // TODO: Handle this case.
      break;
    case PropertyType.Alignment:
      main = _getGenericSelectProperty();
      break;
    case PropertyType.AlignmentGeometry:
      main = _getGenericSelectProperty();
      break;
    case PropertyType.AndroidViewController:
      // TODO: Handle this case.
      break;
    case PropertyType.Animation:
      // TODO: Handle this case.
      break;
    case PropertyType.AnimationBehavior:
      // TODO: Handle this case.
      break;
    case PropertyType.AnimationController:
      // TODO: Handle this case.
      break;
    case PropertyType.AppBarTheme:
      // TODO: Handle this case.
      break;
    case PropertyType.AssetBundle:
      // TODO: Handle this case.
      break;
    case PropertyType.AutofillContextAction:
      // TODO: Handle this case.
      break;
    case PropertyType.AutovalidateMode:
      // TODO: Handle this case.
      break;
    case PropertyType.Axis:
      main = _getGenericSelectProperty();
      break;
    case PropertyType.AxisDirection:
      main = _getGenericSelectProperty();
      break;
    case PropertyType.BackButtonDispatcher:
      // TODO: Handle this case.
      break;
    case PropertyType.BannerLocation:
      main = _getGenericSelectProperty();
      break;
    case PropertyType.BlendMode:
      main = _getGenericSelectProperty();
      break;
    case PropertyType.Bool:
      main = InkWell(
        onTap: () =>
            _propertyState.updatePropertyValue(property, !(property.getValue ?? false)),
        child: Icon(
          property.getValue ?? false
              ? Icons.check_box_outlined
              : Icons.check_box_outline_blank,
          color: Colors.grey.withOpacity(0.6),
        ),
      );
      break;
    case PropertyType.Border:
      // TODO: Handle this case.
      break;
    case PropertyType.BorderRadius:
      // TODO: Handle this case.
      break;
    case PropertyType.BorderRadiusGeometry:
      // TODO: Handle this case.
      break;
    case PropertyType.BorderSide:
      // TODO: Handle this case.
      break;
    case PropertyType.BorderStyle:
      main = _getGenericSelectProperty();
      break;
    case PropertyType.BottomAppBarTheme:
      // TODO: Handle this case.
      break;
    case PropertyType.BottomNavigationBarThemeData:
      // TODO: Handle this case.
      break;
    case PropertyType.BottomNavigationBarType:
      // TODO: Handle this case.
      break;
    case PropertyType.BottomSheetThemeData:
      // TODO: Handle this case.
      break;
    case PropertyType.BoxBorder:
      // TODO: Handle this case.
      break;
    case PropertyType.BoxConstraints:
      // TODO: Handle this case.
      break;
    case PropertyType.BoxDecoration:
      // TODO: Handle this case.
      break;
    case PropertyType.BoxFit:
      main = _getGenericSelectProperty();
      break;
    case PropertyType.BoxHeightStyle:
      main = _getGenericSelectProperty();
      break;
    case PropertyType.BoxShape:
      main = _getGenericSelectProperty();
      break;
    case PropertyType.BoxWidthStyle:
      main = _getGenericSelectProperty();
      break;
    case PropertyType.Brightness:
      main = _getGenericSelectProperty();
      break;
    case PropertyType.BuildContext:
      // TODO: Handle this case.
      break;
    case PropertyType.ButtonBarLayoutBehavior:
      // TODO: Handle this case.
      break;
    case PropertyType.ButtonBarThemeData:
      // TODO: Handle this case.
      break;
    case PropertyType.ButtonStyle:
      // TODO: Handle this case.
      break;
    case PropertyType.ButtonTextTheme:
      // TODO: Handle this case.
      break;
    case PropertyType.ButtonThemeData:
      // TODO: Handle this case.
      break;
    case PropertyType.CacheExtentStyle:
      // TODO: Handle this case.
      break;
    case PropertyType.CardTheme:
      // TODO: Handle this case.
      break;
    case PropertyType.CheckboxThemeData:
      // TODO: Handle this case.
      break;
    case PropertyType.ChipThemeData:
      // TODO: Handle this case.
      break;
    case PropertyType.Clip:
      // TODO: Handle this case.
      break;
    case PropertyType.CollapseMode:
      main = _getGenericSelectProperty();
      break;
    case PropertyType.Color:
      return ColorPropertyView(valueKey: key, value: property);
    case PropertyType.ColorFilter:
      // TODO: Handle this case.
      break;
    case PropertyType.ColorScheme:
      // TODO: Handle this case.
      break;
    case PropertyType.CrossAxisAlignment:
      main = _getGenericSelectProperty();
      break;
    case PropertyType.CrossFadeState:
      main = _getGenericSelectProperty();
      break;
    case PropertyType.CupertinoDatePickerMode:
      // TODO: Handle this case.
      break;
    case PropertyType.CupertinoTabBar:
      // TODO: Handle this case.
      break;
    case PropertyType.CupertinoTabController:
      // TODO: Handle this case.
      break;
    case PropertyType.CupertinoTextThemeData:
      // TODO: Handle this case.
      break;
    case PropertyType.CupertinoThemeData:
      // TODO: Handle this case.
      break;
    case PropertyType.CupertinoTimerPickerMode:
      // TODO: Handle this case.
      break;
    case PropertyType.CupertinoUserInterfaceLevelData:
      // TODO: Handle this case.
      break;
    case PropertyType.Curve:
      // TODO: Handle this case.
      break;
    case PropertyType.CustomClipper:
      // TODO: Handle this case.
      break;
    case PropertyType.CustomPainter:
      // TODO: Handle this case.
      break;
    case PropertyType.DataTableSource:
      // TODO: Handle this case.
      break;
    case PropertyType.DataTableThemeData:
      // TODO: Handle this case.
      break;
    case PropertyType.DatePickerEntryMode:
      // TODO: Handle this case.
      break;
    case PropertyType.DatePickerMode:
      // TODO: Handle this case.
      break;
    case PropertyType.DateTime:
      // TODO: Handle this case.
      break;
    case PropertyType.DateTimeRange:
      // TODO: Handle this case.
      break;
    case PropertyType.Decoration:
      main = _getGenericSelectProperty();
      break;
    case PropertyType.DecorationImage:
      // TODO: Handle this case.
      break;
    case PropertyType.DecorationPosition:
      // TODO: Handle this case.
      break;
    case PropertyType.DialogTheme:
      // TODO: Handle this case.
      break;
    case PropertyType.DismissDirection:
      // TODO: Handle this case.
      break;
    case PropertyType.DividerThemeData:
      // TODO: Handle this case.
      break;
    case PropertyType.Double:
      main = key == 'opacity'
          ? OpacitySliderProperty(
              color:
                  property.parent != null && property.parent!.type == PropertyType.Color
                      ? property.parent!.getValue
                      : property.children.values.any((x) => x.type == PropertyType.Color)
                          ? property.children.values
                              .firstWhere((y) => y.type == PropertyType.Color)
                              .getValue
                          : null,
              value: property.getValue ?? 1.0,
              onChange: (val) {
                _propertyState.updatePropertyValue(property, val);
              },
            )
          : StringField(
              value: property.getValue == null ? '' : property.getValue.toString(),
              formatter: [doubleFormatter],
              isDouble: true,
              onSubmitted: (v) => _propertyState.updatePropertyValue(property, v),
            );
      break;
    case PropertyType.DragAnchor:
      // TODO: Handle this case.
      break;
    case PropertyType.DragStartBehavior:
      main = _getGenericSelectProperty();
      break;
    case PropertyType.DrawerAlignment:
      main = _getGenericSelectProperty();
      break;
    case PropertyType.Duration:
      // TODO: Handle this case.
      break;
    case PropertyType.Dynamic:
      // TODO: Handle this case.
      break;
    case PropertyType.EdgeInsets:
      // TODO: Handle this case.
      break;
    case PropertyType.EdgeInsetsDirectional:
      // TODO: Handle this case.
      break;
    case PropertyType.EdgeInsetsGeometry:
      // TODO: Handle this case.
      break;
    case PropertyType.ElevatedButtonThemeData:
      // TODO: Handle this case.
      break;
    case PropertyType.Error:
      // TODO: Handle this case.
      break;
    case PropertyType.File:
      // TODO: Handle this case.
      break;
    case PropertyType.FilterQuality:
      main = _getGenericSelectProperty();
      break;
    case PropertyType.FixedExtentScrollController:
      // TODO: Handle this case.
      break;
    case PropertyType.FlexFit:
      main = _getGenericSelectProperty();
      break;
    case PropertyType.FloatingActionButtonAnimator:
      // TODO: Handle this case.
      break;
    case PropertyType.FloatingActionButtonLocation:
      // TODO: Handle this case.
      break;
    case PropertyType.FloatingActionButtonThemeData:
      // TODO: Handle this case.
      break;
    case PropertyType.FloatingLabelBehavior:
      main = _getGenericSelectProperty();
      break;
    case PropertyType.FlowDelegate:
      // TODO: Handle this case.
      break;
    case PropertyType.FlutterError:
      // TODO: Handle this case.
      break;
    case PropertyType.FlutterLogoStyle:
      main = _getGenericSelectProperty();
      break;
    case PropertyType.FocusNode:
      // TODO: Handle this case.
      break;
    case PropertyType.FocusOrder:
      // TODO: Handle this case.
      break;
    case PropertyType.FocusScopeNode:
      // TODO: Handle this case.
      break;
    case PropertyType.FocusTraversalPolicy:
      // TODO: Handle this case.
      break;
    case PropertyType.FontStyle:
      main = _getGenericSelectProperty();
      break;
    case PropertyType.FontWeight:
      main = _getGenericSelectProperty();
      break;
    case PropertyType.Function:
      return FunctionProperty(
        valueKey: key,
        property: property,
        model: _propertyState.model!,
      );
    case PropertyType.Future:
      // TODO: Handle this case.
      break;
    case PropertyType.FutureOr:
      // TODO: Handle this case.
      break;
    case PropertyType.GestureRecognizer:
      // TODO: Handle this case.
      break;
    case PropertyType.GlobalKey:
      // TODO: Handle this case.
      break;
    case PropertyType.Gradient:
      // TODO: Handle this case.
      break;
    case PropertyType.GradientTransform:
      // TODO: Handle this case.
      break;
    case PropertyType.HeroController:
      // TODO: Handle this case.
      break;
    case PropertyType.HitTestBehavior:
      main = _getGenericSelectProperty();
      break;
    case PropertyType.Icon:
      // TODO: Handle this case.
      break;
    case PropertyType.IconData:
      main = SelectProperty(
        options: property.availableValues,
        selectedValue: property.getValue == null ? null : property.encodeValue(),
        infoList: Map.fromIterable(
          property.availableValues,
          key: (value) => '$value',
          value: (value) => Icon(
            getIcon(value),
            size: 14,
            color: Theme.of(context)
                .textTheme
                .button!
                .color!
                .reverseBy(contextMenuLabelBy * 2),
          ),
        ),
        onSelect: (v) => _propertyState.updatePropertyValue(property, v),
      );
      break;
    case PropertyType.IconThemeData:
      // TODO: Handle this case.
      break;
    case PropertyType.Image:
      // TODO: Handle this case.
      break;
    case PropertyType.ImageFilter:
      // TODO: Handle this case.
      break;
    case PropertyType.ImageProvider:
      // TODO: Handle this case.
      break;
    case PropertyType.ImageRepeat:
      // TODO: Handle this case.
      break;
    case PropertyType.InlineSpan:
      // TODO: Handle this case.
      break;
    case PropertyType.InputBorder:
      // TODO: Handle this case.
      break;
    case PropertyType.InputDecoration:
      // TODO: Handle this case.
      break;
    case PropertyType.InputDecorationTheme:
      // TODO: Handle this case.
      break;
    case PropertyType.Int:
      main = StringField(
        value: property.getValue == null ? '' : property.getValue.toString(),
        formatter: [FilteringTextInputFormatter.digitsOnly],
        isInt: true,
        onSubmitted: (v) => _propertyState.updatePropertyValue(property, v),
      );
      break;
    case PropertyType.InteractiveInkFeatureFactory:
      // TODO: Handle this case.
      break;
    case PropertyType.Iterable:
      // TODO: Handle this case.
      break;
    case PropertyType.Key:
      // TODO: Handle this case.
      break;
    case PropertyType.LayerLink:
      // TODO: Handle this case.
      break;
    case PropertyType.List:
      // TODO: Handle this case.
      break;
    case PropertyType.ListTileControlAffinity:
      main = _getGenericSelectProperty();
      break;
    case PropertyType.ListTileStyle:
      main = _getGenericSelectProperty();
      break;
    case PropertyType.ListWheelChildDelegate:
      // TODO: Handle this case.
      break;
    case PropertyType.Listenable:
      // TODO: Handle this case.
      break;
    case PropertyType.Locale:
      // TODO: Handle this case.
      break;
    case PropertyType.MainAxisAlignment:
      main = _getGenericSelectProperty();
      break;
    case PropertyType.MainAxisSize:
      main = _getGenericSelectProperty();
      break;
    case PropertyType.Map:
      // TODO: Handle this case.
      break;
    case PropertyType.MaterialBannerThemeData:
      // TODO: Handle this case.
      break;
    case PropertyType.MaterialColor:
      // TODO: Handle this case.
      break;
    case PropertyType.MaterialStateProperty:
      // TODO: Handle this case.
      break;
    case PropertyType.MaterialTapTargetSize:
      // TODO: Handle this case.
      break;
    case PropertyType.MaterialType:
      main = _getGenericSelectProperty();
      break;
    case PropertyType.Matrix4:
      // TODO: Handle this case.
      break;
    case PropertyType.MaxLengthEnforcement:
      main = _getGenericSelectProperty();
      break;
    case PropertyType.MediaQueryData:
      // TODO: Handle this case.
      break;
    case PropertyType.MessageCodec:
      // TODO: Handle this case.
      break;
    case PropertyType.MouseCursor:
      // TODO: Handle this case.
      break;
    case PropertyType.MultiChildLayoutDelegate:
      // TODO: Handle this case.
      break;
    case PropertyType.NavigationMode:
      // TODO: Handle this case.
      break;
    case PropertyType.NavigationRailLabelType:
      main = _getGenericSelectProperty();
      break;
    case PropertyType.NavigationRailThemeData:
      // TODO: Handle this case.
      break;
    case PropertyType.NoDefaultCupertinoThemeData:
      // TODO: Handle this case.
      break;
    case PropertyType.NotchedShape:
      // TODO: Handle this case.
      break;
    case PropertyType.Object:
      // TODO: Handle this case.
      break;
    case PropertyType.ObstructingPreferredSizeWidget:
      // TODO: Handle this case.
      break;
    case PropertyType.Offset:
      // TODO: Handle this case.
      break;
    case PropertyType.OutlinedBorder:
      // TODO: Handle this case.
      break;
    case PropertyType.OutlinedButtonThemeData:
      // TODO: Handle this case.
      break;
    case PropertyType.Overflow:
      main = _getGenericSelectProperty();
      break;
    case PropertyType.OverflowBarAlignment:
      main = _getGenericSelectProperty();
      break;
    case PropertyType.OverlayVisibilityMode:
      main = _getGenericSelectProperty();
      break;
    case PropertyType.PageController:
      // TODO: Handle this case.
      break;
    case PropertyType.PageStorageBucket:
      // TODO: Handle this case.
      break;
    case PropertyType.PageTransitionsTheme:
      // TODO: Handle this case.
      break;
    case PropertyType.Paint:
      // TODO: Handle this case.
      break;
    case PropertyType.PlatformViewController:
      // TODO: Handle this case.
      break;
    case PropertyType.PlatformViewHitTestBehavior:
      main = _getGenericSelectProperty();
      break;
    case PropertyType.PointerDeviceKind:
      main = _getGenericSelectProperty();
      break;
    case PropertyType.PopupMenuThemeData:
      // TODO: Handle this case.
      break;
    case PropertyType.RadioThemeData:
      // TODO: Handle this case.
      break;
    case PropertyType.Radius:
      // TODO: Handle this case.
      break;
    case PropertyType.RangeLabels:
      // TODO: Handle this case.
      break;
    case PropertyType.RangeSliderThumbShape:
      // TODO: Handle this case.
      break;
    case PropertyType.RangeSliderTickMarkShape:
      // TODO: Handle this case.
      break;
    case PropertyType.RangeSliderTrackShape:
      // TODO: Handle this case.
      break;
    case PropertyType.RangeSliderValueIndicatorShape:
      // TODO: Handle this case.
      break;
    case PropertyType.RangeValues:
      // TODO: Handle this case.
      break;
    case PropertyType.Rect:
      // TODO: Handle this case.
      break;
    case PropertyType.RefreshIndicatorTriggerMode:
      main = _getGenericSelectProperty();
      break;
    case PropertyType.RelativeRect:
      // TODO: Handle this case.
      break;
    case PropertyType.RenderBox:
      // TODO: Handle this case.
      break;
    case PropertyType.RenderObjectWithChildMixin:
      // TODO: Handle this case.
      break;
    case PropertyType.RestorationBucket:
      // TODO: Handle this case.
      break;
    case PropertyType.RouteInformationParser:
      // TODO: Handle this case.
      break;
    case PropertyType.RouteInformationProvider:
      // TODO: Handle this case.
      break;
    case PropertyType.RouterDelegate:
      // TODO: Handle this case.
      break;
    case PropertyType.ScrollBehavior:
      // TODO: Handle this case.
      break;
    case PropertyType.ScrollController:
      // TODO: Handle this case.
      break;
    case PropertyType.ScrollPhysics:
      // TODO: Handle this case.
      break;
    case PropertyType.ScrollViewKeyboardDismissBehavior:
      main = _getGenericSelectProperty();
      break;
    case PropertyType.ScrollbarThemeData:
      // TODO: Handle this case.
      break;
    case PropertyType.SemanticsGestureDelegate:
      // TODO: Handle this case.
      break;
    case PropertyType.SemanticsHintOverrides:
      // TODO: Handle this case.
      break;
    case PropertyType.SemanticsProperties:
      // TODO: Handle this case.
      break;
    case PropertyType.SemanticsSortKey:
      // TODO: Handle this case.
      break;
    case PropertyType.SemanticsTag:
      // TODO: Handle this case.
      break;
    case PropertyType.Set:
      // TODO: Handle this case.
      break;
    case PropertyType.ShapeBorder:
      // TODO: Handle this case.
      break;
    case PropertyType.ShortcutManager:
      // TODO: Handle this case.
      break;
    case PropertyType.ShowValueIndicator:
      main = _getGenericSelectProperty();
      break;
    case PropertyType.SingleChildLayoutDelegate:
      // TODO: Handle this case.
      break;
    case PropertyType.Size:
      // TODO: Handle this case.
      break;
    case PropertyType.SliderComponentShape:
      // TODO: Handle this case.
      break;
    case PropertyType.SliderThemeData:
      // TODO: Handle this case.
      break;
    case PropertyType.SliderTickMarkShape:
      // TODO: Handle this case.
      break;
    case PropertyType.SliderTrackShape:
      // TODO: Handle this case.
      break;
    case PropertyType.SliverChildDelegate:
      // TODO: Handle this case.
      break;
    case PropertyType.SliverGridDelegate:
      // TODO: Handle this case.
      break;
    case PropertyType.SliverOverlapAbsorberHandle:
      // TODO: Handle this case.
      break;
    case PropertyType.SliverPersistentHeaderDelegate:
      // TODO: Handle this case.
      break;
    case PropertyType.SmartDashesType:
      main = _getGenericSelectProperty();
      break;
    case PropertyType.SmartQuotesType:
      main = _getGenericSelectProperty();
      break;
    case PropertyType.SnackBarAction:
      // TODO: Handle this case.
      break;
    case PropertyType.SnackBarBehavior:
      main = _getGenericSelectProperty();
      break;
    case PropertyType.SnackBarThemeData:
      // TODO: Handle this case.
      break;
    case PropertyType.StackFit:
      main = _getGenericSelectProperty();
      break;
    case PropertyType.StepperType:
      main = _getGenericSelectProperty();
      break;
    case PropertyType.Stream:
      // TODO: Handle this case.
      break;
    case PropertyType.String:
      main = StringField(
        value: property.getValue == null ? '' : property.getValue.toString(),
        onSubmitted: (v) => _propertyState.updatePropertyValue(property, v),
      );
      break;
    case PropertyType.StrutStyle:
      // TODO: Handle this case.
      break;
    case PropertyType.SwitchThemeData:
      // TODO: Handle this case.
      break;
    case PropertyType.SystemUiOverlayStyle:
      // TODO: Handle this case.
      break;
    case PropertyType.TabBarIndicatorSize:
      main = _getGenericSelectProperty();
      break;
    case PropertyType.TabBarTheme:
      // TODO: Handle this case.
      break;
    case PropertyType.TabController:
      // TODO: Handle this case.
      break;
    case PropertyType.TableBorder:
      // TODO: Handle this case.
      break;
    case PropertyType.TableCellVerticalAlignment:
      main = _getGenericSelectProperty();
      break;
    case PropertyType.TableColumnWidth:
      // TODO: Handle this case.
      break;
    case PropertyType.TargetPlatform:
      betterPrint('TargetPlatform');
      main = _getGenericSelectProperty();
      break;
    case PropertyType.TextAlign:
      main = _getGenericSelectProperty();
      break;
    case PropertyType.TextAlignVertical:
      // TODO: Handle this case.
      break;
    case PropertyType.TextBaseline:
      main = _getGenericSelectProperty();
      break;
    case PropertyType.TextButtonThemeData:
      // TODO: Handle this case.
      break;
    case PropertyType.TextCapitalization:
      main = _getGenericSelectProperty();
      break;
    case PropertyType.TextDecoration:
      // TODO: Handle this case.
      break;
    case PropertyType.TextDecorationStyle:
      main = _getGenericSelectProperty();
      break;
    case PropertyType.TextDirection:
      main = _getGenericSelectProperty();
      break;
    case PropertyType.TextEditingController:
      // TODO: Handle this case.
      break;
    case PropertyType.TextHeightBehavior:
      // TODO: Handle this case.
      break;
    case PropertyType.TextInputAction:
      main = _getGenericSelectProperty();
      break;
    case PropertyType.TextInputType:
      // TODO: Handle this case.
      break;
    case PropertyType.TextLeadingDistribution:
      main = _getGenericSelectProperty();
      break;
    case PropertyType.TextOverflow:
      main = _getGenericSelectProperty();
      break;
    case PropertyType.TextSelectionControls:
      // TODO: Handle this case.
      break;
    case PropertyType.TextSelectionThemeData:
      // TODO: Handle this case.
      break;
    case PropertyType.TextSpan:
      // TODO: Handle this case.
      break;
    case PropertyType.TextStyle:
      // TODO: Handle this case.
      break;
    case PropertyType.TextTheme:
      // TODO: Handle this case.
      break;
    case PropertyType.TextWidthBasis:
      main = _getGenericSelectProperty();
      break;
    case PropertyType.ThemeData:
      // TODO: Handle this case.
      break;
    case PropertyType.ThemeMode:
      main = _getGenericSelectProperty();
      break;
    case PropertyType.TickerProvider:
      // TODO: Handle this case.
      break;
    case PropertyType.TimePickerThemeData:
      // TODO: Handle this case.
      break;
    case PropertyType.ToggleButtonsThemeData:
      // TODO: Handle this case.
      break;
    case PropertyType.ToolbarOptions:
      // TODO: Handle this case.
      break;
    case PropertyType.TooltipThemeData:
      // TODO: Handle this case.
      break;
    case PropertyType.TransformationController:
      // TODO: Handle this case.
      break;
    case PropertyType.TransitionDelegate:
      // TODO: Handle this case.
      break;
    case PropertyType.Tween:
      // TODO: Handle this case.
      break;
    case PropertyType.Typography:
      // TODO: Handle this case.
      break;
    case PropertyType.Uint8List:
      // TODO: Handle this case.
      break;
    case PropertyType.ValueListenable:
      // TODO: Handle this case.
      break;
    case PropertyType.VerticalDirection:
      main = _getGenericSelectProperty();
      break;
    case PropertyType.ViewportOffset:
      // TODO: Handle this case.
      break;
    case PropertyType.VisualDensity:
      // TODO: Handle this case.
      break;
    case PropertyType.Widget:
      // TODO: Handle this case.
      break;
    case PropertyType.WrapAlignment:
      main = _getGenericSelectProperty();
      break;
    case PropertyType.WrapCrossAlignment:
      main = _getGenericSelectProperty();
      break;
  }
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisSize: MainAxisSize.min,
    children: [
      if (main == null && parentKey != key)
        Opacity(
          opacity: property.isInitialized || _propertyState.model!.type == ModelType.Root
              ? 1
              : 0.4,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(key.separate.capitalize),
          ),
        ),
      if (main != null)
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              flex: 2,
              child: Opacity(
                opacity:
                    property.isInitialized || _propertyState.model!.type == ModelType.Root
                        ? 1
                        : 0.4,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    key.separate.capitalize,
                    style: TextStyle(color: Colors.grey.withOpacity(0.8)),
                  ),
                ),
              ),
            ),
            Flexible(
              flex: 3,
              fit: FlexFit.tight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: main,
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ...children
          .map(
            (e) => Padding(
              padding: const EdgeInsets.only(left: 12.0, top: 4),
              child: e,
            ),
          )
          .toList(),
    ],
  );
}
