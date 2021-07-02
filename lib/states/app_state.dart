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
import 'dart:ui';
import 'package:better_print/better_print.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

final isAppStarted = StateProvider((_) => false);

final appLocale = StateProvider<Locale?>((_) => null);

final appThemeMode = StateProvider<ThemeMode?>((_) => null);

final appState = ChangeNotifierProvider((ref) => AppStateViewNotifier(ref));

class AppStateViewNotifier extends ChangeNotifier {
  static const buildNo = 0;
  final ProviderReference _ref;
  AppStateViewNotifier(this._ref);
  bool _isAppStartupCompleted = false;
  String? _updateUrl;
  String? _latestUrl;
  late PackageInfo _info;
  late BuildContext _context;
  late Size _windowSize;
  bool _isAppUpToDate = true;
  String _updateName = '';

  bool get isStarted => _ref.read(isAppStarted).state;
  bool get isAppStartupCompleted => _isAppStartupCompleted;
  Locale? get locale => _ref.read(appLocale).state;
  ThemeMode? get themeMode => _ref.read(appThemeMode).state;
  PackageInfo get info => _info;
  BuildContext get context => _context;
  Size get windowSize => _windowSize;
  String? get latestUrl => _latestUrl;
  String? get updateUrl => _updateUrl;
  String? get updateName => _updateName;
  bool get isAppUpToDate => _isAppUpToDate;

  start(
    PackageInfo info,
    BuildContext context,
  ) {
    _info = info;
    _context = context;
    notifyListeners();
  }

  setSize(Size size) {
    _windowSize = size;
    notifyListeners();
  }

  completeStart() => _isAppStartupCompleted = true;

  Future<http.Response> _fetchReleases() {
    return http.get(Uri.parse(
        'https://api.github.com/repos/flutter-blossom/flutter_blossom/releases'));
  }

  Future<bool> checkForUpdate() async {
    final releasesRequest = await _fetchReleases();
    if (releasesRequest.statusCode == 200) {
      final List releases = jsonDecode(releasesRequest.body);
      int latest = buildNo;
      Map latestData = {};
      releases.forEach((el) {
        final no = int.parse(el['name'].split('+').last);
        if (no > latest) {
          latest = no;
          latestData = el;
          _latestUrl = latestData['html_url'];
        }
      });
      if (latest > buildNo) {
        latest = buildNo;
        _updateUrl = _updateName = latestData['name'];
        _isAppUpToDate = false;
      } else
        _isAppUpToDate = true;
    }
    notifyListeners();
    return releasesRequest.statusCode == 200;
  }

  /// Define an async function to initialize FlutterFire
  ///
  /// set [isTest] to`true`for testing Crashlytics in your app locally.
  ///
  /// set [shouldTestAsyncErrorOnInit] to`true`to cause an async error to be thrown during initialization
  /// and to test that runZonedGuarded() catches the error
  Future<void> initializeFlutterFire(
      bool isTest, bool shouldTestAsyncErrorOnInit) async {
    // Wait for Firebase to initialize

    if (isTest) {
      // Force enable crashlytics collection enabled if we're testing it.
      await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    } else {
      // Else only enable it in non-debug builds.
      // You could additionally extend this to allow users to opt-in.
      await FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(!kDebugMode);
    }

    // Pass all uncaught errors to Crashlytics.
    FlutterExceptionHandler? originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails errorDetails) async {
      await FirebaseCrashlytics.instance.recordFlutterError(errorDetails);
      // Forward to original handler.
      if (originalOnError != null) originalOnError(errorDetails);
    };

    if (shouldTestAsyncErrorOnInit) {
      await _testAsyncErrorOnInit();
    }
  }

  Future<void> _testAsyncErrorOnInit() async {
    Future<void>.delayed(const Duration(seconds: 2), () {
      final List<int> list = <int>[];
      print(list[100]);
    });
  }
}
