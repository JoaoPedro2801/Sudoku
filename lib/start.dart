// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sudokuv2/arguments.dart';
import 'package:sudokuv2/database.dart';
import 'package:sudokuv2/home.dart';

class Start extends StatefulWidget {
  const Start({super.key});

  @override
  State<Start> createState() => _StartState();
}

class _StartState extends State<Start> {
  TextEditingController nameControler = TextEditingController();

  int dif = -1;
  bool nameSet = false;
  bool difSet = false;
  Duration durationGame = Duration.zero;

  Duration setTimer() {
    if (dif == 0) {
      return Duration(minutes: 10, seconds: 0);
    }
    if (dif == 1) {
      return Duration(minutes: 15, seconds: 0);
    }
    if (dif == 2) {
      return Duration(minutes: 20, seconds: 0);
    } else {
      return Duration(minutes: 30, seconds: 0);
    }
  }

  Future<void> fetchAllData() async {
    final banco = await DB().database;
    try {
      final List<Map<String, dynamic>> results = await banco.query('sudoku');
      for (var row in results) {
        print(row);
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

  Future<void> deleteData() async {
    final db = await DB().database;
    await db.rawDelete('DELETE FROM sudoku');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Image.asset('assets/Sudoku.png'),
            SizedBox(
              width: 300,
              child: TextField(
                  keyboardType: TextInputType.name,
                  controller: nameControler,
                  decoration: InputDecoration(
                      labelText: "Digite seu Nome:",
                      labelStyle: TextStyle(
                          fontSize: 20,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                      border: OutlineInputBorder(),
                      floatingLabelBehavior: FloatingLabelBehavior.always),
                  maxLength: 20,
                  maxLengthEnforcement: MaxLengthEnforcement.enforced,
                  style: TextStyle(fontSize: 20, color: Colors.black),
                  onSubmitted: (_) {}),
            ),
            Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 180,
                    height: 45,
                    child: RadioListTile(
                      value: 0,
                      groupValue: dif,
                      onChanged: (int? val) {
                        setState(() {
                          dif = val!;
                        });
                      },
                      activeColor: Colors.black,
                      title: Text(
                        "Easy",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  SizedBox(
                    width: 180,
                    height: 45,
                    child: RadioListTile(
                      value: 1,
                      groupValue: dif,
                      onChanged: (int? val) {
                        setState(() {
                          dif = val!;
                        });
                      },
                      activeColor: Colors.black,
                      title: Text("Medium",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  SizedBox(
                    width: 180,
                    height: 45,
                    child: RadioListTile(
                      value: 2,
                      groupValue: dif,
                      onChanged: (int? val) {
                        setState(() {
                          dif = val!;
                        });
                      },
                      activeColor: Colors.black,
                      title: Text("Hard",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  SizedBox(
                    width: 180,
                    height: 45,
                    child: RadioListTile(
                      value: 3,
                      groupValue: dif,
                      onChanged: (int? val) {
                        setState(() {
                          dif = val!;
                        });
                      },
                      activeColor: Colors.black,
                      title: Text("Expert",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  )
                ]),
            ElevatedButton(
              onPressed: () {
                /*Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Home(nameControler.text)));*/
                if (dif != -1 && nameControler.text != "") {
                  durationGame = setTimer();
                  Navigator.pushNamed(context, Home.routeName,
                      arguments:
                          Arguments(nameControler.text, dif, durationGame));
                }
              },
              style: ElevatedButton.styleFrom(
                  surfaceTintColor: Colors.amberAccent,
                  splashFactory: InkRipple.splashFactory,
                  shadowColor: Colors.black,
                  side: BorderSide(color: Colors.black, width: 3),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  backgroundColor: Colors.amber,
                  elevation: 10,
                  padding: EdgeInsets.symmetric(horizontal: 80, vertical: 20)),
              child: Text("Jogar",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, "/busca");
                //fetchAllData();
                //deleteData();
              },
              style: ElevatedButton.styleFrom(
                  surfaceTintColor: Colors.amberAccent,
                  splashFactory: InkRipple.splashFactory,
                  shadowColor: Colors.black,
                  side: BorderSide(color: Colors.black, width: 3),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  backgroundColor: Colors.amber,
                  elevation: 10,
                  padding: EdgeInsets.symmetric(horizontal: 80, vertical: 20)),
              child: Text("Busca",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20)),
            )
          ],
        ),
      ),
    );
  }
}
