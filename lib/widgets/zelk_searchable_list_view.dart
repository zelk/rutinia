import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// TODO: I PROBABLY NEED A LOT OF SETSTATE CALLS IN THIS WIDGET!!!

// TODO: Rename to ZelkFilteredListView???

// TODO: Consider if I should add <T> to the widget.

// TODO: Space does not work to activate items, likely because of what has focus

// TODO: Handle mouse and keyboard interaction the way superhuman does
// TODO: Click an item should use focus correctly
// TODO: Check ideas below when needed:
// DirectionalFocusTraversalPolicyMixin may be good with many columns where
//   some rows are missing some
// https://medium.com/@omlondhe/keyboard-focus-in-flutter-9fd28af0672
// FocusManager.instance.primaryFocus?.nearestScope
// FocusManager.instance.primaryFocus?.enclosingScope
// It seems as if ChatGPT 1o mini often adds controllers (and possibly
// focus nodes) to the model classes. It may be something to consider, unless
// it takes up too much resources if I load a lot of data.

class ZelkSearchableListView extends StatefulWidget {
  final int itemCount;
  final Function(String) filter;
  final Function(int index) onItemTap;
  final Widget Function(BuildContext context, int index, bool hasFocus)
      itemBuilder;

  const ZelkSearchableListView(
      {super.key,
      required this.itemCount,
      required this.filter,
      required this.onItemTap,
      required this.itemBuilder});

  @override
  ZelkSearchableListViewState createState() => ZelkSearchableListViewState();
}

class ZelkSearchableListViewState extends State<ZelkSearchableListView> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final FocusScopeNode _listFocusScopeNode = FocusScopeNode();
  final int _numColumns = 3;
  late List<List<FocusNode>> _listFocusNodes;
  int _listRowIndex = -1;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => widget.filter(_searchController.text));
    _listFocusNodes = List.generate(
      1, // TODO: Is it better to generate more from the get go?
      // Actually, it might be best to do lazy initialization.
      (_) => List.generate(
        _numColumns,
        (_) => FocusNode(),
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_searchFocusNode);
    });
  }

  @override
  void dispose() {
    _listFocusScopeNode.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    for (var list in _listFocusNodes) {
      for (var node in list) {
        node.dispose();
      }
    }
    super.dispose();
  }

  FocusNode _getListFocusNode(int row, int col) {
    assert(row >= 0 && col >= 0);
    if (row > _listFocusNodes.length - 1) {
      // TODO: I will need to generate more than one. Check diff!!!
      _listFocusNodes.add(List.generate(
        _numColumns,
        (_) => FocusNode(),
      ));
    }
    // No dynamic column addition supported:
    assert(col < _listFocusNodes[row].length);
    return _listFocusNodes[row][col];
  }

  KeyEventResult _handleSearchFocusKeyPress(
      BuildContext context, KeyEvent event) {
    if ((event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.numpadEnter) &&
        event is KeyDownEvent) {
      if (widget.itemCount > 0) {
        _listFocusScopeNode.requestFocus();
        _getListFocusNode(0, 0).requestFocus();
      }
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.escape &&
        (event is KeyDownEvent || event is KeyRepeatEvent)) {
      if (_searchController.text.isNotEmpty) {
        _searchController.clear();
        widget.filter('');
      } else {
        Navigator.of(context).maybePop();
      }
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowDown &&
        (event is KeyDownEvent || event is KeyRepeatEvent)) {
      if (_searchController.selection.baseOffset ==
          _searchController.text.length) {
        _getListFocusNode(0, 0).requestFocus();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  KeyEventResult _handleListFocusKeyPress(
      BuildContext context, KeyEvent event) {
    if ((event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.numpadEnter) &&
        event is KeyDownEvent) {
      assert(widget.itemCount > 0);
      assert(_listRowIndex != -1);
      widget.onItemTap(_listRowIndex);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.escape &&
        (event is KeyDownEvent || event is KeyRepeatEvent)) {
      _searchFocusNode.requestFocus();
      FocusScope.of(context).focusedChild?.unfocus();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp &&
        (event is KeyDownEvent || event is KeyRepeatEvent)) {
      if (_listRowIndex > 0) {
        FocusScope.of(context)
            .focusedChild
            ?.focusInDirection(TraversalDirection.up);
      } else {
        _getListFocusNode(_listRowIndex, 0).unfocus();
        _searchFocusNode.requestFocus();
      }
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowDown &&
        (event is KeyDownEvent || event is KeyRepeatEvent)) {
      if (_listRowIndex < widget.itemCount - 1) {
        setState(() {
          FocusScope.of(context)
              .focusedChild
              ?.focusInDirection(TraversalDirection.down);
        });
      }
      return KeyEventResult.handled;
    }
    if (event.character != null &&
        event.character!.isNotEmpty &&
        event.logicalKey != LogicalKeyboardKey.tab &&
        event.logicalKey != LogicalKeyboardKey.space) {
      _getListFocusNode(_listRowIndex, 0).unfocus();
      _searchFocusNode.requestFocus();
      _searchController.text += event.character!;
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("$_listRowIndex"),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: FocusScope(
            onKeyEvent: (node, event) {
              return _handleSearchFocusKeyPress(context, event);
            },
            child: TextField(
              autofocus: true,
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: 'Search routines',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        tooltip: 'Esc',
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
              // TODO: Do I really need both this and the listener in initState?
              //              onChanged: widget.filter(_searchController.text),
            ),
          ),
        ),
        Expanded(
          child: FocusScope(
            node: _listFocusScopeNode,
            onKeyEvent: (node, event) {
              return _handleListFocusKeyPress(context, event);
            },
            child: widget.itemCount == 0
                ? const Center(
                    child: Text('No matches'),
                  )
                : ListView.builder(
                    itemCount: widget.itemCount,
                    itemBuilder: (context, index) {
                      final focusNode = _getListFocusNode(index, 0);
                      return Focus(
                          focusNode: focusNode,
                          onFocusChange: (hasFocus) {
                            if (hasFocus) {
                              setState(() {
                                _listRowIndex = index;
                              });
                            } else {
                              if (_listRowIndex == index) {
                                setState(() {
                                  _listRowIndex = -1;
                                });
                              }
                            }
                          },
                          child: ExcludeFocus(
                            child: widget.itemBuilder(
                                context, index, _listRowIndex == index),
                          ));
                    },
                  ),
          ),
        ),
      ],
    );
  }
}
