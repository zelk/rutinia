import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models.dart';
import 'routine_page.dart';

class RoutineListPage extends StatefulWidget {
  const RoutineListPage({super.key});

  @override
  _RoutineListPageState createState() => _RoutineListPageState();
}

class _RoutineListPageState extends State<RoutineListPage> {
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();
  int _focusedIndex = -1;
  late List<Routine> _routines;

  @override
  void initState() {
    super.initState();
    _routines = DummyDataGenerator.generateRoutines();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _searchController.dispose();
    super.dispose();
  }

  KeyEventResult _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        return _moveFocus(1);
      }
      if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        return _moveFocus(-1);
      }
      if (event.logicalKey == LogicalKeyboardKey.enter) {
        if (_focusedIndex >= 0) {
          _openRoutinePage(_routines[_focusedIndex]);
          return KeyEventResult.handled;
        }
      }
    }
    return KeyEventResult.ignored;
  }

  KeyEventResult _moveFocus(int direction) {
    if ((_focusedIndex == _routines.length - 1 && direction > 0) ||
        (_focusedIndex == -1 && direction < 0)) {
      return KeyEventResult.ignored;
    }

    setState(() {
      if (_focusedIndex == -1 && direction > 0) {
        _focusedIndex = 0;
      } else {
        _focusedIndex =
            (_focusedIndex + direction).clamp(0, _routines.length - 1);
      }
    });
    return KeyEventResult.handled;
  }

  void _openRoutinePage(Routine routine) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoutinePage(routine: routine),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      onKeyEvent: (node, event) {
        return _handleKeyEvent(event);
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
                    subtitle: Text('Instances: ${routine.instances.length}'),
                    tileColor: isFocused ? Colors.blue.withOpacity(0.1) : null,
                    onTap: () => _openRoutinePage(routine),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
