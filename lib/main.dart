import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wigilijka/screens/main_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wigilijka',
      theme: ThemeData(
        fontFamily: 'Comfortaa',
        primaryColor: Colors.white,
        accentColor: Color.fromRGBO(255, 182, 185, 1),
        textTheme: TextTheme(
          bodyText2: TextStyle(color: Colors.grey),
          headline5: TextStyle(color: Colors.black),
        ),
      ),
      darkTheme: ThemeData(
        fontFamily: 'Comfortaa',
        primaryColor: Color.fromRGBO(40, 44, 55, 1),
        accentColor: Color.fromRGBO(255, 182, 185, 1),
        textTheme: TextTheme(
          bodyText2: TextStyle(color: Colors.grey),
          headline5: TextStyle(color: Colors.white),
        ),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  final _formKey = GlobalKey<FormState>();
  String _numer;
  String _kod;
  bool loading = false;
  bool error = false;
  String errorText;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Theme.of(context).primaryColor,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.0,
        title: Text(
          'Wigilijka',
          style: GoogleFonts.comfortaa(),
        ),
      ),
      body: FutureBuilder(
        future: _initialization,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            return FutureBuilder(
              future: isLogged(),
              builder: (BuildContext context, AsyncSnapshot sh) {
                if (sh.hasData) {
                  if (sh.data != 'not-logged') {
                    return MainScreen(
                      myId: sh.data,
                    );
                  } else {
                    return Container(
                      padding: EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            'Aby móc wylosować, musisz potwierdzić tożsamość',
                            style: GoogleFonts.comfortaa(
                              fontSize: 32.0,
                            ),
                          ),
                          Form(
                            key: _formKey,
                            child: Container(
                              margin: EdgeInsets.only(bottom: 20.0, top: 20.0),
                              child: Theme(
                                data: ThemeData(
                                  primaryColor: Theme.of(context).accentColor,
                                ),
                                child: Column(
                                  children: [
                                    error
                                        ? Container(
                                            padding: EdgeInsets.fromLTRB(
                                                30.0, 10.0, 30.0, 10.0),
                                            margin: EdgeInsets.all(10.0),
                                            // decoration: BoxDecoration(color: Colors.red),
                                            child: Text(
                                              errorText.toString(),
                                              style: GoogleFonts.comfortaa(
                                                  color: Colors.red,
                                                  fontSize: 18.0),
                                            ),
                                          )
                                        : SizedBox(),
                                    TextFormField(
                                      inputFormatters: [
                                        UpperCaseTextFormatter(),
                                      ],
                                      enabled: !loading,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .textTheme
                                              .headline5
                                              .color),
                                      showCursor: true,
                                      autocorrect: true,
                                      autofocus: true,
                                      cursorColor:
                                          Theme.of(context).accentColor,
                                      decoration: InputDecoration(
                                        labelStyle: TextStyle(
                                          color: Theme.of(context)
                                              .textTheme
                                              .headline5
                                              .color,
                                        ),
                                        labelText:
                                            "Numer z dziennika w formacie: 2AG06",
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Theme.of(context)
                                                .textTheme
                                                .headline5
                                                .color,
                                            width: 2.0,
                                          ),
                                        ),
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (value) {
                                        _numer = value;
                                      },
                                    ),
                                    SizedBox(height: 20.0),
                                    TextFormField(
                                      enabled: !loading,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .textTheme
                                              .headline5
                                              .color),
                                      showCursor: true,
                                      autocorrect: true,
                                      autofocus: true,
                                      cursorColor:
                                          Theme.of(context).accentColor,
                                      decoration: InputDecoration(
                                        labelStyle: TextStyle(
                                          color: Theme.of(context)
                                              .textTheme
                                              .headline5
                                              .color,
                                        ),
                                        labelText:
                                            "Kod wysłany w wiadomości prywatnej",
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                            color: Theme.of(context)
                                                .textTheme
                                                .headline5
                                                .color,
                                            width: 2.0,
                                          ),
                                        ),
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (value) {
                                        _kod = value;
                                      },
                                    ),
                                    SizedBox(height: 20.0),
                                    FlatButton(
                                      minWidth: double.infinity,
                                      height: 50.0,
                                      onPressed: () async {
                                        if (_numer != null && _kod != null) {
                                          setState(() {
                                            loading = !loading;
                                          });
                                          final _firestore =
                                              FirebaseFirestore.instance;
                                          _firestore
                                              .collection('users')
                                              .doc(_numer)
                                              .get()
                                              .then((doc) {
                                            if (doc.exists) {
                                              Map<String, dynamic> _data =
                                                  doc.data();
                                              if (_data['pass'] == _kod) {
                                                saveLogins(id: _numer)
                                                    .then((value) {
                                                  if (value) {
                                                    _firestore
                                                        .collection('users')
                                                        .doc(_numer)
                                                        .set({
                                                      'logged': true,
                                                    }, SetOptions(merge: true));
                                                    WidgetsBinding.instance
                                                        .addPostFrameCallback(
                                                      (_) => Navigator
                                                          .pushReplacement(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (_) =>
                                                              MyApp(),
                                                        ),
                                                      ),
                                                    );
                                                  } else {
                                                    setState(() {
                                                      error = true;
                                                      errorText =
                                                          'Coś poszło nie tak';
                                                      loading = false;
                                                    });
                                                  }
                                                });
                                              } else {
                                                setState(() {
                                                  error = true;
                                                  errorText = 'Niepoprawny kod';
                                                  loading = false;
                                                });
                                              }
                                            } else {
                                              setState(() {
                                                error = true;
                                                errorText = 'Niepoprawny numer';
                                                loading = false;
                                              });
                                            }
                                          });
                                        }
                                      },
                                      child: loading
                                          ? CircularProgressIndicator()
                                          : Text('Zaloguj się'),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                } else {
                  return LinearProgressIndicator();
                }
              },
            );
          } else {
            return LinearProgressIndicator();
          }
        },
      ),
    );
  }
}

Future<bool> saveLogins({@required String id}) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('id', id);
  return true;
}

Future<String> isLogged() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String result = prefs.getString('id');
  if (result != null && result != '') {
    return result;
  } else {
    return 'not-logged';
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text?.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
