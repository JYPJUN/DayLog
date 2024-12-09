class CoupleInfo {
  final String backgroundImagePath;
  final int user1Id;
  final int user2Id;
  final String user1Name;
  final String user2Name;
  final String user1ProfileImagePath;
  final String user2ProfileImagePath;
  final DateTime relationshipStartDate;

  CoupleInfo({
    required this.backgroundImagePath,
    required this.user1Id,
    required this.user2Id,
    required this.user1Name,
    required this.user2Name,
    required this.user1ProfileImagePath,
    required this.user2ProfileImagePath,
    required this.relationshipStartDate,
  });

  factory CoupleInfo.fromJson(Map<String, dynamic> json) {
    return CoupleInfo(
      backgroundImagePath: json['backgroundImagePath'],
      user1Id: json['user1Id'],
      user2Id: json['user2Id'],
      user1Name: json['user1Name'],
      user2Name: json['user2Name'],
      user1ProfileImagePath: json['user1ProfileImagePath'],
      user2ProfileImagePath: json['user2ProfileImagePath'],
      relationshipStartDate: DateTime.parse(json['relationshipStartDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'backgroundImagePath': backgroundImagePath,
      'user1Name': user1Name,
      'user2Name': user2Name,
      'user1Id': user1Id,
      'user2Id': user2Id,
      'user1ProfileImagePath': user1ProfileImagePath,
      'user2ProfileImagePath': user2ProfileImagePath,
      'relationshipStartDate': relationshipStartDate.toIso8601String(),
    };
  }
}
