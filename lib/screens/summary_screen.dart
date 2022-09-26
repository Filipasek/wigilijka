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
              resetData();
            },
            icon: Icon(
              Icons.delete_forever,
              color: Colors.white,
            ),
          ),
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
    "3AG01": "PPK6BY",
    "3AG02": "EPZAOU",
    "3AG03": "R1LGRY",
    "3AG04": "HYKZB7",
    "3AG05": "MSZ0QO",
    "3AG06": "OEOEOE",
    "3AG07": "QR4GGZ",
    "3AG08": "WYT1KM",
    "3AG09": "A13ONY",
    "3AG10": "RGE1SN",
    "3AG11": "VZNPBQ",
    "3AG12": "WSUGAR",
    "3AG13": "FDPJGW",
    "3AG14": "3MPSDL",
    "3AG15": "T8N56Y",
    "3AG16": "J2ZAXQ",
    "3AG17": "GJ6E5X",
    "3AG18": "ADYGFZ",
    "3AG19": "ELKHZR",
    "3AG20": "WHYWPI",
    "3AG21": "JPBQGE",
    "3AG22": "TU3LYN",
    "3AG23": "D6MJGI",
    "3AG24": "PGAXAS",
    "3AG25": "PFWDS6",
    "3AG26": "PMFPVC",
    "3AG27": "VRG8BT",
    "3AG28": "DUCZEA",
    "3AG29": "957CJR",
    "3AG30": "ZLKTGA",
    "KOSEK": "HDJSWD",
    "WŁOCH": "LSKDTW",
  };

  Map<String, String> names = {
    "3AG01": "Natalia Babrzymąka",
    "3AG02": "Tomek Bryndza",
    "3AG03": "Szymon Burliga",
    "3AG04": "Kamil Górkowy",
    "3AG05": "Filip Guzdek",
    "3AG06": "Iwona Jarosz", //---
    "3AG07": "Paweł Kolber",
    "3AG08": "Szymon Korzeniowski",
    "3AG09": "Ola Koźbiał",
    "3AG10": "Antek Krempa",
    "3AG11": "Kaśka Łaski",
    "3AG12": "Dominik Macioł",
    "3AG13": "Bartek Madej", //---
    "3AG14": "Claudia Assad",
    "3AG15": "Monika Miarka",
    "3AG16": "Szymon Niziński",
    "3AG17": "Mateusz Oleksy",
    "3AG18": "Mateusz Polak",
    "3AG19": "Wojtek Popiel",
    "3AG20": "Dominika Rajda",
    "3AG21": "Tomek Sałapatek",
    "3AG22": "Przemek Sikorski",
    "3AG23": "Miłosz Smyrak",
    "3AG24": "Ola Talaga",
    "3AG25": "Paweł Talaga",
    "3AG26": "Aga Węgrzyn",
    "3AG27": "Ola Węgrzyn", //---
    "3AG28": "Damian Wiercimak",
    "3AG29": "Julka Wróbel",
    "3AG30": "Gabrysia Żmuda",
    "KOSEK": "Krzysztof Kosek",
    "WŁOCH": "Monika Włoch",
  };
  final _firestore = FirebaseFirestore.instance;
  for (int i = 1; i < names.length; i++) {
    String name;
    if (i < 10) {
      name = "3AG0" + i.toString();
    } else if (i < names.length - 2) {
      name = "3AG" + i.toString();
    } else if (i == names.length - 2) {
      name = "KOSEK";
    } else if (i == names.length - 1) {
      name = "WŁOCH";
    }
    // await _firestore.collection('users').doc(name).delete();
    await _firestore.collection('users').doc(name).set({
      "chose": "",
      "logged": false,
      "nazwa": names[name],
      "pass": passes[name],
      "wolny": true,
      "showResultsOfLottery": name == "3AG05" ? true : false
    }).catchError((e) {
      print('ERROR: ' + e.toString());

      throw Exception();
    });
  }
  return true;
}
