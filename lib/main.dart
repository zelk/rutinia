import 'package:flutter/material.dart';
import 'models.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rutinia',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const RoutineListPage(),
    );
  }
}

class RoutineListPage extends StatelessWidget {
  const RoutineListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final routines = DummyDataGenerator.generateRoutines();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Routines'),
      ),
      body: Column(
        children: [
          // Search box
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
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
          // List of routines
          Expanded(
            child: ListView.builder(
              itemCount: routines.length,
              itemBuilder: (context, index) {
                final routine = routines[index];
                return ListTile(
                  title: Text(routine.name),
                  subtitle: Text('Instances: ${routine.instances.length}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RoutinePage(routine: routine),
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
