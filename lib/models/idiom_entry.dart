/// 成语条目数据模型
class IdiomEntry {
  final String word;

  IdiomEntry({required this.word});

  factory IdiomEntry.fromJson(Map<String, dynamic> json) => IdiomEntry(
        word: json['word'] as String,
      );

  factory IdiomEntry.fromLine(String line) {
    final parts = line.trim().split(RegExp(r'\s+'));
    return IdiomEntry(word: parts[0]);
  }

  Map<String, dynamic> toJson() => {'word': word};

  @override
  String toString() => word;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IdiomEntry &&
          runtimeType == other.runtimeType &&
          word == other.word;

  @override
  int get hashCode => word.hashCode;
}
