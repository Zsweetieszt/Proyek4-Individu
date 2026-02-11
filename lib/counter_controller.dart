class CounterController {
  int _counter = 0;
  int _step = 1;

  final List<Map<String, String>> _history = [];

  int get value => _counter;
  List<Map<String, String>> get history => List.unmodifiable(_history);

  // Update nilai step 
  void updateStep(String value) {
    final parsed = int.tryParse(value);

    // Validasi Nilai Step
    if (parsed != null && parsed != 0) {
      _step = parsed;
    }
  }
  
  void increment() {
    _counter += _step;
    // parameter add untuk penanda ini penambahan
    _addHistory("Menambah $_step", 'add');
  }

  void decrement() {
    _counter -= _step;
    // parameter substract untuk penanda ini pengurangan
    _addHistory("Mengurangi $_step", 'subtract');
  }

  void reset() {
    _counter = 0;
    // parameter reset untuk penanda ini reset
    _addHistory("Reset counter", 'reset');
  }

  // Menambahkan riwayat aktivitas dengan tipe dan aksi yang ditentukan
  void _addHistory(String action, String type) {
    final time = DateTime.now();
    final formattedTime =
        "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";

    // Menyimpan data pakai MAP
    _history.add({
      'action': "$action pada jam $formattedTime",
      'type': type,
      'time': formattedTime,
    });

    // Batasi riwayat hanya 5 entri terakhir
    if (_history.length > 5) {
      _history.removeAt(0);
    }
  }
}