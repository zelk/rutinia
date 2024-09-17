import 'package:flutter/material.dart';
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
          // Search box
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search instances',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                // TODO: Implement search functionality
              },
            ),
          ),
          // List of instances
          Expanded(
            child: ListView.builder(
              itemCount: widget.routine.instances.length,
              itemBuilder: (context, index) {
                final instance = widget.routine.instances[index];
                return ListTile(
                  title: Text(instance.name),
                  subtitle: Text('Due: ${instance.dueDate.toString()}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InstancePage(instance: instance),
                      ),
                    );
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
