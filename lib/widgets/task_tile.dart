import 'package:flutter/material.dart';
import '../models/tasks.dart';


class TaskTile extends StatelessWidget {
  final Task task;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onDelete;

  TaskTile({
    required this.task,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: Text(
            task.title[0].toUpperCase() + task.title.substring(1),
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
          selected: isSelected,
          tileColor: Colors.black,
          trailing: IconButton(
            icon: Icon(Icons.delete, color: Colors.white54),
            onPressed: onDelete,
          ),
          selectedTileColor: Colors.red[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding: EdgeInsets.all(16),
          dense: true,
          onTap: onTap,
          onLongPress: onLongPress,
        ),
        SizedBox(height: 10),
      ],
    );
  }
}


