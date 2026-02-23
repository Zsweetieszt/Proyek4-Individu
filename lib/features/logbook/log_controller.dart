import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/log_model.dart';

class LogController {
  final ValueNotifier<List<LogModel>> logsNotifier =
      ValueNotifier<List<LogModel>>([]);

  // Key yang dipakai untuk menyimpan/membaca data di SharedPreferences
  static const String _storageKey = 'logbook_data';

  Future<void> loadLogs(String username) async {
    final prefs = await SharedPreferences.getInstance();
    // Key unik per user, misal: 'logbook_data_admin'
    final String? jsonString = prefs.getString('${_storageKey}_$username');

    if (jsonString != null) {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      final List<LogModel> loadedLogs =
          jsonList.map((item) => LogModel.fromMap(item)).toList();
      logsNotifier.value = loadedLogs;
    }
  }

  // Ubah List<LogModel> → JSON String → simpan ke SharedPrefs.
  Future<void> _saveLogs(String username) async {
    final prefs = await SharedPreferences.getInstance();
    // 1. Map setiap LogModel → Map menggunakan toMap()
    final List<Map<String, dynamic>> mapList =
        logsNotifier.value.map((log) => log.toMap()).toList();
    // 2. Encode List<Map> → JSON String
    final String jsonString = jsonEncode(mapList);
    // 3. Simpan ke SharedPreferences
    await prefs.setString('${_storageKey}_$username', jsonString);
  }

  // CREATE: Tambah catatan baru ke logbook. Kita buat list baru dengan item baru di depan.
  void addLog(String username, String title, String description) {
    final newLog = LogModel(
      title: title,
      description: description,
      timestamp: DateTime.now(),
    );
    // Buat list baru dengan semua item lama + item baru di depan
    logsNotifier.value = [newLog, ...logsNotifier.value];
    _saveLogs(username); // Auto-save setiap ada perubahan
  }

  // UPDATE: Update catatan berdasarkan index. Kita buat list baru dengan item yang diupdate.
  void updateLog(String username, int index, String title, String description) {
    final updatedLog = LogModel(
      title: title,
      description: description,
      timestamp: logsNotifier.value[index].timestamp,
    );
    // Buat salinan list, ganti item di index tertentu
    final updatedList = List<LogModel>.from(logsNotifier.value);
    updatedList[index] = updatedLog;
    logsNotifier.value = updatedList;
    _saveLogs(username); // Auto-save
  }

  // DELETE: Hapus catatan berdasarkan index. Kita buat list baru tanpa item yang dihapus.
  void removeLog(String username, int index) {
    final updatedList = List<LogModel>.from(logsNotifier.value);
    updatedList.removeAt(index);
    logsNotifier.value = updatedList;
    _saveLogs(username); // Auto-save
  }

  // Dispose ValueNotifier saat controller tidak dipakai lagi
  void dispose() {
    logsNotifier.dispose();
  }
}