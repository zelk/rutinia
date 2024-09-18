import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// TODO: Tab key in filter text field should move focus to the list, after "X"

// TODO: Add support for columns

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
  final Function(String) filter;
  final Function(int index) onItemTap;
  final Widget Function(BuildContext context, int index, bool hasFocus)
      itemBuilder;

  const ZelkFilteredListView(
      {super.key,
      required this.itemCount,
      required this.filter,
      required this.onItemTap,
      required this.itemBuilder});

  @override
  ZelkFilteredListViewState createState() => ZelkFilteredListViewState();
}

class ZelkFilteredListViewState extends State<ZelkFilteredListView> {
  final TextEditingController _textFieldController = TextEditingController();
  final FocusNode _textFieldFocusNode = FocusNode();
  final FocusScopeNode _listFocusScopeNode = FocusScopeNode();
  int _listRowIndex = -1;

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
      } else {
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
        Text("$_listRowIndex"),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: FocusScope(
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
                    itemBuilder: (context, index) {
                      return Focus(
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
