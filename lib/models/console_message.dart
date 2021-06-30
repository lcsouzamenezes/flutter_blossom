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

enum ConsoleMessageType {
  info,
  warning,
  error,
}

class ConsoleMessage {
  final String id;
  final String message;
  final ConsoleMessageType type;
  final bool addToLog;
  final String? locationInfo;
  final bool isSticky;
  ConsoleMessage({
    required this.id,
    required this.message,
    this.type = ConsoleMessageType.warning,
    this.addToLog = true,
    this.locationInfo,
    this.isSticky = false,
  });
}
