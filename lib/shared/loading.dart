import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../app_localizations.dart';
import 'constants.dart';

class Loading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Material(
      child: Container(
        padding: EdgeInsets.fromLTRB(0,150.0,0,0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [appBackgroundColor1, appBackgroundColor2]),
        ),
        child: Column(
          children: <Widget>[
            SizedBox(height: 20.0,),
            Center(
              child: SpinKitDualRing(color: appBackgroundColor1, size: 50.0),
            ),
            SizedBox(height: 20.0,),
            Text(AppLocalizations.of(context).translate('loading').toString(), style: TextStyle(fontSize: 20.0,)),
          ],
        ),
      ),
    );
  }
}