import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdminAddProject extends StatefulWidget {
  @override
  _AdminAddProjectState createState() => _AdminAddProjectState();
}

class _AdminAddProjectState extends State<AdminAddProject> {
  final TextEditingController _projectNameController = TextEditingController();
  final TextEditingController _taskController = TextEditingController();
  final List<String> _tasks = [];
  final List<String> _assignedDep = [];
  final List<String> Departments = [
    'maintenance ',
    'security',
    'electrique and mecanique'
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
      map[(i + 1).toString()] = {
        'name': list[i],
        'state': false,
        "who_finish": []
      };
    }
    return map;
  }

  void saveProject() async {
    bool main = false;
    bool sec = false;
    bool ele_mec = false;

    try {
      Map<String, dynamic> map = castToMap(_assignedDep);
      late Map<String, dynamic> map1 = {};
      if (_assignedDep.contains("maintenance")) {
        main = true;
      }
      if (_assignedDep.contains("security")) {
        sec = true;
      }
      if (_assignedDep.contains("electrique and mecanique")) {
        ele_mec = true;
      }

      map1 = {
        "maintenance": main,
        "security": sec,
        "electrique and mecanique": ele_mec,
        "name": _projectNameController.text,
        "start": _dateFormat.format(_startDate!),
        "end": _dateFormat.format(_endDate!),
        "tasks": _tasks.length,
        "Superviser": FirebaseAuth.instance.currentUser!.email
      };

      DocumentReference pro =
          await FirebaseFirestore.instance.collection("projects").add(map1);

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
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Project'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        // Wrap the entire content in SingleChildScrollView
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _projectNameController,
                decoration: InputDecoration(
                  labelText: 'Project Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: screenWidth * 0.04),
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
              SizedBox(height: screenWidth * 0.04),
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
              SizedBox(height: screenWidth * 0.04),
              TextField(
                controller: _taskController,
                decoration: InputDecoration(
                  labelText: 'New Task',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: screenWidth * 0.02),
              ElevatedButton(
                onPressed: _addTask,
                child: Text('Add Task'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
              ),
              SizedBox(height: screenWidth * 0.04),
              Text(
                'Tasks',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: screenWidth * 0.02),
              ListView.builder(
                shrinkWrap:
                    true, // Ensures the ListView takes up only the needed space
                physics:
                    NeverScrollableScrollPhysics(), // Disable scrolling for ListView
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_tasks[index]),
                  );
                },
              ),
              SizedBox(height: screenWidth * 0.04),
              Text(
                'Assign Department',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: screenWidth * 0.02),
              ListView.builder(
                shrinkWrap:
                    true, // Ensures the ListView takes up only the needed space
                physics:
                    NeverScrollableScrollPhysics(), // Disable scrolling for ListView
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
              SizedBox(height: screenWidth * 0.04),
              ElevatedButton(
                onPressed: saveProject,
                child: Text('Save Project'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(vertical: screenWidth * 0.04),
                ),
              ),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Finished"))
            ],
          ),
        ),
      ),
    );
  }
}
