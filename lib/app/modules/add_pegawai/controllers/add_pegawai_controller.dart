import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddPegawaiController extends GetxController {
  RxBool isLoading = false.obs;
  RxBool isLoadingAddEmployee = false.obs;
  TextEditingController nameC = TextEditingController();
  TextEditingController nipC = TextEditingController();
  TextEditingController emailC = TextEditingController();
  TextEditingController passAdminC = TextEditingController();

  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> processAddEmployee() async {
    if (passAdminC.text.isNotEmpty) {
      isLoading.value = true;
      try {
        String emailAdmin = auth.currentUser!.email!;

        UserCredential userCredentialAdmin =
            await auth.signInWithEmailAndPassword(
          email: emailAdmin,
          password: passAdminC.text,
        );

        UserCredential employeeCredential =
            await auth.createUserWithEmailAndPassword(
          email: emailC.text,
          password: "password",
        );
        print(employeeCredential);

        if (employeeCredential.user != null) {
          String uid = employeeCredential.user!.uid;
          await firestore.collection("employee").add({
            "nip": nipC.text,
            "name": nameC.text,
            "email": emailC.text,
            "uid": uid,
            "role": "pegawai",
            "createdAt": DateTime.now().toIso8601String(),
          });

          await employeeCredential.user!.sendEmailVerification();
          await auth.signOut();

          // Login Ulang
          UserCredential userCredentialAdmin =
              await auth.signInWithEmailAndPassword(
            email: emailAdmin,
            password: passAdminC.text,
          );

          Get.back(); // close dialog
          Get.back(); // back to home
          Get.snackbar("Success", "Success add new employee");
          isLoadingAddEmployee.value = false;
        }
      } on FirebaseAuthException catch (e) {
        isLoadingAddEmployee.value = false;
        if (e.code == 'weak-password') {
          Get.snackbar('Error', 'Your password is too weak');
        } else if (e.code == 'email-already-in-use') {
          Get.snackbar('Error', 'Email already exist');
        } else if (e.code == 'wrong-password') {
          Get.snackbar('Error', 'wrong password');
        } else {
          Get.snackbar('Error', e.code);
        }
      } catch (e) {
        isLoadingAddEmployee.value = false;
        Get.snackbar('Error', "Can't add new employee");
      }
    } else {
      isLoading.value = false;
      Get.snackbar("Error", "Password is required");
    }
  }

  Future<void> addEmployee() async {
    if (nameC.text.isNotEmpty &&
        nipC.text.isNotEmpty &&
        emailC.text.isNotEmpty) {
      //execution
      isLoading.value = true;
      Get.defaultDialog(
          title: "Validasi Admin",
          content: Column(
            children: [
              const Text("Masukkan password anda..."),
              const SizedBox(height: 10),
              TextField(
                controller: passAdminC,
                autocorrect: false,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                ),
              )
            ],
          ),
          actions: [
            OutlinedButton(
              onPressed: () {
                isLoading.value = false;
                Get.back();
              },
              child: const Text('Cancel'),
            ),
            Obx(
              () => ElevatedButton(
                onPressed: () async {
                  if (isLoadingAddEmployee.isFalse) {
                    await processAddEmployee();
                  }
                  isLoading.value = false;
                },
                child: Text(
                  isLoadingAddEmployee.isFalse ? 'Add Employee' : "Loading...",
                ),
              ),
            ),
          ]);
    } else {
      Get.snackbar('Error', 'NIP, name, and email is empty');
    }
    print('test');
  }
}
