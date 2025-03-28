// lib/screens/todo_screen.dart
import 'package:flutter/material.dart';
import '../models/tasks.dart';
import '../services/task_service.dart';
import '../widgets/task_tile.dart';
import '../widgets/custom_bottom_sheet.dart'; // Import the new bottom sheet
import '../widgets/sidebar.dart' ;
import '../widgets/mapScreen.dart';


class TodoScreen extends StatefulWidget {
  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final TaskService _taskService = TaskService();
  List<Task> _tasks = [];
  bool _isSelectionModeActive = false;
  List<bool> _isSelectedList = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _isSelectedList = [];
  }

  Future<void> _loadTasks() async {
    List<Task> tasks = await _taskService.loadTasks();
    setState(() {
      _tasks = tasks;
      _isSelectedList = List.from(List.filled(tasks.length, false));
    });
  }

  Future<void> _addTask(String title) async {
    setState(() {
      _tasks.add(Task(title: title));
      _isSelectedList.add(false);
    });
    await _taskService.saveTasks(_tasks);
  }

  Future<void> _removeTask(int index) async {
    setState(() {
      _tasks.removeAt(index);
      _isSelectedList.removeAt(index);
    });
    await _taskService.saveTasks(_tasks);
  }

  void _toggleSelectionMode() {
    setState(() {
      _isSelectionModeActive = !_isSelectionModeActive;
      if (!_isSelectionModeActive) {
        _isSelectedList = List.filled(_tasks.length, false);
      }
    });
  }

  void _toggleSelection(int index) {
    setState(() {
      _isSelectedList[index] = !_isSelectedList[index];
    });
  }

  void _showAddTaskBottomSheet() {
    final TextEditingController taskController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Make the background transparent
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, // Adjust for keyboard
          ),
          child: CustomBottomSheet(
            controller: taskController,
            onSave: () {
              if(taskController.text.isNotEmpty){
                _addTask(taskController.text);
                Navigator.pop(context);
              }
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("To-Do List"),
        actions: [
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EnhancedRoutePlanner()),
              );
            },
          ),
          if (_isSelectionModeActive)
            IconButton(
              icon: const Icon(Icons.done),
              onPressed: _toggleSelectionMode,
            ),
        ],
      ),
      drawer: Drawer(
        child: Sidebar(),
      )
      ,
      body: ListView.builder(
        itemCount: _tasks.length,
        padding: const EdgeInsets.all(10),
        itemBuilder: (context, index) {
          return TaskTile(
            task: _tasks[index],
            isSelected: _isSelectedList[index],
            onTap: () {
              if (_isSelectionModeActive) {
                _toggleSelection(index);
              }
            },
            onLongPress: () {
              if (!_isSelectionModeActive) {
                _toggleSelectionMode();
                _toggleSelection(index);
              }
            },
            onDelete: () => _removeTask(index),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskBottomSheet,
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.black,
      ),
    );
  }
}