import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class StatisticsPage extends StatefulWidget {
  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  String selectedDepartment = "All";
  List<QueryDocumentSnapshot> projects = [];
  double a = 0;
  double b = 0;
  double c = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProjects();
  }

  loadProjects() async {
    QuerySnapshot collref =
        await FirebaseFirestore.instance.collection("projects").get();
    List<QueryDocumentSnapshot> list = collref.docs;
    projects.addAll(list);

    // Count projects per department
    for (var project in list) {
      if (project["electrique and mecanique"] == true) {
        a += 1;
      }
      if (project["security"] == true) {
        b += 1;
      }
      if (project["maintenance"] == true) {
        c += 1;
      }
    }

    setState(() {
      isLoading = false; // Update state to rebuild with new data
    });
  }

  List<PieChartSectionData> _buildPieChartSections() {
    final totalProjects = a + b + c;
    if (totalProjects == 0) return [];

    return [
      PieChartSectionData(
        value: (a / totalProjects) * 100,
        title: '${((a / totalProjects) * 100).toString()}% elec and mecanique',
        color: Colors.blue,
        radius: 100,
        titleStyle: TextStyle(color: Colors.white, fontSize: 16),
      ),
      PieChartSectionData(
        value: (b / totalProjects) * 100,
        title: '${((b / totalProjects) * 100).toString()} % Security',
        color: Colors.red,
        radius: 100,
        titleStyle: TextStyle(color: Colors.white, fontSize: 16),
      ),
      PieChartSectionData(
        value: (c / totalProjects) * 100,
        title: '${((c / totalProjects) * 100).toString()}% Maintenance',
        color: Colors.green,
        radius: 100,
        titleStyle: TextStyle(color: Colors.white, fontSize: 16),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Project Statistics"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("lib/assets/Knauf-usine-belgique-1319x800.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            isLoading
                ? Center(child: CircularProgressIndicator())
                : _buildPieChart(),
            _buildDepartmentFilter(),
            _buildProjectList(),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    return Container(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: _buildPieChartSections(),
          borderData: FlBorderData(show: false),
          centerSpaceRadius: 0,
        ),
      ),
    );
  }

  Widget _buildDepartmentFilter() {
    return DropdownButton<String>(
      value: selectedDepartment,
      onChanged: (String? newValue) {
        setState(() {
          selectedDepartment = newValue!;
        });
      },
      items: <String>[
        'All',
        'electrique and mecanique',
        'security',
        'maintenance'
      ].map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  Widget _buildProjectList() {
    List<QueryDocumentSnapshot> filteredProjects = selectedDepartment == "All"
        ? projects
        : projects
            .where((project) => project[selectedDepartment] == true)
            .toList();

    return Expanded(
      child: ListView.builder(
        itemCount: filteredProjects.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(filteredProjects[index]['name']),
            subtitle: Text(
                "Start: ${filteredProjects[index]['start']} - End: ${filteredProjects[index]['end']}"),
            onTap: () {
              _showProjectDetails(filteredProjects[index]);
            },
          );
        },
      ),
    );
  }

  void _showProjectDetails(QueryDocumentSnapshot project) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProjectDetailsPage(project: project),
      ),
    );
  }
}

class ProjectDetailsPage extends StatefulWidget {
  final QueryDocumentSnapshot project;

  ProjectDetailsPage({required this.project});

  @override
  _ProjectDetailsPageState createState() => _ProjectDetailsPageState();
}

class _ProjectDetailsPageState extends State<ProjectDetailsPage> {
  List<QueryDocumentSnapshot> list_of_tasks = [];
  List<QueryDocumentSnapshot> comments = [];
  bool isLoading = true;

  List<BarChartGroupData> barGroups = [];

  loadTasks() async {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection("projects")
        .doc(widget.project.id)
        .collection("Tasks")
        .get();
    list_of_tasks.addAll(query.docs);

    for (int i = 0; i < list_of_tasks.length; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: list_of_tasks[0][(i + 1).toString()]["who_finish"]
                  .length
                  .toDouble(),
              color: const Color.fromARGB(255, 28, 80, 169),
              width: 15,
              borderRadius: BorderRadius.circular(5),
            ),
          ],
        ),
      );
    }

    QuerySnapshot q = await FirebaseFirestore.instance
        .collection("projects")
        .doc(widget.project.id)
        .collection("Tasks")
        .doc(list_of_tasks[0].id)
        .collection("comments")
        .get();
    comments.addAll(q.docs);

    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.project['name']),
        backgroundColor: Colors.blueAccent,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      "lib/assets/Knauf-usine-belgique-1319x800.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                children: [
                  Text("Project Start: ${widget.project['start']}"),
                  Text("Project End: ${widget.project['end']}"),
                  isLoading == true
                      ? CircularProgressIndicator()
                      : Container(
                          height: 300,
                          child: BarChart(
                            BarChartData(
                              gridData: FlGridData(show: true),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        value.toInt().toString(),
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      );
                                    },
                                    interval: 1,
                                  ),
                                  axisNameWidget: Text(
                                    'Number of Achievements',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  axisNameSize: 30,
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                    getTitlesWidget: (value, meta) {
                                      if (value >= 0 &&
                                          value < list_of_tasks.length) {
                                        return Text(
                                          '${list_of_tasks[0][(value.toInt() + 1).toString()]["name"]}',
                                          style: TextStyle(
                                            color: Color.fromARGB(
                                                255, 24, 137, 243),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        );
                                      } else {
                                        return Text('');
                                      }
                                    },
                                    interval: 1,
                                  ),
                                  axisNameWidget: Text(
                                    'Tasks',
                                    style: TextStyle(
                                      color: Color.fromARGB(255, 230, 79, 10),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  axisNameSize: 30,
                                ),
                              ),
                              borderData: FlBorderData(show: true),
                              minY: 0,
                              maxY: 20,
                              barGroups: barGroups,
                            ),
                          ),
                        ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: comments.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          margin:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ListTile(
                            title: Text(
                              "${comments[index]["comment"]}",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Row(
                              children: [
                                Text("${comments[index]["By"]}"),
                                SizedBox(width: 5),
                                Text("Task:"),
                                SizedBox(width: 5),
                                Text("${comments[index]["task"]["name"]}"),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
