import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:beacons/services/AuthService.dart';
import 'package:beacons/shared/constants.dart';
import 'package:beacons/shared/screenSize.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../app_localizations.dart';
import 'package:beacons/models/beacon.dart';

class Home extends StatefulWidget {

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> with WidgetsBindingObserver{
  //VARIABLES NECESARIAS DEL HOME
  final AuthService _auth = AuthService();
  final db = Firestore.instance;
  final beaconsCollection = Firestore.instance.collection("beacons");

  final StreamController<BluetoothState> streamController = StreamController();
  StreamSubscription<BluetoothState> _streamBluetooth;
  StreamSubscription<RangingResult> _streamRanging;

  final _regionBeacons = <Region, List<Beacon>>{};
  final _beacons = <Beacon>[];
  final _firebaseBeacons = [];
  final _beaconsTrue = <Beacon,DateTime>{};
  bool authorizationStatusOk = false;
  bool locationServiceEnabled = false;
  bool bluetoothEnabled = false;

  @override
  void initState() {
    AuthService().getCurrentUser();
    WidgetsBinding.instance.addObserver(this);
    super.initState();
    listeningState();
  }

  //listeningState() que debe vigilar si hay un cambio en el estado del bluetooth
  listeningState() async {
    print('Listening to bluetooth state');
    _streamBluetooth = flutterBeacon
        .bluetoothStateChanged()
        .listen((BluetoothState state) async {
      print('BluetoothState = $state');
      streamController.add(state);

      switch (state) {
        case BluetoothState.stateOn:
          initScanBeacon();
          break;
        case BluetoothState.stateOff:
          await pauseScanBeacon();
          await checkAllRequirements();
          break;
      }
    });
  }
  //checkAllRequirements() que debe comprobar que tenemos todos los permisos del usuario necesarios
  checkAllRequirements() async {
    final bluetoothState = await flutterBeacon.bluetoothState;
    final bluetoothEnabled = bluetoothState == BluetoothState.stateOn;
    final authorizationStatus = await flutterBeacon.authorizationStatus;
    final authorizationStatusOk =
        authorizationStatus == AuthorizationStatus.allowed ||
            authorizationStatus == AuthorizationStatus.always;
    final locationServiceEnabled = await flutterBeacon.checkLocationServicesIfEnabled;

    setState(() {
      this.authorizationStatusOk = authorizationStatusOk;
      this.locationServiceEnabled = locationServiceEnabled;
      this.bluetoothEnabled = bluetoothEnabled;
    });
  }

  //initScanBeacon() que es quien comienza la busqueda de beacons
  initScanBeacon() async {
    _firebaseBeacons.addAll(await getBeaconListFromFirebase());
    await flutterBeacon.initializeScanning;
    await checkAllRequirements();
    if (!authorizationStatusOk || !locationServiceEnabled || !bluetoothEnabled) {
      print('RETURNED, authorizationStatusOk=$authorizationStatusOk, '
          'locationServiceEnabled=$locationServiceEnabled, '
          'bluetoothEnabled=$bluetoothEnabled');
      return;
    }
    final regions = <Region>[];

    if (Platform.isIOS) {
      // iOS platform, at least set identifier and proximityUUID for region scanning
      regions.add(Region(
          identifier: 'Apple Airlocate',
          proximityUUID: 'E2C56DB5-DFFB-48D2-B060-D0F5A71096E0'));
    } else {
      // Android platform, it can ranging out of beacon that filter all of Proximity UUID
      regions.add(Region(identifier: 'com.beacon',));
    }

    if (_streamRanging != null) {
      if (_streamRanging.isPaused) {
        _streamRanging.resume();
        return;
      }
    }
    //_streamRanging coge todos los beacon que haya en una "region" en nuestro caso los meteremos en _beacons
    _streamRanging = flutterBeacon.ranging(regions).listen((RangingResult result) async{
          if (result != null && mounted) {
            setState(() {
              _regionBeacons[result.region] = result.beacons;
              _beacons.clear();
              _regionBeacons.values.forEach((list) {//los añadimos desde _regionBeacons
                _beacons.addAll(list);
              });
              _beacons.sort(_compareParameters);//los ordenamos por UUID

              /*compruebo que los beacons que recojo de afuera son los de mi base de datos*/
              _beacons.forEach((beaconAComparar) {
                var beaconValido = false;
                _firebaseBeacons.forEach((beaconDeFirebase) {
                  if(beaconAComparar.macAddress==beaconDeFirebase.MAC){
                    beaconValido=true;
                  }
                });
                if(beaconValido==true){
                  _beaconsTrue[beaconAComparar]=DateTime.now();//los meto junto a una hora
                }
              });

              /*compruebo si estoy en rango y si ya no lo estoy dejo un documento que muestra evidencia de ello*/
              _beaconsTrue.forEach((key, value) async {
                var getBeaconOut = true;
                _beacons.forEach((element) {
                  if(_beaconsTrue.containsKey(element)){
                    getBeaconOut = false;
                  }
                });
                if(getBeaconOut == true){
                  //await makeBeaconDocument(key,value);
                  _beaconsTrue.remove(key);
                }
              });

            });
          }
        });
  }
  //pauseScanBeacon() para la busqueda de beacons
  pauseScanBeacon() async {
    _streamRanging?.pause();
    if (_beacons.isNotEmpty) {
      setState(() {
        _beacons.clear();
      });
    }
  }
  //_compareParameters() para ordenar los beacons por el uuid de proximidad
  int _compareParameters(Beacon a, Beacon b) {
    int compare = a.proximityUUID.compareTo(b.proximityUUID);
    if (compare == 0) {compare = a.major.compareTo(b.major);}
    if (compare == 0) {compare = a.minor.compareTo(b.minor);}
    return compare;
  }

  //coge la lista de beacons de la base de datos
  getBeaconListFromFirebase() async {
    var lista = <DocumentSnapshot>[];
    var listaBeaconsFirebase = [];
    await beaconsCollection.getDocuments().then((value) => lista = value.documents.toList());
    lista.forEach((element) {
      listaBeaconsFirebase.add(Beacons(
        beaconId: element.documentID,
        nombreBeacon: element.data["nombreBeacon"],
        UUID: element.data["UUID"],
        MAC: element.data["MAC"],
        longitude: element.data["longitude"],
        latitude: element.data["latitude"],
      ));
    });
    return listaBeaconsFirebase;
  }

  //crea documentos del usuario pasando por un beacon entre un momento concreto
  makeBeaconDocument(Beacon beacon, DateTime entrada) async{
    if(AuthService.currentId!=null){
      await db.collection('usuarios/' + AuthService.currentId + '/userPassingBy').add({
        'beaconUUID': beacon.proximityUUID,
        'beaconMAC': beacon.macAddress,
        'horaEntradaEnRango': entrada,
        'horaSalidaDeRango': DateTime.now(),
      });
    }
  }

  //didChangeAppLifecycleState() inicia todas las funciones anteriores dependiendo de si tenemos permisos necesarios o no
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    print('AppLifecycleState = $state');
    if (state == AppLifecycleState.resumed) {
      if (_streamBluetooth != null && _streamBluetooth.isPaused) {
        _streamBluetooth.resume();
      }
      await checkAllRequirements();
      if (authorizationStatusOk && locationServiceEnabled && bluetoothEnabled) {
        await initScanBeacon();
      } else {
        await pauseScanBeacon();
        await checkAllRequirements();
      }
    } else if (state == AppLifecycleState.paused) {
      _streamBluetooth?.pause();
    }
  }

