import '../database/db_helper.dart';
import '../models/request_model.dart';

class RequestRepository {
  Future<void> add(RequestModel r) async {
    final db = await DBHelper.db;
    await db.insert('requests', r.toMap());
  }

  Future<List<RequestModel>> getAll() async {
    final db = await DBHelper.db;
    final data = await db.query('requests');
    return data.map((e) => RequestModel.fromMap(e)).toList();
  }

  Future<void> updateStatus(String id, RequestStatus status) async {
    final db = await DBHelper.db;
    await db.update('requests', {'status': status.index},
        where: 'id=?', whereArgs: [id]);
  }
}