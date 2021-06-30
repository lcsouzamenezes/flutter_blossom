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

import 'package:better_print/better_print.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blossom/components/context_menu_item.dart';
import 'package:flutter_blossom/constants/lengths.dart';
import 'package:flutter_blossom/states/context_menu_state.dart';
import 'package:flutter_blossom/helpers/extensions.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SearchList extends HookWidget {
  SearchList({
    Key? key,
    this.height = 300.0,
    required this.list,
    required this.onTap,
    this.info,
  }) : super(key: key);
  final List<String> list;
  final double height;
  final TextEditingController _searchController = TextEditingController();
  final void Function(String key) onTap;
  final Widget? Function(String key)? info;

  @override
  Widget build(BuildContext context) {
    final _searchLock = useState(false);
    final sortList = useState<List<String>>([]);

    List<String> _sort(List<String> list) {
      return list..sort((a, b) => a.capitalize.compareTo(b.capitalize));
    }

    useEffect(() {
      sortList.value.addAll(_sort(list));
      return;
    }, const []);

    _search(String searchTerm) {
      sortList.value = [];
      list.forEach((name) {
        if (_searchLock.value) {
          if (name.toLowerCase().startsWith(searchTerm.toLowerCase())) {
            sortList.value.add(name);
          }
        } else {
          if (name.toLowerCase().contains(searchTerm.toLowerCase())) {
            sortList.value.add(name);
          }
        }
      });
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
              left: 4.0, right: 10.0, top: 6.0, bottom: 2.0),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            onChanged: (value) {
              _search(value);
            },
            decoration: InputDecoration(
              hintText: 'Search',
              isDense: true,
              suffix: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    color: Colors.white38,
                    padding: const EdgeInsets.all(1.0),
                    child: Text(
                      '${sortList.value.length}',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(
                    width: 2,
                  ),
                  InkWell(
                    onTap: () {
                      _searchLock.value = !_searchLock.value;
                      _search(_searchController.text);
                    },
                    child: Container(
                      color: _searchLock.value ? Colors.white54 : null,
                      child: Icon(
                        Icons.text_rotation_none_outlined,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 2),
        SizedBox(
          height: height - 40,
          child: ListView.builder(
            itemCount: sortList.value.length,
            itemBuilder: (ctx, i) => ContextMenuItem(
              sortList.value[i].capitalize,
              height: contextMenuItemHeightDense,
              isDense: true,
              info: info != null ? info!(sortList.value[i]) : null,
              onTap: () {
                onTap(sortList.value[i]);
                context.read(contextMenuState).clear();
              },
            ),
          ),
        ),
      ],
    );
  }
}
