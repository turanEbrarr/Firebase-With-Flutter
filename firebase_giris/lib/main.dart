import 'package:firebase_giris/adminScreen.dart';
import 'package:firebase_giris/kullaniciScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FirebaseAuth auth = FirebaseAuth.instance;
  late String username;
  late String password;
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController c1 = new TextEditingController();
    TextEditingController c2 = new TextEditingController();
    c1.text = "admin@admin.com";
    c2.text = "123321";
    final _formKey = GlobalKey<FormState>();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.yellow,
        title: const Text(
          "Giriş Sayfası",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        leading: Icon(Icons.lightbulb_outlined, color: (Colors.black)),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 60.0),
              ),
              Padding(
                //padding: const EdgeInsets.only(left:15.0,right: 15.0,top:0,bottom: 0),
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: TextFormField(
                  controller: c1,
                  decoration: InputDecoration(
                      icon: Icon(Icons.person),
                      focusColor: Colors.yellow,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50.0),
                          borderSide: BorderSide(
                              color: Colors.yellowAccent, width: 3.0)),
                      labelText: 'Kullanıcı Mail',
                      hintText: 'Turan Küçükşahin'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Bos geçilemez";
                    } else {
                      return null;
                    }
                  },
                  onSaved: (value) {
                    username = value!;
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: 15.0, right: 15.0, top: 15, bottom: 0),
                //padding: EdgeInsets.symmetric(horizontal: 15),
                child: TextFormField(
                  cursorColor: Colors.yellow,
                  controller: c2,
                  obscureText: true,
                  decoration: InputDecoration(
                      icon: Icon(Icons.password),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(50.0)),
                      labelText: 'Şifre',
                      hintText: 'Şifre giriniz'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Bos geçilemez";
                    } else {
                      return null;
                    }
                  },
                  onSaved: (value) {
                    password = value!;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 60.0),
              ),
              Container(
                height: 100,
                width: 250,
                decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(60)),
                child: ElevatedButton(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Giriş Yap"),
                    ],
                  ),
                  style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(20.0),
                      fixedSize: Size(300, 200),
                      textStyle:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                      primary: Colors.yellow,
                      onPrimary: Colors.black87,
                      elevation: 15,
                      shadowColor: Colors.yellow,
                      shape: StadiumBorder()),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState?.save();

                      final sp = username.split('@');
                      if (sp[1] == "admin.com") {
                        UserCredential giriskullanici =
                            await auth.signInWithEmailAndPassword(
                                email: username, password: password);
                        User? user = giriskullanici.user;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => adminScreen()),
                        );
                      } else {
                        UserCredential giriskullanici =
                            await auth.signInWithEmailAndPassword(
                                email: username, password: password);
                        User? user = giriskullanici.user;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => UserInformation()),
                        );
                      }
                    }
                  },
                ),
              ),
              /*
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Uye_Ol()),
                  );
                },
                child: const Text(
                  'Yeni üye olmak istiyorum.',
                  style: TextStyle(color: Colors.black, fontSize: 15),
                ),
                
              ),
              */
            ],
          ),
        ),
      ),
    );
  }
}
