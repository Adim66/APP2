import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Profil extends StatefulWidget {
  @override
  State<Profil> createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  // Exemple de données
  final String userImage = 'https://via.placeholder.com/150';
  // URL de l'image de l'utilisateur
  final List<QueryDocumentSnapshot> likedProducts = [];

  loadlikedproduct() async {
    QuerySnapshot coll = await FirebaseFirestore.instance
        .collection("history")
        .where("user_id", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();
    likedProducts.clear();
    likedProducts.addAll(coll.docs);
    setState(() {});
  }

  final List<Map<String, String>> recentDistributors = [
    {'name': 'Distributor 1', 'contact': 'contact1@example.com'},
    {'name': 'Distributor 2', 'contact': 'contact2@example.com'},
    {'name': 'Distributor 3', 'contact': 'contact3@example.com'},
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadlikedproduct();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profil"),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Image de l'utilisateur
                CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(userImage),
                ),
                SizedBox(height: 16),

                // Section pour les informations utilisateur
                Text(
                  'User Information',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                SizedBox(height: 16),
                // Ajoutez ici les informations utilisateur (par exemple, nom, email, etc.)
                Text(
                  'Name: John Doe',
                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                ),
                Text(
                  'Email: john.doe@example.com',
                  style: TextStyle(fontSize: 18, color: Colors.grey[700]),
                ),
                SizedBox(height: 32),

                // Section pour les produits aimés
                Text(
                  'Liked Products',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: likedProducts.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          leading: Image.network(likedProducts[index]['url']!),
                          title: Text(likedProducts[index]['name']!),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 32),

                // Section pour les contacts récents avec les distributeurs
                Text(
                  'Recent Distributors Contacts',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: recentDistributors.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          leading: Icon(
                            Icons.contact_mail,
                            color: Colors.blue,
                          ),
                          title: Text(recentDistributors[index]['name']!),
                          subtitle: Text(recentDistributors[index]['contact']!),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
