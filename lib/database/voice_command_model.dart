const String tableVoiceCommands = "voice_commands";

class VoiceCommandFields {
  static final List<String> values = [
    id, applicationPackageName, command, xCoord, yCoord, language
  ];

  static const String id = "_id";
  static const String applicationPackageName = "applicationPackageName";
  static const String command = "command";
  static const String xCoord = "xCoord";
  static const String yCoord = "yCoord";
  static const String language = "createdTime";
}

class VoiceCommand {
  final int? id;
  final String applicationPackageName;
  final String command;
  final int xCoord;
  final int yCoord;
  final String language;

  const VoiceCommand({
    this.id,
    required this.command,
    required this.xCoord,
    required this.yCoord,
    required this.applicationPackageName,
    required this.language,
  });
  
  VoiceCommand copy({
    int? id,
    String? applicationPackageName,
    String? command,
    int? xCoord,
    int? yCoord,
    String? language,
  }) => VoiceCommand(
      id: id ?? this.id,
      applicationPackageName: applicationPackageName ?? this.applicationPackageName,
      command: command ?? this.command,
      xCoord: xCoord ?? this.xCoord,
      yCoord: yCoord ?? this.yCoord,
      language: language ?? this.language
  );

  static VoiceCommand fromJson(Map<String, Object?> json) => VoiceCommand(
    id: json[VoiceCommandFields.id] as int?,
    applicationPackageName: json[VoiceCommandFields.applicationPackageName] as String,
    command: json[VoiceCommandFields.command] as String,
    xCoord: json[VoiceCommandFields.xCoord] as int,
    yCoord: json[VoiceCommandFields.yCoord] as int,
    language: json[VoiceCommandFields.language] as String,
  );

  Map<String, Object?> toJson() => {
    VoiceCommandFields.id: id,
    VoiceCommandFields.applicationPackageName: applicationPackageName,
    VoiceCommandFields.command: command,
    VoiceCommandFields.xCoord: xCoord,
    VoiceCommandFields.yCoord: yCoord,
    VoiceCommandFields.language: language,
  };
}