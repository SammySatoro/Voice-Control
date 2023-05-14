const String tableApplications = "applications";

class ApplicationFields {
  static final List<String> values = [
    id, applicationPackageName
  ];

  static const String id = "_id";
  static const String applicationPackageName = "applicationPackageName";
}

class Application {
  final int? id;
  final String applicationPackageName;

  const Application({
    this.id,
    required this.applicationPackageName,
  });

  Application copy({
    int? id,
    String? applicationPackageName,
  }) => Application(
      id: id ?? this.id,
      applicationPackageName: applicationPackageName ?? this.applicationPackageName
  );

  static Application fromJson(Map<String, Object?> json) => Application(
    id: json[ApplicationFields.id] as int?,
    applicationPackageName: json[ApplicationFields.applicationPackageName] as String,
  );

  Map<String, Object?> toJson() => {
    ApplicationFields.id: id,
    ApplicationFields.applicationPackageName: applicationPackageName,
  };
}
