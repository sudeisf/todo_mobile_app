

import "package:flutter/material.dart";
import 'package:shared_preferences/shared_preferences.dart';


void main () => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "To-Do App",
      theme: ThemeData(primarySwatch: Colors.blue),
      home: TodoScreen(),
    );
  }
}


class TodoScreen extends StatefulWidget {
   @override
   _TodoScreenState createState () => _TodoScreenState();


  }


  class _TodoScreenState extends State<TodoScreen> {

      List<String> _tasks = [] ;
      List<bool> _isSelectedList = [false ,false, false];
      bool _isSelectionModeActive = false ;

      void _togleSlectionMode() {
        setState(() {
          _isSelectionModeActive = !_isSelectionModeActive ;
          if(!_isSelectionModeActive) {
            _isSelectedList = List.filled(_isSelectedList.length, false);
          }
        });
      }

      void _toggleSelection(int index) {
          setState(() {
            _isSelectedList[index] = ! _isSelectedList[index] ;
          });
      }

      void _exitSelectionMode() {
        setState(() {
          _isSelectionModeActive = false; // Exit selection mode
          _isSelectedList = List.filled(_isSelectedList.length, false); // Clear all selections
        });
      }

      TextEditingController _taskController = TextEditingController() ;
      void _showAddTaskDialog() {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("add Task"),
              content: TextField(
                controller: _taskController,
                decoration: InputDecoration(hintText: "Enter Task"),
              ),
              actions: [
                TextButton(
                    child: Text("cancel"),
                    onPressed: (){
                      Navigator.of(context).pop();
                      _taskController.clear();
                      }
            ),
                TextButton(
                child: Text("Add"),
                onPressed: (){
                  if(_taskController.text.isNotEmpty) {
                     setState(() {
                      _addTask(_taskController.text);
                      _isSelectedList.add(false);
            });
            Navigator.of(context).pop();
            _taskController.clear();
            }
            },
            
            ),

              ]
            );
            
          }
        );
      }

      void _loadTasks() async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        setState(() {
          _tasks = prefs.getStringList('tasks') ?? [];
        });
      }

      void _saveTasks () async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setStringList("tasks", _tasks);
      }

      void _addTask(String task) {
        setState(() {
          _tasks.add(task);
        });
        _saveTasks();
      }

      void _removeTask(int index) {
        setState(() {
          _tasks.removeAt(index);
        });
        _saveTasks();
      }
      @override
      void initState() {
        super.initState();
        _loadTasks(); // Load saved tasks when the app starts
      }


      @override
      Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text("To-Do list"),
        actions: [
          if (_isSelectionModeActive)
            IconButton(
              icon: Icon(Icons.done),
              onPressed: _exitSelectionMode, // Exit selection mode
            ),
        ],
      ),

      body: ListView.builder(
        itemCount: _tasks.length,
        padding: EdgeInsets.all(10),

        itemBuilder: (context , index) {
          return Column(
            children: [
          ListTile(
          title: Text(_tasks[index][0].toUpperCase() + _tasks[index].substring(1) ,style: TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontFamily: 'Roboto',
            fontStyle: FontStyle.normal,
          )),
          selected: _isSelectedList[index],
          tileColor: Colors.black,
          trailing: IconButton(
          icon: Icon(Icons.delete , color: Colors.white54),
          onPressed: () {
          setState(() {
          _removeTask(index);
          });
          },
          ),
          selectedTileColor: Colors.red[900],
          shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)
          ),
          contentPadding: EdgeInsets.all(16),
          dense: true,
            onTap: () {
            if(_isSelectionModeActive){
              _toggleSelection(index);
            }
            },
            onLongPress: () {
                if(!_isSelectionModeActive){
                  _togleSlectionMode();
                  _toggleSelection(index);
                }
            },


          ),
              SizedBox(height: 10,)
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: Colors.black,
        shape: CircleBorder(),
      ),
    );
  }
  }
