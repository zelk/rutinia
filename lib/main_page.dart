import 'package:flutter/material.dart';
import 'widgets/zelk_searchable_list_view.dart';
import 'models.dart';
import 'routine_page.dart';

// TODO: Make my own ListView that handles navigation and search bar
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
// TODO: Implement a breadcrumb navigation system that allows the user to go back to the main page by pressing the back button
// TODO: Add a "+" button that allows the user to add a new routine and how to do keyboard shortcuts for that

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  late List<Routine> _allRoutines;
  late List<Routine> _filteredRoutines;

  @override
  void initState() {
    super.initState();
    _allRoutines = DummyDataGenerator.generateRoutines();
    _filteredRoutines = _allRoutines;
  }

  void _openRoutinePage(Routine routine) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoutinePage(routine: routine),
      ),
    );
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Routines'),
      ),
      body: ZelkSearchableListView(
          itemCount: _filteredRoutines.length,
          filter: _filterRoutines,
          onItemTap: (index) {
            _openRoutinePage(_filteredRoutines[index]);
          },
          itemBuilder: (context, index, hasFocus) {
            final routine = _filteredRoutines[index];
            return ListTile(
              title: Text(routine.name),
              subtitle: Text('${routine.instances.length} instances'),
// TODO: Where do I put this?
              tileColor: hasFocus ? Colors.blue.withOpacity(0.5) : null,
              onTap: () {
                _openRoutinePage(routine);
              },
            );
          }),
    );
  }
}
