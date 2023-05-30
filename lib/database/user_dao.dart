import 'package:isar/isar.dart';
import 'package:isar_example/database/isar_helper.dart';
import 'package:isar_example/models/user.dart';

class UserDao {
  final isar = IsarHelper.instance.isar;

  Future<List<User>> getAll() async {
    return isar.users.where().findAll();
  }

  Future<bool> deleteOne(User user) async {
    return isar.writeTxn(() => isar.users.delete(user.id));
  }

  Future<int> upsert(User user) async {
    return isar.writeTxn(() => isar.users.put(user));
  }

  Stream<List<User>> watchUsers() async* {
    yield* isar.users.where().watch(fireImmediately: true);
  }

  Stream<List<User>> watchUsersByName(String str) async*{
    yield* isar.users.filter().nameContains(str).watch(fireImmediately: true);
  }


  


 





 
}
