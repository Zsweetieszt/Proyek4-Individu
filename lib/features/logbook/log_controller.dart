import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../services/mongo_services.dart';
import '../../services/access_control_service.dart';
import 'models/log_model.dart';

class LogController {
  static const String _boxName = 'logs_box';
  final MongoService _mongo = MongoService();

  final String username;
  final String teamId;

  // ValueNotifier untuk reactive UI, semua log yang boleh dilihat user ini
  final ValueNotifier<List<LogModel>> logsNotifier = ValueNotifier([]);

  // ValueNotifier khusus search
  final ValueNotifier<String> searchQuery = ValueNotifier('');

  LogController({required this.username, required this.teamId}) {
    _loadFromHive();
    // Setiap query berubah, otomatis filter ulang
    searchQuery.addListener(_loadFromHive);
  }

  Box<LogModel> get _box => Hive.box<LogModel>(_boxName);

  // LOAD & FILTER

  //  - Catatan milik user sendiri: selalu muncul
  //  - Catatan publik dari tim yang sama: muncul
  //  - Catatan private milik orang lain: TIDAK muncul
  void _loadFromHive() {
    final query = searchQuery.value.toLowerCase();
    final allLogs = _box.values.toList();

    final visible = allLogs.where((log) {
      // visibility check
      final canSee = AccessPolicy.canView(
        currentUsername: username,
        teamId: teamId,
        log: log,
      );
      if (!canSee) return false;

      // Filter search query
      if (query.isEmpty) return true;
      return log.title.toLowerCase().contains(query) ||
          log.description.toLowerCase().contains(query);
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    logsNotifier.value = visible;
  }

  // SYNC FROM CLOUD

  Future<void> syncFromCloud() async {
    try {
      final cloudLogs = await _mongo.getLogs(username: username, teamId: teamId);
      for (final log in cloudLogs) {
        final key = log.id?.toHexString() ?? '${log.username}_${log.date}';
        // Cek duplikat berdasarkan username+date agar tidak terjadi duplikat saat sync
        // meskipun key Hive lokal (username_date) berbeda dengan key cloud (ObjectId hex)
        final isDuplicate = _box.values.any(
          (local) => local.username == log.username && local.date == log.date,
        );
        if (!isDuplicate) {
          await _box.put(key, log.copyWith(isSynced: true));
        }
      }
      _loadFromHive();
    } catch (e) {
      debugPrint("Sync from cloud failed: $e");
    }
  }

  // CREATE

  Future<void> addLog(LogModel log) async {
    final key = '${log.username}_${log.date}';
    // 1. Simpan ke Hive dulu (offline-first)
    await _box.put(key, log.copyWith(isSynced: false));
    _loadFromHive();

    // 2. Upload ke MongoDB di background
    try {
      await _mongo.insertLog(log);
      await _box.put(key, log.copyWith(isSynced: true));
      _loadFromHive();
    } catch (e) {
      debugPrint("Cloud insert failed, kept in Hive: $e");
    }
  }

  // UPDATE

  Future<void> updateLog(LogModel updatedLog) async {
    final key = updatedLog.id?.toHexString() ?? '${updatedLog.username}_${updatedLog.date}';
    await _box.put(key, updatedLog.copyWith(isSynced: false));
    _loadFromHive();

    try {
      await _mongo.updateLog(updatedLog);
      await _box.put(key, updatedLog.copyWith(isSynced: true));
      _loadFromHive();
    } catch (e) {
      debugPrint("Cloud update failed: $e");
    }
  }

  // DELETE

  Future<void> removeLog(LogModel log) async {
    final key = log.id?.toHexString() ?? '${log.username}_${log.date}';
    await _box.delete(key);
    _loadFromHive();

    if (log.id != null) {
      try {
        await _mongo.deleteLog(log.id!);
      } catch (e) {
        debugPrint("Cloud delete failed: $e");
      }
    }
  }

  // BACKGROUND SYNC (pending logs saat offline)

  Future<void> syncPendingLogs() async {
    final pending = _box.values.where((log) => !log.isSynced).toList();
    for (final log in pending) {
      try {
        if (log.id != null) {
          await _mongo.updateLog(log);
        } else {
          await _mongo.insertLog(log);
        }
        final key = log.id?.toHexString() ?? '${log.username}_${log.date}';
        await _box.put(key, log.copyWith(isSynced: true));
      } catch (e) {
        debugPrint("Pending sync failed for '${log.title}': $e");
      }
    }
    _loadFromHive();
  }

  //FORMAT DATE

  static String formatDate(DateTime dt) {
    final months = ['Jan','Feb','Mar','Apr','Mei','Jun',
                    'Jul','Ags','Sep','Okt','Nov','Des'];
    return '${dt.day} ${months[dt.month-1]} ${dt.year}, '
        '${dt.hour.toString().padLeft(2,'0')}:'
        '${dt.minute.toString().padLeft(2,'0')}';
  }

  void dispose() {
    searchQuery.removeListener(_loadFromHive);
    searchQuery.dispose();
    logsNotifier.dispose();
  }
}