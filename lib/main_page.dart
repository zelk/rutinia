import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models.dart';
import 'routine_page.dart';

// Custom intents
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
  late List<Routine> _routines;
  final FocusNode _searchFocusNode = FocusNode();
  final FocusNode _listFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _routines = DummyDataGenerator.generateRoutines();
    _searchFocusNode.addListener(_onFocusChange);
    _listFocusNode.addListener(_onFocusChange);
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
            (_focusedIndex + direction).clamp(0, _routines.length - 1);
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
    if (_focusedIndex < _routines.length - 1) {
      _moveFocus(1);
      return true;
    }
    return false;
  }

  bool _handleGoForward(GoForwardIntent intent) {
    if (_focusedIndex >= 0) {
      _openRoutinePage(_routines[_focusedIndex]);
    } else {
      _moveFocus(1);
    }
    return true;
  }

  bool _handleGoBack(GoBackIntent intent) {
    _goBack();
    return true;
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
                    onChanged: (value) {
                      // TODO: Implement search functionality
                    },
                  ),
                ),
                Expanded(
                  child: Focus(
                    focusNode: _listFocusNode,
                    child: ListView.builder(
                      itemCount: _routines.length,
                      itemBuilder: (context, index) {
                        final routine = _routines[index];
                        final isFocused = _focusedIndex == index;
                        return ListTile(
                          title: Text(routine.name),
                          subtitle:
                              Text('Instances: ${routine.instances.length}'),
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
