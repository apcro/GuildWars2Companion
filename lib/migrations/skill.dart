import 'package:sqflite_migration/sqflite_migration.dart';

class SkillMigrations {
  static final List<String> _initializationScripts = [
    '''
      CREATE TABLE skills(
        id INTEGER PRIMARY KEY,
        name TEXT,
        description TEXT,
        icon TEXT,
        type TEXT,
        slot TEXT,
        chatLink TEXT,
        tier INTEGER,
        facts TEXT,
        traitedFacts TEXT,
        expiration_date DATE
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