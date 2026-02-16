// File: lib/features/onboarding/onboarding_view.dart
import 'package:flutter/material.dart';
// Menggunakan relative path agar aman (sesuaikan jika perlu)
import '../auth/login_view.dart'; 

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  int _step = 1; // State untuk melacak halaman (1, 2, atau 3)

  void _nextStep() {
    if (_step < 3) {
      setState(() {
        _step++;
      });
    } else {
      // Jika sudah step 3, pindah ke Login dan hapus Onboarding dari stack
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginView()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Halaman Onboarding"),
            const SizedBox(height: 20),
            // Menampilkan Angka Besar
            Text(
              '$_step',
              style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _nextStep,
              child: Text(_step == 3 ? "Mulai" : "Lanjut"),
            ),
          ],
        ),
      ),
    );
  }
}