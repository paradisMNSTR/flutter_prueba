import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_prueba/Endpoints/endpoints.dart';

import '../Endpoints/resources.dart';

class Dashboard extends StatefulWidget {
  String ACCESS_TOKEN;
  User usuario;
  Dashboard({super.key,required this.ACCESS_TOKEN,required this.usuario});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<Repos> repositorios=<Repos>[];
  get_data(){
    repositorios.clear();
    api_class().retriveInfo(widget.ACCESS_TOKEN,'REPOS').then((value){
      for(var notejson in value as List){
        setState(() {
          repositorios.add(Repos.fromJson(notejson));
        });
      }
    });
  }
  @override
  void initState() {
    get_data();
    //Bloc_Retriver(api_class()).add(LoadedEvento(ACCESS_TOKEN: widget.ACCESS_TOKEN));
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
                    Expanded(child: CircleAvatar(child: Image.network(widget.usuario.avatarUrl!,),radius: 30,)),
                    Expanded(
                        child: Text(widget.usuario.login!),
                    ),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      body:repositorios.isNotEmpty?
          Container(
            child: ListView.builder(
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
      /*BlocBuilder<Bloc_Retriver,States>(
          builder: (context,state){
            print(state.toString());
            if(state is LoaderStates){
              return const Center(
                child: CircularProgressIndicator(),
              );
            }else if(state is LoadedStates){
              return ListView.builder(
                  itemCount: state.repo.length,
                  itemBuilder: (BuildContext context,int index){
                    return ListTile(
                      title: Text(state.repo[index].name!),
                    );  
                  }
              );
            }
            return Container();
          }
      ),*/
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          get_data();
        },
        child: Icon(Icons.refresh),
      ),
    );
  }
}


