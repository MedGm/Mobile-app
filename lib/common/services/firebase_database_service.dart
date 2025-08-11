import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';

final firebaseDatabaseServiceProvider = Provider<RealtimeDatabaseService>(
  (ref) => RealtimeDatabaseService(FirebaseDatabase.instance),
);

class RealtimeDatabaseService {
  RealtimeDatabaseService(this._db);
  final FirebaseDatabase _db;

  Future<String?> readString(String path) async {
    final snapshot = await _db.ref(path).get();
    final value = snapshot.value;
    if (value is String) return value;
    return value?.toString();
  }

  Future<dynamic> read(String path) async {
    final snapshot = await _db.ref(path).get();
    return snapshot.value;
  }

  Future<void> writeAt(String path, Object value) {
    return _db.ref(path).set(value);
  }

  Future<void> updateAt(String path, Map<String, Object?> value) {
    return _db.ref(path).update(value);
  }

  Future<void> deleteAt(String path) {
    return _db.ref(path).remove();
  }
}
