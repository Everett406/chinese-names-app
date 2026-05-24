import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

/// 核心数据服务 - 单例模式，提供静态方法供各页面调用
class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  // 缓存数据
  static List<Map<String, dynamic>>? _namesCache;
  static List<String>? _surnamesCache;
  static List<Map<String, dynamic>>? _idiomsCache;
  static List<Map<String, dynamic>>? _ancientNamesCache;
  static List<Map<String, dynamic>>? _japaneseNamesCache;

  static const List<String> _fallbackSurnames = [
    '赵', '钱', '孙', '李', '周', '吴', '郑', '王', '冯', '陈',
    '褚', '卫', '蒋', '沈', '韩', '杨', '朱', '秦', '尤', '许',
    '何', '吕', '施', '张', '孔', '曹', '严', '华', '金', '魏',
    '陶', '姜', '戚', '谢', '邹', '喻', '柏', '水', '窦', '章',
    '云', '苏', '潘', '葛', '奚', '范', '彭', '郎', '鲁', '韦',
    '昌', '马', '苗', '凤', '花', '方', '俞', '任', '袁', '柳',
    '酆', '鲍', '史', '唐', '费', '廉', '岑', '薛', '雷', '贺',
    '倪', '汤', '滕', '殷', '罗', '毕', '郝', '邬', '安', '常',
    '乐', '于', '时', '傅', '皮', '卞', '齐', '康', '伍', '余',
    '元', '卜', '顾', '孟', '平', '黄', '和', '穆', '萧', '尹',
  ];

  static const List<String> _fallbackGivenNameChars = [
    '瑞', '祥', '福', '禄', '寿', '喜', '吉', '庆', '安', '康',
    '宁', '和', '平', '顺', '兴', '旺', '盛', '昌', '隆', '茂',
    '德', '仁', '义', '礼', '智', '信', '忠', '孝', '廉', '正',
    '诚', '善', '贤', '良', '温', '恭', '俭', '让', '敬', '慈',
    '文', '武', '才', '学', '博', '明', '慧', '聪', '睿', '哲',
    '思', '志', '远', '达', '通', '晓', '知', '理', '书', '翰',
    '山', '川', '海', '江', '河', '湖', '林', '森', '松', '柏',
    '竹', '梅', '兰', '菊', '莲', '荷', '桂', '桐', '柳', '枫',
    '云', '雨', '雪', '风', '霞', '露', '霜', '星', '月', '日',
    '天', '地', '泉', '溪', '石', '峰', '岩', '谷', '原', '野',
    '美', '丽', '娟', '婷', '雅', '静', '淑', '惠', '秀', '英',
    '华', '荣', '富', '贵', '金', '玉', '珍', '珠', '宝', '琳',
    '瑶', '琼', '瑛', '珊', '璐', '瑾', '瑜', '璇', '珺', '琪',
    '伟', '强', '刚', '毅', '勇', '杰', '豪', '雄', '俊', '帅',
    '威', '壮', '猛', '力', '健', '翔', '飞', '鹏', '程', '浩',
    '春', '夏', '秋', '冬', '晨', '曦', '旭', '阳', '辉', '光',
    '影', '虹', '霄', '汉', '宇', '宙', '乾', '坤', '元', '亨',
    '怡', '悦', '欣', '欢', '乐', '畅', '恬', '清', '淡', '素',
    '朴', '真', '纯', '洁', '白', '韵', '诗', '画', '琴', '棋',
  ];

  Future<void> init() async {
    await loadNames();
  }

  static Future<List<Map<String, dynamic>>> loadNames() async {
    if (_namesCache != null) return _namesCache!;
    try {
      final text = await rootBundle.loadString('assets/data/names.txt');
      _namesCache = text
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .map((line) {
        final parts = line.trim().split(RegExp(r'\s+'));
        return {
          'name': parts[0],
          'gender': parts.length > 1 ? parts[1] : null,
        };
      }).toList();
    } catch (_) {
      _namesCache = _generateFallbackNames();
    }
    return _namesCache!;
  }

  static Future<List<Map<String, dynamic>>> searchNames(String query) async {
    final names = await loadNames();
    if (query.isEmpty) return names;
    return names.where((entry) {
      final name = entry['name'] as String? ?? '';
      return name.contains(query);
    }).toList();
  }

  static Future<String> generateRandomName({String? surname, String? gender}) async {
    final surnames = await loadSurnames();
    final random = Random();
    final finalSurname = surname ?? surnames[random.nextInt(surnames.length)];
    final givenNameLength = random.nextBool() ? 1 : 2;
    final givenNameChars = <String>[];
    for (int i = 0; i < givenNameLength; i++) {
      givenNameChars.add(_fallbackGivenNameChars[random.nextInt(_fallbackGivenNameChars.length)]);
    }
    return finalSurname + givenNameChars.join();
  }

  static Future<List<String>> loadSurnames() async {
    if (_surnamesCache != null) return _surnamesCache!;
    try {
      final text = await rootBundle.loadString('assets/data/surnames.txt');
      _surnamesCache = text
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .map((line) => line.trim())
          .toList();
    } catch (_) {
      _surnamesCache = List.from(_fallbackSurnames);
    }
    return _surnamesCache!;
  }

  static Future<List<Map<String, dynamic>>> loadIdioms() async {
    if (_idiomsCache != null) return _idiomsCache!;
    try {
      final text = await rootBundle.loadString('assets/data/idioms.txt');
      _idiomsCache = text
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .map((line) {
        final parts = line.trim().split(RegExp(r'\s+'));
        return {
          'word': parts[0],
          'explanation': parts.length > 1 ? parts.sublist(1).join(' ') : '',
        };
      }).toList();
    } catch (_) {
      _idiomsCache = [];
    }
    return _idiomsCache!;
  }

  static Future<List<Map<String, dynamic>>> searchIdioms(String query) async {
    final idioms = await loadIdioms();
    if (query.isEmpty) return idioms;
    return idioms.where((entry) {
      final word = entry['word'] as String? ?? '';
      return word.contains(query);
    }).toList();
  }

  static Future<List<Map<String, dynamic>>> loadAncientNames({int offset = 0, int limit = 50}) async {
    if (_ancientNamesCache == null) {
      try {
        final text = await rootBundle.loadString('assets/data/ancient_names.txt');
        _ancientNamesCache = text
            .split('\n')
            .where((line) => line.trim().isNotEmpty)
            .map((line) {
          final parts = line.trim().split(RegExp(r'\s+'));
          return {
            'name': parts[0],
            'gender': parts.length > 1 ? parts[1] : null,
            'dynasty': parts.length > 2 ? parts[2] : '',
            'description': parts.length > 3 ? parts.sublist(3).join(' ') : '',
          };
        }).toList();
      } catch (_) {
        _ancientNamesCache = [];
      }
    }
    final all = _ancientNamesCache!;
    final end = (offset + limit).clamp(0, all.length);
    return all.sublist(offset.clamp(0, all.length), end);
  }

  static Future<List<Map<String, dynamic>>> loadJapaneseNames({int offset = 0, int limit = 50}) async {
    if (_japaneseNamesCache == null) {
      try {
        final text = await rootBundle.loadString('assets/data/japanese_names.txt');
        _japaneseNamesCache = text
            .split('\n')
            .where((line) => line.trim().isNotEmpty)
            .map((line) {
          final parts = line.trim().split(RegExp(r'\s+'));
          return {
            'name_kanji': parts[0],
            'name_hiragana': parts.length > 1 ? parts[1] : '',
            'name_romaji': parts.length > 2 ? parts[2] : '',
            'meaning': parts.length > 3 ? parts.sublist(3).join(' ') : '',
          };
        }).toList();
      } catch (_) {
        _japaneseNamesCache = [];
      }
    }
    final all = _japaneseNamesCache!;
    final end = (offset + limit).clamp(0, all.length);
    return all.sublist(offset.clamp(0, all.length), end);
  }

  static List<Map<String, dynamic>> _generateFallbackNames() {
    final random = Random();
    final names = <Map<String, dynamic>>[];
    final genders = ['男', '女'];
    for (int i = 0; i < 200; i++) {
      final surname = _fallbackSurnames[random.nextInt(_fallbackSurnames.length)];
      final givenLength = random.nextBool() ? 1 : 2;
      final givenChars = <String>[];
      for (int j = 0; j < givenLength; j++) {
        givenChars.add(_fallbackGivenNameChars[random.nextInt(_fallbackGivenNameChars.length)]);
      }
      final gender = genders[random.nextInt(genders.length)];
      names.add({'name': surname + givenChars.join(), 'gender': gender});
    }
    return names;
  }

  static void reset() {
    _namesCache = null;
    _surnamesCache = null;
    _idiomsCache = null;
    _ancientNamesCache = null;
    _japaneseNamesCache = null;
  }
}
