# flutter_prueba

Amigo doctor prueba

Requerimientos para compilar:
*Poner como el minsdkVersion 34
*Cambiar en lib/Auth/authentication.dart los parametros client_id ,
client secret,y el URL del callback que se gnero al dar de alta la aplicacion y cambiarlas por las credenciales propias

La aplicación se conforma: 
La pantalla principal:{Navegación}
WebView:{Autencación de OAUTH}
Dashboard:{Peticiones de Usuario,Y Repositorios}

Para el manejo de autenticacion de OAuth de GitHub, se ejecutara una WebView, para evitar problemas con la
autenticacion, registrar de forma correcta las credenciales de GitHub.
Y hay un tiempo muerto visualizando una pagina que no responde pero es aquella que retorna el code.

