// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:sudokuv2/busca.dart';
import 'package:sudokuv2/home.dart';
import 'package:sudokuv2/start.dart';

void main() {
  runApp(MaterialApp(
    title: "Sudoku",
    debugShowCheckedModeBanner: false,
    home: Start(),
    initialRoute: "/",
    routes: {
      "/start": (context) => Start(),
      Home.routeName: (context) => Home(),
      "/busca": (context) => Busca()
    },
  ));
}
