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

import 'package:flutter/material.dart';

class BlossomIconButton extends StatefulWidget {
  BlossomIconButton({
    required this.icon,
    this.iconActive,
    this.iconColor,
    this.isActive = false,
    this.toolTip,
    required this.onPressed,
  });
  final IconData icon;
  final IconData? iconActive;
  final Color? iconColor;
  final bool isActive;
  final String? toolTip;
  final void Function()? onPressed;

  @override
  _BlossomIconButtonState createState() => _BlossomIconButtonState();
}

class _BlossomIconButtonState extends State<BlossomIconButton> {
  bool _isOnHover = false;
  @override
  Widget build(BuildContext context) {
    final btn = Padding(
      padding: const EdgeInsets.all(8.0),
      child: Icon(
        _isOnHover || widget.isActive
            ? widget.iconActive ?? widget.icon
            : widget.icon,
        color: widget.onPressed == null ? Colors.white54 : widget.iconColor,
      ),
    );
    return InkWell(
      onTap: widget.onPressed,
      onHover: (hover) {
        setState(() {
          _isOnHover = hover;
        });
      },
      child: widget.toolTip != null
          ? Tooltip(
              message: widget.toolTip!,
              child: btn,
            )
          : btn,
    );
  }
}
