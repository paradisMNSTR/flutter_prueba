import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_prueba/Dashboard/main_dash.dart';
import 'package:flutter_prueba/Endpoints/resources.dart';
import 'package:http/http.dart' as http;

class FetchDataEvent {
  final String end_point;
  final String access_token;
  FetchDataEvent({required this.end_point,required this.access_token});
}

class DataState {
  final List<User> data;
  final bool isLoading;

  DataState({required this.data, required this.isLoading});

  factory DataState.initial() {
    return DataState(data: [], isLoading: true);
  }

  DataState copyWith({List<User>? data, bool? isLoading}) {
    return DataState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/*class endpoints extends Bloc<FetchDataEvent,DataState>{
  endpoints():super(DataState.initial()){
    on<FetchDataEvent>((event, emit) async* {
      yield state.copyWith(isLoading: true);
      String resource = '';
      switch(event.end_point){
        case'USER':
          resource = 'https://api.github.com/user';
          break;
      }
      try {
        final url = Uri.parse(resource);
        var headers = {
          'Authorization': 'Bearer ${event.access_token}',
        };
        final response = await http.get(url,headers: headers);
        if (response.statusCode == 200) {
          final List<User> jsonData = json.decode(response.body);
          yield state.copyWith(data: jsonData, isLoading: false); // Actualizar el estado con los datos cargados
        } else {
          // Manejar errores de solicitud
          yield state.copyWith(isLoading: false);
        }
      } catch (e) {
        print(e);
        yield state.copyWith(isLoading: false);
      }
    });
  }




  /*Stream<dynamic>mapEvent(FetchDataEvent event)async*{
    yield state.copyWith(isLoading: true);
    String resource = '';
    switch(event.end_point){
      case'USER':
        resource = 'https://api.github.com/user';
        break;
    }
    try {
      final url = Uri.parse(resource);
      var headers = {
        'Authorization': 'Bearer ${event.access_token}',
      };
      final response = await http.get(url,headers: headers);
      if (response.statusCode == 200) {
        final List<User> jsonData = json.decode(response.body);
        yield state.copyWith(data: jsonData, isLoading: false); // Actualizar el estado con los datos cargados
      } else {
        // Manejar errores de solicitud
        yield state.copyWith(isLoading: false);
      }
    } catch (e) {
      // Manejar errores de red o de decodificación JSON
      yield state.copyWith(isLoading: false);
    }
  }*/

}*/
abstract class Eventos {
  String ACCESS_TOKEN;
  Eventos({required this.ACCESS_TOKEN});
}
class LoaderEvent extends Eventos {
  LoaderEvent({required super.ACCESS_TOKEN});

  @override
  // TODO: implement props
  List<Object?> get props => [];
}
class LoadedEvento extends Eventos {
  LoadedEvento({required super.ACCESS_TOKEN});

  @override
  // TODO: implement props
  List<Object?> get props => [];
}

abstract class States {}

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
    on<LoadedEvento>((state, emit) async {
      emit(LoaderStates());
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