import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';

part 'db.g.dart';

class Tokens extends Table {
  IntColumn get id => integer()();
  TextColumn get accessToken => text().nullable()();
  TextColumn get refreshToken => text().nullable()();
  IntColumn get expiresAt => integer().nullable()(); // epoch seconds
  @override
  Set<Column> get primaryKey => {id};
}
class Instruments extends Table {
  TextColumn get instrumentKey => text()();
  TextColumn get symbol => text()();
  TextColumn get name => text().nullable()();
  @override
  Set<Column> get primaryKey => {instrumentKey};
}
class MinuteBars extends Table {
  TextColumn get instrumentKey => text()();
  IntColumn get ts => integer()(); // epoch seconds
  RealColumn get open => real()();
  RealColumn get high => real()();
  RealColumn get low => real()();
  RealColumn get close => real()();
  RealColumn get volume => real()();
  @override
  Set<Column> get primaryKey => {instrumentKey, ts};
}
class Predictions extends Table {
  TextColumn get instrumentKey => text()();
  IntColumn get ts => integer()();
  IntColumn get horizon => integer()(); // 60
  RealColumn get retPred => real()();
  TextColumn get curve => text()(); // JSON array
}
class Clusters extends Table {
  IntColumn get ts => integer()();
  TextColumn get instrumentKey => text()();
  IntColumn get cluster => integer()();
  TextColumn get label => text()(); // profitable/neutral
}
@DriftDatabase(tables: [Tokens,Instruments,MinuteBars,Predictions,Clusters])
class AppDb extends _$AppDb {
  AppDb() : super(NativeDatabase(File('alpha.db')));
  @override
  int get schemaVersion => 1;
}