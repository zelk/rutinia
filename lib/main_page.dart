import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models.dart';
import 'routine_page.dart';

// TODO: Handle mouse and keyboard interaction the way superhuman does
// TODO: Click an item should use focus correctly
// TODO: Make my own ListView that handles navigation and search bar
//        FocusManager.instance.primaryFocus?.nearestScope
//        FocusManager.instance.primaryFocus?.enclosingScope
// DirectionalFocusTraversalPolicyMixin may be good with many columns where
//   some rows are missing some
// https://medium.com/@omlondhe/keyboard-focus-in-flutter-9fd28af0672
//
// It seems as if ChatGPT 1o mini often adds controllers (and possibly
// focus nodes) to the model classes. It may be something to consider, unless
// it takes up too much resources if I load a lot of data.
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
// TODO: Verify how this works with mouse navigation
      _listFocusScopeNode.requestFocus();
    });
  }

  void _filterRoutines(String value) {
    setState(() {
      _filteredRoutines = _allRoutines
          .where((routine) =>
              routine.name.toLowerCase().contains(value.toLowerCase()))
          .toList();
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
                        return ListTile(
                          title: Text(routine.name),
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
                          subtitle:
                              Text('${routine.instances.length} instances'),
                          onTap: () {
                            _openRoutinePage(routine);
                          },
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
