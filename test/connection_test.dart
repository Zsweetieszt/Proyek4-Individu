import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logbook_app_001/services/mongo_services.dart';
import 'package:logbook_app_001/helpers/log_helper.dart';

void main() {
  const String sourceFile = "connection_test.dart";

  setUpAll(() async {
    await dotenv.load(mergeWith: {
      'MONGODB_URI': 'mongodb+srv://admin_logbook:admin123@dinanda041.zf9bfas.mongodb.net/logbook_db?retryWrites=true&w=majority&appName=Dinanda041',
      'LOG_LEVEL': '3',
      'LOG_MUTE': '',
    });
  });

  test(
    'Memastikan koneksi ke MongoDB Atlas berhasil via MongoService',
    () async {
      final mongoService = MongoService();

      await LogHelper.writeLog(
        "--- START CONNECTION TEST ---",
        source: sourceFile,
      );

      try {
        await mongoService.connect();
        expect(dotenv.env['MONGODB_URI'], isNotNull);

        await LogHelper.writeLog(
          "SUCCESS: Koneksi Atlas Terverifikasi",
          source: sourceFile,
          level: 2,
        );
      } catch (e) {
        await LogHelper.writeLog(
          "ERROR: Kegagalan koneksi - $e",
          source: sourceFile,
          level: 1,
        );
        fail("Koneksi gagal: $e");
      } finally {
        await mongoService.close();
        await LogHelper.writeLog("--- END TEST ---", source: sourceFile);
      }
    },
  );
}