import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:beacons/models/user.dart';
import 'package:beacons/screens/wrapper.dart';
import 'package:beacons/services/AuthService.dart';
import 'package:provider/provider.dart';
import 'app_localizations.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<User>.value(
      value: AuthService().user,
      child: MaterialApp(
        title: "Tracking Beacon",
        home: Wrapper(),
        supportedLocales: [
          Locale('en','US'),
          Locale('es','ES')
        ],
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        localeResolutionCallback: (locale, supportedLocales){
          for (var supportedLocale in supportedLocales){
            if(supportedLocale.languageCode == locale.languageCode &&
                supportedLocale.countryCode == locale.countryCode){
              return supportedLocale;
            }
          }
          return supportedLocales.first;
        },
      ),
    );
  }
}
