import '../features/logbook/models/log_model.dart';

class UserRole {
  static const String ketua   = 'Ketua';
  static const String anggota = 'Anggota';
}

class LogAction {
  static const String create = 'create';
  static const String read   = 'read';
  static const String update = 'update';
  static const String delete = 'delete';
}

/// Policy Manager terpusat
class AccessPolicy {
  static bool canPerform({
    required String currentUsername,
    required String currentRole,
    required String action,
    LogModel? log,
  }) {
    switch (action) {

      // Semua orang boleh membuat catatan baru
      case LogAction.create:
        return true;

      // Boleh baca jika pemilik, atau catatan publik
      case LogAction.read:
        if (log == null) return true;
        return isOwner(currentUsername: currentUsername, log: log) || log.isPublic;

      // Update:
      // - Pemilik selalu boleh edit catatannya sendiri
      // - Ketua juga boleh edit catatan PUBLIK milik siapapun dalam tim
      case LogAction.update:
        if (log == null) return false;
        if (isOwner(currentUsername: currentUsername, log: log)) return true;
        if (currentRole == UserRole.ketua && log.isPublic) return true;
        return false;

      // Delete:
      // - Pemilik selalu boleh hapus catatannya sendiri
      // - Ketua juga boleh hapus catatan PUBLIK milik siapapun dalam tim
      case LogAction.delete:
        if (log == null) return false;
        if (isOwner(currentUsername: currentUsername, log: log)) return true;
        if (currentRole == UserRole.ketua && log.isPublic) return true;
        return false;

      default:
        return false;
    }
  }

  /// Cek kepemilikan catatan
  static bool isOwner({required String currentUsername, required LogModel log}) {
    return log.username == currentUsername || log.authorId == currentUsername;
  }

  // Cek apakah user bisa melihat catatan
  static bool canView({
    required String currentUsername,
    required String teamId,
    required LogModel log,
  }) {
    if (isOwner(currentUsername: currentUsername, log: log)) return true;
    if (log.isPublic && log.teamId == teamId) return true;
    return false;
  }
}