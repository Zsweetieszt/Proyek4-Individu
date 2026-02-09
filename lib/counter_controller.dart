class CounterController {
  int _counter = 0;
  int _step = 1;
  int get value => _counter;
  int get step => _step;

  // Mengubah nilai step berdasarkan input user
  // Parsing dan validasi
  void updateStep(String input) {
    final parsed = int.tryParse(input);

    if (parsed != null && parsed > 0) {
      _step = parsed;
    }
  }

  // Menambah counter
  void increment() {
    _counter += _step;
  }

  // Mengurangi counter tapi gaboleh < 0
  void decrement() {
    if (_counter - _step >= 0) {
      _counter -= _step;
    }
  }

  void reset() {
    _counter = 0;
  }
}
