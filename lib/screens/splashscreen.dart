// ignore_for_file: must_call_super

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:inksight/constants/colors.dart';
import 'package:inksight/screens/home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    Future.delayed(const Duration(seconds: 5), () {
      Navigator.of(context)
          .pushReplacement(MaterialPageRoute(builder: (_) => const Home()));
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [mainBlue, Color.fromARGB(255, 35, 14, 223)],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/img/logo-white.png',
              height: 100,
            ),
            const SizedBox(
              height: 10,
            ),
            const Text.rich(
              TextSpan(
                style: TextStyle(
                  fontFamily: 'Futura',
                  fontSize: 34,
                  shadows: [
                    Shadow(
                      offset: Offset(2.0, 2.0),
                      blurRadius: 3.0,
                      color: Color.fromARGB(62, 0, 0, 0),
                    ),
                  ],
                ),
                children: [
                  TextSpan(
                    text: 'Ink',
                    style: TextStyle(color: Colors.white),
                  ),
                  TextSpan(
                    text: 'Sight',
                    style: TextStyle(color: Color.fromARGB(255, 3, 5, 94)),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            const Text(
              'Penmanship Processing:\nEmpowering Computer Vision\nto Read Penmanship',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'SFDisplay',
                fontSize: 11,
                color: Colors.white,
                shadows: [
                  Shadow(
                    offset: Offset(2.0, 2.0),
                    blurRadius: 3.0,
                    color: Color.fromARGB(62, 0, 0, 0),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
