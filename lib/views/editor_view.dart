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
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blossom/components/micro_components/context_menu_container.dart';
import 'package:flutter_blossom/components/micro_components/context_menu_hint_text.dart';
import 'package:flutter_blossom/components/profile_action.dart';
import 'package:flutter_blossom/constants/colors.dart';
import 'package:flutter_blossom/constants/lengths.dart';
import 'package:flutter_blossom/dialogs/rename_file.dart';
import 'package:flutter_blossom/generated/l10n.dart';
import 'package:flutter_blossom/helpers/bind_keys.dart';
import 'package:flutter_blossom/helpers/extensions.dart';
import 'package:flutter_blossom/components/blossom_icon_button.dart';
import 'package:flutter_blossom/components/context_menu_item.dart';
import 'package:flutter_blossom/states/canvas_state.dart';
import 'package:flutter_blossom/states/context_menu_state.dart';
import 'package:flutter_blossom/states/editor_state.dart';
import 'package:flutter_blossom/states/tree_state.dart';
import 'package:flutter_blossom/utils/tap_watcher.dart';
import 'package:flutter_blossom/views/sub_views/editor_canvas.dart';
import 'package:flutter_blossom/views/sub_views/editor_panels.dart';
import 'package:flutter_blossom/views/sub_views/part_views/console_view.dart';
import 'package:flutter_blossom/views/sub_views/part_views/property_view.dart';
import 'package:flutter_blossom/views/sub_views/part_views/tree_view.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:keyboard_shortcuts/keyboard_shortcuts.dart';
import 'package:line_icons/line_icons.dart';
import 'package:keybinder/keybinder.dart';

class EditorScreen extends HookWidget {
  static final routeName = '/editor';
  static final double appBarHeight = 45;
  final _subMenuHeight = contextMenuItemHeight;
  EditorScreen(
      {this.file, this.isNew = false, this.data, this.suggestedFileName});
  final XFile? file;
  final bool isNew;
  final Map<String, dynamic>? data;
  final String? suggestedFileName;

