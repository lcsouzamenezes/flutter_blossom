// Flutter Blossom -- A low code editor with the full power of flutter.
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

import 'dart:async';

import 'package:better_print/better_print.dart'; // ignore: unused_import
import 'package:file_selector/file_selector.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blossom/constants/langs.dart';
import 'package:flutter_blossom/helpers/pre_cache.dart';
import 'package:flutter_blossom/states/canvas_state.dart';
import 'package:flutter_blossom/states/context_menu_state.dart';
import 'package:flutter_blossom/themes/dark_theme.dart';
import 'package:flutter_blossom/themes/light_theme.dart';
import 'package:flutter_blossom/helpers/extensions.dart';
import 'package:flutter_blossom/views/editor_view.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_blossom/generated/l10n.dart';
import 'package:flutter_blossom/constants/colors.dart';
import 'package:flutter_blossom/states/app_state.dart';
import 'package:flutter_blossom/states/storage_state.dart';
import 'package:flutter_blossom/views/404.dart';
import 'package:flutter_blossom/views/start_view.dart';
import 'package:flutter_blossom/views/startup_view.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_strategy/url_strategy.dart';

// Note: Firebase functionality is not yet active. It's for future use.
// only web analytics is somewhat active but only for basic usage.
// any future use will be limited to app performance and user authentication.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setPathUrlStrategy();
  LicenseRegistry.addLicense(() async* {
    final nunitoLicense =
        await rootBundle.loadString('assets/google_fonts/nunito_OFL.txt');
    final interLicense =
        await rootBundle.loadString('assets/google_fonts/inter_OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], nunitoLicense);
    yield LicenseEntryWithLineBreaks(['google_fonts'], interLicense);
  });
  if (kIsWeb) {
    await Firebase.initializeApp();
    runApp(_app);
    // runZonedGuarded(() => _ranApp, FirebaseCrashlytics.instance.recordError);
  } else
    runApp(_app);
}

final _app = ProviderScope(
  child: AppWrapper(),
);

class AppWrapper extends HookWidget {
  const AppWrapper({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _contextMenu = context.read(contextMenuState);

    return WidgetsApp(
      title: 'Flutter Blossom',
      color: appColor,
      debugShowCheckedModeBanner: false,
      builder: (context, _) =>
          NotificationListener<SizeChangedLayoutNotification>(
        child: App(),
        onNotification: (details) {
          Future.delayed(Duration(milliseconds: 0)).then((value) {
            context.read(appState).setSize(MediaQuery.of(context).size);
            if (_contextMenu.menu != null) {
              _contextMenu.clear();
              _contextMenu.clearSubMenus();
            }
            if (context.read(enableCanvasControl).state)
              context.read(canvasState).setSelectedBox();
          });
          return true;
        },
      ),
    );
  }
}

class App extends HookWidget {
  App([this.observer]);
  final NavigatorObserver? observer;
  @override
  Widget build(BuildContext context) {
    // handle unforeseen error may cause app to not start
    useEffect(() {
      Future.delayed(Duration(milliseconds: 0)).then((value) {
        precacheImageFromAll(context);
      });
      SharedPreferences.getInstance().then((prefs) {
        PackageInfo.fromPlatform().then((info) {
          context.read(appState).start(info, context);
          context.read(appState).setSize(MediaQuery.of(context).size);
          context.read(appState).checkForUpdate();
          context.read(storageState).setPreferences(prefs);
          Future.delayed(Duration(seconds: 1, milliseconds: 500)).then((value) {
            if (!context.read(isAppStarted).state)
              context.read(appLocale).state =
                  supportedLanguages.firstWhereOrNull(
                      (e) => e.languageCode == (prefs.getString('app-locale')));
            final isDark = prefs.getBool('app-is-dark');
            if (isDark != null)
              context.read(appThemeMode).state =
                  isDark ? ThemeMode.dark : ThemeMode.light;
            context.read(isAppStarted).state = true;
          });
        });
      });
      return;
    }, const []);
    final locale = useProvider(appLocale);
    final mode = useProvider(appThemeMode);
    return SizeChangedLayoutNotifier(
      child: MaterialApp(
        theme: lightTheme,
        darkTheme: darkTheme,
        // Todo: set to [ThemeMode.system] when light theme is ready
        themeMode: mode.state ?? ThemeMode.dark,
        debugShowCheckedModeBanner: false,
        locale: locale.state,
        localizationsDelegates: [
          AppLocalizationDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: supportedLanguages,
        initialRoute: StartupScreen.routeName,
        navigatorObservers: [if (observer != null) observer!],
        onGenerateRoute: (settings) {
          if (settings.name == StartupScreen.routeName) {
            return PageRouteBuilder(
              pageBuilder: (_, __, ___) => StartupScreen(),
              transitionsBuilder: (_, anim, __, child) {
                return FadeTransition(opacity: anim, child: child);
              },
            );
          } else if (settings.name == StartScreen.routeName) {
            return PageRouteBuilder(
              pageBuilder: (_, __, ___) => StartScreen(),
              transitionsBuilder: (_, anim, __, child) {
                return child;
              },
            );
          } else if (settings.name == EditorScreen.routeName) {
            final args = settings.arguments as StartScreenArgument;
            return PageRouteBuilder(
              pageBuilder: (_, __, ___) => EditorScreen(
                file: args.file,
                isNew: args.isNew,
                data: args.data,
                suggestedFileName: args.suggestedName,
              ),
              transitionsBuilder: (_, anim, __, child) {
                return child;
              },
            );
          }
          // unknown route
          return PageRouteBuilder(
            pageBuilder: (_, __, ___) => Page404(),
            transitionsBuilder: (_, anim, __, child) {
              return FadeTransition(opacity: anim, child: child);
            },
          );
        },
      ),
    );
  }
}
