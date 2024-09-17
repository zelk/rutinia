import 'package:flutter/material.dart';
import 'widgets/zelk_searchable_list_view.dart';
import 'models.dart';
import 'instance_page.dart';

// TODO: Implement ZelkSearchableListView for the instances
// TODO: Add a "+" button that allows the user to add a new instance and how to do keyboard shortcuts for that
// TODO: Add a way to edit the routine
// TODO: Add a way to delete the routine
// TODO: Add a way to duplicate the routine
// TODO: Add a way to move the routine up or down the list
// TODO: Add a way to move the routine to a different list

class RoutinePage extends StatefulWidget {
  final Routine routine;

  const RoutinePage({super.key, required this.routine});

  @override
  State<RoutinePage> createState() => _RoutinePageState();
}

class _RoutinePageState extends State<RoutinePage> {
  late List<RoutineInstance> _allItems;
  late List<RoutineInstance> _filteredItems;

  @override
  void initState() {
    super.initState();
    _allItems = widget.routine.instances;
    _filteredItems = _allItems;
  }

  void _openInstancePage(RoutineInstance instance) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InstancePage(instance: instance),
      ),
    );
  }

  void _filterItems(String value) {
    setState(() {
      _filteredItems = _allItems
          .where((instance) =>
              instance.name.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.routine.name} Routine'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Instances headline
          const Padding(
            padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: Text(
              'Instances',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ZelkSearchableListView(
              itemCount: _filteredItems.length,
              filter: _filterItems,
              onItemTap: (index) {
                _openInstancePage(_filteredItems[index]);
              },
              itemBuilder: (context, index, hasFocus) {
                final instance = _filteredItems[index];
                return ListTile(
                  title: Text(instance.name),
                  subtitle: Text('Due: ${instance.dueDate.toString()}'),
                  tileColor: hasFocus ? Colors.blue.withOpacity(0.5) : null,
                  onTap: () {
                    _openInstancePage(instance);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
