class CalendarModel {
  String id;
  final String name;
  final String createdBy;

  CalendarModel({
    required this.id,
    required this.name,
    required this.createdBy,
  });

  factory CalendarModel.fromJson(Map<String, dynamic> json) => CalendarModel(
        id: json["id"],
        name: json["name"],
        createdBy: json["createdBy"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "createdBy": createdBy,
      };
}
