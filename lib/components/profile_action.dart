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
import 'dart:io';

import 'package:better_print/better_print.dart'; // ignore: unused_import
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blossom/components/create_dialog.dart';
import 'package:flutter_blossom/components/micro_components/context_menu_container.dart';
import 'package:flutter_blossom/components/micro_components/context_menu_hint_text.dart';
import 'package:flutter_blossom/constants/colors.dart';
import 'package:flutter_blossom/constants/langs.dart';
import 'package:flutter_blossom/constants/lengths.dart';
import 'package:flutter_blossom/constants/shapes.dart';
import 'package:flutter_blossom/generated/l10n.dart';
import 'package:flutter_blossom/helpers/extensions.dart';
import 'package:flutter_blossom/components/context_menu_item.dart';
import 'package:flutter_blossom/models/console_message.dart';
import 'package:flutter_blossom/states/app_state.dart';
import 'package:flutter_blossom/states/console_state.dart';
import 'package:flutter_blossom/states/context_menu_state.dart';
import 'package:flutter_blossom/states/storage_state.dart';
import 'package:flutter_blossom/views/editor_view.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_localized_locales/native_locale_names.dart';
import 'package:flutter_widget_model/flutter_widget_model.dart';
import 'package:github/github.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:line_icons/line_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class ProfileAction extends HookWidget {
  ProfileAction({
    Key? key,
  }) : super(key: key);
  final _subMenuHeight = contextMenuItemHeight;
  final uuid = Uuid();

  @override
  Widget build(BuildContext context) {
    final _locale = context.read(appLocale);
    final _appState = useProvider(appState);
    final _themeMode = context.read(appThemeMode);
    final _contextMenu = useProvider(contextMenuState);

    bool _isLanguageListOnHover = false;
    List<ContextMenuItem> _langList = [];
    _langList = supportedLanguages
        .map(
          (e) => ContextMenuItem(
            all_native_names[
                    '${e.languageCode}${e.countryCode != null && e.countryCode != '' ? "_${e.countryCode!.toUpperCase()}" : ''}'] ??
                '(${e.languageCode}${e.countryCode != null && e.countryCode != '' ? "_${e.countryCode!.toUpperCase()}" : ''})',
            height: _subMenuHeight,
            info: Row(
              children: [
                if (_locale.state == e || _locale.state == null && e.languageCode == 'en')
                  Icon(
                    LineIcons.check,
                    size: 12,
                  )
              ],
            ),
            onTap: () {
              _locale.state = e;
              S.load(e);
              context
                  .read(storageState)
                  .sharedPreferences
                  .setString('app-locale', e.languageCode);
            },
            onHover: (val) {
              Future.delayed(Duration(milliseconds: 0)).then((value) {
                if (!_isLanguageListOnHover &&
                    !val &&
                    !_langList.any((e) => e.isOnHover == true)) {
                  context.read(contextMenuState).clearSubMenus();
                }
              });
            },
          ),
        )
        .toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: InkWell(
        onTap: () {
          _contextMenu.show(
            id: 'user-setting',
            height: _subMenuHeight * (kIsWeb && !_appState.isAppUpToDate ? 7 : 8) + 2,
            menu: ContextMenuContainer(
              child: Column(
                children: [
                  Container(
                    height: _subMenuHeight * 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Theme.of(context).canvasColor.reverseBy(3),
                          backgroundImage: _appState.user != null
                              ? NetworkImage(_appState.user!.avatarUrl ?? '')
                              : null,
                        ),
                        ContextMenuHintText(_appState.user != null
                            ? _appState.user!.login ?? 'Error!!'
                            : S.of(context).userMenuGuest)
                      ],
                    ),
                  ),
                  Divider(
                    height: 2,
                  ),
                  ContextMenuItem(
                    S.of(context).userMenuLanguage,
                    info: Icon(
                      LineIcons.angleRight,
                      size: 14,
                      color: Colors.white.darken(darken5),
                    ),
                    height: _subMenuHeight,
                    onTap: () {},
                    onHover: (value) {
                      _isLanguageListOnHover = value;
                      if (value &&
                          !context
                              .read(contextMenuState)
                              .subMenus
                              .any((e) => e.id == 'language-list')) {
                        Future.delayed(Duration(
                          milliseconds: 0,
                        )).then((_) {
                          context.read(contextMenuState).addSubMenu(
                                id: 'language-list',
                                height: _subMenuHeight * _langList.length,
                                paddingTop: _subMenuHeight * 2,
                                menu: ContextMenuContainer(
                                  child: Column(
                                    children: _langList,
                                  ),
                                ),
                              );
                        });
                      } else
                        Future.delayed(Duration(
                          milliseconds: 0,
                        )).then(
                          (_) {
                            if (!value && !_langList.any((e) => e.isOnHover == true))
                              context.read(contextMenuState).clearSubMenus();
                          },
                        );
                    },
                  ),
                  ContextMenuItem(
                    S.of(context).userMenuDarkMode,
                    info: Icon(
                      _themeMode.state == ThemeMode.dark
                          ? LineIcons.checkSquare
                          : LineIcons.square,
                      size: 18,
                      color: Colors.white.darken(darken5),
                    ),
                    height: _subMenuHeight,
                    onTap: () {
                      _themeMode.state = _themeMode.state == ThemeMode.dark
                          ? ThemeMode.light
                          : ThemeMode.dark;
                      context
                          .read(storageState)
                          .sharedPreferences
                          .setBool('app-is-dark', _themeMode.state == ThemeMode.dark);
                    },
                  ),
                  ContextMenuItem(
                    S.of(context).userMenuSetting,
                    height: _subMenuHeight,
                    onTap: () {},
                  ),
                  if (!kIsWeb)
                    ContextMenuItem(
                      _appState.updateUrl != null
                          ? S.of(context).userMenuUpdateAvailable
                          : S.of(context).userMenuCheckUpdate,
                      height: _subMenuHeight,
                      onTap: () async {
                        bool status = false;
                        if (_appState.updateUrl != null) {
                          status = await launch(_appState.updateUrl!);
                        } else {
                          status = await _appState.checkForUpdate();
                          if (_appState.updateUrl != null)
                            context.read(consoleState).addMessage(
                                  ConsoleMessage(
                                    id: uuid.v4(),
                                    message: 'Update ${_appState.updateName} available',
                                  ),
                                );
                          else
                            context.read(consoleState).addMessage(
                                  ConsoleMessage(
                                    id: uuid.v4(),
                                    message: 'No update available',
                                  ),
                                );
                        }
                      },
                      info: _appState.updateUrl != null
                          ? Padding(
                              padding: const EdgeInsets.only(top: 4.0),
                              child: Icon(
                                Icons.circle,
                                color: Colors.red,
                                size: 8,
                              ),
                            )
                          : null,
                    ),
                  ContextMenuItem(
                    S.of(context).userMenuAbout,
                    height: _subMenuHeight,
                    onTap: () {
                      createDialog<Widget>(context,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/icon/blossom.png',
                                width: 200,
                                height: 200,
                              ),
                              Text(context.read(appState).info.appName),
                              Padding(
                                padding: const EdgeInsets.only(left: 4.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(context.read(appState).info.version),
                                    Padding(
                                      padding:
                                          const EdgeInsets.symmetric(horizontal: 2.0),
                                      child: Text(
                                        '+${AppStateViewNotifier.buildNo}',
                                        style: TextStyle(color: Colors.white24),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  showLicensePage(
                                    context: context,
                                    applicationName: context.read(appState).info.appName,
                                    applicationVersion:
                                        context.read(appState).info.version,
                                  );
                                },
                                child: Text('Show License'),
                              )
                            ],
                          ));
                    },
                  ),
                  if (_appState.github.auth != null &&
                      !_appState.github.auth!.isAnonymous)
                    ContextMenuItem(
                      S.of(context).userMenuSignOut,
                      height: _subMenuHeight,
                      onTap: () {
                        _appState.setAuth(Authentication.anonymous());
                      },
                    )
                  else
                    ContextMenuItem(
                      S.of(context).userMenuSignIn,
                      height: _subMenuHeight,
                      onTap: () {
                        context.read(contextMenuState).clear();
                        final _id = TextEditingController();
                        createDialog(
                          context,
                          height: 220,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Stack(
                                children: [
                                  Align(
                                    alignment: Alignment.topRight,
                                    child: InkWell(
                                      onTap: () {
                                        betterPrint('showHelp!!');
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Icon(
                                          Icons.help,
                                          color: Theme.of(context).canvasColor,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(22.0),
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 28.0),
                                      child: TextButton(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Row(
                                              children: [
                                                Text('Get Access Token from'),
                                                Icon(LineIcons.github),
                                              ],
                                            ),
                                          ],
                                        ),
                                        onPressed: () {
                                          launch(
                                              "https://github.com/login/oauth/authorize?client_id=$githubClientId");
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                                child: Column(
                                  children: [
                                    TextFormField(
                                      controller: _id,
                                      decoration: InputDecoration(hintText: 'token id'),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(18.0),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    final response = await http.post(
                                      Uri.parse(
                                          'https://github.com/login/oauth/access_token'),
                                      headers: <String, String>{
                                        'Accept': 'application/vnd.github.v3+json',
                                        'Content-Type': 'application/json',
                                      },
                                      body: jsonEncode(<String, String>{
                                        'client_id': githubClientId,
                                        'client_secret': githubSecret,
                                        'code': _id.text
                                      }),
                                    );
                                    if (response.statusCode == 200) {
                                      final token =
                                          jsonDecode(response.body)['access_token'];
                                      final _auth = Authentication.withToken(token);
                                      _appState.setAuth(_auth);
                                    } else {
                                      HttpException(response.body);
                                    }
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Sign in'),
                                ),
                              )
                            ],
                          ),
                        );
                        // _appState.auth.
                        // throw AssertionError("Sign in not available");
                      },
                    ),
                ],
              ),
            ),
            offset: Offset(
              MediaQuery.of(context).size.width,
              EditorScreen.appBarHeight,
            ),
          );
        },
        child: Stack(
          children: [
            Center(
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? Theme.of(context).canvasColor.by(3)
                    : Theme.of(context).canvasColor.reverseBy(10),
                backgroundImage: _appState.user != null
                    ? NetworkImage(_appState.user!.avatarUrl ?? '')
                    : null,
              ),
            ),
            if (_appState.updateUrl != null && _contextMenu.menu?.id != 'user-setting')
              Padding(
                padding: const EdgeInsets.only(left: 25.0, top: 8.0),
                child: Icon(
                  Icons.circle,
                  color: Colors.red,
                  size: 8,
                ),
              )
          ],
        ),
      ),
    );
  }
}
