//main.dart

import 'dart:convert';
import 'dart:js';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:device_preview/device_preview.dart';

class Pokemons {
  List<Dados>? dados;

  Pokemons({this.dados});

  Pokemons.fromJson(Map<String, dynamic> json) {
    if (json['dados'] != null) {
      dados = <Dados>[];
      json['dados'].forEach((v) {
        dados!.add(new Dados.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.dados != null) {
      data['dados'] = this.dados!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Dados {
  int? id;
  String? name;
  String? img;

  Dados({
    this.id,
    this.name,
    this.img,
  });

  Dados.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    img = json['img'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['img'] = this.img;
    return data;
  }
}

Future<List<Dados>> dados() async {
  final List<dynamic> result = await fetchUsers();
  //print(result);
  List<Dados> pokemons;
  pokemons = (result).map((pokemon) => Dados.fromJson(pokemon)).toList();
  return pokemons;
}

const String url =
    "https://raw.githubusercontent.com/Biuni/PokemonGO-Pokedex/master/pokedex.json";

Future<List<dynamic>> fetchUsers() async {
  var result = await http.get(Uri.parse(url));
  return jsonDecode(result.body)['pokemon'];
}

void main() =>
    runApp(DevicePreview(enabled: true, builder: (context) => MyApp()));

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const appTitle = 'Lista de Pokemons';

    return MaterialApp(
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          color: Colors.black12, // cor de fundo
          foregroundColor: Colors.white, // cor do texto
          elevation: 2, // sombreamento
        ),
      ),
      title: appTitle,
      initialRoute: '/',
      routes: {
        '/': (context) => MyHomePage(title: appTitle),
        pokemonwidget.routeName: (context) {
          return pokemonwidget();
        },
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: FutureBuilder<List<Dados>>(
        future: dados(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text('An error has occurred!');
          } else if (snapshot.hasData) {
            return PokemonsList(pokemons: snapshot.data!);
          } else {
            return CircularProgressIndicator();
          }
        },
      ),
    );
  }
}

class PokemonsList extends StatelessWidget {
  const PokemonsList({Key? key, required this.pokemons}) : super(key: key);

  final List<Dados> pokemons;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: pokemons.length,
      itemBuilder: (context, index) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 300,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(247, 193, 18, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                            color: Color.fromRGBO(48, 108, 172, 1), width: 5),
                      ),
                    ),
                    /*style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                        Color.fromRGBO(247, 193, 18, 1),
                      ),
                      side: MaterialStateProperty.all(
                        BorderSide(
                            width: 5,
                            color: Color.fromRGBO(48, 108, 172, 1),
                            style: BorderStyle.solid),
                      ),
                    ), */
                    onPressed: () =>
                        Navigator.pushNamed(context, 'details', arguments: {
                      'name': pokemons[index].name,
                      'img': pokemons[index].img,
                      'id': pokemons[index].id,
                    }),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.network(
                          "${pokemons[index].img}",
                          width: 250,
                          height: 200,
                          alignment: Alignment.center,
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 150),
                          alignment: Alignment.bottomCenter,
                          child: Text(
                            "${pokemons[index].name}",
                            style: TextStyle(
                                fontSize: 18,
                                color: Color.fromRGBO(0, 0, 0, 0.5)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Container(
              height: 30,
            ),
          ],
        );
      },
    );
  }
}

class pokemonwidget extends StatelessWidget {
  static const routeName = 'details';

  const pokemonwidget({super.key});

  @override
  Widget build(BuildContext context) {
    final Map args = ModalRoute.of(context)!.settings.arguments as Map;
    final String name = args['name'];
    final String img = args['img'];
    final int id = args['id'];
    return Scaffold(
      appBar: AppBar(
        title: Text('Informações sobre ' + name),
      ),
      body: Container(
        color: Colors.blue,
        child: Column(
          children: [
            Row(
              children: [
                Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(40),
                            topRight: Radius.circular(40),
                            bottomLeft: Radius.circular(40),
                            bottomRight: Radius.circular(40)),
                      ),
                      width: 270,
                      height: 170,
                      margin: EdgeInsets.only(left: 120, top: 80),
                    ),
                    Column(
                      children: [
                        Container(
                          margin: EdgeInsets.only(left: 0, top: 30),
                          child: Image.network(
                            img,
                            width: 250,
                            height: 250,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Color.fromRGBO(255, 255, 255, 1)),
                      child: Text(
                        name,
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                      margin: EdgeInsets.only(left: 190, top: 80),
                    ),
                    Container(
                      child: Text(''),
                    )
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