  // dispose se encarga de borrar funciones temporales para que no se queden guardadas en cache cuando creemos otra instancia de home
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    streamController?.close();
    _streamRanging?.cancel();
    _streamBluetooth?.cancel();
    flutterBeacon.close;

    super.dispose();
  }

  //build de home
  @override
  Widget build(BuildContext context) {
    
    ScreenSize().init(context);
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
            if (!authorizationStatusOk)
              IconButton(
                  icon: Icon(Icons.portable_wifi_off),
                  color: Colors.red,
                  onPressed: () async {
                    await flutterBeacon.requestAuthorization;
                  }),
            if (!locationServiceEnabled)
              IconButton(
                  icon: Icon(Icons.location_off),
                  color: Colors.red,
                  onPressed: () async {
                    if (Platform.isAndroid) {
                      await flutterBeacon.openLocationSettings;
                    } else if (Platform.isIOS) {

                    }
                  }),
            StreamBuilder<BluetoothState>(
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final state = snapshot.data;

                  if (state == BluetoothState.stateOn) {
                    return IconButton(
                      icon: Icon(Icons.bluetooth_connected),
                      onPressed: () {},
                      color: Colors.lightBlueAccent,
                    );
                  }

                  if (state == BluetoothState.stateOff) {
                    return IconButton(
                      icon: Icon(Icons.bluetooth),
                      onPressed: () async {
                        if (Platform.isAndroid) {
                          try {
                            await flutterBeacon.openBluetoothSettings;
                          } on PlatformException catch (e) {
                            print(e);
                          }
                        } else if (Platform.isIOS) {

                        }
                      },
                      color: Colors.red,
                    );
                  }

                  return IconButton(
                    icon: Icon(Icons.bluetooth_disabled),
                    onPressed: () {},
                    color: Colors.grey,
                  );
                }

                return SizedBox.shrink();
              },
              stream: streamController.stream,
              initialData: BluetoothState.stateUnknown,
            ),
            FlatButton.icon(
              icon: Icon(Icons.person, size: ScreenSize.blockSizeHorizontal * 5, color: Colors.black87),
              label: Text(AppLocalizations.of(context).translate('logOutAppBar'),style: TextStyle(fontSize: ScreenSize.blockSizeHorizontal * 3.5, color: Colors.black87)),
              onPressed: () async {
                await _auth.signOut();
              },
            ),
          ],
        ),
        body: authorizationStatusOk==false || locationServiceEnabled==false || bluetoothEnabled==false
            ? Center(
              child: Container(
                  height: ScreenSize.blockSizeVertical * 15,
                  width: ScreenSize.blockSizeHorizontal * 60,
                  child: Card(
                      elevation: 3,
                      child: Center(
                          child: Text(AppLocalizations.of(context).translate('homeCheckBluetooth'),textAlign: TextAlign.center, style: TextStyle(fontSize: ScreenSize.blockSizeHorizontal * 4),)
                      )
                  ),
        ),
            )
            : _beaconsTrue == null || _beaconsTrue.isEmpty
            ? Center(child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SpinKitWave(color: Colors.white70,size: ScreenSize.blockSizeVertical*10,),
                SizedBox(height: ScreenSize.blockSizeVertical*3,),
                Text(AppLocalizations.of(context).translate('homeCheckBluetooth'),style: TextStyle(color: Colors.white70,fontSize: ScreenSize.blockSizeVertical*4),)
              ],
            ))
            : ListView(
          children: ListTile.divideTiles(
              context: context,
              tiles: _beaconsTrue.keys.map((beacon) {
                return Card(
                  elevation: 4,
                  child: ListTile(
                    title: Text('UUID: ${beacon.proximityUUID}',
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: ScreenSize
                          .blockSizeHorizontal * 4),),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Text('MAC: ${beacon.macAddress}',
                          textAlign: TextAlign.end,),
                        new Row(
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            Flexible(
                                child: Text(
                                    'Major: ${beacon.major}\nMinor: ${beacon
                                        .minor}',
                                    style: TextStyle(fontSize: 13.0)),
                                flex: 1,
                                fit: FlexFit.tight),
                            Flexible(
                                child: Text(
                                    'Accuracy: ${beacon
                                        .accuracy}m\nRSSI: ${beacon.rssi}',
                                    style: TextStyle(fontSize: 13.0)),
                                flex: 2,
                                fit: FlexFit.tight)
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              })).toList(),
        ),
      ),
    );
  }
}