  @override
  Widget build(BuildContext context) {
    final _enableControls = useProvider(enableCanvasControl);
    final _treeState = useProvider(treeState);
    final _contextMenu = useProvider(contextMenuState);
    bool _isRecentListOnHover = false;

    useEffect(() {
      bindKeys(context, isNew);
      Future.delayed(Duration(milliseconds: 0)).then((value) {
        if (!context.read(treeState).alreadyLoadedRecents)
          context.read(treeState).loadRecents();
        if (!kIsWeb && !isNew) context.read(treeState).initTree(file);
        if (isNew)
          context
              .read(treeState)
              .newProject(true, data, this.suggestedFileName);
      });
      return;
    }, const []);

    List<ContextMenuItem> _recentList = [];

    _recentList = [
      ..._treeState.recents.map(
        (e) => ContextMenuItem(
          e.name,
          height: _subMenuHeight,
          onTap: () => _treeState.loadFromFile(e),
          onHover: (val) {
            Future.delayed(Duration(milliseconds: 0)).then((value) {
              if (!_isRecentListOnHover &&
                  !val &&
                  !_recentList.any((e) => e.isOnHover == true)) {
                context.read(contextMenuState).clearSubMenus();
              }
            });
          },
        ),
      ),
      if (_treeState.recents.isNotEmpty)
        ContextMenuItem(
          S.of(context).mainMenuClearRecentsText,
          height: _subMenuHeight,
          onTap: () => _treeState.clearRecentList(true),
          onHover: (val) {
            Future.delayed(Duration(milliseconds: 0)).then((value) {
              if (!_isRecentListOnHover &&
                  !val &&
                  !_recentList.any((e) => e.isOnHover == true)) {
                context.read(contextMenuState).clearSubMenus();
              }
            });
          },
        ),
    ];

    Future<void> _saveOrDownload() async {
      if (kIsWeb)
        showDialog(
            context: context,
            barrierColor: Colors.black38,
            builder: (context) =>
                getDownloadDialog(context, suggestedFileName));
      else
        _treeState.saveToFile(
            saveAs: _treeState.recents.firstOrNull == null || isNew,
            name: suggestedFileName);
    }

    final _leadingList = [
      BlossomIconButton(
        icon: LineIcons.bars,
        iconActive: FontAwesomeIcons.bars,
        isActive: context.read(contextMenuState).menu?.id == 'main-menu',
        onPressed: () async {
          context.read(contextMenuState).show(
                id: 'main-menu',
                height: _subMenuHeight * 7,
                offset: Offset(1, EditorScreen.appBarHeight),
                fixOffsetY: true,
                menu: ContextMenuContainer(
                  child: Column(
                    children: [
                      ContextMenuItem(
                        S.of(context).mainMenuNewText,
                        info: !kIsWeb ? ContextMenuHintText('Ctrl+N') : null,
                        height: _subMenuHeight,
                        onTap: !kIsWeb
                            ? () async =>
                                await context.read(treeState).newProject()
                            : null,
                      ),
                      ContextMenuItem(
                        S.of(context).mainMenuOpenText,
                        info: ContextMenuHintText('Ctrl+O'),
                        height: _subMenuHeight,
                        onTap: () async =>
                            await context.read(treeState).loadFromFile(),
                      ),
                      ContextMenuItem(
                        S.of(context).mainMenuRecentsText,
                        info: _treeState.recents.isNotEmpty && !kIsWeb
                            ? Icon(
                                LineIcons.angleRight,
                                size: 14,
                                color: Colors.white.darken(darken5),
                              )
                            : null,
                        height: _subMenuHeight,
                        onTap: !kIsWeb ? () {} : null,
                        onHover: !kIsWeb
                            ? (value) {
                                _isRecentListOnHover = value;
                                if (value &&
                                    !context
                                        .read(contextMenuState)
                                        .subMenus
                                        .any((e) => e.id == 'recent-list')) {
                                  context.read(contextMenuState).addSubMenu(
                                        id: 'recent-list',
                                        height:
                                            _subMenuHeight * _recentList.length,
                                        paddingTop: (_subMenuHeight * 2) - 2,
                                        menu: ContextMenuContainer(
                                          child: Column(
                                            children: _recentList,
                                          ),
                                        ),
                                      );
                                } else
                                  Future.delayed(Duration(
                                    milliseconds: 0,
                                  )).then(
                                    (_) {
                                      if (!value &&
                                          !_recentList
                                              .any((e) => e.isOnHover == true))
                                        context
                                            .read(contextMenuState)
                                            .clearSubMenus();
                                    },
                                  );
                              }
                            : null,
                      ),
                      ContextMenuItem(
                        S.of(context).mainMenuReloadText,
                        info: ContextMenuHintText('Ctrl+R'),
                        height: _subMenuHeight,
                        onTap: _treeState.file?.path ==
                                _treeState.recents.firstOrNull?.path
                            ? () async => await context
                                .read(treeState)
                                .loadFromFile(_treeState.recents.firstOrNull)
                            : null,
                      ),
                      ContextMenuItem(
                        !kIsWeb
                            ? S.of(context).mainMenuSaveText
                            : S.of(context).mainMenuDownloadText,
                        info: ContextMenuHintText('Ctrl+S'),
                        height: _subMenuHeight,
                        onTap: () async => await _saveOrDownload(),
                      ),
                      ContextMenuItem(
                        S.of(context).mainMenuSaveAsText,
                        info: !kIsWeb
                            ? ContextMenuHintText('Ctrl+shift+S')
                            : null,
                        height: _subMenuHeight,
                        onTap: !kIsWeb
                            ? () => _treeState.saveToFile(saveAs: true)
                            : null,
                      ),
                      ContextMenuItem(
                        S.of(context).mainMenuQuitText,
                        info: ContextMenuHintText('Ctrl+Q'),
                        height: _subMenuHeight,
                        onTap: () => Navigator.maybePop(context),
                      ),
                    ],
                  ),
                ),
              );
        },
      ),
      BlossomIconButton(
        icon: LineIcons.mousePointer,
        toolTip: '${S.of(context).appBarSelectMode} (Ctrl+V)',
        iconActive: FontAwesomeIcons.mousePointer,
        isActive: _enableControls.state,
        onPressed: () => _enableControls.state = !_enableControls.state,
      ),
      BlossomIconButton(
        icon: LineIcons.undo,
        toolTip: '${S.of(context).appBarUndo} (Ctrl+Z)',
        isActive: _enableControls.state,
        onPressed: !_treeState.isUndoAble
            ? null
            : () async => await context.read(treeState).undo(),
      ),
      BlossomIconButton(
        icon: LineIcons.redo,
        toolTip: '${S.of(context).appBarRedo} (Ctrl+Shift+Z)',
        isActive: _enableControls.state,
        onPressed: !_treeState.isRedoAble
            ? null
            : () async => await context.read(treeState).redo(),
      ),
      BlossomIconButton(
        icon: LineIcons.cog,
        toolTip: '${S.of(context).appBarSetting} (Ctrl+\\)',
        iconActive: FontAwesomeIcons.cog,
        onPressed: () {},
      ),
      BlossomIconButton(
        icon: LineIcons.question,
        toolTip: '${S.of(context).appBarHelp} (F1)',
        iconActive: FontAwesomeIcons.question,
        onPressed: () {},
      ),
    ];

    return WillPopScope(
      onWillPop: () async {
        Future.delayed(Duration(milliseconds: 0))
            .then((value) => Keybinder.dispose());
        return true;
      },
      child: KeyBoardShortcuts(
        keysToPress: {LogicalKeyboardKey.controlLeft, LogicalKeyboardKey.keyV},
        onKeysPressed: () {
          _enableControls.state = !_enableControls.state;
          context.read(canvasState).loadCanvas();
        },
        child: KeyBoardShortcuts(
          keysToPress: {
            LogicalKeyboardKey.controlLeft,
            LogicalKeyboardKey.keyZ
          },
          onKeysPressed: () async {
            if (_treeState.isUndoAble) await context.read(treeState).undo();
          },
          child: KeyBoardShortcuts(
            keysToPress: {
              LogicalKeyboardKey.controlLeft,
              LogicalKeyboardKey.shiftLeft,
              LogicalKeyboardKey.keyZ
            },
            onKeysPressed: () async {
              if (_treeState.isRedoAble) await context.read(treeState).redo();
            },
            child: Title(
              title: 'Flutter Blossom',
              color: appColor,
              child: Material(
                child: Stack(
                  children: [
                    Listener(
                      onPointerDown: (_) {
                        if (_contextMenu.menu != null) {
                          _contextMenu.clear();
                          _contextMenu.clearSubMenus();
                        }
                      },
                      child: GestureDetector(
                        // reset
                        onTap: () {
                          context.read(treeShadowKey).state = null;
                        },
                        child: KeyBoardShortcuts(
                          keysToPress: {LogicalKeyboardKey.escape},
                          onKeysPressed: () {
                            if (_contextMenu.menu != null) {
                              if (_contextMenu.subMenus.isEmpty)
                                _contextMenu.clear();
                              else
                                _contextMenu.removeLastSubMenu();
                            }
                          },
                          child: TapWatcher(
                            child: Scaffold(
                              appBar: PreferredSize(
                                preferredSize:
                                    Size.fromHeight(EditorScreen.appBarHeight),
                                child: Listener(
                                  onPointerDown: (_) => context
                                      .read(activeLayout)
                                      .state = 'editor-appbar-area',
                                  child: AppBar(
                                    elevation: 0,
                                    backgroundColor:
                                        Theme.of(context).primaryColor,
                                    automaticallyImplyLeading: false,
                                    leadingWidth: 40.0 * _leadingList.length,
                                    leading: Row(
                                      children: _leadingList,
                                    ),
                                    title: Text(
                                        '${_treeState.file?.name ?? ''}${_treeState.isFileEdited ? '*' : ''}'),
                                    actions: [
                                      ProfileAction(),
                                    ],
                                  ),
                                ),
                              ),
                              body: Container(
                                child: FutureBuilder(
                                    future: Future.delayed(
                                        Duration(milliseconds: 100)),
                                    builder: (context, snapshot) {
                                      return Stack(
                                        children: [
                                          EditorCanvas(),
                                          EditorPanels(),
                                        ],
                                      );
                                    }),
                              ),
                            ),
                          ),
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
            ),
          ),
        ),
      ),
    );
  }
}
