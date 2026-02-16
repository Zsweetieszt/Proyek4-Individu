class LoginController {
  final Map<String, String> _users = {
    'admin': '123',
    'mahasiswa': '123',
    'dosen': 'admin123',
  };

  // Variabel hitung percobaan gagal
  int failedAttempts = 0;

  bool login(String username, String password) {
    // validasi
    if (_users.containsKey(username) && _users[username] == password) {
      // Jika berhasil, reset percobaan gagal
      failedAttempts = 0;
      return true;
    } else {
      // Jika gagal, tambah hitungan kesalahan
      failedAttempts++;
      return false;
    }
  }

  // Validasi banned akun (lebih dari 3x salah)
  bool isLocked() {
    return failedAttempts >= 3;
  }

  // Fungsi untuk mereset kunci (dipanggil setelah timer 10 detik habis)
  void resetLock() {
    failedAttempts = 0;
  }
}