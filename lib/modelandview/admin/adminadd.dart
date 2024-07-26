import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminAddProject extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _AdminAddProjectState createState() => _AdminAddProjectState();
}

class _AdminAddProjectState extends State<AdminAddProject> {
  final TextEditingController _projectNameController = TextEditingController();
  final TextEditingController _taskController = TextEditingController();
  final List<String> _tasks = [];
  final List<String> _assignedDep = [];
  final List<String> Departments = [
    'Maintance ',
    'Security',
    'Electrique et Mécanique'
  ];

  DateTime? _startDate;
  DateTime? _endDate;

  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  void _addTask() {
    if (_taskController.text.isNotEmpty) {
      setState(() {
        _tasks.add(_taskController.text);
        _taskController.clear();
      });
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (selectedDate != null &&
        selectedDate != (isStartDate ? _startDate : _endDate)) {
      setState(() {
        if (isStartDate) {
          _startDate = selectedDate;
        } else {
          _endDate = selectedDate;
        }
      });
    }
  }

  Map<String, dynamic> castToMap(List<String> list) {
    Map<String, dynamic> map = {};
    for (int i = 0; i < list.length; i++) {
      map[(i + 1).toString()] = list[i];
    }
    return map;
  }

  Map<String, dynamic> ToTask(List<String> list) {
    Map<String, dynamic> map = {};
    for (int i = 0; i < list.length; i++) {
      map[(i + 1).toString()] = {'name': list[i], 'state': "not_yet"};
    }
    return map;
  }

  void saveProject() async {
    try {
      Map<String, dynamic> map = castToMap(_assignedDep);
      Map<String, dynamic> map1 = {
        "name": _projectNameController.text,
        "start": _dateFormat.format(_startDate!),
        "end": _dateFormat.format(_endDate!),
        "tasks": _tasks.length.toString()
      };

      map1.addAll(map);
      DocumentReference pro =
          await FirebaseFirestore.instance.collection("projects").add(map1);
      print("Document ajouté avec ID: ${pro.id}");

      try {
        await FirebaseFirestore.instance
            .collection("projects")
            .doc(pro.id)
            .collection("Tasks")
            .add(ToTask(_tasks))
            .then((value) {
          print("Document ajouté avec ID: ${value.id}");
        }).catchError((error) {
          AwesomeDialog(
            context: context,
            dialogType: DialogType.error,
            animType: AnimType.rightSlide,
            title: 'Error',
            desc: error.toString(),
          ).show();
        });
      } catch (e) {
        AwesomeDialog(
          context: context,
          dialogType: DialogType.error,
          animType: AnimType.rightSlide,
          title: 'Error',
          desc: e.toString(),
        ).show();
      }

      map.clear();
      map1.clear();
      _projectNameController.clear();
      _tasks.clear();

      // Mise à jour de l'état de l'interface utilisateur
      setState(() {
        _assignedDep.clear();
        _startDate = null;
        _endDate = null;
      });
    } catch (e) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        animType: AnimType.rightSlide,
        title: 'Error',
        desc: e.toString(),
      ).show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Project'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nom du projet
            TextField(
              controller: _projectNameController,
              decoration: InputDecoration(
                labelText: 'Project Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),

            // Date de début
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Start Date: ${_startDate != null ? _dateFormat.format(_startDate!) : 'Not set'}',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context, true),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Date de fin
            Row(
              children: [
                Expanded(
                  child: Text(
                    'End Date: ${_endDate != null ? _dateFormat.format(_endDate!) : 'Not set'}',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDate(context, false),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Ajouter des tâches
            TextField(
              controller: _taskController,
              decoration: InputDecoration(
                labelText: 'New Task',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: _addTask,
              child: Text('Add Task'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
            ),
            SizedBox(height: 16),

            // Liste des tâches
            Text(
              'Tasks',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_tasks[index]),
                  );
                },
              ),
            ),
            SizedBox(height: 16),

            // Attribuer des ouvriers
            Text(
              'Assign Department',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: Departments.length,
                itemBuilder: (context, index) {
                  return CheckboxListTile(
                    title: Text(Departments[index]),
                    value: _assignedDep.contains(Departments[index]),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          _assignedDep.add(Departments[index]);
                        } else {
                          _assignedDep.remove(Departments[index]);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 16),

            // Bouton d'enregistrement
            ElevatedButton(
              onPressed: () {
                saveProject();
              },
              child: Text('Save Project'),
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
