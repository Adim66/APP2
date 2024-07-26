// ignore: depend_on_referenced_packages
import 'package:fl_chart/fl_chart.dart'; // Ajouter le package fl_chart à pubspec.yaml pour les graphiques
import 'package:flutter/material.dart';

class ProjectDetailPage extends StatefulWidget {
  final Map<String, dynamic> project;

  const ProjectDetailPage({Key? key, required this.project}) : super(key: key);

  @override
  _ProjectDetailPageState createState() => _ProjectDetailPageState();
}

class _ProjectDetailPageState extends State<ProjectDetailPage> {
  final List<Map<String, String>> comments = [
    {'author': 'Admin', 'comment': 'Great progress!', 'response': ''},
    {
      'author': 'Worker 1',
      'comment': 'Encountered issues with Task 2.',
      'response': ''
    },
  ];

  void _showCommentDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController commentController = TextEditingController();
        return AlertDialog(
          title: Text('Add Comment'),
          content: TextField(
            controller: commentController,
            decoration: InputDecoration(hintText: 'Enter your comment'),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  comments.add({
                    'author': 'Admin',
                    'comment': commentController.text,
                    'response': '',
                  });
                });
                Navigator.of(context).pop();
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void _showResponseDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController responseController =
            TextEditingController();
        return AlertDialog(
          title: Text('Respond to Comment'),
          content: TextField(
            controller: responseController,
            decoration: InputDecoration(hintText: 'Enter your response'),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  comments[index]['response'] = responseController.text;
                });
                Navigator.of(context).pop();
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var project = widget.project;
    var tasks = project['tasks'] as List<Map<String, dynamic>>;

    double calculateCompletionPercentage(List<Map<String, dynamic>> tasks) {
      int totalTasks = tasks.length;
      int completedTasks = tasks.where((task) => task['completed']).length;
      return totalTasks == 0 ? 0 : (completedTasks / totalTasks) * 100;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(project['name']),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Graphique de l'évolution des tâches
            Container(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: tasks.asMap().entries.map((entry) {
                        int index = entry.key;
                        Map<String, dynamic> task = entry.value;
                        return FlSpot(
                            index.toDouble(), task['completed'] ? 1 : 0);
                      }).toList(),
                      isCurved: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Liste des commentaires
            Text(
              'Comments',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  var comment = comments[index];
                  return Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(comment['author']!),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(comment['comment']!),
                          if (comment['response']!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                'Response: ${comment['response']}',
                                style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    color: Colors.blueGrey),
                              ),
                            ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.reply, color: Colors.blue),
                        onPressed: () => _showResponseDialog(index),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),

            // Ajouter un commentaire
            ElevatedButton(
              onPressed: _showCommentDialog,
              child: Text('Add Comment'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
