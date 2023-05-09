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
  List<String>? type;
  String? weight;
  String? height;
  List<String>? weaknesses;

  Dados(
      {this.id,
      this.name,
      this.img,
      this.type,
      this.weight,
      this.height,
      this.weaknesses});

  Dados.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    img = json['img'];
    type = json['type'].cast<String>();
    weight = json['weight'];
    height = json['height'];
    weaknesses = json['weaknesses'].cast<String>();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['img'] = this.img;
    data['type'] = this.type;
    data['weight'] = this.weight;
    data['height'] = this.height;
    data['weaknesses'] = this.weaknesses;
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
                    onPressed: () =>
                        Navigator.pushNamed(context, 'details', arguments: {
                      'name': pokemons[index].name,
                      'img': pokemons[index].img,
                      'id': pokemons[index].id,
                      'type': pokemons[index].type,
                      'weight': pokemons[index].weight,
                      'height': pokemons[index].height,
                      'weaknesses': pokemons[index].weaknesses,
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
    final List<String> type = args['type'];
    final String weight = args['weight'];
    final String height = args['height'];
    final List<String> weaknesses = args['weaknesses'];
    return Scaffold(
      appBar: AppBar(
        title: Text('Informações sobre $name'),
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
                      width: 370,
                      height: 300,
                      margin: EdgeInsets.only(left: 10, top: 200),
                    ),
                    Container(
                      child: Image.network(
                        img,
                        width: 380,
                        height: 300,
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 0, top: 150),
                      child: Row(
                        children: [
                          Stack(
                            children: [
                              Container(
                                margin: EdgeInsets.only(left: 130, top: 50),
                                child: Text(
                                  name,
                                  style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              widgetdesclist('Tipo: ', args["type"], 80),
                              widgetdescricao('Peso: ', args['weight'], 100),
                              widgetdescricao('Altura: ', args['height'], 120),
                              widgetdesclist(
                                  'Fraquezas: ', args['weaknesses'], 140)
                            ],
                          ),
                        ],
                      ),
                    ),
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

widgetdescricao(String texto, String informacao, double val) {
  return Container(
    decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255, 1)),
    margin: EdgeInsets.only(top: val, left: 20),
    child: Row(
      children: [
        Text(
          '$texto $informacao',
          //'Tipo: ${args["type"]}',
          style: TextStyle(fontSize: 17),
        ),
      ],
    ),
  );
}

widgetdesclist(String texto, List<String> informacao, double val) {
  String nome = informacao.join(', ');
  return Container(
    decoration: BoxDecoration(color: Color.fromRGBO(255, 255, 255, 1)),
    margin: EdgeInsets.only(top: val, left: 20),
    child: Row(
      children: [
        Text(
          '$texto $nome',
          //'Tipo: ${args["type"]}',
          style: TextStyle(fontSize: 17),
        ),
      ],
    ),
  );
}
