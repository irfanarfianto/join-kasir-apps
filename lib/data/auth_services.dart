import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:http/http.dart' as http;
import 'package:join_kasir/constants/contstants.dart';
import 'package:join_kasir/pages/auth/login_page.dart';
import 'package:join_kasir/pages/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthenticationController {
  final isLoading = false.obs;
  final token = ''.obs;
  final rememberMeKey = 'remember_me';

  // Method untuk login
  Future<void> login({
    required String username,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      // Validasi input
      if (username.isEmpty || password.isEmpty) {
        throw 'Username dan password harus diisi';
      }

      isLoading.value = true;
      var data = {
        'username': username,
        'password': password,
      };

      var response = await http.post(
        Uri.parse('${Constants.url}login'),
        headers: {
          'Accept': 'application/json',
        },
        body: data,
      );

      if (response.statusCode == 200) {
        // Jika respons berhasil, simpan token
        isLoading.value = false;
        token.value = json.decode(response.body)['token'];

        // Simpan token ke shared preferences jika rememberMe bernilai true
        if (rememberMe) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token.value);
          await prefs.setBool(rememberMeKey, true);
        }

        // Navigasi ke halaman beranda
        Get.offAll(() => const HomePage(
              title: 'Join Kasir',
            ));
      } else {
        // Jika respons tidak berhasil, tampilkan pesan kesalahan
        isLoading.value = false;
        var responseBody = json.decode(response.body);
        var errorMessage = responseBody != null
            ? responseBody['message'] ?? 'Terjadi kesalahan'
            : 'Terjadi kesalahan';

        Get.snackbar(
          'Error',
          errorMessage,
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        print(json.decode(response.body));
      }
    } catch (e) {
      // Tangani kesalahan
      isLoading.value = false;
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
      );
      print(e.toString());
    }
  }

  // Method untuk logout
  static void logout(BuildContext context) async {
    // Menghapus token dari shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('remember_me');

    // Navigasi kembali ke halaman login
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }
}
