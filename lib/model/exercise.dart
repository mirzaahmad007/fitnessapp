class Exercise {
  final String id;
  final String name;
  final String bodyPart;
  final String equipment;
  final String target;
  final String gifUrl;
  final List<String>? instructions; // Added to support instructions if available

  Exercise({
    required this.id,
    required this.name,
    required this.bodyPart,
    required this.equipment,
    required this.target,
    required this.gifUrl,
    this.instructions,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json["id"].toString(),
      name: json["name"] ?? "",
      bodyPart: json["bodyPart"] ?? "",
      equipment: json["equipment"] ?? "",
      target: json["target"] ?? "",
      gifUrl: json["gifUrl"] ?? "",
      instructions: json["instructions"] != null
          ? json["instructions"] is List
          ? List<String>.from(json["instructions"])
          : [json["instructions"].toString()]
          : null,
    );
  }
}