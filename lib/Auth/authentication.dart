import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_prueba/Dashboard/main_dash.dart';
import 'package:flutter_prueba/Endpoints/endpoints.dart';
import 'package:flutter_prueba/Endpoints/resources.dart';
import 'package:flutter_prueba/Widgets/widgets.dart';
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

Future<void> signInWithGitHub(BuildContext context) async {


  // Construir la URL de autorización
  final authUrl = Uri.https(authorizationEndpoint.authority, authorizationEndpoint.path, {
    'client_id': client_Id,
    'redirect_uri': redirectUri,
    'scope': scope,
  });

  // Lanzar el navegador web para autenticación
  final result = await FlutterWebAuth.authenticate(
      url: authUrl.toString(),
      callbackUrlScheme: "miappoauth"
  );

  // Extraer el código desde la URL de redirección
  final code = Uri.parse(result).queryParameters['code'];

  if (code != null) {
    // Solicitar el token de acceso
    final response = await http.post(tokenEndpoint, headers: {
      'Accept': 'application/json',
    }, body: {
      'client_id': client_Id,
      'client_secret': client_secret,
      'code': code,
      'redirect_uri': redirectUri,
    });

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      final accessToken = responseBody['access_token'];

      // Usa el accessToken para solicitudes a la API de GitHub
      // Por ejemplo, obtener datos del usuario
      final userResponse = await http.get(
        Uri.parse('https://api.github.com/user'),
        headers: {
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (userResponse.statusCode == 200) {
        final userData = json.decode(userResponse.body);
        // Haz algo con los datos del usuario
        print("¡Autenticado! Usuario: ${userData['login']}");
      } else {
        // Manejar errores
        print("Error obteniendo datos de usuario: ${userResponse.body}");
      }
    } else {
      // Manejar errores
      print("Error obteniendo token de acceso: ${response.body}");
    }
  } else {
    // Manejar el error o la cancelación del flujo de autenticación
    print("Autenticación cancelada o fallida");
  }
}

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
  //final void Function(Uri redirectUrl) onAuthorizationRedirectAttempt;

  LoginPage({Key? key, required this.authorizationUrl, 
    //required this.onAuthorizationRedirectAttempt
  }) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  WebViewController _controller = WebViewController();
  @override
  void initState() {
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
      print('Error: ${response.statusCode}');
    }
  }
}


/*class LoginPage extends StatelessWidget {
  final oauth2.AuthorizationCodeGrant grant = oauth2.AuthorizationCodeGrant(
    'YOUR_CLIENT_ID',
    Uri.parse('https://example.com/oauth/authorize'),
    Uri.parse('https://example.com/oauth/token'),
    secret: 'YOUR_CLIENT_SECRET',
  );
  final WebViewController _controller = WebViewController().;
  @override
  Widget build(BuildContext context) {
    final String authorizationUrl = grant.getAuthorizationUrl(
        Uri.parse('YOUR_REDIRECT_URI')).toString();

    return Scaffold(
      appBar: AppBar(title: Text('Iniciar Sesión')),
      body: WebViewWidget(
        controller: _controller,
        initialUrl: authorizationUrl,
        onWebViewNavigationStarted: (String url) {
          if (url.startsWith('YOUR_REDIRECT_URI')) {
            _onRedirectUrl(url);
            Navigator.pop(context);
          }
        },
      ),
    );
  }
  Future<void> _onRedirectUrl(String url) async {
    try {
      final client = await grant.handleAuthorizationResponse(Uri.parse(url).queryParameters);
      print('Access token: ${client.credentials.accessToken}');
      // Aquí puedes guardar el token de acceso y usarlo para hacer solicitudes a la API
    } catch (e) {
      print('Error al obtener el token de acceso: $e');
    }
  }
}*/

