import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_giris/deneme.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class yerGuncelle extends StatelessWidget {
  final String documentId;
  const yerGuncelle({super.key, required this.documentId});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: yerGuncelleSayfa(title: "Flutter", documentId: documentId));
  }
}

class yerGuncelleSayfa extends StatefulWidget {
  const yerGuncelleSayfa(
      {super.key, required this.title, required this.documentId});
  final String title;
  final String documentId;
  @override
  State<yerGuncelleSayfa> createState() => _yerGuncelleSayfaState(documentId);
}

class _yerGuncelleSayfaState extends State<yerGuncelleSayfa> {
  final String docID;
  Completer<GoogleMapController> haritakontrol = Completer();
  List<Marker> isaret = <Marker>[];

  _yerGuncelleSayfaState(this.docID);
  @override
  Widget build(BuildContext context) {
    var alinanResim;
    // TODO: implement build
    TextEditingController t1 = new TextEditingController();
    TextEditingController t2 = new TextEditingController();
    TextEditingController t3 = new TextEditingController();
    var lat;
    var long;
    var konumLat;
    var konumLong;
    FirebaseAuth auth = FirebaseAuth.instance;
    final String documentId;
    String? yerAdi;
    String? yerBilgi;
    late File resim;
    final _formKey = GlobalKey<FormState>();
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference users = FirebaseFirestore.instance.collection('yerler');
    Future<void> updateUser(var url, var adi, var bilgi, var glat, var glon) {
      return users
          .doc(docID)
          .update({
            'yerAdi': adi,
            'yerBilgi': bilgi,
            'resimURL': url,
            'konumlat': glat.toString(),
            'konumlong': glon.toString()
          })
          .then((value) => print("User Updated"))
          .catchError((error) => print("Failed to update user: $error"));
    }

    void resimBas(
        var alinan, var isim, var bilgi, var gelenlat, var gelenlon) async {
      setState(() {
        resim = File(alinan!.path);
      });
      final reference = await FirebaseStorage.instance
          .ref()
          .child("resimler")
          .child(auth.currentUser!.uid)
          .child(isim + ".png");
      UploadTask uploadTask = reference.putFile(resim);
      uploadTask.whenComplete(() async {
        try {
          var imageUrl = await reference.getDownloadURL();
          updateUser(imageUrl, isim, bilgi, gelenlat, gelenlon);
        } catch (onError) {
          print("Error");
        }

        //print(imageUrl);
      });
    }

    return FutureBuilder<DocumentSnapshot>(
      future: users.doc(docID).get(),
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
          t3.text = data['resimURL'];
          var lat = data['konumlat'];
          var long = data['konumlong'];
          var ilkkonum = CameraPosition(
              target: LatLng(double.parse(lat), double.parse(long)), zoom: 15);
          return Scaffold(
              body: SingleChildScrollView(
            child: Center(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                          left: 15.0, right: 15.0, top: 40, bottom: 0),
                      child: TextFormField(
                        controller: t1,
                        decoration: InputDecoration(
                          icon: Icon(Icons.near_me),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20)),
                          labelText: 'Yer Adı',
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Bos geçilemez";
                          } else {
                            return null;
                          }
                        },
                        onSaved: (value) {
                          yerAdi = value!;
                        },
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(top: 20)),
                    Padding(
                      padding: EdgeInsets.only(
                          left: 15.0, right: 15.0, top: 15, bottom: 0),
                      child: TextFormField(
                        controller: t2,
                        decoration: InputDecoration(
                          icon: Icon(Icons.data_array_rounded),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20)),
                          labelText: 'Yer Bilgisi',
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Bos geçilemez";
                          } else {
                            return null;
                          }
                        },
                        onSaved: (value) {
                          yerBilgi = value!;
                        },
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(top: 20)),
                    Text(
                      "Resim:",
                      style: TextStyle(fontSize: 20),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: 15.0, right: 15.0, top: 15, bottom: 0),
                      child: GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                                context: context,
                                builder: (context) {
                                  return Container(
                                    height: 150,
                                    padding: EdgeInsets.all(10),
                                    child: Column(
                                      children: [
                                        Text(
                                          "Resim Seç",
                                          style: TextStyle(fontSize: 15),
                                        ),
                                        TextButton(
                                            onPressed: () async {
                                              var hangiKaynak = 0;
                                              alinanResim = await ImagePicker()
                                                  .getImage(
                                                      source:
                                                          ImageSource.gallery);
                                              //galeriden();
                                            },
                                            child: Text("Galeriden")),
                                        TextButton(
                                            onPressed: () async {
                                              var hangiKaynak = 1;
                                              alinanResim = await ImagePicker()
                                                  .getImage(
                                                      source:
                                                          ImageSource.camera);
                                              //kameradan();
                                            },
                                            child: Text("Kameradan"))
                                      ],
                                    ),
                                  );
                                });
                          },
                          child: Image.network(t3.text)),
                    ),
                    Padding(padding: EdgeInsets.only(top: 20)),
                    Text(
                      "Konum Bigisi:",
                      style: TextStyle(fontSize: 20),
                    ),
                    SizedBox(
                      width: 400,
                      height: 300,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                            target:
                                LatLng(double.parse(lat), double.parse(long)),
                            zoom: 17.0), //kamera ilk konumu
                        markers: Set<Marker>.of(isaret),
                        mapType: MapType.normal, // harita türü satelite uydudur
                        onMapCreated: (GoogleMapController controller) {
                          haritakontrol.complete(controller);
                        },
                        onTap: (argument) {
                          konumLat = argument.latitude;
                          konumLong = argument.longitude;
                          /*
                      setState(() {
                        isaret = [];
                        isaret.add(Marker(
                            markerId: MarkerId(argument.toString()),
                            position: argument));
                      });
                      */
                        },
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(top: 20)),
                    Padding(
                      padding: EdgeInsets.only(
                          left: 15.0, right: 15.0, top: 15, bottom: 0),
                      child: ElevatedButton(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Güncelle"),
                            Icon(Icons.swap_vertical_circle_rounded)
                          ],
                        ),
                        style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.all(20.0),
                            fixedSize: Size(300, 80),
                            textStyle: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.bold),
                            primary: Colors.yellow,
                            onPrimary: Colors.black87,
                            elevation: 15,
                            shadowColor: Colors.yellow,
                            shape: StadiumBorder()),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState?.save();
                            // updateUser();
                            resimBas(alinanResim, yerAdi, yerBilgi, konumLat,
                                konumLong);
                          }
                        },
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(top: 20)),
                  ],
                ),
              ),
            ),
          ));
        }

        return Scaffold(body: Center(child: Text("Loading...")));
      },
    );
  }
}
