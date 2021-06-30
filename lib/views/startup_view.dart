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
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blossom/constants/colors.dart';
import 'package:flutter_blossom/states/app_state.dart';
import 'package:flutter_blossom/views/editor_view.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:flutter_hooks/flutter_hooks.dart';

import 'package:flutter_blossom/views/start_view.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:hooks_riverpod/hooks_riverpod.dart';

class StartupScreen extends HookWidget {
  static final routeName = '/';
  @override
  Widget build(BuildContext context) {
    bool isAnimReversing = false;
    final _isAppStarted = useProvider(isAppStarted);
    final animation = useAnimationController(
      duration: kThemeAnimationDuration * 2,
      initialValue: 2,
      upperBound: 2,
    );
    final logoAnimation = useAnimationController(
        duration: kThemeAnimationDuration, initialValue: 0);
    if (!_isAppStarted.state)
      animation.reverse().then((value) => {
            Future.delayed(Duration(milliseconds: 100))
                .then((value) => logoAnimation.forward())
          });
    if (_isAppStarted.state) {
      isAnimReversing = true;
      logoAnimation.reverse();
      animation.forward();
      Future.delayed(Duration(milliseconds: 400)).then((value) {
        if (!context.read(appState).isAppStartupCompleted) {
          Navigator.popAndPushNamed(context, StartScreen.routeName);
          context.read(appState).completeStart();
        }
      });
    }
    return Title(
      title: 'Flutter Blossom',
      color: appColor,
      child: Stack(
        children: [
          Container(
            color: Colors.blue,
          ),
          ScaleTransition(
            scale: animation,
            child: Container(
              decoration: BoxDecoration(
                color: isAnimReversing
                    ? Colors.grey[850]
                    : Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Align(
            alignment: Alignment.center,
            child: FadeTransition(
              opacity: logoAnimation,
              child: ScaleTransition(
                scale: logoAnimation,
                child: FlutterLogo(
                  size: 100,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
