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


const client_Id = '*';
const client_secret = '*';

const String redirectUri = 'http://localhost:3000/callback';
const String scope = 'read:user user:email';
final authorizationEndpoint = Uri.parse('https://github.com/login/oauth/authorize');
final tokenEndpoint = Uri.parse('https://github.com/login/oauth/access_token');

Future<void> authorize(BuildContext context) async {
  final grant = oauth2.AuthorizationCodeGrant(
    client_Id,
    authorizationEndpoint,
    tokenEndpoint,
    secret: client_secret,
  );
  final authorizationUrl = grant.getAuthorizationUrl(Uri.parse(redirectUri));
  print('Authorization URL: $authorizationUrl');
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => LoginPage(authorizationUrl: authorizationUrl)),
  );
}

Future<void> authorization(BuildContext context)async {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => LoginPage(authorizationUrl: authorizationEndpoint.replace(
      queryParameters: {
        'client_id': client_Id,
        'redirect_uri': redirectUri,
        'scope': scope,
      }
    ))),
  );
}


class LoginPage extends StatefulWidget {
  final Uri authorizationUrl;

  LoginPage({Key? key, required this.authorizationUrl,}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  WebViewController _controller = WebViewController();
  @override
  void initState() {
    print(widget.authorizationUrl);
    _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    _controller.setNavigationDelegate(NavigationDelegate(
        onProgress: (int progress) {

        },
        onPageStarted: (String url) {
          if(url.startsWith(redirectUri.toString())){
            final Uri uri = Uri.parse(url);
            print(uri);
            final String? code = uri.queryParameters['code'];
            if (code != null) {
              _requestAccessToken(code);
            } else {
              print('Authorization code is null.');
            }
          }
        }
    ));
    _controller.loadRequest(widget.authorizationUrl);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: WebViewWidget(
          controller: _controller,
      ),
    );
  }
  Future<void> _requestAccessToken(String code) async {
    final response = await http.post(
      tokenEndpoint,
      headers: {'Accept': 'application/json'},
      body: {
        'client_id': client_Id,
        'client_secret': client_secret,
        'code': code,
        'redirect_uri': redirectUri,
      },
    );
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final accessToken = responseData['access_token'];
      final tokenType = responseData['token_type'];
      print('Access token: $accessToken');
      print('Token type: $tokenType');
     await api_class().retriveInfo(accessToken,'USER').then((value){
        User usuario = User.fromJson(value);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Dashboard(ACCESS_TOKEN: accessToken,usuario: usuario,)),
        );
      });

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

class Alerta extends StatelessWidget {
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


