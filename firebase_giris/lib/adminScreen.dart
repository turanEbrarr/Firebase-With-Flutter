import 'package:firebase_giris/yerEkle.dart';
import 'package:firebase_giris/yerGuncelleListe.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'ilacDeneme.dart';

class adminScreen extends StatelessWidget {
  const adminScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    late String isim, soyisim, tel;
    final _formKey = GlobalKey<FormState>();
    return Scaffold(
        body: Container(
      child: Center(
        child: Form(
          key: _formKey,
          child: Center(
            child: Column(
              children: [
                Padding(padding: EdgeInsets.only(top: 80)),
                ElevatedButton(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Yeni Lokasyon Ekle"),
                      Icon(Icons.location_on_sharp)
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => yerEkle()),
                    );
                  },
                ),
                Padding(padding: EdgeInsets.only(top: 20)),
                ElevatedButton(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Lokasyon Güncelle"),
                      Icon(Icons.data_usage_sharp)
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => yerGuncelleListe()),
                    );
                  },
                )
              ],
            ),
          ),
        ),
      ),
    ));
  }
}
