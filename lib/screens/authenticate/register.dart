import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:beacons/app_localizations.dart';
import 'package:beacons/services/AuthService.dart';
import 'package:beacons/shared/constants.dart';
import 'package:beacons/shared/loading.dart';
import 'package:beacons/shared/screenSize.dart';
import 'package:wc_form_validators/wc_form_validators.dart';

class Register extends StatefulWidget {

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  final AuthService _auth = AuthService();
  final db = Firestore.instance;
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  String name = '';
  String email = '';
  String password = '';
  String error = '';
  @override
  Widget build(BuildContext context) {

    Pattern pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);

    ScreenSize().init(context);
    return loading ? Loading() : Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 74, 224, 211),
              Color.fromARGB(255, 71, 112, 214)
            ]),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          title: Text(AppLocalizations.of(context)
              .translate('registerAppBar')
              .toString(),
              style: TextStyle(fontSize: ScreenSize.blockSizeHorizontal * 5)),
          actions: <Widget>[
          ],
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Container(
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    SizedBox(height: ScreenSize.blockSizeVertical * 15),
                    Container(
                      width: ScreenSize.blockSizeHorizontal * 70,
                      child: TextFormField(
                        decoration: textInputDecoration.copyWith(
                            hintText: AppLocalizations.of(context).translate(
                                'nameField').toString()),
                        validator: Validators.required(AppLocalizations.of(context).translate('nameFieldRequired').toString()),
                        onChanged: (val) {
                          setState(() => name = val);
                        },
                      ),
                    ),
                    SizedBox(height: ScreenSize.blockSizeVertical * 3),
                    Container(
                      width: ScreenSize.blockSizeHorizontal * 70,
                      child: TextFormField(
                        decoration: textInputDecoration.copyWith(
                            hintText: AppLocalizations.of(context).translate(
                                'emailField').toString()),
                        validator: (val) => val.isEmpty ?(AppLocalizations.of(context).translate('emailFieldRequired').toString()): (!regex.hasMatch(val)) ? (AppLocalizations.of(context).translate('emailFieldBadFormat').toString()) : null,
                        onChanged: (val) {
                          setState(() => email = val);
                        },
                      ),
                    ),
                    //pass
                    SizedBox(height: ScreenSize.blockSizeVertical * 3),
                    Container(
                      width: ScreenSize.blockSizeHorizontal * 70,
                      child: TextFormField(
                        decoration: textInputDecoration.copyWith(
                            hintText: AppLocalizations.of(context).translate(
                                'passwField').toString()),
                        obscureText: true,
                        validator: (val) => val.isEmpty ? AppLocalizations.of(context).translate('passwFieldRequired').toString() : val.length<6 ? AppLocalizations.of(context).translate('passwFieldMoreThan5').toString() : null ,
                        onChanged: (val) {
                          setState(() => password = val);
                        },
                      ),
                    ),
                    SizedBox(height: ScreenSize.blockSizeVertical * 3),
                    ButtonTheme(
                      height: ScreenSize.blockSizeVertical * 6,
                      minWidth: ScreenSize.blockSizeHorizontal * 70,
                      child: RaisedButton(
                        child: Text(AppLocalizations.of(context).translate(
                            'registerAppBar').toString(),
                          style: TextStyle(color: Colors.white),),
                        color: Colors.transparent,
                        elevation: 0,
                        shape: ContinuousRectangleBorder(
                            borderRadius: new BorderRadius.circular(2),
                            side: BorderSide(color: Colors.white, width: 2)
                        ),
                        onPressed: () async {
                          try {
                            final result = await InternetAddress.lookup(
                                'google.com');
                            if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
                              print('connected');

                              if (_formKey.currentState.validate()) {
                                setState(() => loading = true);
                                dynamic result = await _auth.createUserWithEmailAndPassword(email, password);
                                if (result == null) {
                                  setState(() {
                                    error = AppLocalizations.of(context).translate('registerError').toString();
                                  });
                                }else{
                                  error="";
                                  await db.collection('usuarios').document(AuthService.currentId.toString()).setData({
                                    'userId' : AuthService.currentId,
                                    'cuentaUsuario': email,
                                    'nombreUsuario': name,
                                    'passUsuario': password,
                                    'isBluetoothOn': false,
                                  });
                                  await _auth.getCurrentUser();
                                  Navigator.pop(this.context);
                                  _showWelcomeUserMessage(context);
                                }
                                setState(() => loading = false);
                              }
                            }
                          } on SocketException catch (_) {
                            print('not connected');
                            _showNoInternetDialog(context);

                          }
                        },
                      ),
                    ),
                    SizedBox(height: ScreenSize.blockSizeVertical * 2),
                    Text(
                      error,
                      style: TextStyle(color: Colors.red, fontSize: 14.0),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  void _showNoInternetDialog(context) {
    AlertDialog alert = AlertDialog(
      content: Text(AppLocalizations.of(context).translate('noInternet').toString()),
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
  void _showWelcomeUserMessage(context) {
    AlertDialog alert = AlertDialog(
      content: Text(AppLocalizations.of(context).translate('welcomeUser').toString()+" "+ AuthService.currentUserName.toString() +"!",textAlign: TextAlign.center,),
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}