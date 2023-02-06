import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:presence/app/routes/app_pages.dart';

class LoginController extends GetxController {
  RxBool isLoading = false.obs;
  TextEditingController emailC = TextEditingController();
  TextEditingController passwordC = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;
  Future<void> login() async {
    if (emailC.text.isNotEmpty && passwordC.text.isNotEmpty) {
      isLoading.value = true;
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailC.text,
          password: passwordC.text,
        );
        print(userCredential);

        if (userCredential.user != null) {
          if (userCredential.user!.emailVerified) {
            isLoading.value = false;
            if (passwordC.text == "password") {
              Get.offAllNamed(Routes.NEW_PASSWORD);
            } else {
              Get.offAllNamed(Routes.HOME);
            }
          } else {
            Get.defaultDialog(
              title: "Not Verified",
              middleText: "Please verification your email.",
              actions: [
                OutlinedButton(
                  onPressed: () {
                    isLoading.value = false;
                    Get.back();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await userCredential.user!.sendEmailVerification();
                      Get.back();
                      Get.snackbar(
                        "Success",
                        "Please check your email!.",
                      );
                      isLoading.value = false;
                    } catch (e) {
                      isLoading.value = false;
                      Get.snackbar(
                        "Error",
                        "Cannot resend email verification.",
                      );
                    }
                  },
                  child: const Text('Resend Verification'),
                ),
              ],
            );
          }
        }
        isLoading.value = false;
      } on FirebaseAuthException catch (e) {
        isLoading.value = false;
        if (e.code == 'user-not-found') {
          Get.snackbar("error", "email is not registered");
          print('No user found for that email.');
        } else if (e.code == 'wrong-password') {
          Get.snackbar("error", "wrong password");
          print('Wrong password provided for that user.');
        }
      } catch (e) {
        isLoading.value = false;
        Get.snackbar("Error", "Cannot login");
      }
    } else {
      Get.snackbar("error", "email and password are required");
    }
  }
}
