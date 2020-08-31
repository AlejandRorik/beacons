import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:beacons/services/AuthService.dart';
import 'package:beacons/shared/constants.dart';
import 'package:beacons/shared/screenSize.dart';
import 'package:flutter_blue/flutter_blue.dart';
import '../../app_localizations.dart';
import 'package:beacons/services/BlueService.dart';

class Home extends StatefulWidget {

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  final AuthService _auth = AuthService();

  //cambiara segun una funcion que detectara si esta funcionando o no el bluetooth
  bool isBluetoothOn = false;

  var iconTrue = Icon(Icons.bluetooth,color: Colors.deepOrange,size: ScreenSize.blockSizeVertical*5,);
  var iconFalse = Icon(Icons.bluetooth_disabled,color: Colors.black,size: ScreenSize.blockSizeVertical*5,);

  var blueS = BlueService();

  @override
  Widget build(BuildContext context) {
    ScreenSize().init(context);
    _auth.getCurrentUser();

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [appBackgroundColor1, appBackgroundColor2]),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).translate('homeAppBar'),style: TextStyle(fontSize: ScreenSize.blockSizeHorizontal * 5, color: Colors.black87)),
          backgroundColor: Colors.white,
          elevation: 2.5,
          actions: <Widget>[

            FlatButton.icon(
              icon: isBluetoothOn==false?iconFalse:iconTrue,
              label: Text(""),
              onPressed: () async{
                blueS.bluetoothChangeState();
              },
            ),
            FlatButton.icon(
              icon: Icon(Icons.person, size: ScreenSize.blockSizeHorizontal * 5, color: Colors.black87),
              label: Text(AppLocalizations.of(context).translate('logOutAppBar'),style: TextStyle(fontSize: ScreenSize.blockSizeHorizontal * 3.5, color: Colors.black87)),
              onPressed: () async{
                await _auth.signOut();
              },
            ),
          ],
        ),
        body: isBluetoothOn==false?
            Center(
              child: Text("Activa el Bluetooth para poder usar la aplicación",textAlign: TextAlign.center ,style: TextStyle(fontSize: ScreenSize.blockSizeVertical*3),)
            )
            :SingleChildScrollView(
          child: Column(
           children: <Widget>[
             Card(
               color: Colors.white,
               child: ListTile(
                 leading: Icon(Icons.bluetooth_audio, color: Colors.deepOrange, size: 50,),
                 title: Text("-Id del dispositivo del usuario \n-Nombre del beacon con el que interacciona (localización)"),
                 subtitle: Text("-Entrada:Hora de entrada al rango del beacon \n-Salida:Hora de salida del rango del beacon"),
                 isThreeLine: true,

               ),
             ),
           ],


          ),
        ),
      ),
    );
  }


}