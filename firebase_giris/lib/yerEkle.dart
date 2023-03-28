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
import 'package:flutter/material.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';

class yerEkle extends StatelessWidget {
  const yerEkle({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Anasayfa(),
    );
  }
}

class Anasayfa extends StatefulWidget {
  const Anasayfa({Key? key}) : super(key: key);
  @override
  _AnasayfaState createState() => _AnasayfaState();
}

class _AnasayfaState extends State<Anasayfa> {
  Completer<GoogleMapController> haritakontrol = Completer();
  List<Marker> isaret = <Marker>[];
  var ilkkonum =
      CameraPosition(target: LatLng(38.7412482, 26.1844276), zoom: 4);

  final storage = FirebaseStorage.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  late File resim;

  void kameradan(var alinan, var isim) async {
    setState(() {
      resim = File(alinan!.path);
    });
    final reference = FirebaseStorage.instance
        .ref()
        .child("resimler")
        .child(auth.currentUser!.uid)
        .child(isim + ".png");
    reference.putFile(resim!);
  }

  void resimBas(var alinan, var isim, var bilgi, var konumgelenLat,
      var konumgelenLong) async {
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
        Map<String, dynamic> data = Map();

        print(konumgelenLat);
        data["yerAdi"] = isim;
        data["yerBilgi"] = bilgi;
        data["resimURL"] = await imageUrl;
        data["konumlat"] = konumgelenLat.toString();
        data["konumlong"] = konumgelenLong.toString();
        firestore.collection("yerler").add(data).then((DocumentReference doc) =>
            print('DocumentSnapshot added with ID: ${doc.id}'));
      } catch (onError) {
        print("Error");
      }

      //print(imageUrl);
    });
  }

  Future getDocs() async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection("collection").get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      var a = querySnapshot.docs[i];
      print(a);
    }
  }

  TextEditingController yerAdiCont = new TextEditingController();
  TextEditingController yerAdibilgi = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    var konumLat;
    var konumLong;
    DocumentSnapshot documentSnapshot;
    int? hangiKaynak;

    String? yerAdi;
    String? yerBilgi;
    var alinanResim;
    final _formKey = GlobalKey<FormState>();
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 60.0),
                ),
                Padding(
                  //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: TextFormField(
                    controller: yerAdiCont,
                    decoration: InputDecoration(
                        icon: Icon(Icons.near_me),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        labelText: 'Yer Adı',
                        hintText: 'Hacı Şükrü'),
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
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                ),
                Padding(
                  //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: TextFormField(
                    controller: yerAdibilgi,
                    decoration: InputDecoration(
                      icon: Icon(Icons.data_array_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
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
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                ),
                ElevatedButton(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Resim Ekle"),
                      Icon(Icons.add_photo_alternate_rounded)
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(20.0),
                      fixedSize: Size(300, 80),
                      textStyle:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                      primary: Colors.green,
                      onPrimary: Colors.black87,
                      elevation: 15,
                      shadowColor: Colors.green,
                      shape: StadiumBorder()),
                  onPressed: () {
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
                                      hangiKaynak = 0;
                                      alinanResim = await ImagePicker()
                                          .getImage(
                                              source: ImageSource.gallery);
                                      //galeriden();
                                    },
                                    child: Text("Galeriden")),
                                TextButton(
                                    onPressed: () async {
                                      hangiKaynak = 1;
                                      alinanResim = await ImagePicker()
                                          .getImage(source: ImageSource.camera);
                                      //kameradan();
                                    },
                                    child: Text("Kameradan"))
                              ],
                            ),
                          );
                        });
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                ),
                SizedBox(
                  width: 400,
                  height: 300,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                        target: LatLng(37.8728749, 32.4924729),
                        zoom: 14.0), //kamera ilk konumu
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
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                ),
                ElevatedButton(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Kaydet"),
                      Icon(Icons.swap_vertical_circle_rounded)
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(20.0),
                      fixedSize: Size(300, 80),
                      textStyle:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                      primary: Colors.yellow,
                      onPrimary: Colors.black87,
                      elevation: 15,
                      shadowColor: Colors.yellow,
                      shape: StadiumBorder()),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState?.save();

                      resimBas(
                          alinanResim, yerAdi, yerBilgi, konumLat, konumLong);
                    }
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
