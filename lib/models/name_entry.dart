/// 姓名条目数据模型
class NameEntry {
  final String name;
  final String? gender;

  NameEntry({required this.name, this.gender});

  factory NameEntry.fromJson(Map<String, dynamic> json) => NameEntry(
        name: json['name'] as String,
        gender: json['gender'] as String?,
      );

  factory NameEntry.fromLine(String line) {
    final parts = line.trim().split(RegExp(r'\s+'));
    return NameEntry(
      name: parts[0],
      gender: parts.length > 1 ? parts[1] : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        if (gender != null) 'gender': gender,
      };

  @override
  String toString() => gender != null ? '$name ($gender)' : name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NameEntry &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          gender == other.gender;

  @override
  int get hashCode => name.hashCode ^ (gender?.hashCode ?? 0);
}
