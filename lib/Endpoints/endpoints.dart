import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_prueba/Dashboard/main_dash.dart';
import 'package:flutter_prueba/Endpoints/resources.dart';
import 'package:http/http.dart' as http;

abstract class Eventos extends Equatable{
  String ACCESS_TOKEN;
  Eventos({required this.ACCESS_TOKEN});
}

class LoadedEvento extends Eventos {
  LoadedEvento({required super.ACCESS_TOKEN});

  @override
  List<Object?> get props => [];
}
class LoaderEvento extends Eventos {
  LoaderEvento({required super.ACCESS_TOKEN});

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

abstract class States extends Equatable{}

class LoaderStates extends States {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}
class LoadedStates extends States {
  final List<Repos> repo;
  LoadedStates(this.repo);
  @override
  // TODO: implement props
  List<Object?> get props => [repo];
}

class Bloc_Retriver extends Bloc<Eventos,States>{
  api_class? getter;
  Bloc_Retriver(this.getter) : super(LoaderStates()) {
    on<LoadedEvento>((state,emit)async{
      emit(LoaderStates());
      await Future.delayed(const Duration(seconds: 1));
      List<Repos> data = <Repos>[];
      var results = await getter?.retriveInfo(state.ACCESS_TOKEN, 'REPOS');
      for(var notejson in results as List){
        data.add(Repos.fromJson(notejson));
      }
      print(data.length);
      emit(LoadedStates(data));
    });
  }
}

class api_class{
  Future retriveInfo(String access_token,String end_point)async{
    String resource = '';
    switch(end_point){
      case'USER':
        resource = 'https://api.github.com/user';
        break;
      case'REPOS':
        resource= 'https://api.github.com/users/paradisMNSTR/repos';
    }
    final url = Uri.parse(resource);
    var headers = {
      'Authorization': 'Bearer ${access_token}',
    };
    final response = await http.get(url,headers: headers);
    if(response.statusCode==200){
      print(json.decode(response.body));
      return json.decode(response.body);
    }else{
      throw Exception('Error fatal');
    }
  }
}