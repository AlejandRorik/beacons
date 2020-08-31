import 'package:cloud_firestore/cloud_firestore.dart';
class Location {
  final String locationId;
  final num latitude;
  final num longitude;
  final String nombreBeacon;
  final Timestamp fechaLocation;

  Location({
    this.locationId, this.latitude, this.longitude, this.nombreBeacon, this.fechaLocation
  });
}