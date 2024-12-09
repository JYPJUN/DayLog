class ClipModel {
  final int id;
  final String filePath, date;

  ClipModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        filePath = json['filePath'],
        date = json['date'];
}
