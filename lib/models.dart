import 'package:flutter/foundation.dart';

class User {
  final String userId;
  final String firstName;
  final String lastName;
  final String phoneNumber;

  User({
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
  });
}

class Action {
  final String name;

  Action({required this.name});
}

class Routine {
  final String name;
  final List<Action> actions;
  final List<RoutineInstance> instances;

  Routine({
    required this.name,
    required this.actions,
    List<RoutineInstance>? instances,
  }) : instances = instances ?? [];
}

class ActionInstance {
  final RoutineInstance routineInstance;
  final Action action;
  final String assigneeUserId;
  final DateTime dueDate;
  String comment;
  bool isCompleted;

  ActionInstance({
    required this.routineInstance,
    required this.action,
    required this.assigneeUserId,
    required this.dueDate,
    this.comment = '',
    this.isCompleted = false,
  });
}

class RoutineInstance {
  final String name;
  final Routine routine;
  final DateTime dueDate;
  final List<ActionInstance> actionInstances;

  RoutineInstance({
    required this.name,
    required this.routine,
    required this.dueDate,
    required this.actionInstances,
  });
}

class DummyDataGenerator {
  static List<User> generateUsers() {
    return [
      User(
          userId: 'john@example.com',
          firstName: 'John',
          lastName: 'Doe',
          phoneNumber: '1234567890'),
      User(
          userId: 'jane@example.com',
          firstName: 'Jane',
          lastName: 'Smith',
          phoneNumber: '0987654321'),
      User(
          userId: 'bob@example.com',
          firstName: 'Bob',
          lastName: 'Johnson',
          phoneNumber: '5555555555'),
    ];
  }

  static List<Routine> generateRoutines() {
    final users = generateUsers();
    final routines = [
      Routine(
        name: 'Morning Routine',
        actions: [
          Action(name: 'Wake up'),
          Action(name: 'Brush teeth'),
          Action(name: 'Eat breakfast'),
        ],
      ),
      Routine(
        name: 'Work Routine',
        actions: [
          Action(name: 'Check emails'),
          Action(name: 'Team meeting'),
          Action(name: 'Complete tasks'),
        ],
      ),
      Routine(
        name: 'Evening Routine',
        actions: [
          Action(name: 'Cook dinner'),
          Action(name: 'Watch TV'),
          Action(name: 'Read a book'),
        ],
      ),
    ];

    for (var routine in routines) {
      final instances = [
        RoutineInstance(
          name: '${routine.name} - Instance 1',
          routine: routine,
          dueDate: DateTime.now().add(Duration(days: 1)),
          actionInstances: [],
        ),
        RoutineInstance(
          name: '${routine.name} - Instance 2',
          routine: routine,
          dueDate: DateTime.now().add(Duration(days: 2)),
          actionInstances: [],
        ),
      ];

      for (var instance in instances) {
        instance.actionInstances.addAll(
          routine.actions.map((action) => ActionInstance(
                routineInstance: instance,
                action: action,
                assigneeUserId:
                    users[routine.actions.indexOf(action) % users.length]
                        .userId,
                dueDate: instance.dueDate
                    .add(Duration(hours: routine.actions.indexOf(action))),
              )),
        );
      }

      routine.instances.addAll(instances);
    }

    return routines;
  }
}
