import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/components/textforms.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn(
              clientId:
                  "843185362555-pev0ink7dndgehfl3tpn39k1poa3d0e6.apps.googleusercontent.com")
          .signIn();
      if (googleUser == null) {
        print('ba77a');
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      print('Signed in as: ${userCredential.user?.displayName}');
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.message}');
    } catch (e) {
      print('Error: $e');
    }
  }

  void goToScreen() async {
    print(FirebaseAuth.instance.currentUser!.uid);
    QuerySnapshot q = await FirebaseFirestore.instance
        .collection("Users")
        .where("id", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();

    List<QueryDocumentSnapshot> list = q.docs;

    if (list.isNotEmpty) {
      String userType = list[0]["type"];

      if (userType == "Client") {
        Navigator.of(context).pushNamed("AdminClient");
      } else if (userType == "Admin") {
        Navigator.of(context).pushNamed("Admin");
      } else if (userType == "Employer") {
        Navigator.of(context).pushNamed("staff");
      } else if (userType == "Distributor") {
        Navigator.of(context).pushNamed("admindest");
      }
    } else {
      print("void");
    }
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
              Center(child: Text("")),
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
              Text("LOGIN",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                  )),
              Container(height: 10),
              Text(
                "Enter Your KNAUF Account ",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Container(height: 10),
              CostumTextForm(
                mycontroller: email,
                hint: "Enter Your Email",
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
              MaterialButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                height: 40,
                onPressed: () async {
                  try {
                    UserCredential userCredential = await FirebaseAuth.instance
                        .signInWithEmailAndPassword(
                            email: email.text, password: password.text);
                    AwesomeDialog(
                      context: context,
                      dialogType: DialogType.success,
                      animType: AnimType.rightSlide,
                      title: 'Sucsess',
                      desc: 'Welcome! ',
                    ).show();
                    print("hhhhhhhh");
                    goToScreen();

                    //CollectionReference products =
                    //  FirebaseFirestore.instance.collection("Products");
                  } on FirebaseAuthException catch (e) {
                    if (e.code == 'user-not-found') {
                      AwesomeDialog(
                        context: context,
                        dialogType: DialogType.error,
                        animType: AnimType.rightSlide,
                        title: 'ERROR',
                        desc: 'User Not Found ',
                      )..show();
                    } else if (e.code == 'wrong-password') {
                      AwesomeDialog(
                        context: context,
                        dialogType: DialogType.error,
                        animType: AnimType.rightSlide,
                        title: 'ERROR',
                        desc: 'Malformed or expired Password, ',
                        btnCancelText: "Forget Password ?",
                        btnCancelOnPress: () {
                          FirebaseAuth.instance
                              .sendPasswordResetEmail(email: email.text);
                        },
                      ).show();
                    } else {
                      AwesomeDialog(
                        context: context,
                        dialogType: DialogType.error,
                        animType: AnimType.rightSlide,
                        title: 'ERROR',
                        desc: 'Malformed or expired Password, ',
                      )..show();
                    }
                  } catch (e) {
                    print('Erreur inattendue');
                    // Gérer les autres types d'erreurs
                  }
                },
                child: Text("LOGIN",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                color: Colors.blue,
              ),
              Container(height: 10),
              MaterialButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                height: 40,
                onPressed: () {
                  signInWithGoogle();
                },
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(
                    " GOOGLE     ",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Image.asset(
                    "lib/assets/logo2.png",
                    width: 20,
                  )
                ]),
                color: Color.fromARGB(255, 230, 202, 20),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text("do not have an account ? "),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed("register");
                    },
                    child: Text("Create account"))
              ]),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text("                      "),
                  Text("@ Adim Boubaker")
                ],
              )
            ])));
  }
}
