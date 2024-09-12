import 'package:flutter/material.dart';
import 'models.dart';

class InstancePage extends StatelessWidget {
  final RoutineInstance instance;

  const InstancePage({super.key, required this.instance});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(instance.name),
      ),
      body: Column(
        children: [
          // Search box
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search actions',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                // TODO: Implement search functionality
              },
            ),
          ),
          // List of actions
          Expanded(
            child: ListView.builder(
              itemCount: instance.actionInstances.length,
              itemBuilder: (context, index) {
                final actionInstance = instance.actionInstances[index];
                return ListTile(
                  leading: Checkbox(
                    value: actionInstance.isCompleted,
                    onChanged: (bool? value) {
                      // TODO: Implement checkbox functionality
                    },
                  ),
                  title: Text(actionInstance.action.name),
                  subtitle: Text('Assignee: ${actionInstance.assigneeUserId}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.comment),
                    onPressed: () {
                      // TODO: Implement comments functionality
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
