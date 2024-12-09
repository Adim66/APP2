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
  bool isloading = true;
  List<bool> picked = [];
  @override
  void initState() {
    super.initState();

    print(widget.nd_of_tasks);
    for (int i = 0; i < widget.nd_of_tasks; i++) {
      _commentControllers[i] = TextEditingController();
    }
    loadtasks();
  }

  Future<void> updateTask(
      {required String collectionName,
      required String documentId,
      required String fieldName,
      required Map newValue}) async {
    try {
      print("innnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn");
      print(newValue);
      await FirebaseFirestore.instance
          .collection("projects")
          .doc(widget.project.id)
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
          title: Text(
              'Ask for help or needs for ${tasks[0][(index + 1).toString()]["name"]}'),
          content: TextField(
            controller: _commentControllers[index],
            decoration:
                InputDecoration(hintText: 'Enter your opinion / trouble /'),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () {
                addComment(s: _commentControllers[index]!.text, index: index);

                Navigator.of(context).pop();
              },
              child: Text('Submit Your Comment'),
            ),
          ],
        );
      },
    );
  }

  List<QueryDocumentSnapshot> tasks = [];
  late String taskforcmts;

  loadtasks() async {
    print(widget.project.id);
    QuerySnapshot list = await FirebaseFirestore.instance
        .collection("projects")
        .doc(widget.project.id)
        .collection("Tasks")
        .get();
    tasks = list.docs;

    taskforcmts = tasks[0].id;
    isloading = false;
    for (int i = 0; i < widget.nd_of_tasks; i++) {
      if (tasks[0][(i + 1).toString()]["who_finish"]
          .contains(FirebaseAuth.instance.currentUser!.email)) {
        picked.add(true);
      } else {
        picked.add(false);
      }
    }
    print(picked.length);
    setState(() {});
  }

  Future addComment({required String s, required int index}) async {
    print("hhhh");
    print(taskforcmts);
    await FirebaseFirestore.instance
        .collection("projects")
        .doc(widget.project.id)
        .collection("Tasks")
        .doc(taskforcmts)
        .collection("comments")
        .add({
      "task": tasks[0][(index + 1).toString()],
      "comment": s,
      "By": FirebaseAuth.instance.currentUser?.email
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project['name'], style: TextStyle(fontSize: 20)),
        backgroundColor: const Color.fromARGB(255, 102, 157, 202),
        centerTitle: true,
      ),
      body: isloading
          ? CircularProgressIndicator()
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: widget.nd_of_tasks,
                itemBuilder: (context, inkdex) {
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    margin: EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text(tasks[0][(inkdex + 1).toString()]['name']),
                      trailing: Checkbox(
                        value: picked[inkdex],
                        onChanged: (bool? value) {
                          if (value == true) {
                            List<String> list = [
                              "${FirebaseAuth.instance.currentUser!.email}"
                            ];

                            for (int i = 0;
                                i <
                                    tasks[0][(inkdex + 1).toString()]
                                            ['who_finish']
                                        .length;
                                i++) {
                              list.add(tasks[0][(inkdex + 1).toString()]
                                      ['who_finish'][i]
                                  .toString());
                            }
                            bool state = false;
                            if (list.length == 10) {
                              state = true;
                            }
                            Map map = {
                              "name":
                                  "${tasks[0][(inkdex + 1).toString()]["name"]}",
                              "state": state,
                              "who_finish": list
                            };
                            updateTask(
                                collectionName: "Tasks",
                                documentId: tasks[0].id,
                                fieldName: (inkdex + 1).toString(),
                                newValue: map);
                            picked[inkdex] = !picked[inkdex];
                            setState(() {});
                          }
                        },
                      ),
                      onTap: () => _showTaskCommentDialog(inkdex),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
