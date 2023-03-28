import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_giris/deneme.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';

var resim;
File? file;
Uint8List? fel;

class GetUserName extends StatelessWidget {
  Completer<GoogleMapController> haritakontrol = Completer();

  TextEditingController t1 = new TextEditingController();
  TextEditingController t2 = new TextEditingController();
  final String documentId;
  final String resimAdi;
  final String url;
  final storageRef = FirebaseStorage.instance.ref();
  var downloadTask;

  GetUserName(this.documentId, this.resimAdi, this.url);
  Future<void> resimAl() async {
    final Uint8List? data;
    final islandRef = storageRef.child("resimler/" + resimAdi + ".png");

    try {
      const oneMegabyte = 1024 * 1024;
      data = await islandRef.getData(oneMegabyte);

      // Data for "images/island.jpg" is returned, use this as needed.
    } on FirebaseException catch (e) {
      // Handle any errors.
    }
    /*
    final islandRef = storageRef.child("resimler/" + resimAdi + ".png");

    final appDocDir = await getApplicationDocumentsDirectory();
    final filePath = "${appDocDir.absolute}/images/" + resimAdi + ".png";
    final file = File(filePath);

    downloadTask = islandRef.writeToFile(file);
    */
    7;
  }

  @override
  Widget build(BuildContext context) {
    Uint8List? resim;
    CollectionReference users = FirebaseFirestore.instance.collection('yerler');

    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(documentId).get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text("Something went wrong")));
        }

        if (snapshot.hasData && !snapshot.data!.exists) {
          return Scaffold(body: Center(child: Text("Document does not exist")));
        }

        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;
          t1.text = data['yerAdi'];
          t2.text = data['yerBilgi'];
          var url = data['resimURL'];
          var lat = data['konumlat'];
          var long = data['konumlong'];
          var ilkkonum = CameraPosition(
              target: LatLng(double.parse(lat), double.parse(long)), zoom: 15);

          return Scaffold(
              body: SingleChildScrollView(
            child: Center(
              child: Column(
                children: [
                  Padding(padding: EdgeInsets.only(top: 30)),
                  Padding(
                    padding: EdgeInsets.only(
                        left: 15.0, right: 15.0, top: 15, bottom: 0),
                    child: TextFormField(
                      enabled: false,
                      controller: t1,
                      decoration: InputDecoration(
                        icon: Icon(Icons.near_me),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)),
                        labelText: 'Yer Adı',
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(top: 20)),
                  Padding(
                    padding: EdgeInsets.only(
                        left: 15.0, right: 15.0, top: 15, bottom: 0),
                    child: TextFormField(
                      enabled: false,
                      controller: t2,
                      decoration: InputDecoration(
                        icon: Icon(Icons.data_array_rounded),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)),
                        labelText: 'Yer Bilgisi',
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(top: 20)),
                  Text(
                    "Resim:",
                    style: TextStyle(fontSize: 20),
                  ),
                  Card(
                    child: Padding(
                        padding: EdgeInsets.only(
                            left: 15.0, right: 15.0, top: 15, bottom: 0),
                        child: Image.network(url)),
                  ),
                  Padding(padding: EdgeInsets.only(top: 20)),
                  Text(
                    "Konum:",
                    style: TextStyle(fontSize: 20),
                  ),
                  Card(
                    child: SizedBox(
                      width: 400,
                      height: 300,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(double.parse(lat), double.parse(long)),
                          zoom: 17,
                        ), //kamera ilk konumu
                        mapType: MapType.normal, // harita türü satelite uydudur
                        onMapCreated: (GoogleMapController controller) {
                          haritakontrol.complete(controller);
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
          ));
        }

        return Scaffold(body: Center(child: Text("Loading...")));
      },
    );
  }
}
