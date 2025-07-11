// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:sudokuv2/database.dart';

class Busca extends StatefulWidget {
  const Busca({super.key});

  @override
  State<Busca> createState() => _BuscaState();
}

class _BuscaState extends State<Busca> {
  Map<int, int> qtdPartidas = {};

  @override
  void initState() {
    super.initState();
    _getQtdPartidas();
  }

  Future<void> _getQtdPartidas() async {
    final db = await DB().database;
    final List<Map<String, dynamic>> res = await db.rawQuery('''
      SELECT level, COUNT(*) AS quantidade
      FROM sudoku
      GROUP BY level
''');
    setState(() {
      qtdPartidas = {
        for (var i in res) i['level'] as int: i['quantidade'] as int
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text("Partidas por dificulade:",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        actions: [
          IconButton.outlined(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
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
      body: qtdPartidas.isEmpty
          ? Center(child: Text("No Data Available :("))
          : ListView.builder(
              itemCount: qtdPartidas.length,
              itemBuilder: (context, index) {
                int nivel = qtdPartidas.keys.elementAt(index);
                int qtd = qtdPartidas.values.elementAt(index);
                String txtNivel;
                if (nivel == 0) {
                  txtNivel = "Easy";
                } else if (nivel == 1) {
                  txtNivel = "Medium";
                } else if (nivel == 2) {
                  txtNivel = "Hard";
                } else {
                  txtNivel = "Expert";
                }
                return ListTile(
                  title: Text(
                    "Nível de Jogo: $txtNivel",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "Partidas jogadas: $qtd",
                    style: TextStyle(fontSize: 18),
                  ),
                );
              }),
    );
  }
}
