// File: lib/features/logbook/log_controller.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/log_model.dart';

class LogController {
  final ValueNotifier<List<LogModel>> logsNotifier = ValueNotifier([]);
  ValueNotifier<List<LogModel>> filteredLogs = ValueNotifier([]);

  static const String _storageKey = 'user_logs_data';

  LogController() {
    loadFromDisk();
  }

  // searchLog: Filter logs berdasarkan query, update filteredLogs
  void searchLog(String query) {
    if (query.isEmpty) {
      // Kosong Maka, tampilkan semua
      filteredLogs.value = logsNotifier.value;
    } else {
      // Ada query Maka, filter yang judulnya mengandung teks
      filteredLogs.value = logsNotifier.value
          .where(
            (log) => log.title.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    }
  }

  // Create
  void addLog(String title, String desc, String category) {
    final newLog = LogModel(
      title: title,
      description: desc,
      // Simpan tanggal sebagai String
      date: _formatDate(DateTime.now()),
      category: category,
      username: '',
    );
    logsNotifier.value = [...logsNotifier.value, newLog];
    // Sync ke filteredLogs agar UI ikut update
    filteredLogs.value = logsNotifier.value;
    saveToDisk();
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}, $hour:$minute';
  }


  // UPDATE
  void updateLog(int index, String title, String desc, String category) {
    // index dari filteredLogs Maka, cari index asli di logsNotifier
    final logToUpdate = filteredLogs.value[index];
    final originalIndex = logsNotifier.value.indexOf(logToUpdate);

    final currentLogs = List<LogModel>.from(logsNotifier.value);
    currentLogs[originalIndex] = LogModel(
      title: title,
      description: desc,
      date: logToUpdate.date, // Agar tanggal tidak berubah
      category: category,
      username: logToUpdate.username,
    );
    logsNotifier.value = currentLogs;
    filteredLogs.value = logsNotifier.value;
    saveToDisk();
  }

  // DELETE
  void removeLog(int index) {
    // index dari filteredLogs Maka, cari index asli di logsNotifier
    final logToRemove = filteredLogs.value[index];
    final originalIndex = logsNotifier.value.indexOf(logToRemove);

    final currentLogs = List<LogModel>.from(logsNotifier.value);
    currentLogs.removeAt(originalIndex);
    logsNotifier.value = currentLogs;
    filteredLogs.value = logsNotifier.value;
    saveToDisk();
  }

  // SAVE
  Future<void> saveToDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData =
        jsonEncode(logsNotifier.value.map((e) => e.toMap()).toList());
    await prefs.setString(_storageKey, encodedData);
  }

  // LOAD
  Future<void> loadFromDisk() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_storageKey);
    if (data != null) {
      final List decoded = jsonDecode(data);
      logsNotifier.value =
          decoded.map((e) => LogModel.fromMap(e)).toList();
    }
    // Setelah load, sync filteredLogs dengan semua data
    filteredLogs.value = logsNotifier.value;
  }

  // Dispose method untuk membersihkan ValueNotifier
  void dispose() {
    logsNotifier.dispose();
    filteredLogs.dispose();
  }
}