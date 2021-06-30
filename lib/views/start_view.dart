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

import 'dart:convert';

import 'package:better_print/better_print.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blossom/components/profile_action.dart';
import 'package:flutter_blossom/constants/colors.dart';
import 'package:flutter_blossom/constants/langs.dart';
import 'package:flutter_blossom/constants/templates.dart';
import 'package:flutter_blossom/generated/l10n.dart';
import 'package:flutter_blossom/states/app_state.dart';
import 'package:flutter_blossom/states/context_menu_state.dart';
import 'package:flutter_blossom/states/tree_state.dart';
import 'package:flutter_blossom/views/editor_view.dart';
import 'package:flutter_blossom/views/sub_views/part_views/console_view.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_localized_locales/native_locale_names.dart';
import 'package:flutter_widget_model/flutter_widget_model.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_blossom/helpers/extensions.dart';
import 'package:line_icons/line_icons.dart';
import 'package:tree_view/node_model.dart';

class StartScreenArgument {
  StartScreenArgument(
      {this.file, this.data, this.isNew = false, this.suggestedName});
  final XFile? file;
  final Map<String, dynamic>? data;
  final bool isNew;
  final String? suggestedName;
}

class StartScreen extends HookWidget {
  static final routeName = '/start';
  @override
  Widget build(BuildContext context) {
    final _contextMenu = useProvider(contextMenuState);
    final _treeState = useProvider(treeState);

    useEffect(() {
      if (!kIsWeb) context.read(treeState).loadRecents();
      Future.delayed(Duration(milliseconds: 0)).then((value) {
        // if (!kReleaseMode)
        //   Navigator.pushNamed(context, EditorScreen.routeName,
        //       arguments: {StartScreenRouteArgType.Null: null});
      });
      return;
    }, const []);
    return Title(
      title: 'Flutter Blossom',
      color: appColor,
      child: Material(
        child: Stack(
          children: [
            Listener(
              // reset
              onPointerDown: (_) {
                if (_contextMenu.menu != null) {
                  _contextMenu.clear();
                  _contextMenu.clearSubMenus();
                }
              },
              child: Scaffold(
                appBar: PreferredSize(
                  preferredSize: Size.fromHeight(EditorScreen.appBarHeight + 8),
                  child: AppBar(
                    elevation: 1,
                    title: Text(
                      S.of(context).selectRequestSort,
                      style: Theme.of(context).appBarTheme.titleTextStyle,
                    ),
                    actions: [
                      ProfileAction(),
                    ],
                  ),
                ),
                body: Stack(
                  children: [
                    SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 88.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 2,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 4.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Recently opened'),
                                  Row(
                                    children: [
                                      if (_treeState.recents.isNotEmpty)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 4.0),
                                          child: StartNewProjectButton(true),
                                        ),
                                      StartNewProjectButton(false),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  if (_treeState.recents.isNotEmpty)
                                    ..._treeState.recents
                                        .map(
                                          (e) => Padding(
                                            padding: const EdgeInsets.all(2.0),
                                            child:
                                                StartFromRecentsProjectButton(
                                              file: e,
                                              key: ValueKey(e.path),
                                            ),
                                          ),
                                        )
                                        .toList(),
                                  if (_treeState.recents.length < 12) OpenBox()
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [Text('Templates'), SizedBox()],
                              ),
                            ),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  ...templates
                                      .map(
                                        (e) => Padding(
                                          padding: const EdgeInsets.all(2.0),
                                          child: TemplateProjectButton(
                                              template: e),
                                        ),
                                      )
                                      .toList()
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: Container(
                          height: 80,
                          color: Theme.of(context).canvasColor.darken(2),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: EditorConsole(),
            ),
            Transform.translate(
              offset: _contextMenu.menu?.offset ?? Offset.zero,
              child: _contextMenu.menu?.child,
            ),
            ..._contextMenu.subMenus
                .map((e) => Transform.translate(
                      offset: e.offset,
                      child: e.child,
                    ))
                .toList()
          ],
        ),
      ),
    );
  }
}

class OpenBox extends HookWidget {
  const OpenBox({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final app = useProvider(appState);
    double width = app.windowSize.width / 4 - 14;
    width = width > 300 ? app.windowSize.width / 6 - 14 : width;
    final isOnHover = useState(false);
    return InkWell(
      onTap: () async {
        final file = await openFile(
          acceptedTypeGroups: [typeGroup],
        );
        if (file != null)
          Navigator.pushNamed(context, EditorScreen.routeName,
              arguments: StartScreenArgument(file: file));
      },
      onHover: (value) {
        isOnHover.value = !isOnHover.value;
      },
      child: Container(
        width: width,
        height: width * 0.8,
        child: DottedBorder(
          color: Colors.black26,
          strokeWidth: 1.5,
          borderType: BorderType.RRect,
          radius: Radius.circular(isOnHover.value ? 0 : 12),
          dashPattern: [10, 3],
          child: Center(
            child: Icon(
              LineIcons.plus,
              color: isOnHover.value ? Colors.white54 : Colors.black38,
            ),
          ),
        ),
      ),
    );
  }
}

class TemplateProjectButton extends HookWidget {
  const TemplateProjectButton({
    required this.template,
    Key? key,
  }) : super(key: key);
  final String template;

  @override
  Widget build(BuildContext context) {
    final app = useProvider(appState);
    double width = app.windowSize.width / 4 - 14;
    width = width > 300 ? app.windowSize.width / 6 - 14 : width;
    final _widget = useState<Widget?>(null);
    final _title = useState<String>('');
    final json = useState<Map<String, dynamic>>({});
    final isOnHover = useState(false);
    useEffect(() {
      Future.delayed(Duration(milliseconds: 0)).then((_) {
        DefaultAssetBundle.of(context)
            .loadString("assets/templates/$template.json")
            .then((value) {
          json.value = jsonDecode(value);
          _title.value = json.value['name'];
          final node = Node.fromMap(json.value['cover']);
          _widget.value = WidgetModelController()
              .loadNodes((_) {}, [node])
              .children
              .first
              .toWidget((key, {required Widget child}) => child, true);
        });
      });
    }, const []);
    return Container(
      width: width,
      height: width * 0.8,
      child: Card(
        color: Theme.of(context).canvasColor.by(6),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.all(Radius.circular(isOnHover.value ? 6.0 : 12.0)),
        ),
        elevation: isOnHover.value ? 3 : 1,
        margin: const EdgeInsets.all(0),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            if (json.value['template'] != null)
              Navigator.pushNamed(context, EditorScreen.routeName,
                  arguments: StartScreenArgument(
                      isNew: true,
                      data: json.value['template'],
                      suggestedName: json.value['suggestedName']));
          },
          onHover: (value) {
            isOnHover.value = !isOnHover.value;
          },
          child: Stack(
            children: [
              Container(
                child: AbsorbPointer(child: _widget.value),
              ),
              if (isOnHover.value)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    color: Theme.of(context).canvasColor.withOpacity(0.3),
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            child: Center(
                              child: Text(
                                _title.value,
                                style: Theme.of(context).textTheme.subtitle2,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            child: Center(
                              child: Text(
                                json.value['description'] ?? 0,
                                style: Theme.of(context).textTheme.subtitle2,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class StartFromRecentsProjectButton extends HookWidget {
  const StartFromRecentsProjectButton({
    required this.file,
    Key? key,
  }) : super(key: key);
  final XFile file;

  @override
  Widget build(BuildContext context) {
    final app = useProvider(appState);
    double width = app.windowSize.width / 4 - 14;
    width = width > 300 ? app.windowSize.width / 6 - 14 : width;
    final _widget = useState<Widget?>(null);
    final isOnHover = useState(false);
    useEffect(() {
      file.readAsString().then((value) {
        final json = jsonDecode(value);
        final trees = Map<String, dynamic>.from(json['trees']);
        final List? tree = trees.values.toList().firstOrNull;
        if (tree != null) {
          final data = tree.firstOrNull;
          final node = Node.fromMap(data);
          _widget.value = WidgetModelController()
              .loadNodes((_) {}, [node])
              .children
              .first
              .toWidget((key, {required Widget child}) => child, true);
        }
      });
    }, const []);
    return Container(
      width: width,
      height: width * 0.8,
      child: Card(
        color: Theme.of(context).canvasColor.by(3),
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.all(Radius.circular(isOnHover.value ? 6.0 : 12.0)),
        ),
        elevation: isOnHover.value ? 3 : 1,
        margin: const EdgeInsets.all(0),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, EditorScreen.routeName,
              arguments: StartScreenArgument(file: file)),
          onHover: (value) {
            isOnHover.value = !isOnHover.value;
          },
          child: Stack(
            children: [
              Container(
                child: AbsorbPointer(child: _widget.value),
              ),
              if (isOnHover.value)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    color: Theme.of(context).canvasColor.withOpacity(0.3),
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            file.name,
                            style: Theme.of(context).textTheme.subtitle2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (isOnHover.value)
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).canvasColor.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      width: 30,
                      height: 30,
                      child: IconButton(
                        tooltip: 'remove from list',
                        onPressed: () {
                          context.read(treeState).removeFromRecentList(file);
                        },
                        visualDensity: VisualDensity.compact,
                        icon: Icon(
                          LineIcons.times,
                          size: 12,
                        ),
                      ),
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}

class StartNewProjectButton extends HookWidget {
  const StartNewProjectButton(
    this.openLast, {
    Key? key,
  }) : super(key: key);

  final bool openLast;

  @override
  Widget build(BuildContext context) {
    final isOnHover = useState(false);

    return Container(
      color: Theme.of(context).brightness == Brightness.dark
          ? Theme.of(context).canvasColor.lighten(5)
          : Theme.of(context).canvasColor.darken(5),
      height: 30,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, EditorScreen.routeName,
            arguments: StartScreenArgument(isNew: !openLast)),
        onHover: (value) {
          isOnHover.value = !isOnHover.value;
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                openLast ? LineIcons.play : LineIcons.plus,
                size: 16,
                color: isOnHover.value ? Colors.white : Colors.white70,
              ),
              SizedBox(
                width: 4,
              ),
              RichText(
                  text: TextSpan(
                text: openLast ? 'continue with ' : 'New',
                style: openLast
                    ? TextStyle(
                        color:
                            isOnHover.value ? Colors.white60 : Colors.white30)
                    : TextStyle(
                        color: isOnHover.value ? Colors.white : Colors.white70),
                children: [
                  if (openLast)
                    TextSpan(
                      text:
                          '${context.read(treeState).recents.firstOrNull?.name.replaceFirst('.json', '')}',
                      style: TextStyle(
                          color:
                              isOnHover.value ? Colors.white : Colors.white70),
                    )
                ],
              ))
            ],
          ),
        ),
      ),
    );
  }
}
