import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/components/textforms.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController username = TextEditingController();
  TextEditingController userprename = TextEditingController();
  TextEditingController Phone = TextEditingController();
  late String usertype;
  late String dep;
  bool tappedemployer = false;
  bool tappedadmin = false;
  bool tappedclient = false;
  bool tappeddist = false;

  void ajouterUser(
      {required String user_id,
      required String client_type,
      required String Phone}) async {
    CollectionReference coll =
        await FirebaseFirestore.instance.collection("Users");
    if (client_type == "Employer") {
      DocumentReference doc = await coll.add(
          {"id": user_id, "type": client_type, "dep": dep, "Phone_Num": Phone});
    } else {
      await coll.add({"id": user_id, "type": client_type, "Phone_Num": Phone});
    }
  }

  cheched(int i) {
    switch (i) {
      case (1):
        tappedemployer = !tappedemployer;
        break;
      case (2):
        tappedadmin = !tappedadmin;
        break;
      case (3):
        tappedclient = !tappedclient;
        break;
      case (4):
        tappeddist = !tappeddist;
    }
    setState(() {});
  }

  verify() async {
    await FirebaseAuth.instance.currentUser!.sendEmailVerification();
    AwesomeDialog(
            context: context,
            dialogType: DialogType.success,
            animType: AnimType.rightSlide,
            title: 'Sucsess',
            desc: 'You are Signed Up ! , Try to Login Know ')
        .show();

    Navigator.of(context).pushNamed("login");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            "",
            style: TextStyle(fontSize: 14),
          ),
        ),
        body: Container(
            padding: EdgeInsets.all(20),
            child: ListView(children: [
              Center(child: Text("@ Adim Boubaker")),
              Container(height: 20),
              Center(
                  child: Card(
                      elevation: 7,
                      child: Image.asset("lib/assets/logo.png"),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)))),
              Container(
                height: 20,
              ),
              Text("Register",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                  )),
              Container(height: 10),
              Text(
                "Your Name",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Container(height: 10),
              CostumTextForm(
                mycontroller: username,
                hint: "Enter Your name",
                icon: Icon(Icons.person),
                keyboard: TextInputType.name,
                is_password: false,
              ),
              Container(height: 10),
              Text(
                "Family Name",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Container(height: 10),
              CostumTextForm(
                mycontroller: userprename,
                hint: "Enter your Pre-Name",
                icon: Icon(Icons.person_2),
                keyboard: TextInputType.name,
                is_password: false,
              ),
              Container(height: 10),
              Text(
                "Phone Number ",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Container(height: 10),
              CostumTextForm(
                  mycontroller: Phone,
                  hint: "Your Phone Number ",
                  icon: Icon(Icons.phone),
                  keyboard: TextInputType.phone,
                  is_password: false),
              Container(height: 10),
              Text(
                "Email",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Container(height: 10),
              CostumTextForm(
                mycontroller: email,
                hint: "Enter Your Mail",
                icon: Icon(Icons.email),
                keyboard: TextInputType.emailAddress,
                is_password: false,
              ),
              Container(height: 10),
              Text(
                "PassWord",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Container(height: 10),
              CostumTextForm(
                mycontroller: password,
                hint: "Enter Your Password",
                icon: Icon(Icons.password_rounded),
                keyboard: TextInputType.visiblePassword,
                is_password: true,
              ),
              Container(height: 10),
              Text(
                "Client / Provider / Admin",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ListTile(
                  title: Text("Employer"),
                  trailing: Checkbox(
                    value: tappedemployer,
                    onChanged: (bool? value) {
                      usertype = "Employer";
                      cheched(1);
                    },
                  ),
                  onTap: () {
                    AwesomeDialog(
                        context: context,
                        dialogType: DialogType.question,
                        animType: AnimType.topSlide,
                        title: 'Departemnts',
                        desc: 'Choose your Department',
                        btnOk: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ElevatedButton(
                                  onPressed: () {
                                    dep = "security";
                                  },
                                  child: Text("Security")),
                              ElevatedButton(
                                  onPressed: () {
                                    dep = "maintenance";
                                  },
                                  child: Text("Maintenance")),
                              ElevatedButton(
                                  onPressed: () {
                                    dep = "electrique and mecanique";
                                  },
                                  child: Text("Electrique or Mencanique"))
                            ])).show();
                  }),
              ListTile(
                title: Text("Admin"),
                trailing: Checkbox(
                  value: tappedadmin,
                  onChanged: (bool? value) {
                    setState(() {});
                    usertype = "Admin";
                    cheched(2);
                  },
                ),
              ),
              ListTile(
                  title: Text("Client"),
                  trailing: Checkbox(
                    value: tappedclient,
                    onChanged: (bool? value) {
                      usertype = "Client";
                      cheched(3);
                    },
                  )),
              ListTile(
                  title: Text("Distributor"),
                  trailing: Checkbox(
                    value: tappeddist,
                    onChanged: (bool? value) {
                      usertype = "Distributor";
                      cheched(4);
                    },
                  )),
              Container(height: 10),
              MaterialButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                height: 40,
                onPressed: () async {
                  try {
                    final credential = await FirebaseAuth.instance
                        .createUserWithEmailAndPassword(
                            email: email.text, password: password.text);
                    verify();
                    ajouterUser(
                        user_id: FirebaseAuth.instance.currentUser!.uid,
                        client_type: usertype,
                        Phone: Phone.text);
                  } on FirebaseAuthException catch (e) {
                    if (e.code == 'weak-password') {
                      AwesomeDialog(
                        // ignore: use_build_context_synchronously
                        context: context,
                        dialogType: DialogType.warning,
                        animType: AnimType.scale,
                        title: 'Security ',
                        desc: 'Week Password',
                      ).show();
                    } else if (e.code == 'email-already-in-use') {
                      AwesomeDialog(
                        context: context,
                        dialogType: DialogType.warning,
                        animType: AnimType.scale,
                        title: 'Used Email',
                        desc: 'Try new Mail',
                      ).show();
                    }
                  } catch (e) {
                    print(e);
                  }
                },
                child: Text("Register",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                color: Colors.blue,
              ),
              Container(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text("have an account ? "),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed("login");
                    },
                    child: Text("Back to Login"))
              ])
            ])));
  }
}
