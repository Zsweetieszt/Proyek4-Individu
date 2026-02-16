import 'package:flutter/material.dart';
import 'dart:async'; // Import untuk Timer
import 'login_controller.dart';
import '../logbook/counter_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final LoginController _controller = LoginController();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  // State Tambahan
  bool _isObscure = true; // Untuk Show/Hide Password
  bool _isLocked = false; // Untuk status tombol login (Disabled/Enabled)

  void _handleLogin() {
    String user = _userController.text;
    String pass = _passController.text;

    // 1. Validasi Input Kosong (Security Logic)
    if (user.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Username dan Password tidak boleh kosong!"),
          backgroundColor: Colors.orange,
        ),
      );
      return; // Stop proses jika kosong
    }

    // 2. Panggil Logika Login dari Controller
    bool isSuccess = _controller.login(user, pass);

    if (isSuccess) {
      // Jika Sukses: Pindah Halaman
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CounterView(username: user),
        ),
      );
    } else {
      // Jika Gagal: Cek apakah terkunci?
      if (_controller.isLocked()) {
        setState(() {
          _isLocked = true; // Disable tombol
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Terlalu banyak percobaan! Tunggu 10 detik."),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );

        // Timer 10 Detik untuk membuka kunci
        Timer(const Duration(seconds: 10), () {
          setState(() {
            _isLocked = false; // Enable tombol kembali
            _controller.resetLock(); // Reset counter di controller
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Silakan coba login kembali."),
              backgroundColor: Colors.green,
            ),
          );
        });
      } else {
        // Jika Gagal tapi belum terkunci (percobaan ke 1 atau 2)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "Login Gagal! Sisa percobaan: ${3 - _controller.failedAttempts}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login Gatekeeper")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, size: 80, color: Colors.indigo),
            const SizedBox(height: 20),
            
            // Input Username
            TextField(
              controller: _userController,
              decoration: const InputDecoration(
                labelText: "Username",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            
            // Input Password dengan Fitur Show/Hide
            TextField(
              controller: _passController,
              obscureText: _isObscure, // Menggunakan variabel state
              decoration: InputDecoration(
                labelText: "Password",
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.vpn_key),
                // Tombol Mata (Show/Hide)
                suffixIcon: IconButton(
                  icon: Icon(
                    _isObscure ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscure = !_isObscure; // Toggle status
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Tombol Login
            ElevatedButton(
              // Jika _isLocked true, onPressed jadi null (tombol disabled)
              onPressed: _isLocked ? null : _handleLogin,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: _isLocked ? Colors.grey : Colors.indigo,
                foregroundColor: Colors.white,
              ),
              child: Text(_isLocked ? "Tunggu..." : "Masuk"),
            ),
          ],
        ),
      ),
    );
  }
}