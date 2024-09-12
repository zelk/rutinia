import 'package:flutter/material.dart';
import 'models.dart';
import 'instance_page.dart';

class RoutinePage extends StatelessWidget {
  final Routine routine;

  const RoutinePage({super.key, required this.routine});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${routine.name} Instances'),
      ),
      body: Column(
        children: [
          // Search box
          Padding(
            padding: const EdgeInsets.all(8.0),
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
              itemCount: routine.instances.length,
              itemBuilder: (context, index) {
                final instance = routine.instances[index];
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
