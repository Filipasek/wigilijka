import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
          List<Map<String, dynamic>> datas = new List(size);
          int meHasChosenIndex;
          // List<Map<String, String>> datas;
          for (int i = 0; i < size; i++) {
            datas[i] = new Map();
            datas[i]["numer"] = snapshot.data.docs[i].id;
            datas[i]["wolny"] = snapshot.data.docs[i]['wolny'];
            datas[i]["nazwa"] = snapshot.data.docs[i]['nazwa'];
            if (datas[i]["numer"] == widget.myId &&
                snapshot.data.docs[i]['chose'] != "" &&
                snapshot.data.docs[i]['chose'] != null) {
              meHasChosenIndex = i;
            }
          }
          if(meHasChosenIndex != null){
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

          datas = shuffle(datas);

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
          child: RaisedButton(
            onPressed: selectedIndex != null
                ? () async {
                    if (widget.datas[selectedIndex]["wolny"] == false) {
                      setState(() {
                        selectedIndex = null;
                        errorMessage = 'Coś poszło nie tak, spróbuj ponownie';
                      });
                    } else {
                      final _firestore = FirebaseFirestore.instance;
                      await _firestore.collection('users').doc(widget.myId).set({
                        'chose':
                            widget.datas[selectedIndex]["numer"].toString(),
                        'logged': true,
                      }, SetOptions(merge: true));

                      await _firestore
                          .collection('users')
                          .doc(widget.datas[selectedIndex]["numer"])
                          .set({
                        'wolny': false,
                      }, SetOptions(merge: true));

                      WidgetsBinding.instance.addPostFrameCallback(
                        (_) => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SummaryScreen(
                            id: widget.datas[selectedIndex]["numer"],
                            name: widget.datas[selectedIndex]["nazwa"],
                          ),
                          ),
                        ),
                      );
                    }
                    print("Wybrane: " +
                        widget.datas[selectedIndex]["numer"].toString());
                  }
                : null,
            child: Text('Zatwierdź wybór'),
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
