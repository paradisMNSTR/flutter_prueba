import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_prueba/Dashboard/main_dash.dart';
import 'package:flutter_prueba/Endpoints/endpoints.dart';
import 'package:flutter_prueba/Endpoints/resources.dart';
import 'package:flutter_web_auth/flutter_web_auth.dart';
import 'package:http/http.dart' as http;
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

//Credenciales
const client_Id = '*';
const client_secret = '*';

//Rcursos para la autencticación
const String redirectUri = '*';
const String scope = 'read:user user:email';
final authorizationEndpoint = Uri.parse('https://github.com/login/oauth/authorize');
final tokenEndpoint = Uri.parse('https://github.com/login/oauth/access_token');

Future<void> authorization(BuildContext context)async {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => LoginPage(authorizationUrl: authorizationEndpoint.replace(//Agregar parametros a la URL en base a a las credenciales y recursos
      queryParameters: {
        'client_id': client_Id,
        'redirect_uri': redirectUri,
        'scope': scope,
      }
    ))),
  );
}


class LoginPage extends StatefulWidget {
  final Uri authorizationUrl;//URL compuesta

  LoginPage({Key? key, required this.authorizationUrl,}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  WebViewController _controller = WebViewController();//Controlador del visualizador Web
  @override
  void initState() {
    print(widget.authorizationUrl);
    _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    _controller.setNavigationDelegate(NavigationDelegate(
        onProgress: (int progress) {

        },
        onPageStarted: (String url) async {//Cuando se carga la pagina obtener la URL , retirnada del sitio con el CODE
          if(url.startsWith(redirectUri.toString())){//Si se dio acceso correcto retorna la URL
            final Uri uri = Uri.parse(url);
            print(uri);
            final String? code = uri.queryParameters['code'];//opbtenemos el parametro code de la URL
            if (code != null) {
              _requestAccessToken(code);//Obtenemos el Access TOKEN
            } else {
              print('Authorization code is null.');
              await showDialog(context: context,
              builder: (BuildContext context){
                return Alerta(
                    title: 'ERROR!!',
                    content: 'NO se encontro el CODE');
              });
            }
          }
        }
    ));
    _controller.loadRequest(widget.authorizationUrl);//cargar pagina con la URL
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: WebViewWidget(//Visualizador Web
          controller: _controller,
      ),
    );
  }
  Future<void> _requestAccessToken(String code) async {
    final response = await http.post(//Peticion para obtener Access token
      tokenEndpoint,
      headers: {'Accept': 'application/json'},
      body: {
        'client_id': client_Id,
        'client_secret': client_secret,
        'code': code,
        'redirect_uri': redirectUri,
      },
    );
    if (response.statusCode == 200) {//Encaso de ser exitosa obtenemos el Access token de la peticion.
      final responseData = jsonDecode(response.body);
      final accessToken = responseData['access_token'];
      final tokenType = responseData['token_type'];
      print('Access token: $accessToken');
      print('Token type: $tokenType');
      try {
        await api_class().retriveInfo(accessToken,'USER','').then((value){//Obtener la informacion del Usuario ya con el TOKEN
          User usuario = User.fromJson(value);//Valor usuario guardado
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Dashboard(ACCESS_TOKEN: accessToken,usuario: usuario,)),//Mandar el ACCESS TOKEN y USuario a la siguiente pantalla
          );
        });
      } on Exception catch (_) {
        await showDialog(context: context,
            builder: (BuildContext context){
              return Alerta(
                  title: 'ERROR!!',
                  content: 'Problemas de red');
            });
      }
    } else {
      await showDialog(context: context,
          builder: (BuildContext context){
            return Alerta(
                title: 'ERROR!!',
                content: 'Problemas de autenticación');
          });
      print('Error: ${response.statusCode}');
    }
  }
}

class Alerta extends StatelessWidget {//Alert Dialog como funcionalidad de aviso de errores
  String title;
  String content;
  Alerta({super.key,required this.title,required this.content});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
    );
  }
}


