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
import 'package:flutter_blossom/constants/colors.dart';
import 'package:flutter_blossom/helpers/extensions.dart';
import 'package:flutter_blossom/states/tree_state.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_blossom/constants/shapes.dart';

getDownloadDialog(BuildContext context, [String? text]) {
  final _controller = TextEditingController(text: text);
  return Dialog(
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(contextMenuRadius.x),
    ),
    backgroundColor: Theme.of(context).canvasColor.by(darken2),
    child: Container(
      width: 100,
      height: 100,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              autofocus: true,
              controller: _controller,
              decoration: InputDecoration(hintText: 'give a name'),
              onSubmitted: (value) {
                if (value != '') {
                  context.read(treeState).saveToFile(name: '$value.json');
                  Navigator.of(context).pop();
                }
              },
            ),
          ),
          ElevatedButton(
              onPressed: () {
                if (_controller.text != '') {
                  context
                      .read(treeState)
                      .saveToFile(name: '${_controller.text}.json');
                  Navigator.of(context).pop();
                }
              },
              child: Text('Download'))
        ],
      ),
    ),
  );
}
