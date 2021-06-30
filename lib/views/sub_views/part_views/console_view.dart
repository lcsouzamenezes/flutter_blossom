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

import 'package:flutter/foundation.dart';
import 'package:flutter_blossom/components/blossom_icon_button.dart';
import 'package:flutter_blossom/constants/shapes.dart';
import 'package:flutter_blossom/helpers/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blossom/states/console_state.dart';
import 'package:flutter_blossom/states/editor_state.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:line_icons/line_icons.dart';
import 'package:url_launcher/url_launcher.dart';

class EditorConsole extends HookWidget {
  static const id = 'editor-console-view';
  const EditorConsole({
    Key? key,
  }) : super(key: key);
  final logViewHeight = 350.0;

  @override
  Widget build(BuildContext context) {
    final _consoleState = useProvider(consoleState);
    final _showLogs = useState(false);

    return Listener(
      onPointerDown: (_) {
        context.read(activeLayout).state = EditorConsole.id;
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height -
                  (_showLogs.value ? logViewHeight + 80 : 80),
            ),
            child: SingleChildScrollView(
              reverse: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (kIsWeb)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(snackWarningRadius),
                          color: Theme.of(context).canvasColor.darken(10),
                        ),
                        constraints: BoxConstraints(
                          maxWidth: 400,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 16.0, right: 16.0, top: 16.0, bottom: 8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(LineIcons.desktop),
                              SizedBox(width: 10),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 2.0, bottom: 4.0),
                                    child: Text(
                                        'Use desktop version for better experience.'),
                                  ),
                                  TextButton(
                                    onPressed: () async => await launch(
                                        'https://github.com/flutter-blossom/flutter-blossom/releases'),
                                    child: Text('Release Page'),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ..._consoleState.consoleMessages
                      .map(
                        (e) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(snackWarningRadius),
                              color: Theme.of(context).canvasColor.darken(10),
                            ),
                            constraints: BoxConstraints(
                              maxWidth: 400,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              child: Text(e.message),
                            ),
                          ),
                        ),
                      )
                      .toList()
                      .reversed,
                ],
              ),
            ),
          ),
          if (_showLogs.value)
            Container(
              color: Theme.of(context).canvasColor.darken(4),
              constraints:
                  BoxConstraints(maxHeight: logViewHeight, maxWidth: 600),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('Info'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('Warnings'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('Error'),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('All'),
                          ),
                        ],
                      ),
                      BlossomIconButton(
                        icon: LineIcons.times,
                        onPressed: () => _showLogs.value = false,
                      )
                    ],
                  ),
                  Divider(
                    height: 1,
                    thickness: 1.5,
                  ),
                ],
              ),
            )
          else
            InkWell(
              onTap: () => _showLogs.value = true,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Opacity(
                  opacity: 0.5,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).canvasColor.darken(10),
                    ),
                    child: Icon(LineIcons.infoCircle),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
