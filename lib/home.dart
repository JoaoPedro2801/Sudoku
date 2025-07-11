//Last Version
// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names, must_be_immutable, unused_local_variable

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pausable_timer/pausable_timer.dart';
//import 'package:slide_countdown/slide_countdown.dart';
import 'package:sudoku_dart/sudoku_dart.dart';
import 'package:sudokuv2/arguments.dart';
import 'package:sudokuv2/database.dart';

class Home extends StatefulWidget {
  String nome = "";
  static String routeName = "/home";
  Home();
  Home.nome(this.nome);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController nameController = TextEditingController();
  //Key countdownKey = UniqueKey();
  bool game_started = false;

  late PausableTimer timer;
  String _timeDisplay = "00:00";
  //bool _isTimerRunning = false;

  int clicked_now = -1;
  late int selected_num;
  late List<int> values = List.filled(81, -1);
  late List<int> fixed_pos = [];
  List<bool> rep = List.filled(81, false);

  bool won = false;
  bool lost = false;
  late Arguments args;

  String msg = "";
  late Timer t;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      args = ModalRoute.of(context)!.settings.arguments as Arguments;
      start_game(args);
    });
  }

  @override
  void dispose() {
    //countdownKey = UniqueKey();
    timer.cancel();
    super.dispose();
  }

  void tap_box(int index) {
    if (clicked_now != -1 && !fixed_pos.contains(index)) {
      setState(() {
        values[index] = clicked_now;
      });
    }

    update_boxes(index);

    clicked_now = -1;
  }

  void start_game(var args) {
    Sudoku sudoku;
    if (args.dif == 0) {
      sudoku = Sudoku.generate(Level.easy);
    } else if (args.dif == 1) {
      sudoku = Sudoku.generate(Level.medium);
    } else if (args.dif == 2) {
      sudoku = Sudoku.generate(Level.hard);
    } else {
      sudoku = Sudoku.generate(Level.expert);
    }
    setState(() {
      values = sudoku.puzzle;
    });

    for (int i = 0; i < values.length; i++) {
      if (values[i] != -1) {
        fixed_pos.add(i);
      }
    }
    timer = PausableTimer(args.durationGame, loss);
    timer.start();
    t = Timer.periodic(Duration(seconds: 1), (Timer viewTime) {
      updateTimer();
    });
    game_started = true;
  }

  void loss() {
    setState(() {
      this.msg = "Você Perdeu";
      lost = true;
    });
    add(args.name, 0, args.dif);
  }

  void reset_game() {
    setState(() {
      lost = false;
      values = List.filled(81, -1);
      rep = List.filled(81, false);
      fixed_pos = [];
      msg = "";
      won = false;
      game_started = false;
      //countdownKey = UniqueKey();
    });
    start_game(args);
  }

  bool verify_row(int index, int n) {
    int aux = (index ~/ 9) * 9;
    for (int i = aux; i < aux + 9; i++) {
      if (i != index && values[i] == n) {
        return true;
      }
    }
    return false;
  }

  bool verify_column(int index, int n) {
    int aux = index % 9;
    for (int i = aux; i <= aux + 72; i += 9) {
      if (i != index && values[i] == n) {
        return true;
      }
    }
    return false;
  }

  bool verify_submatrix(int index, int n) {
    //bool repeats = false;
    int sm_row = index ~/ 27;
    int sm_col = (index % 9) ~/ 3;
    int pos = (sm_row * 27) + (sm_col * 3);

    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        int aux = pos + (i * 9) + j;
        if (aux != index && values[aux] == n) {
          return true;
          //repeats = true;
        }
      }
    }
    return false;
  }

  void verify_victory() {
    if (!rep.contains(true)) {
      setState(() {
        this.msg = "Você Venceu!";
        won = true;
      });
      add(args.name, 1, args.dif);
      timer.cancel();
      //countdownKey = UniqueKey();
    }
  }

  void update_boxes(int index) {
    for (int i = 0; i < values.length; i++) {
      rep[i] = false;
    }

    for (int i = 0; i < values.length; i++) {
      if (values[i] != -1) {
        if (verify_row(i, values[i]) ||
            verify_column(i, values[i]) ||
            verify_submatrix(i, values[i])) {
          rep[i] = true;
        }
      }
    }
    if (values[index] != -1) {
      verify_submatrix(index, values[index]);
    }
    setState(() {});
  }

  String difText(args) {
    if (args.dif == 0) {
      return 'Easy';
    }
    if (args.dif == 1) {
      return 'Medium';
    }
    if (args.dif == 2) {
      return 'Hard';
    } else {
      return 'Expert';
    }
  }

  void updateTimer() {
    if (timer.isActive) {
      final timeLeft = args.durationGame.inSeconds - timer.elapsed.inSeconds;
      if (timeLeft >= 0) {
        final minutes = (timeLeft ~/ 60).toString().padLeft(2, '0');
        final seconds = (timeLeft % 60).toString().padLeft(2, '0');
        setState(() {
          _timeDisplay = "$minutes:$seconds";
        });
      } else {
        setState(() {
          _timeDisplay = "00:00";
        });
      }
    }
  }

  /*void testTimer() {
    if (timer.isExpired) {
      print('expirou');
    }
    if (timer.isActive) {
      print("ativo");
    }
  }*/

  void add(String nome, int result, int level) async {
    await DB().addDB(nome, result, DateTime.now().toIso8601String(), level);
  }

  @override
  Widget build(BuildContext context) {
    //var args = ModalRoute.of(context)!.settings.arguments as Arguments;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Sudoku",
          style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton.outlined(
              icon: Icon(
                Icons.refresh,
                color: Colors.black,
              ),
              color: Colors.white,
              onPressed: () {
                timer.cancel();
                reset_game();
              },
              style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white,
                  side: BorderSide(color: Colors.black, width: 2))),
          IconButton.outlined(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              timer.cancel();
              Navigator.pushNamed(context, "/start");
            },
            style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: BorderSide(color: Colors.black, width: 2)),
          )
        ],
        backgroundColor: Colors.amber,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.amber, const Color.fromARGB(255, 255, 157, 11)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            "Nome: ${args.name}",
            style: TextStyle(
                fontSize: 25, color: Colors.black, fontWeight: FontWeight.bold),
          ),
          Text(
            "Level: ${difText(args)}",
            style: TextStyle(
                fontSize: 25, color: Colors.black, fontWeight: FontWeight.bold),
          ),
          SizedBox(
              height: 400,
              child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 9,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2,
                  ),
                  padding: EdgeInsets.all(15),
                  itemCount: 81,
                  itemBuilder: (context, index) {
                    BorderSide borderSide =
                        BorderSide(color: Colors.black, width: 1);
                    int row = index ~/ 9;
                    int col = index % 9;
                    BorderSide topBorder = borderSide;
                    BorderSide leftBorder = borderSide;
                    BorderSide rightBorder = borderSide;
                    BorderSide bottomBorder = borderSide;

                    if (row % 3 == 0) {
                      topBorder = BorderSide(color: Colors.black, width: 3);
                    }
                    if (col % 3 == 0) {
                      leftBorder = BorderSide(color: Colors.black, width: 3);
                    }
                    if (row % 3 == 2) {
                      bottomBorder = BorderSide(color: Colors.black, width: 3);
                    }
                    if (col % 3 == 2) {
                      rightBorder = BorderSide(color: Colors.black, width: 3);
                    }
                    Border border = Border(
                      top: topBorder,
                      left: leftBorder,
                      right: rightBorder,
                      bottom: bottomBorder,
                    );

                    int box_value = values[index];
                    bool is_fixed = fixed_pos.contains(index);
                    Color box_color = Colors.lightBlue;
                    return GestureDetector(
                        onTap: () {
                          if (won == false && !(is_fixed) && lost == false) {
                            tap_box(index);
                          }
                          if (!values.contains(-1)) {
                            verify_victory();
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: rep[index] ? Colors.red : box_color,
                            border: border,
                          ),
                          child: Center(
                            child: Text(
                              box_value == -1 ? "" : "$box_value",
                              style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                  color: is_fixed
                                      ? const Color.fromARGB(255, 202, 202, 202)
                                      : Colors.white),
                            ),
                          ),
                        ));
                  })),
          Text(
            msg,
            style: TextStyle(
                fontSize: 35, color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            SizedBox(
                width: 400,
                height: 100,
                child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 9,
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 2,
                    ),
                    itemCount: 9,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                          onTap: () {
                            clicked_now = index + 1;
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.black, width: 2),
                                color: Colors.amber,
                                borderRadius: BorderRadius.circular(8)),
                            child: Center(
                              child: Text(
                                "${index + 1}",
                                style: TextStyle(
                                    fontSize: 25,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ));
                    })),
          ]),
        ],
      ),
      bottomNavigationBar: Container(
        height: 60,
        decoration: BoxDecoration(
            gradient: LinearGradient(
          colors: [Colors.amber, const Color.fromARGB(255, 255, 157, 11)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )),
        child: Center(
            child: Text(
          _timeDisplay,
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        )),
      ),
    );
  }
}
