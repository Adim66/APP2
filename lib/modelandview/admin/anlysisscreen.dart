import 'package:flutter/material.dart';
import 'package:flutter_application_2/modelandview/projects/projectdelais.dart';

class AnalysisAdmin extends StatelessWidget {
  final List<Map<String, dynamic>> projects = [
    {
      'name': 'Project 1',
      'tasks': [
        {'task': 'Task 1', 'completed': true},
        {'task': 'Task 2', 'completed': false},
        {'task': 'Task 3', 'completed': true},
      ],
    },
    {
      'name': 'Project 2',
      'tasks': [
        {'task': 'Task 1', 'completed': true},
        {'task': 'Task 2', 'completed': true},
        {'task': 'Task 3', 'completed': false},
      ],
    },
  ];

  double calculateCompletionPercentage(List<Map<String, dynamic>> tasks) {
    int totalTasks = tasks.length;
    int completedTasks = tasks.where((task) => task['completed']).length;
    return totalTasks == 0 ? 0 : (completedTasks / totalTasks) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Project Analysis"),
        backgroundColor: Colors.blue,
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16.0),
        itemCount: projects.length,
        itemBuilder: (context, index) {
          var project = projects[index];
          var percentage = calculateCompletionPercentage(project['tasks']);

          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            margin: EdgeInsets.symmetric(vertical: 8.0),
            child: ListTile(
              title: Text(project['name']),
              subtitle: Text('Completion: ${percentage.toStringAsFixed(1)}%'),
              trailing: Icon(Icons.assessment, color: Colors.blue),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProjectDetailPage(project: project),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
