import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:presence/app/routes/app_pages.dart';

class NewPasswordController extends GetxController {
  TextEditingController newPassC = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;
  void newPassword() async {
    if (newPassC.text.isNotEmpty) {
      if (newPassC.text != "password") {
        try {
          String email = auth.currentUser!.email!;
          await auth.currentUser!.updatePassword(newPassC.text);

          await auth.signOut();
          await auth.signInWithEmailAndPassword(
            email: email,
            password: newPassC.text,
          );
          Get.offAllNamed(Routes.HOME);
        } on FirebaseAuthException catch (e) {
          if (e.code == 'weak-password') {
            Get.snackbar('Error', 'Your password is too weak');
          }
        } catch (e) {
          Get.snackbar('Error', 'Cannot registered new password');
        }
      } else {
        Get.snackbar("Error", "New password cannot be 'password' again");
      }
    } else {
      Get.snackbar("Error", "Password is required");
    }
  }
}
