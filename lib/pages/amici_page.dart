import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';


class AmiciPage extends StatefulWidget {

  const AmiciPage({super.key});


  @override

  State<AmiciPage> createState() => _AmiciPageState();

}


class _AmiciPageState extends State<AmiciPage> {

  final User user = FirebaseAuth.instance.currentUser!;

  final TextEditingController _emailController = TextEditingController();


  CollectionReference<Map<String, dynamic>> get _friendsCollection =>

      FirebaseFirestore.instance.collection('users').doc(user.uid).collection('friends');


  /// Aggiunge un nuovo amico per email

  Future<void> _aggiungiAmico() async {

    final email = _emailController.text.trim();

    if (email.isEmpty) return;


    await _friendsCollection.add({'email': email});

    _emailController.clear();

  }


  /// Rimuove un amico dato il documento

  Future<void> _rimuoviAmico(String docId) async {

    await _friendsCollection.doc(docId).delete();

  }


  @override

  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text('Amici'),

        backgroundColor: Colors.purple.shade800,

      ),

      backgroundColor: Colors.black87,

      body: Column(

        children: [

          Padding(

            padding: const EdgeInsets.all(16.0),

            child: Row(

              children: [

                Expanded(

                  child: TextField(

                    controller: _emailController,

                    style: const TextStyle(color: Colors.white),

                    decoration: InputDecoration(

                      hintText: 'Email amico',

                      hintStyle: const TextStyle(color: Colors.white54),

                      filled: true,

                      fillColor: Colors.grey[800],

                      border: OutlineInputBorder(

                        borderRadius: BorderRadius.circular(12),

                      ),

                    ),

                  ),

                ),

                const SizedBox(width: 10),

                ElevatedButton(

                  onPressed: _aggiungiAmico,

                  style: ElevatedButton.styleFrom(

                    backgroundColor: Colors.purple.shade700,

                  ),

                  child: const Text('Aggiungi'),

                ),

              ],

            ),

          ),

          Expanded(

            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(

              stream: _friendsCollection.snapshots(),

              builder: (context, snapshot) {

                if (snapshot.connectionState == ConnectionState.waiting) {

                  return const Center(child: CircularProgressIndicator());

                }


                final amici = snapshot.data?.docs ?? [];


                if (amici.isEmpty) {

                  return const Center(

                    child: Text(

                      'Non hai ancora amici aggiunti.',

                      style: TextStyle(color: Colors.white70),

                    ),

                  );

                }


                return ListView.builder(

                  itemCount: amici.length,

                  itemBuilder: (context, index) {

                    final amico = amici[index];

                    return ListTile(

                      title: Text(

                        amico['email'] ?? 'Email sconosciuta',

                        style: const TextStyle(color: Colors.white),

                      ),

                      trailing: IconButton(

                        icon: const Icon(Icons.delete, color: Colors.redAccent),

                        onPressed: () => _rimuoviAmico(amico.id),

                      ),

                    );

                  },

                );

              },

            ),

          ),

        ],

      ),

    );

  }

}



