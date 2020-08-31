import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:beacons/models/user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final db = Firestore.instance;
  static String currentId;
  static String currentUserName;

  void getCurrentUser() async {
    FirebaseUser user = await _auth.currentUser();
    var fireUser = _userFromFirebaseUser(user);
    AuthService.currentId = fireUser.userId;
    await db.collection("usuarios").document(fireUser.userId).get().then((value) => {AuthService.currentUserName  = value.data["nombreUsuario"]});
  }

  User _userFromFirebaseUser(FirebaseUser user){
    return user !=null ? User(userId: user.uid) : null;
  }

  Stream<User> get user {
    return _auth.onAuthStateChanged.map(_userFromFirebaseUser);
  }

  Future signInWithEmailAndPassword(String email, String password) async{
    try{
      AuthResult result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      FirebaseUser user = result.user;
      getCurrentUser();
      return _userFromFirebaseUser(user);
    }catch(e){
      print(e.toString());
      return null;
    }
  }

  Future createUserWithEmailAndPassword(String email, String password) async{
    try{
      AuthResult result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      FirebaseUser user = result.user;
      AuthService.currentId = user.uid;
      return _userFromFirebaseUser(user);
    }catch(e){
      print(e.toString());
      return null;
    }
  }

  Future signOut() async{
    try{
      return await _auth.signOut();
    }catch(e){
      print(e.toString());
      return null;
    }
  }
}