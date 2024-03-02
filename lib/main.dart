import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:join_kasir/pages/auth/login_page.dart';
import 'package:join_kasir/splash%20screen/splash_screen.dart';
import 'package:join_kasir/pages/home_page.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final box = GetStorage();
    final token = box.read('token');
    final isLoggedIn = token != null;

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Join Kasir',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // Jika pengguna telah login sebelumnya dan belum logout, arahkan langsung ke halaman beranda.
      // Jika tidak, arahkan ke halaman splash screen untuk menentukan rute berikutnya.
      initialRoute: isLoggedIn ? '/home' : '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/home': (context) => isLoggedIn
            ? const HomePage(title: 'Join Kasir')
            : const LoginPage(),
        '/login': (context) => const LoginPage(),
      },
    );
  }
}
