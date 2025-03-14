import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'database.dart';
import '../../listing/presentation/homepage.dart';

class AuthMethods {
  final FirebaseAuth auth = FirebaseAuth.instance;

  /// Get the currently signed-in user
  Future<User?> getCurrentUser() async {
    return auth.currentUser;
  }

  /// Get the current user's UID
  Future<String> getCurrentUserId() async {
    User? user = auth.currentUser;
    return user?.uid ?? ''; // Returns empty string if no user is signed in
  }

  /// Sign in with Google and navigate to homepage if successful
  Future<void> signInWithGoogle(BuildContext context) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleSignInAuthentication.idToken,
        accessToken: googleSignInAuthentication.accessToken,
      );

      UserCredential result = await auth.signInWithCredential(credential);
      User? userDetails = result.user;

      if (userDetails != null) {
        Map<String, dynamic> userInfoMap = {
          "email": userDetails.email,
          "name": userDetails.displayName,
          "imgUrl": userDetails.photoURL,
          "id": userDetails.uid
        };

        await DatabaseMethods().addUser(userDetails.uid, userInfoMap).then((_) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => HomePage()));
        });
      }
    }
  }
}
