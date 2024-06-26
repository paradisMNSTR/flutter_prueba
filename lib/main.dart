import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_prueba/Endpoints/endpoints.dart';

import 'Auth/authentication.dart';

void main() {
  runApp(
      //BlocProvider(
    //create: (context)=>Bloc_Retriver(api_class()),
    MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Test',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(),
    );
  }
}
class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.network('https://github.githubassets.com/assets/GitHub-Mark-ea2971cee799.png'),//Logo de GitHUb
            ElevatedButton(
              onPressed: ()async{
                await authorization(context);//Funcion para abrir la ventana Web, para la utenticación OAuth
              },
              child: Text('Iniciar sesión con GitHub'),
            )
          ],
        ),
      ),
    );
  }
}