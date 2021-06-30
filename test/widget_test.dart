// @dart=2.9

// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_blossom/states/app_state.dart';
import 'package:flutter_blossom/views/editor_view.dart';
import 'package:flutter_blossom/views/start_view.dart';
import 'package:flutter_blossom/views/startup_view.dart';
import 'package:flutter_blossom/helpers/extensions.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_blossom/main.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:mockito/mockito.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('Do startup check 1', (WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(child: AppWrapper()));

    find.byType(AppWrapper);

    final wrapper = tester
        .widgetList(find.byType(WidgetsApp))
        .toList()
        .firstOrNull as WidgetsApp;

    assert(wrapper != null);

    expect(wrapper.color, isNotNull);
    expect(wrapper.title, 'Flutter Blossom');

    final appFinder = find.byType(App);

    final app = tester.widget(appFinder) as App;

    await tester.pump(Duration(seconds: 0));

    final startupScreenFinder = find.byType(StartupScreen);
    // ignore: unused_local_variable
    final startupScreen = tester.widget(startupScreenFinder) as StartupScreen;

    await tester.pump(Duration(seconds: 1));

    await tester.pumpAndSettle();
  });

  // testWidgets('Do startup check 2', (WidgetTester tester) async {
  //   final mockObserver = MockNavigatorObserver();

  //   await tester.pumpWidget(ProviderScope(
  //     overrides: [
  //       isAppStarted.overrideWithProvider(StateProvider((_) => true)),
  //     ],
  //     child: App(mockObserver),
  //   ));

  //   await tester.pump(Duration(seconds: 0));
  //   await tester.pump(Duration(seconds: 1));

  //   verify(mockObserver.didPush(any, any));
  //   verify(mockObserver.didPop(any, any));

  //   final startupScreenFinder = find.byType(StartScreen);
  //   // ignore: unused_local_variable
  //   final startScreen = tester.widget(startupScreenFinder) as StartScreen;

  //   // expect(find.text('Select a project'), findsOneWidget);

  //   await tester.tap(find.byType(InkWell));

  //   final editorScreenFinder = find.byType(EditorScreen);

  //   // ignore: unused_local_variable
  //   final editorScreen = tester.widget(editorScreenFinder) as EditorScreen;

  //   await tester.pumpAndSettle();
  // });
}
