import 'dart:io';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_giris/deneme.dart';
import 'package:firebase_giris/yerDetay.dart';
import 'package:firebase_giris/yerEkle.dart';
import 'package:firebase_giris/yerGuncelle.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class yerGuncelleListe1 extends StatefulWidget {
  @override
  _yerGuncelleListe1State createState() => _yerGuncelleListe1State();
}

class _yerGuncelleListe1State extends State<yerGuncelleListe1> {
  final Stream<QuerySnapshot> _usersStream =
      FirebaseFirestore.instance.collection('yerler').snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: _usersStream,
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Loading");
          }

          return Scaffold(
            body: ListView(
              children: snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data =
                    document.data()! as Map<String, dynamic>;
                var id = document.id;
                return Card(
                  color: Colors.yellow,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: ListTile(
                      leading:
                          Icon(Icons.location_on_outlined, color: Colors.black),
                      title: Text(
                        data['yerAdi'],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(data['yerBilgi']),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  yerGuncelle(documentId: id)),
                        );
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
