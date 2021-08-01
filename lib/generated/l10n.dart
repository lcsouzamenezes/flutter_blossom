// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Hello World!!`
  String get helloWorld {
    return Intl.message(
      'Hello World!!',
      name: 'helloWorld',
      desc: 'The conventional newborn programmer greeting',
      args: [],
    );
  }

  /// `Select a Project`
  String get selectRequestSort {
    return Intl.message(
      'Select a Project',
      name: 'selectRequestSort',
      desc: 'A message requesting a user to select a project',
      args: [],
    );
  }

  /// `Tree View`
  String get treeView {
    return Intl.message(
      'Tree View',
      name: 'treeView',
      desc: 'Indicator for tree panel',
      args: [],
    );
  }

  /// `Property View`
  String get propertyView {
    return Intl.message(
      'Property View',
      name: 'propertyView',
      desc: 'Indicator for property panel',
      args: [],
    );
  }

  /// `New File`
  String get mainMenuNewText {
    return Intl.message(
      'New File',
      name: 'mainMenuNewText',
      desc: '',
      args: [],
    );
  }

  /// `Open File`
  String get mainMenuOpenText {
    return Intl.message(
      'Open File',
      name: 'mainMenuOpenText',
      desc: '',
      args: [],
    );
  }

  /// `Recent Files`
  String get mainMenuRecentsText {
    return Intl.message(
      'Recent Files',
      name: 'mainMenuRecentsText',
      desc: '',
      args: [],
    );
  }

  /// `Clear recent list`
  String get mainMenuClearRecentsText {
    return Intl.message(
      'Clear recent list',
      name: 'mainMenuClearRecentsText',
      desc: '',
      args: [],
    );
  }

  /// `Reload`
  String get mainMenuReloadText {
    return Intl.message(
      'Reload',
      name: 'mainMenuReloadText',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get mainMenuSaveText {
    return Intl.message(
      'Save',
      name: 'mainMenuSaveText',
      desc: '',
      args: [],
    );
  }

  /// `Download`
  String get mainMenuDownloadText {
    return Intl.message(
      'Download',
      name: 'mainMenuDownloadText',
      desc: '',
      args: [],
    );
  }

  /// `Save as`
  String get mainMenuSaveAsText {
    return Intl.message(
      'Save as',
      name: 'mainMenuSaveAsText',
      desc: '',
      args: [],
    );
  }

  /// `Quit`
  String get mainMenuQuitText {
    return Intl.message(
      'Quit',
      name: 'mainMenuQuitText',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get userMenuLanguage {
    return Intl.message(
      'Language',
      name: 'userMenuLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Dark Mode`
  String get userMenuDarkMode {
    return Intl.message(
      'Dark Mode',
      name: 'userMenuDarkMode',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get userMenuSetting {
    return Intl.message(
      'Settings',
      name: 'userMenuSetting',
      desc: '',
      args: [],
    );
  }

  /// `Check for Update`
  String get userMenuCheckUpdate {
    return Intl.message(
      'Check for Update',
      name: 'userMenuCheckUpdate',
      desc: '',
      args: [],
    );
  }

  /// `Download Update`
  String get userMenuUpdateAvailable {
    return Intl.message(
      'Download Update',
      name: 'userMenuUpdateAvailable',
      desc: '',
      args: [],
    );
  }

  /// `Using Latest Version`
  String get userMenuUpToDate {
    return Intl.message(
      'Using Latest Version',
      name: 'userMenuUpToDate',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get userMenuAbout {
    return Intl.message(
      'About',
      name: 'userMenuAbout',
      desc: '',
      args: [],
    );
  }

  /// `Sign in`
  String get userMenuSignIn {
    return Intl.message(
      'Sign in',
      name: 'userMenuSignIn',
      desc: '',
      args: [],
    );
  }

  /// `Sign out`
  String get userMenuSignOut {
    return Intl.message(
      'Sign out',
      name: 'userMenuSignOut',
      desc: '',
      args: [],
    );
  }

  /// `Guest`
  String get userMenuGuest {
    return Intl.message(
      'Guest',
      name: 'userMenuGuest',
      desc: '',
      args: [],
    );
  }

  /// `Rename Tree`
  String get treeMenuRename {
    return Intl.message(
      'Rename Tree',
      name: 'treeMenuRename',
      desc: '',
      args: [],
    );
  }

  /// `Move Up`
  String get treeMenuMoveUp {
    return Intl.message(
      'Move Up',
      name: 'treeMenuMoveUp',
      desc: '',
      args: [],
    );
  }

  /// `Paste Root`
  String get treeMenuPasteRoot {
    return Intl.message(
      'Paste Root',
      name: 'treeMenuPasteRoot',
      desc: '',
      args: [],
    );
  }

  /// `Change Group`
  String get nodeMenuGroup {
    return Intl.message(
      'Change Group',
      name: 'nodeMenuGroup',
      desc: '',
      args: [],
    );
  }

  /// `Make Replaceable`
  String get nodeMenuReplaceable {
    return Intl.message(
      'Make Replaceable',
      name: 'nodeMenuReplaceable',
      desc: '',
      args: [],
    );
  }

  /// `Make Unreplaceable`
  String get nodeMenuUnReplaceable {
    return Intl.message(
      'Make Unreplaceable',
      name: 'nodeMenuUnReplaceable',
      desc: '',
      args: [],
    );
  }

  /// `Rename`
  String get nodeMenuRename {
    return Intl.message(
      'Rename',
      name: 'nodeMenuRename',
      desc: '',
      args: [],
    );
  }

  /// `Replace`
  String get nodeMenuReplace {
    return Intl.message(
      'Replace',
      name: 'nodeMenuReplace',
      desc: '',
      args: [],
    );
  }

  /// `Copy`
  String get nodeMenuCopy {
    return Intl.message(
      'Copy',
      name: 'nodeMenuCopy',
      desc: '',
      args: [],
    );
  }

  /// `Cut`
  String get nodeMenuCut {
    return Intl.message(
      'Cut',
      name: 'nodeMenuCut',
      desc: '',
      args: [],
    );
  }

  /// `Duplicate`
  String get nodeMenuDuplicate {
    return Intl.message(
      'Duplicate',
      name: 'nodeMenuDuplicate',
      desc: '',
      args: [],
    );
  }

  /// `Paste Replace`
  String get nodeMenuPasteReplace {
    return Intl.message(
      'Paste Replace',
      name: 'nodeMenuPasteReplace',
      desc: '',
      args: [],
    );
  }

  /// `Paste as Parent`
  String get nodeMenuPasteParent {
    return Intl.message(
      'Paste as Parent',
      name: 'nodeMenuPasteParent',
      desc: '',
      args: [],
    );
  }

  /// `Paste as Child`
  String get nodeMenuPasteChild {
    return Intl.message(
      'Paste as Child',
      name: 'nodeMenuPasteChild',
      desc: '',
      args: [],
    );
  }

  /// `Delete All`
  String get nodeMenuDeleteAll {
    return Intl.message(
      'Delete All',
      name: 'nodeMenuDeleteAll',
      desc: '',
      args: [],
    );
  }

  /// `New Root`
  String get tooltipNewRoot {
    return Intl.message(
      'New Root',
      name: 'tooltipNewRoot',
      desc: '',
      args: [],
    );
  }

  /// `New Tree`
  String get tooltipNewTree {
    return Intl.message(
      'New Tree',
      name: 'tooltipNewTree',
      desc: '',
      args: [],
    );
  }

  /// `Reload Tree`
  String get tooltipReloadTree {
    return Intl.message(
      'Reload Tree',
      name: 'tooltipReloadTree',
      desc: '',
      args: [],
    );
  }

  /// `Collapse Roots`
  String get tooltipCollapseTree {
    return Intl.message(
      'Collapse Roots',
      name: 'tooltipCollapseTree',
      desc: '',
      args: [],
    );
  }

  /// `Delete Tree`
  String get tooltipDeleteTree {
    return Intl.message(
      'Delete Tree',
      name: 'tooltipDeleteTree',
      desc: '',
      args: [],
    );
  }

  /// `Focus on Canvas`
  String get tooltipNodeFocus {
    return Intl.message(
      'Focus on Canvas',
      name: 'tooltipNodeFocus',
      desc: '',
      args: [],
    );
  }

  /// `New Node`
  String get tooltipNodeAdd {
    return Intl.message(
      'New Node',
      name: 'tooltipNodeAdd',
      desc: '',
      args: [],
    );
  }

  /// `New Parent`
  String get tooltipNodeAddParent {
    return Intl.message(
      'New Parent',
      name: 'tooltipNodeAddParent',
      desc: '',
      args: [],
    );
  }

  /// `Delete Node`
  String get tooltipNodeDelete {
    return Intl.message(
      'Delete Node',
      name: 'tooltipNodeDelete',
      desc: '',
      args: [],
    );
  }

  /// `Collapse Children`
  String get tooltipNodeCollapse {
    return Intl.message(
      'Collapse Children',
      name: 'tooltipNodeCollapse',
      desc: '',
      args: [],
    );
  }

  /// `Select Mode`
  String get appBarSelectMode {
    return Intl.message(
      'Select Mode',
      name: 'appBarSelectMode',
      desc: '',
      args: [],
    );
  }

  /// `Undo`
  String get appBarUndo {
    return Intl.message(
      'Undo',
      name: 'appBarUndo',
      desc: '',
      args: [],
    );
  }

  /// `Redo`
  String get appBarRedo {
    return Intl.message(
      'Redo',
      name: 'appBarRedo',
      desc: '',
      args: [],
    );
  }

  /// `Project Settings`
  String get appBarSetting {
    return Intl.message(
      'Project Settings',
      name: 'appBarSetting',
      desc: '',
      args: [],
    );
  }

  /// `Help`
  String get appBarHelp {
    return Intl.message(
      'Help',
      name: 'appBarHelp',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'es'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
