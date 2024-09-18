import 'package:flutter/material.dart';
import 'widgets/zelk_filtered_list_view.dart';
import 'models.dart';

class InstancePage extends StatefulWidget {
  final RoutineInstance instance;

  const InstancePage({super.key, required this.instance});

  @override
  State<InstancePage> createState() => _InstancePageState();
}

class _InstancePageState extends State<InstancePage> {
  late List<ActionInstance> _allItems;
  late List<ActionInstance> _filteredItems;

  @override
  void initState() {
    super.initState();
    _allItems = widget.instance.actionInstances;
    _filteredItems = _allItems;
  }

  void _filterItems(String value) {
    setState(() {
      _filteredItems = _allItems
          .where((instance) =>
              instance.comment.toLowerCase().contains(value.toLowerCase()) ||
              instance.action.name.toLowerCase().contains(value.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.instance.name),
      ),
      body: Column(
        children: [
          Expanded(
            child: ZelkFilteredListView(
              itemCount: _filteredItems.length,
              filter: _filterItems,
              onItemTap: (index) {},
              itemBuilder: (context, index, hasFocus) {
                final actionInstance = _filteredItems[index];
                return ListTile(
                  tileColor: hasFocus ? Colors.blue.withOpacity(0.5) : null,
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
