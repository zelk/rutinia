import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models.dart';
import 'routine_page.dart';

////////////////////
/// INPUT ISSUES ///
////////////////////
// TODO: Handle user clicking the text field
// TODO: Handle mouse and keyboard interaction the way superhuman does
// TODO: Align arrow keys with the tab index
// TODO: Break out keybaord shortcuts into a separate file or even a separate widget
// TODO: If a user presses the down arrow key at the bottom of the list, the key stroke should be ignored.

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
  int _focusedIndex = -1;
  late List<Routine> _allRoutines;
  late List<Routine> _filteredRoutines;
  final FocusNode _searchFocusNode = FocusNode();
  final FocusNode _listFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _allRoutines = DummyDataGenerator.generateRoutines();
    _filteredRoutines = _allRoutines;
    _searchController
        .addListener(() => _filterRoutines(_searchController.text));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_searchFocusNode);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _listFocusNode.dispose();
    super.dispose();
  }

  void _openRoutinePage(Routine routine) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoutinePage(routine: routine),
      ),
    ).then((_) {
      setState(() {
        _focusedIndex = _filteredRoutines.indexOf(routine);
      });
      _listFocusNode.requestFocus();
    });
  }

  void _filterRoutines(String value) {
    setState(() {
      _filteredRoutines = _allRoutines
          .where((routine) =>
              routine.name.toLowerCase().contains(value.toLowerCase()))
          .toList();
      if (_filteredRoutines.isEmpty) {
        _focusedIndex = -1;
      } else if (_focusedIndex >= _filteredRoutines.length) {
        _focusedIndex = _filteredRoutines.length - 1;
      }
    });
  }

  KeyEventResult _handleSearchFocusKeyPress(KeyEvent event) {
    if ((event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.numpadEnter) &&
        event is KeyDownEvent) {
      if (_filteredRoutines.isNotEmpty) {
        _listFocusNode.requestFocus();
        setState(() {
          _focusedIndex = 0;
        });
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
        _listFocusNode.requestFocus();
        setState(() {
          _focusedIndex = 0;
        });
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  KeyEventResult _handleListFocusKeyPress(KeyEvent event) {
    if ((event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.numpadEnter) &&
        event is KeyDownEvent) {
      assert(_filteredRoutines.isNotEmpty);
      assert(_focusedIndex != -1);
      _openRoutinePage(_filteredRoutines[_focusedIndex]);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.escape &&
        (event is KeyDownEvent || event is KeyRepeatEvent)) {
      _searchFocusNode.requestFocus();
      setState(() {
        _focusedIndex = -1;
      });
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowUp &&
        (event is KeyDownEvent || event is KeyRepeatEvent)) {
      if (_focusedIndex > 0) {
        setState(() {
          _focusedIndex--;
        });
      } else {
        _searchFocusNode.requestFocus();
        setState(() {
          _focusedIndex = -1;
        });
      }
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowDown &&
        (event is KeyDownEvent || event is KeyRepeatEvent)) {
      if (_focusedIndex < _filteredRoutines.length - 1) {
        setState(() {
          _focusedIndex++;
        });
      }
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (_searchFocusNode.hasFocus) {
          return _handleSearchFocusKeyPress(event);
        } else if (_listFocusNode.hasFocus) {
          return _handleListFocusKeyPress(event);
        }
        return KeyEventResult.ignored;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Routines'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
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
            Expanded(
              child: Focus(
                focusNode: _listFocusNode,
                child: ListView.builder(
                  itemCount: _filteredRoutines.length,
                  itemBuilder: (context, index) {
                    final routine = _filteredRoutines[index];
                    final isFocused = _focusedIndex == index;
                    return ListTile(
                      title: Text(routine.name),
                      subtitle: Text('${routine.instances.length} instances'),
                      tileColor:
                          isFocused ? Theme.of(context).focusColor : null,
                      onTap: () => _openRoutinePage(routine),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
