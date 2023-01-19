import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddPegawaiController extends GetxController {
  TextEditingController nameC = TextEditingController();
  TextEditingController nipC = TextEditingController();
  TextEditingController emailC = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  void addPegawai() async {
    if (nameC.text.isNotEmpty &&
        nipC.text.isNotEmpty &&
        emailC.text.isNotEmpty) {
      //execution
      try {
        UserCredential userCredential =
            await auth.createUserWithEmailAndPassword(
          email: emailC.text,
          password: "password",
        );
        print(userCredential);

        if (userCredential.user != null) {
          String uid = userCredential.user!.uid;
          await firestore.collection("employee").add({
            "nip": nipC.text,
            "name": nameC.text,
            "email": emailC.text,
            "uid": uid,
            "createdAt": DateTime.now().toIso8601String(),
          });

          await userCredential.user!.sendEmailVerification();
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          Get.snackbar('Error', 'Your password is too weak');
        } else if (e.code == 'email-already-in-use') {
          Get.snackbar('Error', 'Email already exist');
        }
      } catch (e) {
        Get.snackbar('Error', "Can't add new employee");
      }
    } else {
      Get.snackbar('Error', 'NIP, name, and email is empty');
    }
    print('test');
  }
}
