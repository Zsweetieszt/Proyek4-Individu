class CounterController {
  int _counter = 0;
  int _step = 1;

  // Menyimpan riwayat aktivitas
  final List<String> _history = [];

  int get value => _counter;

  // Riwayat hanya bisa dibaca dari luar
  List<String> get history => List.unmodifiable(_history);

  // Update nilai step dari input user
  void updateStep(String value) {
    final parsed = int.tryParse(value);

    // Step boleh negatif atau positif, tapi tidak boleh 0
    if (parsed != null && parsed != 0) {
      _step = parsed;
    }
  }

  void increment() {
    // Jika step negatif, hasilnya otomatis pengurangan
    _counter += _step;
    _addHistory("Menambah $_step");
  }

  void decrement() {
    // Jika step negatif, pengurangan negatif = penambahan
    _counter -= _step;
    _addHistory("Mengurangi $_step");
  }

  void reset() {
    _counter = 0;
    _addHistory("Reset counter");
  }

  // Fungsi terpusat untuk mencatat riwayat
  void _addHistory(String action) {
    final time = DateTime.now();
    final formattedTime =
        "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";

    _history.add("$action pada jam $formattedTime");

    // Hanya simpan 5 aktivitas terakhir
    if (_history.length > 5) {
      _history.removeAt(0);
    }
  }
}
