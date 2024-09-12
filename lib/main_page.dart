import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models.dart';
import 'routine_page.dart';

// TODO: Make sure that unhandled keys are ignored
// TODO: Make sure that the Tab key and the up/down arrow keys are using the same focus features as right now, the tab based focus can be in one place while the arrow keys focus can be in a different place

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
  bool _handleMoveUp(MoveUpIntent intent) {
    if (_focusedIndex >= 0) {
      _moveFocus(-1);
      return true;
    }
    return false;
  }

  bool _handleMoveDown(MoveDownIntent intent) {
    if (_focusedIndex < _filteredRoutines.length - 1) {
      _moveFocus(1);
      return true;
    }
    return false;
  }

  bool _handleGoForward(GoForwardIntent intent) {
    if (_searchFocusNode.hasFocus) {
      _moveFocus(1);
    } else {
      _openRoutinePage(_filteredRoutines[_focusedIndex]);
    }
    return true;
  }

  bool _handleGoBack(GoBackIntent intent) {
    if (_searchFocusNode.hasFocus) {
      _searchController.clear();
      _filterRoutines(''); // Call _filterRoutines with empty string
    } else if (_focusedIndex != -1) {
      _searchFocusNode.requestFocus();
    } else {
      _goBack();
    }
    return true;
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
          LogicalKeySet(LogicalKeyboardKey.arrowDown): const MoveDownIntent(),
          LogicalKeySet(LogicalKeyboardKey.enter): const GoForwardIntent(),
          LogicalKeySet(LogicalKeyboardKey.escape): const GoBackIntent(),
        },
        child: Actions(
          actions: <Type, Action<Intent>>{
            MoveUpIntent: CallbackAction<MoveUpIntent>(onInvoke: _handleMoveUp),
            MoveDownIntent:
                CallbackAction<MoveDownIntent>(onInvoke: _handleMoveDown),
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
                    decoration: const InputDecoration(
                      hintText: 'Search routines',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
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
