import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_prueba/Endpoints/endpoints.dart';

import '../Auth/authentication.dart';
import '../Endpoints/resources.dart';

class Dashboard extends StatefulWidget {
  String ACCESS_TOKEN;
  User usuario;
  Dashboard({super.key,required this.ACCESS_TOKEN,required this.usuario});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<Repos> repositorios=<Repos>[];//lista principal
  List<Repos> filter=<Repos>[];//lista de filtros
  TextEditingController control = TextEditingController();//Controlador del textfield
  get_data() async {
    repositorios.clear();
    filter.clear();
    try {
      api_class().retriveInfo(widget.ACCESS_TOKEN,'REPOS',widget.usuario.login!).then((value){//Obtener informacion de la peticion de Repositorios del usuario
        for(var notejson in value as List){
          setState(() {
            repositorios.add(Repos.fromJson(notejson));
            filter.add(Repos.fromJson(notejson));
          });
        }
      });
    } on Exception catch (_) {
      await showDialog(context: context,
      builder: (BuildContext context){
        return Alerta(
            title: 'ERROR!!',
            content: 'Problemas de red');
      });
    }

  }

  @override
  void initState() {
    get_data();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        title: Container(
          width: 200,
          child: TextField(
            controller: control,
            onChanged: (value){
              setState(() {
                repositorios = filter.where((element){
                  var filt = element.name!.toUpperCase()+element.description!.toUpperCase();
                  return filt.contains(value.toUpperCase());
                }).toList();//Filtrar la informacion mediante los valores del textfield
              });
            },
          ),
          ),
        ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                //color: Colors.blue,
              ),
              child: Center(
                child: Row(
                  children: [
                    Expanded(child: CircleAvatar(child: Image.network(widget.usuario.avatarUrl!,),radius: 30,)),//Avatar de GiTHUB
                    Expanded(
                        child: Text(widget.usuario.login!),//Nombre de Usuario de GiTHUB
                    ),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body: repositorios.isNotEmpty?
      Container(
        child: ListView.builder(//Lista de Repositorios de GitHUb del usuario
            itemCount: repositorios.length,
            itemBuilder: (BuildContext context , int index){
              return ListTile(
                title: Text(repositorios[index].name!),
                subtitle: Text(repositorios[index].description!),
              );
            }
        ),
      ):Center(
        child: CircularProgressIndicator(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
            get_data();//Recargar informacion
        },
        child: Icon(Icons.refresh),
      ),
    );
  }
}


