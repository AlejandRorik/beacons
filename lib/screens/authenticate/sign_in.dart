import 'dart:io';

import 'package:flutter/material.dart';
import 'package:beacons/app_localizations.dart';
import 'package:beacons/services/AuthService.dart';
import 'package:beacons/shared/constants.dart';
import 'package:beacons/shared/loading.dart';
import 'package:beacons/shared/screenSize.dart';
import 'package:wc_form_validators/wc_form_validators.dart';

class SignIn extends StatefulWidget {

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    ScreenSize().init(context);
    return loading ? Loading() : Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.fromARGB(255, 74, 224, 211), Color.fromARGB(255, 71, 112, 214)]),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0.0,
          title: Text(AppLocalizations.of(context).translate('logInAppBar').toString(),style: TextStyle(fontSize: ScreenSize.blockSizeHorizontal * 5)),
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
                        decoration: textInputDecoration.copyWith(hintText: AppLocalizations.of(context).translate('emailField').toString()),
                        validator: Validators.required(AppLocalizations.of(context).translate('emailFieldRequired').toString()),
                        onChanged: (val){
                          setState(() => email = val.trim());
                        },
                      ),
                    ),
                    //pass
                    SizedBox(height: ScreenSize.blockSizeVertical * 3),
                    Container(
                      width: ScreenSize.blockSizeHorizontal * 70,
                      child: TextFormField(
                        decoration: textInputDecoration.copyWith(hintText: AppLocalizations.of(context).translate('passwField').toString()),
                        obscureText: true,
                        validator: Validators.required(AppLocalizations.of(context).translate('passwFieldRequired').toString()),
                        onChanged: (val){
                          setState(() => password = val);
                        },
                      ),
                    ),
                    SizedBox(height: ScreenSize.blockSizeVertical * 3),
                    ButtonTheme(
                      height: ScreenSize.blockSizeVertical * 6,
                      minWidth: ScreenSize.blockSizeHorizontal * 70,
                      child: RaisedButton(
                        child: Text(AppLocalizations.of(context).translate('logInAppBar').toString(), style: TextStyle(color: Colors.white),),
                        color: Colors.transparent,
                        elevation: 0,
                        shape: ContinuousRectangleBorder(
                            borderRadius: new BorderRadius.circular(2),
                            side: BorderSide(color: Colors.white, width: 2)
                        ),
                        onPressed: () async{
                          try {
                            final result = await InternetAddress.lookup(
                                'google.com');
                            if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
                              print('connected');
                              if (_formKey.currentState.validate()){
                                setState(() => loading = true);
                                dynamic result = await _auth.signInWithEmailAndPassword(email, password);
                                if(result==null){
                                  setState(() {error = AppLocalizations.of(context).translate('logInError').toString();});
                                }else{
                                  error="";
                                  Navigator.pop(this.context);
                                }
                                setState(() {loading = false;});
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
}
