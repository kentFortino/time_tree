class EventModel {
  String id;
  String calendarId;
  final String title;
  final String tag;
  final String? note;
  final DateTime startTime;
  final DateTime endTime;
  String createdBy;
  final DateTime createdAt;

  EventModel({
    required this.id,
    required this.calendarId,
    required this.title,
    this.note,
    required this.tag,
    required this.startTime,
    required this.endTime,
    required this.createdBy,
    required this.createdAt,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) => EventModel(
        id: json["id"],
        calendarId: json["calendarId"],
        title: json["title"],
        note: json["note"],
        tag: json["tag"],
        startTime: DateTime.parse(json["startTime"]),
        endTime: DateTime.parse(json["endTime"]),
        createdBy: json["createdBy"],
        createdAt: DateTime.parse(json["createdAt"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "calendarId": calendarId,
        "title": title,
        "note": note,
        "tag": tag,
        "startTime": startTime.toIso8601String(),
        "endTime": endTime.toIso8601String(),
        "createdBy": createdBy,
        "createdAt": createdAt.toIso8601String(),
      };
}
