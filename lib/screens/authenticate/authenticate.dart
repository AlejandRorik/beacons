import 'package:flutter/material.dart';
import 'package:beacons/screens/authenticate/register.dart';
import 'package:beacons/screens/authenticate/sign_in.dart';
import 'package:beacons/shared/constants.dart';
import 'package:beacons/shared/screenSize.dart';

import '../../app_localizations.dart';

class Authenticate extends StatefulWidget {
  @override
  _AuthenticateState createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {

  @override
  Widget build(BuildContext context) {
    ScreenSize().init(context);

    return Center(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [appBackgroundColor1, appBackgroundColor2]),
        ),
        child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: Column(
                children: <Widget>[
                  SizedBox(height: ScreenSize.blockSizeVertical * 16),
                  Image(image: AssetImage('assets/Logo.png')),
                  SizedBox(height: ScreenSize.blockSizeVertical * 4),
                  ButtonTheme(
                    height: ScreenSize.blockSizeVertical * 8,
                    minWidth: ScreenSize.blockSizeHorizontal * 60,
                    child: RaisedButton(
                      elevation: 0,
                      child: Text(AppLocalizations.of(context).translate('logInAppBar').toString(),style: TextStyle(fontSize: ScreenSize.blockSizeHorizontal * 4, color: Colors.white)),
                      color: Colors.transparent,
                      shape: ContinuousRectangleBorder(
                          borderRadius: new BorderRadius.circular(2),
                          side: BorderSide(color: Color.fromARGB(255, 85, 255, 255))
                      ),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => SignIn()));
                      },
                    ),
                  ),
                  SizedBox(height: ScreenSize.blockSizeVertical * 2),
                  ButtonTheme(
                    height: ScreenSize.blockSizeVertical * 8,
                    minWidth: ScreenSize.blockSizeHorizontal * 60,
                    child: RaisedButton(
                      elevation: 0,
                      child: Text(AppLocalizations.of(context).translate('registerAppBar').toString(),style: TextStyle(fontSize: ScreenSize.blockSizeHorizontal * 4, color: Colors.white)),
                      color: Colors.transparent,
                      shape: ContinuousRectangleBorder(
                          borderRadius: new BorderRadius.circular(2),
                          side: BorderSide(color: Color.fromARGB(255, 85, 255, 255))
                      ), onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Register()));
                    },
                    ),
                  ),
                ],
              ),
            )
        ),
      ),
    );
  }
}