import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:voice_control/database/voice_command_model.dart';


class VoiceCommandsDataBase {
  static final VoiceCommandsDataBase instance = VoiceCommandsDataBase._init();

  static Database? _database;

  VoiceCommandsDataBase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('voice_commands.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    print("DB PATH: $path");
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = "INTEGER PRIMARY KEY AUTOINCREMENT";

    const intType = "INTEGER NOT NULL";
    const textType = "TEXT NOT NULL";
    
    await db.execute('''
    CREATE TABLE $tableVoiceCommands (
    ${VoiceCommandFields.id} $idType,
    ${VoiceCommandFields.applicationPackageName} $textType,
    ${VoiceCommandFields.command} $textType,
    ${VoiceCommandFields.xCoord} $intType,
    ${VoiceCommandFields.yCoord} $intType,
    ${VoiceCommandFields.language} $textType,
    UNIQUE(${VoiceCommandFields.applicationPackageName}, ${VoiceCommandFields.command}, ${VoiceCommandFields.xCoord}, ${VoiceCommandFields.yCoord})
    );
    ''');
  }

  Future<VoiceCommand> create(VoiceCommand voiceCommand) async {
    final db = await instance.database;
    int id = -1;
    try {
      id = await db.insert(tableVoiceCommands, voiceCommand.toJson());
    } catch(e) {
      print("Such command already exists");
    }
    return voiceCommand.copy(id: id);
  }

  Future<VoiceCommand> readVoiceCommand(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableVoiceCommands,
      columns: VoiceCommandFields.values,
      where: "${VoiceCommandFields.id} = ?",
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return VoiceCommand.fromJson(maps.first);
    } else {
      throw Exception("ID $id not found");
    }
  }

  Future<List<VoiceCommand>> readAllVoiceCommands() async {
    final db = await instance.database;

    const orderBy = "${VoiceCommandFields.applicationPackageName} ASC";
    final result = await db.query(tableVoiceCommands, orderBy: orderBy);

    return result.map((json) => VoiceCommand.fromJson(json)).toList();
  }

  Future<int> update(VoiceCommand voiceCommand) async {
    final db = await instance.database;

    return db.update(
      tableVoiceCommands,
      voiceCommand.toJson(),
      where: "${VoiceCommandFields.id} = ?",
      whereArgs: [voiceCommand.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;

    return await db.delete(
      tableVoiceCommands,
      where: "${VoiceCommandFields.id} = ?",
      whereArgs: [id],
    );
  }

  Future<List<String>> getUniqueApplicationPackageNames() async {
    final db = await instance.database;
    final result = await db.rawQuery('SELECT DISTINCT ${VoiceCommandFields.applicationPackageName} FROM $tableVoiceCommands');
    return result.map((row) => row[VoiceCommandFields.applicationPackageName] as String).toList();
  }

  Future<Map<String, int>?> getCoordinates(String applicationPackageName, String command) async {
    final db = await instance.database;
    List<Map<String, dynamic>> maps = await db.query(
        tableVoiceCommands,
        columns: [VoiceCommandFields.xCoord, VoiceCommandFields.yCoord],
        where: '${VoiceCommandFields.applicationPackageName} = ? AND ${VoiceCommandFields.command} = ?',
        whereArgs: [applicationPackageName, command]);

    if (maps.isNotEmpty) {
      return {
        'xCoord': maps.first['xCoord'],
        'yCoord': maps.first['yCoord']
      };
    }
    return null;
  }


  Future close() async {
    final db = await instance.database;

    db.close();
  }

}