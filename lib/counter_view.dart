import 'package:flutter/material.dart';
import 'counter_controller.dart';

class CounterView extends StatefulWidget {
  const CounterView({super.key});

  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView> {
  // Controller berisi seluruh logika aplikasi
  final CounterController _controller = CounterController();

  // Controller untuk TextField step
  // Default diisi 1 agar sinkron dengan controller
  final TextEditingController _stepController =
      TextEditingController(text: '1');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("LogBook: Multi-Step Counter",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Label informasi
            const Text("Total Hitungan"),

            // Menampilkan nilai counter dari controller
            Text(
              '${_controller.value}',
              style: const TextStyle(fontSize: 40),
            ),

            const SizedBox(height: 20),

            // Input untuk menentukan nilai step
            // View hanya mengirim input mentah ke controller
            TextField(
              controller: _stepController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Step",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  // Parsing dan validasi tidak dilakukan di view
                  _controller.updateStep(value);
                });
              },
            ),

            const SizedBox(height: 20),

            // Tombol increment, decrement dan reset
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  heroTag: "minus",
                  onPressed: () {
                    setState(() {
                      _controller.decrement();
                    });
                  },
                  child: const Icon(Icons.remove),
                ),
                const SizedBox(width: 20),
                FloatingActionButton(
                  heroTag: "plus",
                  onPressed: () {
                    setState(() {
                      _controller.increment();
                    });
                  },
                  child: const Icon(Icons.add),
                ),
                const SizedBox(width: 20),
                FloatingActionButton(
                  heroTag: "reset",
                  onPressed: () {
                    setState(() {
                      _controller.reset();
                    });
                  },
                  child: const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Judul riwayat
            const Text(
              "Riwayat Aktivitas",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),

            // Menampilkan riwayat dari controller
            SizedBox(
              height: 150,
              child: ListView.builder(
                itemCount: _controller.history.length,
                itemBuilder: (context, index) {
                  return Text(
                    "- ${_controller.history[index]}",
                    style: const TextStyle(fontSize: 14),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
