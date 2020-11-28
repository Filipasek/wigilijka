import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'package:wigilijka/screens/summary_screen.dart';

class MainScreen extends StatefulWidget {
  MainScreen({@required this.myId});
  final String myId;
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          int size = snapshot.data.size;
          List<Map<String, dynamic>> rawDatas = new List(size);
          int meHasChosenIndex;

          for (int i = 0; i < size; i++) {
            rawDatas[i] = new Map();
            rawDatas[i]["numer"] = snapshot.data.docs[i].id;
            rawDatas[i]["wolny"] = snapshot.data.docs[i]['wolny'];
            rawDatas[i]["nazwa"] = snapshot.data.docs[i]['nazwa'];
            if (rawDatas[i]["numer"] == widget.myId &&
                snapshot.data.docs[i]['chose'] != "" &&
                snapshot.data.docs[i]['chose'] != null) {
              meHasChosenIndex = i;
            }
          }
          if (meHasChosenIndex != null) {
            String chosenId = snapshot.data.docs[meHasChosenIndex]['chose'];
            String chosenName;
            for (int p = 0; p < size; p++) {
              if (snapshot.data.docs[p].id ==
                  snapshot.data.docs[meHasChosenIndex]['chose']) {
                chosenName = snapshot.data.docs[p]["nazwa"];
                p = size + 1;
              }
            }
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => SummaryScreen(
                    id: chosenId,
                    name: chosenName,
                  ),
                ),
              ),
            );
          }

          List<Map<String, dynamic>> datas = shuffle(rawDatas);

          print("Snapszot: " + size.toString());
          return MainContent(size: size, datas: datas, myId: widget.myId);
        } else {
          return LinearProgressIndicator();
        }
      },
    );
  }
}

class MainContent extends StatefulWidget {
  MainContent({this.size, this.datas, this.myId});
  final int size;
  final List<Map<String, dynamic>> datas;
  final String myId;
  @override
  _MainContentState createState() => _MainContentState();
}

class _MainContentState extends State<MainContent>
    with TickerProviderStateMixin {
  int indexx = 0;
  String textIndex = '00';
  int selectedIndex;
  var normalRadius = BorderRadius.circular(5.0);
  var smallerRadius = BorderRadius.circular(50.0);
  var currentRadius = BorderRadius.circular(10.0);
  String errorMessage;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          child: FlatButton(
            onPressed: selectedIndex != null
                ? () async {
                    String selectedNumber =
                        widget.datas[selectedIndex]["numer"];
                    if (widget.datas[selectedIndex]["wolny"] == false) {
                      setState(() {
                        selectedIndex = null;
                        errorMessage = 'Coś poszło nie tak, spróbuj ponownie';
                      });
                    } else {
                      final _firestore = FirebaseFirestore.instance;
                      await _firestore
                          .collection('users')
                          .doc(widget.myId)
                          .set({
                        'chose': selectedNumber,
                        'logged': true,
                      }, SetOptions(merge: true));

                      await _firestore
                          .collection('users')
                          .doc(selectedNumber)
                          .set({
                        'wolny': false,
                      }, SetOptions(merge: true));
                    }
                    print("Wybrane: " + selectedNumber);
                  }
                : null,
            child: selectedIndex != null
                ? Text('Zatwierdź wybór', style: GoogleFonts.comfortaa())
                : Text(
                    'Wybierz kwadracik',
                    style: GoogleFonts.comfortaa(
                      color: Theme.of(context).textTheme.headline5.color,
                    ),
                  ),
            color: Color.fromRGBO(217, 217, 243, 1),
          ),
        ),
        Expanded(
          child: GridView.count(
            // Create a grid with 2 columns. If you change the scrollDirection to
            // horizontal, this produces 2 rows.
            crossAxisCount: 5,
            // Generate 100 widgets that display their index in the List.
            children: List.generate(widget.size, (index) {
              bool disabled = !widget.datas[index]["wolny"] ||
                  widget.datas[index]["numer"] == widget.myId;
              if (selectedIndex != null) {
                if (!widget.datas[selectedIndex]["wolny"]) {
                  setState(() {
                    selectedIndex = null;
                    currentRadius = normalRadius;
                  });
                }
              }
              return GestureDetector(
                onTap: disabled
                    ? null
                    : () {
                        setState(() {
                          if (selectedIndex == index) {
                            selectedIndex = null;
                            currentRadius = normalRadius;
                          } else {
                            selectedIndex = index;
                            currentRadius = smallerRadius;
                          }
                        });
                      },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  margin: selectedIndex == index
                      ? EdgeInsets.all(6.0)
                      : selectedIndex == null
                          ? EdgeInsets.all(6.0)
                          : EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: disabled
                        ? Color.fromRGBO(171, 178, 185, 0.2)
                        : Color.fromRGBO(217, 217, 243, 1),
                    borderRadius:
                        selectedIndex == index ? normalRadius : currentRadius,
                  ),
                  child: Center(
                    child: Text(widget.datas[index]["numer"]),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

List shuffle(List items) {
  var random = new Random();

  // Go through all elements.
  for (var i = items.length - 1; i > 0; i--) {
    // Pick a pseudorandom number according to the list length
    var n = random.nextInt(i + 1);

    var temp = items[i];
    items[i] = items[n];
    items[n] = temp;
  }

  return items;
}
