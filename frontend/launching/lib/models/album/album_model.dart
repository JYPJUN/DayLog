class AlbumModel {
  final int id;
  final String filePath, date;

  AlbumModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        filePath = json['filePath'],
        date = json['date'];
}
