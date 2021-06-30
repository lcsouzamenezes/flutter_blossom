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
import 'package:flutter_blossom/models/hsl_color.dart';
import 'package:flutter_blossom/utils/color_manipulator.dart';

extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T) test) {
    for (T element in this) {
      if (test(element)) return element;
    }
    return null;
  }

  T? get lastOrNull => this.isEmpty ? null : this.last;
  T? get firstOrNull => this.isEmpty ? null : this.first;
}

extension ListExtension<T> on List<T> {}

extension MapExtensions on Map<String, dynamic> {
  void replace(int index, String key, dynamic item) {
    var tmpLst = this.entries.map((e) => MapEntry(e.key, e.value)).toList();

    tmpLst.removeAt(index);
    tmpLst.insert(index, MapEntry(key, item));
    this.clear();
    tmpLst.forEach((mapEntry) => this[mapEntry.key] = mapEntry.value);
  }

  void moveUp(String key) {
    var tmpLst = this.entries.map((e) => MapEntry(e.key, e.value)).toList();
    final item = tmpLst.firstWhere((e) => e.key == key);
    tmpLst.removeWhere((e) => e.key == key);
    tmpLst.insert(0, item);
    this.clear();
    tmpLst.forEach((mapEntry) => this[mapEntry.key] = mapEntry.value);
  }
}

extension StringExtension on String {
  String get capitalize => "${this[0].toUpperCase()}${this.substring(1)}";
  String get separate =>
      this.split(RegExp(r"(?<=[a-z])(?=[A-Z])")).join(' ').substring(0);
}

/// Extends the Color class to allow direct ColorManipulator manipulation natively
// from [https://github.com/FooStudio/tinycolor/blob/master/lib/color_extension.dart]
extension ColorManipulatorExtension on Color {
  HslColor toHsl() {
    final hsl = rgbToHsl(
      r: this.red.toDouble(),
      g: this.green.toDouble(),
      b: this.blue.toDouble(),
    );
    return HslColor(
        h: hsl.h * 360, s: hsl.s, l: hsl.l, a: this.alpha.toDouble());
  }

  /// Lighten the color a given amount, from 0 to 100. Providing 100 will always return white.
  Color lighten([int amount = 10]) => ColorManipulator(this).lighten(amount);

  /// Brighten the color a given amount, from 0 to 100.
  Color brighten([int amount = 10]) => ColorManipulator(this).brighten(amount);

  /// Darken the color a given amount, from 0 to 100. Providing 100 will always return black.
  Color darken([int amount = 10]) => ColorManipulator(this).darken(amount);

  /// Mix the color with pure white, from 0 to 100. Providing 0 will do nothing, providing 100 will always return white.
  Color tint([int amount = 10]) => ColorManipulator(this).tint(amount);

  /// Mix the color with pure black, from 0 to 100. Providing 0 will do nothing, providing 100 will always return black.
  Color shade([int amount = 10]) => ColorManipulator(this).shade(amount);

  /// Desaturate the color a given amount, from 0 to 100. Providing 100 will is the same as calling greyscale.
  Color desaturate([int amount = 10]) =>
      ColorManipulator(this).desaturate(amount);

  /// Saturate the color a given amount, from 0 to 100.
  Color saturate([int amount = 10]) => ColorManipulator(this).saturate(amount);

  /// Completely desaturate a color into greyscale. Same as calling desaturate(100).
  Color get greyscale => ColorManipulator(this).greyscale();

  /// Spin the hue a given amount, from -360 to 360. Calling with 0, 360, or -360 will do nothing (since it sets the hue back to what it was before).
  Color spin([double amount = 0]) => ColorManipulator(this).spin(amount);

  /// Returns the perceived brightness of a color, from 0-255, as defined by Web Content Accessibility Guidelines (Version 1.0).Returns the perceived brightness of a color, from 0-255, as defined by Web Content Accessibility Guidelines (Version 1.0).
  double get brightness => ColorManipulator(this).getBrightness();

  /// Return the perceived luminance of a color, a shorthand for flutter Color.computeLuminance
  double get luminance => ColorManipulator(this).getLuminance();

  /// Return a boolean indicating whether the color's perceived brightness is light.
  bool get isLight => ColorManipulator(this).isLight();

  /// Return a boolean indicating whether the color's perceived brightness is dark.
  bool get isDark => ColorManipulator(this).isDark();

  /// Returns the Complimentary Color for dynamic matching
  Color get compliment => ColorManipulator(this).complement();

  Color by(int i) => isDark ? darken(i) : lighten(i);
  Color reverseBy(int i) => !isDark ? darken(i) : lighten(i);

  /// Blends the color with another color a given amount, from 0 - 100, default 50.
  Color mix(Color toColor, [int amount = 50]) =>
      ColorManipulator(this).mix(input: toColor, amount: amount);
}
