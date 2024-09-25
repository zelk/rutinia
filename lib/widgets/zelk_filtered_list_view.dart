import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// TODO: SOMETHING JUST BROKE!!! Esc does not move focus to the text field
//       Clicking items with the mouse does not work.

// TODO: Add Focus for each column

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

class ZelkFilteredListView extends StatefulWidget {
  final int itemCount;
  final int columnCount;
  final Function(String) filter;
  final Function(int rowIndex) onItemTap;
  final List<
      Widget Function(BuildContext context, int rowIndex, bool rowHasFocus,
          int columnIndex, bool columnHasFocus)> itemBuilders;

  const ZelkFilteredListView({
    super.key,
    required this.itemCount,
    required this.columnCount,
    required this.filter,
    required this.onItemTap,
    required this.itemBuilders,
  });

  @override
  ZelkFilteredListViewState createState() => ZelkFilteredListViewState();
}

class ZelkFilteredListViewState extends State<ZelkFilteredListView> {
  final TextEditingController _textFieldController = TextEditingController();
  final FocusNode _textFieldFocusNode = FocusNode();
  final FocusScopeNode _listFocusScopeNode = FocusScopeNode();
  int _listRowIndex = -1;
  int _listColumnIndex = 0;

  @override
  void initState() {
    super.initState();
    _textFieldController
        .addListener(() => widget.filter(_textFieldController.text));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_textFieldFocusNode);
    });
  }

  @override
  void dispose() {
    _listFocusScopeNode.dispose();
    _textFieldController.dispose();
    _textFieldFocusNode.dispose();
    super.dispose();
  }

  KeyEventResult _handleTextFieldFocusKeyPress(
      BuildContext context, KeyEvent event) {
    if ((event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.numpadEnter) &&
        event is KeyDownEvent) {
      if (widget.itemCount > 0) {
        _listFocusScopeNode.requestFocus();
        FocusTraversalGroup.of(context)
            .findFirstFocus(_listFocusScopeNode, ignoreCurrentFocus: true)
            ?.requestFocus();
      }
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.escape &&
        (event is KeyDownEvent || event is KeyRepeatEvent)) {
      if (_textFieldController.text.isNotEmpty) {
        _textFieldController.clear();
        widget.filter('');
      } else {
        Navigator.of(context).maybePop();
      }
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp &&
        (event is KeyDownEvent || event is KeyRepeatEvent)) {
      if (_textFieldController.selection.baseOffset ==
          _textFieldController.text.length) {
        _textFieldFocusNode.focusInDirection(TraversalDirection.up);
        return KeyEventResult.handled;
      }
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowDown &&
        (event is KeyDownEvent || event is KeyRepeatEvent)) {
      if (_textFieldController.selection.baseOffset ==
          _textFieldController.text.length) {
        FocusTraversalGroup.of(context)
            .findFirstFocus(_listFocusScopeNode, ignoreCurrentFocus: true)
            ?.requestFocus();
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
      _textFieldFocusNode.requestFocus();
      FocusScope.of(context).focusedChild?.unfocus();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp &&
        (event is KeyDownEvent || event is KeyRepeatEvent)) {
      if (_listRowIndex > 0) {
        FocusScope.of(context)
            .focusedChild
            ?.focusInDirection(TraversalDirection.up);
      } else if (event is KeyDownEvent) {
        _listFocusScopeNode.unfocus();
        _textFieldFocusNode.requestFocus();
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
    if (event.logicalKey == LogicalKeyboardKey.arrowRight &&
        (event is KeyDownEvent || event is KeyRepeatEvent)) {
      if (_listColumnIndex < widget.columnCount - 1) {
        setState(() {
          FocusScope.of(context)
              .focusedChild
              ?.focusInDirection(TraversalDirection.right);
        });
      }
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft &&
        (event is KeyDownEvent || event is KeyRepeatEvent)) {
      if (_listColumnIndex > 0) {
        setState(() {
          FocusScope.of(context)
              .focusedChild
              ?.focusInDirection(TraversalDirection.left);
        });
      }
      return KeyEventResult.handled;
    }
    if (event.character != null &&
        event.character!.isNotEmpty &&
        event.logicalKey != LogicalKeyboardKey.tab &&
        event.logicalKey != LogicalKeyboardKey.space) {
      _listFocusScopeNode.unfocus();
      _textFieldFocusNode.requestFocus();
      _textFieldController.text += event.character!;
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("$_listRowIndex, $_listColumnIndex"),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Focus(
            onKeyEvent: (node, event) {
              return _handleTextFieldFocusKeyPress(context, event);
            },
            child: TextField(
              autofocus: true,
              controller: _textFieldController,
              focusNode: _textFieldFocusNode,
              decoration: InputDecoration(
                hintText: 'Filter items',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _textFieldController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        tooltip: 'Esc',
                        onPressed: () {
                          _textFieldController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
              ),
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
                    itemBuilder: (context, rowIndex) {
                      return Focus(
                        canRequestFocus:
                            false, // TODO: Change to skipTraversal true?
                        onFocusChange: (hasFocus) {
                          if (hasFocus) {
                            setState(() {
                              _listRowIndex = rowIndex;
                            });
                          } else {
                            if (_listRowIndex == rowIndex) {
                              setState(() {
                                _listRowIndex = -1;
                              });
                            }
                          }
                        },
                        child: Row(
                          children:
                              widget.itemBuilders.asMap().entries.map((entry) {
                            int columnIndex = entry.key;
                            var builder = entry.value;
                            return Expanded(
                              child: Focus(
                                onFocusChange: (hasFocus) {
                                  if (hasFocus) {
                                    setState(() {
                                      _listColumnIndex = columnIndex;
                                    });
                                  }
                                },
                                child: ExcludeFocus(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        top: BorderSide(
                                          color: _listRowIndex == rowIndex &&
                                                  _listColumnIndex ==
                                                      columnIndex
                                              ? Colors.black
                                              : Colors.transparent,
                                          width: 2.0,
                                        ),
                                        bottom: BorderSide(
                                          color: _listRowIndex == rowIndex &&
                                                  _listColumnIndex ==
                                                      columnIndex
                                              ? Colors.black
                                              : Colors.transparent,
                                          width: 2.0,
                                        ),
                                        left: BorderSide(
                                          color: _listRowIndex == rowIndex &&
                                                  _listColumnIndex ==
                                                      columnIndex
                                              ? Colors.black
                                              : Colors.transparent,
                                          width: 2.0,
                                        ),
                                        right: BorderSide(
                                          color: _listRowIndex == rowIndex &&
                                                  _listColumnIndex ==
                                                      columnIndex
                                              ? Colors.black
                                              : Colors.transparent,
                                          width: 2.0,
                                        ),
                                      ),
                                    ),
                                    child: builder(
                                        context,
                                        rowIndex,
                                        _listRowIndex == rowIndex,
                                        columnIndex,
                                        _listColumnIndex == columnIndex),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}
