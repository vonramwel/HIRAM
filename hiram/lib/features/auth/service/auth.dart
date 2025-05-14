import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'database.dart';
import '../../navigation/presentation/navigation.dart';
import '../../admin/presentation/admin_page.dart';

class AuthMethods {
  final FirebaseAuth auth = FirebaseAuth.instance;

  Future<User?> getCurrentUser() async {
    return auth.currentUser;
  }

  Future<String> getCurrentUserId() async {
    User? user = auth.currentUser;
    return user?.uid ?? '';
  }

  Future<void> signInWithEmail(
      BuildContext context, String email, String password) async {
    try {
      await auth.signInWithEmailAndPassword(email: email, password: password);

      Map<String, dynamic>? userData =
          await DatabaseMethods().getCurrentUserData();

      if (userData?['accountStatus'] == 'locked') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("This account is currently locked."),
        ));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => Navigation()), // ← Pass a flag
        );
        return;
      }

      if (userData?['accountStatus'] == 'banned') {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              "Your account has been banned. You can no longer access the app."),
        ));
        await auth.signOut(); // log out banned user
        return;
      }

      if (userData != null && userData['userType'] == 'admin') {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const AdminPage()));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Navigation()));
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = "";
      if (e.code == 'user-not-found') {
        errorMessage = "No User Found for that Email";
      } else if (e.code == 'wrong-password') {
        errorMessage = "Wrong Password Provided by User";
      }

      if (errorMessage.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.orangeAccent,
            content: Text(errorMessage, style: const TextStyle(fontSize: 18.0)),
          ),
        );
      }
    }
  }

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
          "id": userDetails.uid,
          "rating": null,
          "ratingCount": 0,
          "credibilityScore": 0,
          "contactNumber": "",
          "address": "",
          "bio": "",
          "transactionsCompleted": 0,
          "userType": "user",
          "accountStatus": null,
        };

        bool userExists =
            await DatabaseMethods().checkUserExists(userDetails.uid);

        if (!userExists) {
          await DatabaseMethods().addUser(userDetails.uid, userInfoMap);
        }

        Map<String, dynamic>? userData =
            await DatabaseMethods().getCurrentUserData();

        if (userData?['accountStatus'] == 'locked') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("This account is currently locked."),
          ));
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => Navigation()), // ← Pass a flag
          );
          return;
        }

        if (userData?['accountStatus'] == 'banned') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                "Your account has been banned. You can no longer access the app."),
          ));
          await auth.signOut();
          return;
        }

        if (userData != null && userData['userType'] == 'admin') {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) => const AdminPage()));
        } else {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => Navigation()));
        }
      }
    }
  }

  Future<bool> registerUser(BuildContext context, String email, String fullName,
      String password) async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = userCredential.user;

      if (user != null) {
        Map<String, dynamic> userInfoMap = {
          "id": user.uid,
          "email": user.email,
          "name": fullName,
          "imgUrl": null,
          "rating": null,
          "ratingCount": 0,
          "credibilityScore": 0,
          "contactNumber": "",
          "address": "",
          "bio": "",
          "transactionsCompleted": 0,
          "userType": "user",
          "accountStatus": null,
        };

        await DatabaseMethods().addUser(user.uid, userInfoMap);
      }

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content:
            Text("Registered Successfully", style: TextStyle(fontSize: 20.0)),
      ));

      return true;
    } on FirebaseAuthException catch (e) {
      String message = "An error occurred";
      if (e.code == 'weak-password') {
        message = "Password Provided is too Weak";
      } else if (e.code == "email-already-in-use") {
        message = "Account Already exists";
      }

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.orangeAccent,
        content: Text(message, style: const TextStyle(fontSize: 18.0)),
      ));

      return false;
    }
  }

  Future<void> resetPassword(BuildContext context, String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Password Reset Email has been sent!")));
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("No user found for that email.")));
      }
    }
  }
}
