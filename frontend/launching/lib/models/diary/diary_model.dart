class DiaryModel {
  final int id;
  final String title, content, artImagePath, date, name;

  DiaryModel.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        content = json['content'],
        id = json['id'],
        artImagePath = json['artImagePath'],
        name = json['name'],
        date = json['date'];
}
