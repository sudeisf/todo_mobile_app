

class Task {
  String title;
  bool isCompleted ;

  Task({required this.title, this.isCompleted = false});

  // Convert Task object to Map for SharedPreferences storage
  Map<String, dynamic> toJson () {
    return {
      'title' : title ,
      'isCompleted' : isCompleted
    };
  }

  // Convert Map to Task object
  factory Task.fromJson (Map<String , dynamic> json) {
    return Task(title: json['title'] ,isCompleted: json['isCompleted']);
  }
}