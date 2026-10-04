# sqflite (sqflite-2.4.4)

## CHANGELOG (ilk 150 satır)
```
## 2.4.4

* Add `sqflite-crud-and-transactions`, `sqflite-open-database` and `sqflite-testing-and-platforms` agent skills in `skills/`, installable with `dart run skills@ get`

## 2.4.3

* Requires dart 3.12

## 2.4.2+1

* Requires dart 3.10

## 2.4.2

* Requires dart 3.7

## 2.4.1

* Add darwin extension to allow creating unprotected folder in iOS (issue #924)

## 2.4.0

* Make `sqflite` a federated plugin including `sqflite_android` and `sqflite_darwin` (iOS/macOS) plugins

## 2.3.3+2

* Remove android v1 embedding support
* Use `compileSdk 34` on Android
* `sdk: >= 3.3.0`

## 2.3.2

* Shared iOS/MacOS darwin implementation
* Remove FMDB podspec dependency

## 2.3.1

* Add iOS/MacOS privacy manifest

## 2.3.0

* Dart 3 only

## 2.2.8+4

* Android: Adds a namespace for compatibility with AGP 8.0.
* Android: Use compile SDK 33
* Export global sqflite API
* iOS set minimum deployment target to 11.0

## 2.2.7

* Dart 3 support

## 2.2.6

* uri support for supported implementations.

## 2.2.5

* Fix concurrency issue in database worker pool (chriscui@google.com)
* add android `setLocale` API call support.

## 2.2.4+1

* Experimental logger support.

## 2.2.3-1

* strict-casts and sdk 2.18 support
 
## 2.2.2

* Fix iOS/MacOS FMDB include for non-swift project

## 2.2.1

* Allow multiple threads on Android, thanks to zhenpingcui

## 2.2.1-1

* Fix iOS/MacOS FMDB include

## 2.2.0+3

* Implements `Database.queryCursor()` and `Database.rawQueryCursor()`
* Dependency update
* Initial support of cross isolate safe
* Transaction v2 update

## 2.1.0+1

* Android: fix parameter binding for non string parameters
* Android: fix unit test

## 2.0.4-dev.1

* Android: Allow turning on WAL in the manifest.

## 2.0.3+1

* MacOS: Fix crash when an invalid number of parameters is specified in the query

## 2.0.3

* iOS/Android: Flutter 3.0 support, makes all the channel calls happen on thread pool instead of the UI thread
* iOS/MacOS: make close happen in a background thread

## 2.0.2+1

* Android build: remove jcenter, compile sdk set to 31

## 2.0.1

* Bump default android thread priority to `THREAD_PRIORITY_DEFAULT`

## 2.0.0+4

* `nnbd` support

## 1.3.2+3

* iOS/macOS: Update FMDB to 2.7.5+
* android: Update gradle to 6.5
* fix logs on iOS

## 1.3.1+2

* add `databaseFactory` setter to change the default sqflite factory.
* Fix empty Blob returned as null on MacOS/iOS
* Test using `integration_test`

## 1.3.0+2

* Add sqflite_common dependency

## 1.2.2+1

* Fix iOS warning on FMDB import
* Support pedantic 1.9
* Check arguments in debug mode (print errors only)

## 1.2.1

* Support Android embedding v2
* Add private mixin
* Support iOS/MacOS incremental build

## 1.2.0

```

## README (ilk 200 satır)
```
# sqflite

[![pub package](https://img.shields.io/pub/v/sqflite.svg)](https://pub.dev/packages/sqflite)

SQLite plugin for [Flutter](https://flutter.io).
Supports iOS, Android and MacOS.

* Support transactions and batches
* Automatic version managment during open
* Helpers for insert/query/update/delete queries
* DB operation executed in a background thread on iOS and Android

Other platforms support:
* Linux/Windows/DartVM support using [sqflite_common_ffi](https://pub.dev/packages/sqflite_common_ffi)
* Experimental Web support using [sqflite_common_ffi_web](https://pub.dev/packages/sqflite_common_ffi_web).

Usage example: 
* [notepad_sqflite](https://github.com/alextekartik/flutter_app_example/tree/master/notepad_sqflite): Simple flutter notepad working on iOS/Android/Windows/linux/Mac

## Getting Started

To get started, you need to add `sqflite` to your project. Follow the steps below:

1. Open the terminal in your project root. You can do this by pressing `Alt+F12` in Android Studio or `` Ctrl+` `` in VS Code.

