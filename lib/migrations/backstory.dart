import 'package:sqflite_migration/sqflite_migration.dart';

class BackstoryMigrations {
  static final List<String> _initializationScripts = [
    '''
      CREATE TABLE backstory(
        id INTEGER PRIMARY KEY,
        storyid TEXT,
        title TEXT,
        description TEXT,
        journal TEXT,
        question TEXT
      )
    '''
  ];

  static final List<String> _migrationScripts = [

  ];

  static final MigrationConfig config = MigrationConfig(
    initializationScript: _initializationScripts,
    migrationScripts: _migrationScripts,
  );
}