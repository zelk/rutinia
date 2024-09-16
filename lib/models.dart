import 'dart:math';

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

class RoutineAction {
  final String name;

  RoutineAction({required this.name});
}

class Routine {
  final String id;
  final String name;
  final List<RoutineAction> actions;
  final List<RoutineInstance> instances;

  Routine({
    required this.id,
    required this.name,
    required this.actions,
    List<RoutineInstance>? instances,
  }) : instances = instances ?? [];
}

class ActionInstance {
  final RoutineInstance routineInstance;
  final RoutineAction action;
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
        id: Random().nextInt(999999999).toString(),
        name: 'Employee Onboarding',
        actions: [
          RoutineAction(name: 'Create user in Active Directory'),
          RoutineAction(name: 'Create user in Azure AD'),
          RoutineAction(name: 'Create user in Google Workspace'),
          RoutineAction(name: 'Leave a welcome message in Slack'),
          RoutineAction(name: 'Send welcome email to user'),
          RoutineAction(name: 'Add user to Microsoft Teams'),
          RoutineAction(name: 'Add user to Zoom'),
          RoutineAction(name: 'Post about hire on LinkedIn'),
        ],
      ),
      Routine(
        id: Random().nextInt(999999999).toString(),
        name: 'Employee Offboarding',
        actions: [
          RoutineAction(name: 'Remove user from Active Directory'),
          RoutineAction(name: 'Remove user from Azure AD'),
          RoutineAction(name: 'Remove user from Google Workspace'),
          RoutineAction(name: 'Remove user from Microsoft Teams'),
          RoutineAction(name: 'Remove user from Zoom'),
          RoutineAction(name: 'Remove user from LinkedIn'),
          RoutineAction(name: 'Remove user from Slack'),
          RoutineAction(name: 'Remove user from email'),
          RoutineAction(name: 'Remove user from phone'),
          RoutineAction(name: 'Take care of physical access'),
          RoutineAction(name: 'Take possession of equipment'),
          RoutineAction(name: 'Take possession of company car (SUB PROCESS)'),
        ],
      ),
      Routine(
        id: Random().nextInt(999999999).toString(),
        name: 'MNDA',
        actions: [
          RoutineAction(name: 'Open bolago.se'),
          RoutineAction(name: 'Login'),
          RoutineAction(name: 'Make sure that you\'re on the right company'),
          RoutineAction(name: 'Find the right document template'),
          RoutineAction(name: 'Prepare the document'),
          RoutineAction(name: 'Sign the document'),
        ],
      ),
    ];

    for (var routine in routines) {
      final instances = users
          .map((user) => RoutineInstance(
                name: '${user.firstName} ${user.lastName} (${routine.name})',
                routine: routine,
                dueDate:
                    DateTime.now().add(Duration(days: users.indexOf(user) + 1)),
                actionInstances: [],
              ))
          .toList();

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
