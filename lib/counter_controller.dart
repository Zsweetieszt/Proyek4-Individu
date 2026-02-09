class CounterController {
  // Menyimpan nilai counter utama
  int _counter = 0;

  // Menyimpan nilai langkah (step), default 1
  int _step = 1;

  // Getter untuk mengambil nilai counter
  int get value => _counter;

  // Getter untuk mengambil nilai step
  int get step => _step;

  // Mengubah nilai step berdasarkan input user
  // Parsing dan validasi dilakukan di controller
  void updateStep(String input) {
    final parsed = int.tryParse(input);

    // Step hanya boleh angka dan lebih dari 0
    if (parsed != null && parsed > 0) {
      _step = parsed;
    }
  }

  // Menambah counter sesuai nilai step
  void increment() {
    _counter += _step;
  }

  // Mengurangi counter sesuai nilai step
  // Dicegah agar nilai counter tidak menjadi negatif
  void decrement() {
    if (_counter - _step >= 0) {
      _counter -= _step;
    }
  }

  // Mengembalikan counter ke nilai awal
  void reset() {
    _counter = 0;
  }
}
