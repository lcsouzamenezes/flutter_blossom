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

import 'package:flutter/widgets.dart';
import 'package:flutter_blossom/models/app_clipboard.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final storageState = ChangeNotifierProvider((ref) => StorageNotifier(ref));

final appClipboardState = StateProvider((_) => AppClipBoard());

class StorageNotifier extends ChangeNotifier {
  final ProviderReference _ref; // ignore: unused_field
  StorageNotifier(this._ref);
  late SharedPreferences _prefs;

  SharedPreferences get sharedPreferences => _prefs;

  SharedPreferences setPreferences(SharedPreferences sharedPreferences) =>
      _prefs = sharedPreferences;
}
