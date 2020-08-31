import 'package:cloud_firestore/cloud_firestore.dart';
class userPassingBy {
  final String userPassingById;
  final String nombreUser;
  final Timestamp fechaPassingBy;

  userPassingBy({
    this.userPassingById, this.nombreUser, this.fechaPassingBy
  });
}