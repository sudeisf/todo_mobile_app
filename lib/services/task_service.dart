import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/tasks.dart';



class TaskService {
    static const String _taskKey  = 'tasks';

    Future<List<Task>> loadTasks() async {
      try {
        SharedPreferences pref = await SharedPreferences.getInstance();
        String? taskData = pref.getString(_taskKey);
        if (taskData  != null && taskData.isNotEmpty) {
          List<dynamic> jsonList = jsonDecode(taskData);
          return jsonList.map((json) => Task.fromJson(json)).toList();
        }
      }catch (e) {
        print("Error loading tasks: $e");
      }
      return [] ;
      }

    Future<void>  saveTasks (List<Task> tasks) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String jsonString = json.encode(tasks.map((task) => task.toJson()).toList());
      prefs.setString(_taskKey, jsonString);
     }
}
    



