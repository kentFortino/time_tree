import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:linktree_clone/model/calendar_model.dart';

class UserProvider extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  User? _user;

  User? get user => _user;

  set user(User? user) {
    _user = user;
    notifyListeners();
  }

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  String _errorMessage = "";

  String get errorMessage => _errorMessage;

  set errorMessage(String errorMessage) {
    _errorMessage = errorMessage;
    notifyListeners();
  }

  void setIsLoading(bool isLoading) {
    _isLoading = isLoading;
    notifyListeners();
  }

  final _firebaseAuth = FirebaseAuth.instance;

  Future<void> login() async {
    try {
      setIsLoading(true);
      try {
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        final GoogleSignInAuthentication? googleAuth =
            await googleUser?.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);

        user = _firebaseAuth.currentUser;
        final calendar = await _db
            .collection('calendars')
            .where("createdBy", isEqualTo: _user?.uid)
            .get();
        final docRef = _db.collection('calendars').doc();
        final CalendarModel data = CalendarModel(
            id: docRef.id, name: "custom calendar", createdBy: _user!.uid);
        if (calendar.docs.isEmpty) {
          await _db.collection('calendars').add(data.toJson());
        }
      } on Exception catch (e) {
        errorMessage = e.toString();
      }
    } finally {
      setIsLoading(false);
    }
  }
}
