class ScheduleModel {
  final int id, startTime, endTime;
  final String type, content, date;
  final bool isMine;

  ScheduleModel.fromJson(Map<String, dynamic> json)
      : type = json['type'],
        content = json['content'],
        id = json['id'],
        date = json['date'],
        isMine = json['isMine'],
        startTime = json['startTime'],
        endTime = json['endTime'];
}
