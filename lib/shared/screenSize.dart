import 'package:flutter/widgets.dart';

//Clase ScreenSize inicializa variables de manera que obtengan valores
// porcentuales de pantalla, que nos dan porcentajes para nuestra
// aplicacion en distintos dispostivos

class ScreenSize {
  static MediaQueryData _mediaQueryData;
  static double screenWidth;
  static double screenHeight;
  static double blockSizeHorizontal;
  static double blockSizeVertical;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;
  }
}