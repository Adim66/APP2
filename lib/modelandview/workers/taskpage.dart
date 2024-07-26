import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TaskDetailPage extends StatefulWidget {
  final QueryDocumentSnapshot project;
  final int nd_of_tasks;

  const TaskDetailPage(
      {Key? key, required this.project, required this.nd_of_tasks})
      : super(key: key);

  @override
  _TaskDetailPageState createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  final Map<int, TextEditingController> _commentControllers = {};

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.nd_of_tasks; i++) {
      _commentControllers[i] = TextEditingController();
    }
  }

  Future<void> updateTask(
      {required String collectionName,
      required String documentId,
      required String fieldName,
      required dynamic newValue}) async {
    try {
      await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(documentId)
          .update({fieldName: newValue});
      print("Field updated successfully");
    } catch (e) {
      print("Error updating field: $e");
    }
  }

  void _showTaskCommentDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Comment for ${tasks[0][index]["name"]}'),
          content: TextField(
            controller: _commentControllers[index],
            decoration: InputDecoration(hintText: 'Enter your comment'),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () {
                addComment(s: _commentControllers[index]!.text, index: index);

                Navigator.of(context).pop();
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> tasks = [];
  late String taskforcmts;
  loadtasks() async {
    var ltasks = await FirebaseFirestore.instance
        .doc(widget.project.id)
        .collection("tasks")
        .get();
    tasks = ltasks.docs;
    taskforcmts = tasks[0].id;
  }

  Future addComment({required String s, required int index}) async {
    await FirebaseFirestore.instance
        .doc(widget.project.id)
        .collection("tasks")
        .doc(taskforcmts)
        .collection("comments")
        .add({
      "task": tasks[0][index],
      "comment ": s,
      "By": FirebaseAuth.instance.currentUser?.email
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project['name']),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: widget.nd_of_tasks,
          itemBuilder: (context, index) {
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: ListTile(
                title: Text(tasks[0][index]['name']),
                trailing: Checkbox(
                  value: tasks[0][index]['name'],
                  onChanged: (bool? value) {
                    if (value == true) {
                      updateTask(
                          collectionName: "Tasks",
                          documentId: tasks[0].id,
                          fieldName: "state",
                          newValue: "done");
                    }
                  },
                ),
                onTap: () => _showTaskCommentDialog(index),
              ),
            );
          },
        ),
      ),
    );
  }
}
