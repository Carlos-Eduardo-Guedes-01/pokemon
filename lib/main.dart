//main.dart

import 'dart:convert';
import 'dart:js';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const appTitle = 'Lista de Pokemons';

    return MaterialApp(
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
          children: [
            Container(
              height: 10,
            ),
            ElevatedButton(
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
                    width: 500,
                    height: 200,
                    alignment: Alignment.center,
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 150),
                    alignment: Alignment.bottomCenter,
                    child: Text(
                      "${pokemons[index].name}",
                      style: TextStyle(
                          fontSize: 18, color: Color.fromRGBO(0, 0, 0, 0.5)),
                    ),
                  ),
                ],
              ),
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
        title: Text('Detalhes Pokemon'),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Column(
                children: [
                  Image.network(img),
                  Text(name),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}