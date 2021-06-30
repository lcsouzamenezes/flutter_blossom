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
import 'package:flutter_blossom/models/console_message.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final consoleState =
    ChangeNotifierProvider((ref) => ConsoleStateViewNotifier(ref));

class ConsoleStateViewNotifier extends ChangeNotifier {
  ProviderReference _ref;
  ConsoleStateViewNotifier(this._ref);
  final List<ConsoleMessage> _consoleMessages = [];
  final List<ConsoleMessage> _logs = [];
  List<ConsoleMessage> get consoleMessages => _consoleMessages;

  addMessage(ConsoleMessage message) {
    _consoleMessages.add(message);
    if (message.addToLog) _logs.add(message);
    if (!message.isSticky)
      Future.delayed(Duration(seconds: 3)).then((value) {
        if (_consoleMessages.contains(message)) {
          _consoleMessages.remove(message);
          notifyListeners();
        }
      });
    notifyListeners();
  }

  clearLogs() {
    _logs.clear();
    notifyListeners();
  }
}
