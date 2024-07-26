import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/modelandview/workers/taskpage.dart';

class StaffScreen extends StatefulWidget {
  @override
  State<StaffScreen> createState() => _StaffScreenState();
}

class _StaffScreenState extends State<StaffScreen> {
  List<QueryDocumentSnapshot> projects = [];
  bool notfetched = true;
  var collref;
  getproject() async {
    CollectionReference users = FirebaseFirestore.instance.collection("Users");
    QuerySnapshot userwithid = await users
        .where("id", isEqualTo: FirebaseAuth.instance.currentUser?.uid)
        .get();
    String dep = userwithid.docs[0]["dep"];

    CollectionReference collref =
        FirebaseFirestore.instance.collection("projects");
    QuerySnapshot loadprojcts =
        await collref.where("dep", isEqualTo: dep).get();
    projects.clear();
    projects.addAll(loadprojcts.docs);
    notfetched = false;
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getproject();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Staff Projects"),
        backgroundColor: Colors.blue,
      ),
      body: notfetched
          ? CircularProgressIndicator(
              color: Colors.blue,
            )
          : ListView.builder(
              padding: EdgeInsets.all(16.0),
              itemCount: projects.length,
              itemBuilder: (context, index) {
                var project = projects[index];

                return Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  margin: EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(project['name']),
                    trailing: Icon(Icons.assignment, color: Colors.blue),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TaskDetailPage(
                              project: project, nd_of_tasks: project["name"]),
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
