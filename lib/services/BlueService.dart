import 'package:flutter_blue/flutter_blue.dart';
import 'package:system_shortcuts/system_shortcuts.dart';

class BlueService {
    
  isBluetoothOn() async{
    FlutterBlue bluetoothInstance = FlutterBlue.instance;
    return await bluetoothInstance.isOn==true? true: false;
  }

  bluetoothChangeState() async {
    FlutterBlue bluetoothInstance = FlutterBlue.instance;
    await SystemShortcuts.bluetooth().then((value) => isBluetoothOn());
  }

}

