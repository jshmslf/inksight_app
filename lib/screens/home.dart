import 'package:flutter/material.dart';
import 'package:inksight/constants/colors.dart';
import 'package:inksight/screens/camera.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: TextButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CameraScreen(),
            ),
          );
        },
        child: const Text('CAMERA'),
        style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: mainBlue,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            textStyle: const TextStyle(
                fontSize: 18,
                fontFamily: 'SFRounded',
                fontWeight: FontWeight.w700)),
      )),
    );
  }
}
