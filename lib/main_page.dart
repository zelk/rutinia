import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models.dart';
import 'routine_page.dart';

////////////////////
/// INPUT ISSUES ///
////////////////////
// TODO: Still, actually, maybe it makes sense to have focus scopes for each
//       row and focus nodes for each row column item in each row. And an outer
//       focus scope for the list.
// TODO: Make my own ListView that handles navigation, has a FocusScope + Node
//       and handles the keyboard events for the list. I capture tab key to
//       make it align with arrow key right or down, and shift+tab of course.
//       The Flutter system only knows that the FocusScope of the list has focus
//       but what goes on inside the list is not known.

//        FocusManager.instance.primaryFocus?.nearestScope
//        FocusManager.instance.primaryFocus?.enclosingScope
// I MAY NEED DirectionalFocusTraversalPolicyMixin but it may also be overkill,
//   since it's mainly for when items are not greatly aligned... but I was
//   actually thinking the other day about when some rows are missing some
//   of the focusable items...
// Here's another thing:
//   https://medium.com/@omlondhe/keyboard-focus-in-flutter-9fd28af0672
// THIS IS INTERESTING. There's up, down, left, right!!!
//        _focusScopeNode.focusInDirection(TraversalDirection.right);
//        _focusScopeNode.focusedChild
//            ?.focusInDirection(TraversalDirection.right);
// THIS SHOUD STOP NAVIGATION AT THE EDGE WITHOUT CUSTOM CODE
// SO, THE IMPLEMENTATION WOULD BE AS FOLLOWS:
// I make my own ListView that has a FocusScope. Below it, everything focusable
// should have a Focus (and possibly a focus node if needed, hopefully not).
// I can use focusInDirection of the FocusScope to move up, down, left, right
//
// IT SEEMS AS IF ChatGPT 1o mini often adds controllers (and possibly
// focus nodes) to the model classes. It may be something to consider, unless
// it takes up too much resources if I load a lot of data.

// TODO: Make my own SearchBar that is connected to my custom ListView.
// TODO: Handle user clicking the text field
// TODO: Handle mouse and keyboard interaction the way superhuman does
// TODO: Align arrow keys with the tab index
// TODO: If a user presses the down arrow key at the bottom of the list, the key
//       stroke should be ignored. The reason that no OS sound is played is
//       likely because of the tab index system.

/////////////////////////
/// NAVIGATION ISSUES ///
/////////////////////////
// TODO: Implement a breadcrumb navigation system that allows the user to go back to the main page by pressing the back button
// TODO: Add a "+" button that allows the user to add a new routine and how to do keyboard shortcuts for that

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  final TextEditingController _searchController = TextEditingController();
  int _listRowIndex = -1;
  late List<Routine> _allRoutines;
  late List<Routine> _filteredRoutines;
  late List<List<FocusNode>> _listFocusNodes;
  final FocusNode _searchFocusNode = FocusNode();
  final FocusScopeNode _listFocusScopeNode = FocusScopeNode();
  final int _numColumns = 3;

  @override
  void initState() {
    super.initState();
    _allRoutines = DummyDataGenerator.generateRoutines();
    _filteredRoutines = _allRoutines;
    _searchController
        .addListener(() => _filterRoutines(_searchController.text));
    _listFocusNodes = List.generate(
      _filteredRoutines.length,
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
      // TODO: I may need to generate more than one. Check diff!!!
      _listFocusNodes.add(List.generate(
        _numColumns,
        (_) => FocusNode(),
      ));
    }
    assert(col < _listFocusNodes[row].length); // No dynamic column addition
    return _listFocusNodes[row][col];
  }

  void _openRoutinePage(Routine routine) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoutinePage(routine: routine),
      ),
    ).then((_) {
      setState(() {
// TODO: Implement in case it's not automatic now with my new navigation method.
//        _focusedIndex = _filteredRoutines.indexOf(routine);
      });
      _listFocusScopeNode.requestFocus();
    });
  }

  void _filterRoutines(String value) {
    setState(() {
      _filteredRoutines = _allRoutines
          .where((routine) =>
              routine.name.toLowerCase().contains(value.toLowerCase()))
          .toList();
// TODO: Verify that this is not neded
//      if (_filteredRoutines.isEmpty) {
//        _focusedIndex = -1;
//      } else if (_focusedIndex >= _filteredRoutines.length) {
//        _focusedIndex = _filteredRoutines.length - 1;
//      }
    });
  }

  KeyEventResult _handleSearchFocusKeyPress(
      BuildContext context, KeyEvent event) {
    if ((event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.numpadEnter) &&
        event is KeyDownEvent) {
      if (_filteredRoutines.isNotEmpty) {
        _listFocusScopeNode.requestFocus();
        _getListFocusNode(0, 0).requestFocus();
      }
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.escape &&
        (event is KeyDownEvent || event is KeyRepeatEvent)) {
      if (_searchController.text.isNotEmpty) {
        _searchController.clear();
        _filterRoutines('');
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
      assert(_filteredRoutines.isNotEmpty);
      assert(_listRowIndex != -1);
      _openRoutinePage(_filteredRoutines[_listRowIndex]);
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
      if (_listRowIndex < _filteredRoutines.length - 1) {
        setState(() {
          FocusScope.of(context)
              .focusedChild
              ?.focusInDirection(TraversalDirection.down);
        });
      }
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Routines{$_listRowIndex}'),
      ),
      body: Column(
        children: [
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
                onChanged: _filterRoutines,
              ),
            ),
          ),
          Expanded(
            child: FocusScope(
              node: _listFocusScopeNode,
              onKeyEvent: (node, event) {
                return _handleListFocusKeyPress(context, event);
              },
              child: _filteredRoutines.isEmpty
                  ? const Center(
                      child: Text('No matches'),
                    )
                  : ListView.builder(
                      itemCount: _filteredRoutines.length,
                      itemBuilder: (context, index) {
                        final routine = _filteredRoutines[index];
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
                          child: ListTile(
                            title: Text(routine.name),
                            onFocusChange: (hasFocus) {
                              if (hasFocus) {
                                print('Focus on ListTile $index');
                              } else {
                                print('Unfocus on ListTile $index');
                              }
                            },
                            subtitle:
                                Text('${routine.instances.length} instances'),
                            tileColor: focusNode.hasFocus
                                ? Colors.blue.withOpacity(0.1)
                                : null,
                            onTap: () => _openRoutinePage(routine),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
