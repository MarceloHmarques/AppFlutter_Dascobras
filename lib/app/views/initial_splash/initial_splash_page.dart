import 'package:DasCobras/app/views/home/home_page.dart';
import 'package:DasCobras/app/views/login/login_page.dart';
import 'package:DasCobras/app/viewmodels/splash_viewmodel/splash_viewmodel.dart';
import 'package:flutter/material.dart';

class InitialSplashPage extends StatefulWidget {
  const InitialSplashPage({super.key});

  @override
  State<InitialSplashPage> createState() => _InitialSplashPageState();
}

class _InitialSplashPageState extends State<InitialSplashPage> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () async {
      final splashViewModel = SplashViewmodel();

      final canAccess = await splashViewModel.canEnterApp();

      if (!mounted) return;

      if (canAccess) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final sizeHeight = MediaQuery.of(context).size.height;
    final sizeWidth = MediaQuery.of(context).size.width;

    const nameEmp = 'EVOLUTEC';

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset(
                'lib/app/assets/img/Logo.png',
                width: sizeWidth * 0.5,
                height: sizeHeight * 0.5,
              ),

              const Spacer(),
              const Text('from', style: TextStyle(fontSize: 12)),
              const Text(
                nameEmp,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
