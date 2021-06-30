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

import 'package:flutter/painting.dart';

final Map<String, Size> deviceSizeTemplate = {
  'Android': Size(360, 640),
  'Pixel': Size(411, 823),
  'iPhone': Size(375, 667),
  'iPhonePro': Size(375, 812),
  'iPhoneMax': Size(414, 896),
  'Tablet': Size(768, 1024),
  'iPadPro': Size(1024, 1366),
  'SurfacePro': Size(1368, 912),
  'Desktop': Size(1440, 1024),
  'iMac': Size(1280, 720),
  'Watch': Size(162, 197),
};
