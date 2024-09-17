import 'package:flutter/material.dart';
import 'widgets/zelk_searchable_list_view.dart';
import 'models.dart';
import 'routine_page.dart';

// TODO: Apply ZelkSearchableListView to all pages.
// TODO: Implement a breadcrumb navigation system that allows the user to go back to the main page by pressing the back button
// TODO: Add a way to edit the routine
// TODO: Add a way to delete the routine
// TODO: Add a way to duplicate the routine

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  late List<Routine> _allItems;
  late List<Routine> _filteredItems;

  @override
  void initState() {
    super.initState();
    _allItems = DummyDataGenerator.generateRoutines();
    _filteredItems = _allItems;
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
      _filteredItems = _allItems
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
          itemCount: _filteredItems.length,
          filter: _filterRoutines,
          onItemTap: (index) {
            _openRoutinePage(_filteredItems[index]);
          },
          itemBuilder: (context, index, hasFocus) {
            final routine = _filteredItems[index];
            return ListTile(
              title: Text(routine.name),
              subtitle: Text('${routine.instances.length} instances'),
              tileColor: hasFocus ? Colors.blue.withOpacity(0.5) : null,
              onTap: () {
                _openRoutinePage(routine);
              },
            );
          }),
    );
  }
}
