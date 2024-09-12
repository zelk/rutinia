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

class OpenRoutineIntent extends Intent {
  const OpenRoutineIntent();
}

class RoutineListPage extends StatefulWidget {
  const RoutineListPage({super.key});

  @override
  RoutineListPageState createState() => RoutineListPageState();
}

class RoutineListPageState extends State<RoutineListPage> {
  final TextEditingController _searchController = TextEditingController();
  int _focusedIndex = -1;
  late List<Routine> _routines;
  final FocusNode _listFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _routines = DummyDataGenerator.generateRoutines();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _listFocusNode.dispose();
    super.dispose();
  }

  void _moveFocus(int direction) {
    setState(() {
      if (_focusedIndex == -1 && direction > 0) {
        _focusedIndex = 0;
      } else if (_focusedIndex == 0 && direction < 0) {
        _focusedIndex = -1;
      } else {
        _focusedIndex =
            (_focusedIndex + direction).clamp(-1, _routines.length - 1);
      }
    });
    _listFocusNode.requestFocus();
  }

  void _openRoutinePage(Routine routine) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoutinePage(routine: routine),
      ),
    ).then((_) => {
      setState(() {
        if (_focusedIndex == -1) {
          _focusedIndex = 0;
        }
      });
      _listFocusNode.requestFocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        LogicalKeySet(LogicalKeyboardKey.arrowUp): const MoveUpIntent(),
        LogicalKeySet(LogicalKeyboardKey.arrowDown): const MoveDownIntent(),
        LogicalKeySet(LogicalKeyboardKey.enter): const OpenRoutineIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          MoveUpIntent: CallbackAction<MoveUpIntent>(
            onInvoke: (MoveUpIntent intent) {
              if (_focusedIndex > -1) {
                _moveFocus(-1);
                return true;
              }
              return null;
            },
          ),
          MoveDownIntent: CallbackAction<MoveDownIntent>(
            onInvoke: (MoveDownIntent intent) {
              if (_focusedIndex < _routines.length - 1) {
                _moveFocus(1);
                return true;
              }
              return null;
            },
          ),
          OpenRoutineIntent: CallbackAction<OpenRoutineIntent>(
            onInvoke: (OpenRoutineIntent intent) {
              if (_focusedIndex >= 0) {
                _openRoutinePage(_routines[_focusedIndex]);
              } else {
                Actions.invoke(context, const MoveDownIntent());
              }
              return true;
            },
          ),
        },
        child: Focus(
          focusNode: _listFocusNode,
          autofocus: true,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
