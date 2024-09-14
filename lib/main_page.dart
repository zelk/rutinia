import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models.dart';
import 'routine_page.dart';

// TODO: Break out keybaord shortcuts into a separate file or even a separate widget
// TODO: The i, j, k and l keys must not overtake the text input in the search text field
// TODO: If a user presses the down arrow key at the bottom of the list, the key stroke should be ignored.
// TODO: Make sure that the Tab key and the up/down arrow keys are using the same focus features as right now, the tab based focus can be in one place while the arrow keys focus can be in a different place
// TODO: Implement a breadcrumb navigation system that allows the user to go back to the main page by pressing the back button
// TODO: Add a "+" button that allows the user to add a new routine and how to do keyboard shortcuts for that

class MoveUpIntent extends Intent {
  const MoveUpIntent();
}

class MoveDownIntent extends Intent {
  const MoveDownIntent();
}

class GoBackIntent extends Intent {
  const GoBackIntent();
}

class GoForwardIntent extends Intent {
  const GoForwardIntent();
}

class MoveLeftIntent extends Intent {
  const MoveLeftIntent();
}

class MoveRightIntent extends Intent {
  const MoveRightIntent();
}

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
    _searchFocusNode.addListener(_onFocusChange);
    _listFocusNode.addListener(_onFocusChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_searchFocusNode);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.removeListener(_onFocusChange);
    _listFocusNode.removeListener(_onFocusChange);
    _searchFocusNode.dispose();
    _listFocusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      if (_searchFocusNode.hasFocus) {
        _focusedIndex = -1;
      } else if (_listFocusNode.hasFocus && _focusedIndex == -1) {
        _focusedIndex = 0;
      }
    });
  }

  void _moveFocus(int direction) {
    setState(() {
      if (_focusedIndex == -1 && direction > 0) {
        _focusedIndex = 0;
        _listFocusNode.requestFocus();
      } else if (_focusedIndex == 0 && direction < 0) {
        _focusedIndex = -1;
        _searchFocusNode.requestFocus();
      } else {
        _focusedIndex =
            (_focusedIndex + direction).clamp(0, _filteredRoutines.length - 1);
        _listFocusNode.requestFocus();
      }
    });
  }

  void _openRoutinePage(Routine routine) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoutinePage(routine: routine),
      ),
    ).then((_) => _listFocusNode.requestFocus());
  }

  void _goBack() {
    Navigator.of(context).maybePop();
  }

  // New methods for handling intents
  void _handleMoveUp(MoveUpIntent intent) {
    if (_focusedIndex >= 0) {
      _moveFocus(-1);
    }
  }

  void _handleMoveDown(MoveDownIntent intent) {
    if (_focusedIndex < _filteredRoutines.length - 1) {
      _moveFocus(1);
    }
  }

  void _handleGoForward(GoForwardIntent intent) {
    if (_searchFocusNode.hasFocus) {
      _moveFocus(1);
    } else {
      _openRoutinePage(_filteredRoutines[_focusedIndex]);
    }
  }

  void _handleGoBack(GoBackIntent intent) {
    if (_listFocusNode.hasFocus) {
      _searchFocusNode.requestFocus();
    } else if (_searchFocusNode.hasFocus) {
      if (_searchController.text.isNotEmpty) {
        _searchController.clear();
        _filterRoutines('');
      } else {
        _goBack();
      }
    }
  }

  void _handleMoveLeft(MoveLeftIntent intent) {
    // Implement left movement logic if needed
  }

  void _handleMoveRight(MoveRightIntent intent) {
    // Implement right movement logic if needed
  }

  void _filterRoutines(String value) {
    setState(() {
      _filteredRoutines = _allRoutines
          .where((routine) =>
              routine.name.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      autofocus: true,
      child: Shortcuts(
        shortcuts: <ShortcutActivator, Intent>{
          LogicalKeySet(LogicalKeyboardKey.arrowUp): const MoveUpIntent(),
          LogicalKeySet(LogicalKeyboardKey.keyI): const MoveUpIntent(),
          LogicalKeySet(LogicalKeyboardKey.arrowDown): const MoveDownIntent(),
          LogicalKeySet(LogicalKeyboardKey.keyK): const MoveDownIntent(),
          LogicalKeySet(LogicalKeyboardKey.arrowLeft): const MoveLeftIntent(),
          LogicalKeySet(LogicalKeyboardKey.keyJ): const MoveLeftIntent(),
          LogicalKeySet(LogicalKeyboardKey.arrowRight): const MoveRightIntent(),
          LogicalKeySet(LogicalKeyboardKey.keyL): const MoveRightIntent(),
          LogicalKeySet(LogicalKeyboardKey.enter): const GoForwardIntent(),
          LogicalKeySet(LogicalKeyboardKey.escape): const GoBackIntent(),
        },
        child: Actions(
          actions: <Type, Action<Intent>>{
            MoveUpIntent: CallbackAction<MoveUpIntent>(onInvoke: _handleMoveUp),
            MoveDownIntent:
                CallbackAction<MoveDownIntent>(onInvoke: _handleMoveDown),
            MoveLeftIntent:
                CallbackAction<MoveLeftIntent>(onInvoke: _handleMoveLeft),
            MoveRightIntent:
                CallbackAction<MoveRightIntent>(onInvoke: _handleMoveRight),
            GoForwardIntent:
                CallbackAction<GoForwardIntent>(onInvoke: _handleGoForward),
            GoBackIntent: CallbackAction<GoBackIntent>(onInvoke: _handleGoBack),
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
                          subtitle:
                              Text('${routine.instances.length} instances'),
                          tileColor:
                              isFocused ? Colors.blue.withOpacity(0.1) : null,
                          onTap: () => _openRoutinePage(routine),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
