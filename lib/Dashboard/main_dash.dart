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

  @override
  void initState() {
    Bloc_Retriver(api_class()).add(LoadedEvento(ACCESS_TOKEN: widget.ACCESS_TOKEN));
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return  Scaffold(
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
      body: BlocBuilder<Bloc_Retriver,States>(
          builder: (context,state){
            if(state is LoaderStates){
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if(state is LoadedStates){
              print(state.repo.length);
              return ListView.builder(
                  itemCount: state.repo.length,
                  itemBuilder: (BuildContext context,int index){
                    return ListTile(
                      title: Text(state.repo[index].name!),
                      subtitle: Text(state.repo[index].description!),
                    );
                  }
              );
            }
            return Container(color: Colors.black,);
          }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Bloc_Retriver(api_class()).add(LoadedEvento(ACCESS_TOKEN: widget.ACCESS_TOKEN));
        },
        child: Icon(Icons.refresh),
      ),
    );
  }
}


