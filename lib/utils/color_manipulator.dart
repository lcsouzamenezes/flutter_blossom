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

// [https://github.com/FooStudio/tinycolor]

import 'dart:math' as Math;

import 'package:flutter/widgets.dart';
import 'package:flutter_blossom/models/hsl_color.dart';
import 'package:flutter_blossom/helpers/extensions.dart';

class ColorManipulator {
  final Color _color;

  ColorManipulator(this._color);

  Color get color => _color;

  bool isDark() {
    return this.getBrightness() < 128.0;
  }

  bool isLight() {
    return !this.isDark();
  }

  double getBrightness() {
    return (_color.red * 299 + _color.green * 587 + _color.blue * 114) / 1000;
  }

  double getLuminance() {
    return _color.computeLuminance();
  }

  Color lighten([int amount = 10]) {
    final hsl = _color.toHsl()..l += amount / 100;
    hsl.l = clamp01(hsl.l);
    return hslToColor(hsl);
  }

  Color brighten([int amount = 10]) {
    final color = Color.fromARGB(
      _color.alpha,
      Math.max(0, Math.min(255, _color.red - (255 * -(amount / 100)).round())),
      Math.max(
          0, Math.min(255, _color.green - (255 * -(amount / 100)).round())),
      Math.max(0, Math.min(255, _color.blue - (255 * -(amount / 100)).round())),
    );
    return color;
  }

  Color darken([int amount = 10]) {
    final hsl = _color.toHsl();
    hsl.l -= amount / 100;
    hsl.l = clamp01(hsl.l);
    return hslToColor(hsl);
  }

  Color tint([int amount = 10]) {
    return this.mix(input: Color.fromRGBO(255, 255, 255, 1.0));
  }

  Color shade([int amount = 10]) {
    return this.mix(input: Color.fromRGBO(0, 0, 0, 1.0));
  }

  Color desaturate([int amount = 10]) {
    final hsl = _color.toHsl();
    hsl.s -= amount / 100;
    hsl.s = clamp01(hsl.s);
    return hslToColor(hsl);
  }

  Color saturate([int amount = 10]) {
    final hsl = _color.toHsl();
    hsl.s += amount / 100;
    hsl.s = clamp01(hsl.s);
    return hslToColor(hsl);
  }

  Color greyscale() {
    return desaturate(100);
  }

  Color spin(double amount) {
    final hsl = _color.toHsl();
    final hue = (hsl.h + amount) % 360;
    hsl.h = hue < 0 ? 360 + hue : hue;
    return hslToColor(hsl);
  }

  Color mix({required Color input, int amount = 50}) {
    final int p = (amount / 100).round();
    final color = Color.fromARGB(
        (input.alpha - _color.alpha) * p + _color.alpha,
        (input.red - _color.red) * p + _color.red,
        (input.green - _color.green) * p + _color.green,
        (input.blue - _color.blue) * p + _color.blue);
    return color;
  }

  Color complement() {
    final hsl = _color.toHsl();
    hsl.h = (hsl.h + 180) % 360;
    return hslToColor(hsl);
  }
}

double bound01(double n, double max) {
  n = max == 360.0 ? n : Math.min(max, Math.max(0.0, n));
  final double absDifference = n - max;
  if (absDifference.abs() < 0.000001) {
    return 1.0;
  }

  if (max == 360) {
    n = (n < 0 ? n % max + max : n % max) / max;
  } else {
    n = (n % max) / max;
  }
  return n;
}

double clamp01(double val) {
  return Math.min(1.0, Math.max(0.0, val));
}

HslColor rgbToHsl({required double r, required double g, required double b}) {
  r = bound01(r, 255.0);
  g = bound01(g, 255.0);
  b = bound01(b, 255.0);

  final max = [r, g, b].reduce(Math.max);
  final min = [r, g, b].reduce(Math.min);
  double h = 0.0;
  double s = 0.0;
  final double l = (max + min) / 2;

  if (max == min) {
    h = s = 0.0;
  } else {
    final double d = max - min;
    s = l > 0.5 ? d / (2.0 - max - min) : d / (max + min);
    if (max == r) {
      h = (g - b) / d + (g < b ? 6 : 0);
    } else if (max == g) {
      h = (b - r) / d + 2;
    } else if (max == b) {
      h = (r - g) / d + 4;
    }
  }

  h /= 6.0;
  return HslColor(h: h, s: s, l: l);
}

Color hslToColor(HslColor hsl) {
  return hslToRgb(hsl);
}

Color hslToRgb(HslColor hsl) {
  double r;
  double g;
  double b;
  final double h = bound01(hsl.h, 360.0);
  final double s = bound01(hsl.s * 100, 100.0);
  final double l = bound01(hsl.l * 100, 100.0);

  if (s == 0.0) {
    r = g = b = l;
  } else {
    final q = l < 0.5 ? l * (1.0 + s) : l + s - l * s;
    final p = 2 * l - q;
    r = _hue2rgb(p, q, h + 1 / 3);
    g = _hue2rgb(p, q, h);
    b = _hue2rgb(p, q, h - 1 / 3);
  }
  return Color.fromARGB(
      hsl.a.round(), (r * 255).round(), (g * 255).round(), (b * 255).round());
}

HSVColor colorToHsv(Color color) {
  return HSVColor.fromColor(color);
}

HSVColor rgbToHsv(
    {required int r, required int g, required int b, required int a}) {
  return colorToHsv(Color.fromARGB(a, r, g, b));
}

Color hsvToColor(HSVColor hsv) {
  return hsv.toColor();
}

double _hue2rgb(double p, double q, double t) {
  if (t < 0) t += 1;
  if (t > 1) t -= 1;
  if (t < 1 / 6) return p + (q - p) * 6 * t;
  if (t < 1 / 2) return q;
  if (t < 2 / 3) return p + (q - p) * (2 / 3 - t) * 6;
  return p;
}
