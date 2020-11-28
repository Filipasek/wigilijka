import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wigilijka/main.dart';

class SummaryScreen extends StatefulWidget {
  SummaryScreen({this.id, this.name});
  final String id;
  final String name;
  @override
  _SummaryScreenState createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        elevation: 0.0,
        title: Text("Wylosowano", style: GoogleFonts.comfortaa()),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () async {
              bool result = await removeLogins();
              if (result) {
                await Future.delayed(Duration(milliseconds: 400));

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MyApp(),
                  ),
                );
              }
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.id,
              style: GoogleFonts.comfortaa(
                fontSize: 16.0,
              ),
            ),
            Text(
              widget.name,
              style: GoogleFonts.comfortaa(
                fontWeight: FontWeight.bold,
                fontSize: 24.0,
              ),
            ),
            //TODO: remove!!!
            FlatButton(
              onPressed: () async {
                await resetData();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => MyApp(),
                  ),
                );
              },
              child: Text(
                'Press to reset data',
                style: GoogleFonts.comfortaa(
                  color: Theme.of(context).textTheme.headline5.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<bool> removeLogins() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('id');

  return true;
}

Future<bool> resetData() async {
  Map<String, String> passes = {
    "2AG01": "PPK6BY",
    "2AG02": "EPZAOU",
    "2AG03": "R1LGRY",
    "2AG04": "HYKZB7",
    "2AG05": "MSZ0QO",
    "2AG06": "OEOEOE",
    "2AG07": "QR4GGZ",
    "2AG08": "WYT1KM",
    "2AG09": "A13ONY",
    "2AG10": "RGE1SN",
    "2AG11": "VZNPBQ",
    "2AG12": "WSUGAR",
    "2AG13": "FDPJGW",
    "2AG14": "3MPSDL",
    "2AG15": "T8N56Y",
    "2AG16": "J2ZAXQ",
    "2AG17": "GJ6E5X",
    "2AG18": "ADYGFZ",
    "2AG19": "ELKHZR",
    "2AG20": "WHYWPI",
    "2AG21": "JPBQGE",
    "2AG22": "TU3LYN",
    "2AG23": "D6MJGI",
    "2AG24": "PGAXAS",
    "2AG25": "PFWDS6",
    "2AG26": "PMFPVC",
    "2AG27": "VRG8BT",
    "2AG28": "DUCZEA",
    "2AG29": "957CJR",
    "2AG30": "ZLKTGA",
  };

  Map<String, String> names = {
    "2AG01": "Claudia Assad",
    "2AG02": "Natalia Babrzymąka",
    "2AG03": "Tomek Bryndza",
    "2AG04": "Szymon Burliga",
    "2AG05": "Kamil Górkowy",
    "2AG06": "Filip Guzdek",
    "2AG07": "Iwona Jarosz",
    "2AG08": "Paweł Kolber",
    "2AG09": "Szymon Korzeniowski",
    "2AG10": "Ola Koźbiał",
    "2AG11": "Antek Krempa",
    "2AG12": "Kaśka Łaski",
    "2AG13": "Dominik Macioł",
    "2AG14": "Bartek Madej",
    "2AG15": "Monika Miarka",
    "2AG16": "Szymon Niziński",
    "2AG17": "Mateusz Oleksy",
    "2AG18": "Mateusz Polak",
    "2AG19": "Wojtek Popiel",
    "2AG20": "Dominika Rajda",
    "2AG21": "Tomek Sałapatek",
    "2AG22": "Przemek Sikorski",
    "2AG23": "Miłosz Smyrak",
    "2AG24": "Ola Talaga",
    "2AG25": "Paweł Talaga",
    "2AG26": "Aga Węgrzyn",
    "2AG27": "Ola Węgrzyn",
    "2AG28": "Damian Wiercimak",
    "2AG29": "Julka Wróbel",
    "2AG30": "Gabrysia Żmuda",
  };
  final _firestore = FirebaseFirestore.instance;
  for (int i = 1; i <= 30; i++) {
    String name;
    if (i < 10) {
      name = "2AG0" + i.toString();
    } else {
      name = "2AG" + i.toString();
    }

    await _firestore.collection('users').doc(name).set({
      "chose": "",
      "logged": false,
      "nazwa": names[name],
      "pass": passes[name],
      "wolny": true,
      "showResultsOfLottery": name == "2AG06" ? true : false
    }).catchError((e) {
      print('ERROR: ' + e.toString());

      throw Exception();
    });
  }
  return true;
}