2. Run the following command:

```bash
flutter pub add sqflite
```

This command will add a line to your package's `pubspec.yaml` file and run an implicit `flutter pub get`. The added line will look like this:

```yaml
dependencies:
  sqflite: 
```

## Usage example

Import `sqflite.dart`

```dart
import 'package:sqflite/sqflite.dart';
```

### Opening a database

A SQLite database is a file in the file system identified by a path. If relative, this path is relative to the path
obtained by `getDatabasesPath()`, which is the default database directory on Android and the documents directory on iOS/MacOS.

```dart
var db = await openDatabase('my_db.db');
```

There is a basic migration mechanism to handle schema changes during opening.

Many applications use one database and would never need to close it (it will be closed when the application is
terminated). If you want to release resources, you can close the database.

```dart
await db.close();
```

* See [more information on opening a database](https://github.com/tekartik/sqflite/blob/master/sqflite/doc/opening_db.md).
* Full [migration example](https://github.com/tekartik/sqflite/blob/master/sqflite/doc/migration_example.md)

### Raw SQL queries
    
Demo code to perform Raw SQL queries

```dart
// Get a location using getDatabasesPath
var databasesPath = await getDatabasesPath();
String path = join(databasesPath, 'demo.db');

// Delete the database
await deleteDatabase(path);

// open the database
Database database = await openDatabase(path, version: 1,
    onCreate: (Database db, int version) async {
  // When creating the db, create the table
  await db.execute(
      'CREATE TABLE Test (id INTEGER PRIMARY KEY, name TEXT, value INTEGER, num REAL)');
});

// Insert some records in a transaction
await database.transaction((txn) async {
  int id1 = await txn.rawInsert(
      'INSERT INTO Test(name, value, num) VALUES("some name", 1234, 456.789)');
  print('inserted1: $id1');
  int id2 = await txn.rawInsert(
      'INSERT INTO Test(name, value, num) VALUES(?, ?, ?)',
      ['another name', 12345678, 3.1416]);
  print('inserted2: $id2');
});

// Update some record
int count = await database.rawUpdate(
    'UPDATE Test SET name = ?, value = ? WHERE name = ?',
    ['updated name', '9876', 'some name']);
print('updated: $count');

// Get the records
List<Map> list = await database.rawQuery('SELECT * FROM Test');
List<Map> expectedList = [
  {'name': 'updated name', 'id': 1, 'value': 9876, 'num': 456.789},
  {'name': 'another name', 'id': 2, 'value': 12345678, 'num': 3.1416}
];
print(list);
print(expectedList);
assert(const DeepCollectionEquality().equals(list, expectedList));

// Count the records
count = Sqflite
    .firstIntValue(await database.rawQuery('SELECT COUNT(*) FROM Test'));
assert(count == 2);

// Delete a record
count = await database
    .rawDelete('DELETE FROM Test WHERE name = ?', ['another name']);
assert(count == 1);

// Close the database
await database.close();
```

Basic information on SQL [here](https://github.com/tekartik/sqflite/blob/master/sqflite/doc/sql.md).

### SQL helpers

Example using the helpers

```dart
final String tableTodo = 'todo';
final String columnId = '_id';
final String columnTitle = 'title';
final String columnDone = 'done';

class Todo {
  int id;
  String title;
  bool done;

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      columnTitle: title,
      columnDone: done == true ? 1 : 0
    };
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }

  Todo();

  Todo.fromMap(Map<String, Object?> map) {
    id = map[columnId];
    title = map[columnTitle];
    done = map[columnDone] == 1;
  }
}

class TodoProvider {
  Database db;

  Future open(String path) async {
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute('''
create table $tableTodo ( 
  $columnId integer primary key autoincrement, 
  $columnTitle text not null,
  $columnDone integer not null)
''');
    });
  }

  Future<Todo> insert(Todo todo) async {
    todo.id = await db.insert(tableTodo, todo.toMap());
    return todo;
  }

  Future<Todo> getTodo(int id) async {
    List<Map> maps = await db.query(tableTodo,
        columns: [columnId, columnDone, columnTitle],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return Todo.fromMap(maps.first);
    }
    return null;
  }

  Future<int> delete(int id) async {
    return await db.delete(tableTodo, where: '$columnId = ?', whereArgs: [id]);
  }

```
