import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mass_text_flutter/models/user.dart';
import 'package:mass_text_flutter/styles.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  MyUser _userFromFirebaseUser(User user) {
    return user == null ? null : MyUser(uid: user.uid, email: user.email ?? "NaN");
  }

  Stream<MyUser> get userWithNotifier {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  static Future<MyUser> get currentUser async {
    User user = await _auth.currentUser;
    return user == null ? null : MyUser(uid: user.uid, email: user.email ?? "NaN");
  }

  Future signInAnon() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<MyUser> googleSignIn() async {
    try {
      GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential result = await _auth.signInWithCredential(credential);
      User user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future registerWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User user = result.user;

      // await DatabaseService(uid: user.uid).updateUserData('0', '', 100);
      return _userFromFirebaseUser(user);
    } on FirebaseAuthException catch (e) {
      print(e.toString());
      MyToast.show(e.code == "unknown" ? "Cannot connect to the servers" : e.message, isLong: true);
    } catch (e) {
      print(e.toString());
      MyToast.show(e.toString(), isLong: true);
      return null;
    }
  }

  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User user = result.user;
      return _userFromFirebaseUser(user);
    } on FirebaseAuthException catch (e) {
      print(e.toString());
      String toShow = "";
      if (e.code == "wrong-password")
        toShow = "Incorrect password";
      else if (e.code == "unknown")
        toShow = "Cannot connect to the servers";
      else
        toShow = e.message;
      MyToast.show(toShow, isLong: true);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<bool> signOut() async {
    try {
      bool isgoogleSignedIn = await _googleSignIn.isSignedIn();
      if (isgoogleSignedIn) await _googleSignIn.signOut();
      await _auth.signOut();
      return true;
    } catch (e) {
      print(e.toString());
      MyToast.show("Log Out Failed");
      return false;
    }
  }
}
