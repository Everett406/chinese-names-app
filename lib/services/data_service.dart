import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

/// 数据服务 - 单例模式
/// 负责从 assets/data/ 加载和管理所有语料库数据
class DataService {
  // ==================== 单例 ====================
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  // ==================== 缓存 ====================
  List<Map<String, dynamic>>? _namesCache;
  List<Map<String, dynamic>>? _surnamesCache;
  List<String>? _surnamesForGenCache;
  List<Map<String, dynamic>>? _idiomsCache;
  List<String>? _ancientNamesCache;
  List<String>? _japaneseNamesCache;
  List<Map<String, dynamic>>? _englishNamesCache;

  // ==================== 内置 Fallback 数据 ====================
  static const List<Map<String, dynamic>> _fallbackNames = [
    {'name': '张伟', 'gender': '男'},
    {'name': '王芳', 'gender': '女'},
    {'name': '李娜', 'gender': '女'},
    {'name': '刘洋', 'gender': '男'},
    {'name': '陈静', 'gender': '女'},
    {'name': '杨磊', 'gender': '男'},
    {'name': '赵敏', 'gender': '女'},
    {'name': '黄强', 'gender': '男'},
    {'name': '周杰', 'gender': '男'},
    {'name': '吴秀英', 'gender': '女'},
  ];

  static const List<Map<String, dynamic>> _fallbackSurnames = [
    {'surname': '王', 'pinyin': 'W', 'rank': '1'},
    {'surname': '李', 'pinyin': 'L', 'rank': '2'},
    {'surname': '张', 'pinyin': 'Z', 'rank': '3'},
    {'surname': '刘', 'pinyin': 'L', 'rank': '4'},
    {'surname': '陈', 'pinyin': 'C', 'rank': '5'},
    {'surname': '杨', 'pinyin': 'Y', 'rank': '6'},
    {'surname': '赵', 'pinyin': 'Z', 'rank': '7'},
    {'surname': '黄', 'pinyin': 'H', 'rank': '8'},
    {'surname': '周', 'pinyin': 'Z', 'rank': '9'},
    {'surname': '吴', 'pinyin': 'W', 'rank': '10'},
  ];

  static const List<String> _fallbackSurnamesForGen = [
    '王', '李', '张', '刘', '陈', '杨', '赵', '黄', '周', '吴',
    '徐', '孙', '胡', '朱', '高', '林', '何', '郭', '马', '罗',
  ];

  static const List<Map<String, dynamic>> _fallbackIdioms = [
    {'word': '一心一意'},
    {'word': '三心二意'},
    {'word': '四面楚歌'},
    {'word': '五湖四海'},
    {'word': '六神无主'},
    {'word': '七上八下'},
    {'word': '八面玲珑'},
    {'word': '九牛一毛'},
    {'word': '十全十美'},
    {'word': '百发百中'},
  ];

  static const List<String> _fallbackAncientNames = [
    '李白', '杜甫', '白居易', '苏轼', '辛弃疾',
    '李清照', '王维', '孟浩然', '柳永', '欧阳修',
  ];

  static const List<String> _fallbackJapaneseNames = [
    '田中', '铃木', '佐藤', '高桥', '渡边',
    '伊藤', '山本', '中村', '小林', '加藤',
  ];

  static const List<Map<String, dynamic>> _fallbackEnglishNames = [
    {'cn_name': '约翰', 'en_name': 'John', 'gender': 'M'},
    {'cn_name': '玛丽', 'en_name': 'Mary', 'gender': 'F'},
    {'cn_name': '詹姆斯', 'en_name': 'James', 'gender': 'M'},
    {'cn_name': '艾米丽', 'en_name': 'Emily', 'gender': 'F'},
    {'cn_name': '大卫', 'en_name': 'David', 'gender': 'M'},
  ];

  // ==================== 随机数生成器 ====================
  final Random _random = Random();

  // ==================== 通用加载方法 ====================

  /// 从 asset 加载文本文件，失败时返回 null
  Future<String?> _loadAssetText(String path) async {
    try {
      return await rootBundle.loadString(path);
    } catch (e) {
      return null;
    }
  }

  // ==================== 人名相关 ====================

  /// 加载全部人名数据
  /// 返回 [{name: '张伟', gender: '男'}, ...]
  Future<List<Map<String, dynamic>>> loadNames() async {
    if (_namesCache != null) return _namesCache!;

    final text = await _loadAssetText('assets/data/names.txt');
    if (text == null || text.isEmpty) {
      _namesCache = List.from(_fallbackNames);
      return _namesCache!;
    }

    final lines = const LineSplitter().convert(text);
    _namesCache = <Map<String, dynamic>>[];

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      final parts = trimmed.split(',');
      if (parts.length >= 2) {
        _namesCache!.add({
          'name': parts[0].trim(),
          'gender': parts[1].trim(),
        });
      } else if (parts.length == 1 && parts[0].trim().isNotEmpty) {
        _namesCache!.add({
          'name': parts[0].trim(),
          'gender': '未知',
        });
      }
    }

    return _namesCache!;
  }

  /// 搜索人名（按名字 contains 匹配）
  Future<List<Map<String, dynamic>>> searchNames(String query) async {
    if (query.trim().isEmpty) return [];

    final names = await loadNames();
    final lowerQuery = query.trim().toLowerCase();

    return names
        .where((item) =>
            (item['name'] as String).toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// 随机生成名字
  /// [surname] 指定姓氏，为空则从 surnames_for_gen.txt 随机选取
  /// [gender] 指定性别筛选，为空则不筛选
  Future<String> generateRandomName({
    String? surname,
    String? gender,
  }) async {
    // 确定姓氏
    String finalSurname;
    if (surname != null && surname.trim().isNotEmpty) {
      finalSurname = surname.trim();
    } else {
      final surnames = await _loadSurnamesForGen();
      finalSurname = surnames[_random.nextInt(surnames.length)];
    }

    // 加载人名数据，提取名字部分（去掉姓氏）
    final names = await loadNames();
    List<String> namePool;

    if (gender != null && gender.trim().isNotEmpty) {
      final filtered = names
          .where((item) => item['gender'] == gender.trim())
          .toList();
      namePool = _extractGivenNames(filtered, finalSurname);
    } else {
      namePool = _extractGivenNames(names, finalSurname);
    }

    // 如果没有匹配的名字，从全部数据中提取
    if (namePool.isEmpty) {
      namePool = _extractGivenNames(names, '');
    }

    // 如果仍然为空，使用 fallback
    if (namePool.isEmpty) {
      namePool = ['伟', '芳', '娜', '洋', '静', '磊', '敏', '强', '杰', '秀英'];
    }

    final givenName = namePool[_random.nextInt(namePool.length)];
    return finalSurname + givenName;
  }

  /// 从人名列表中提取名字部分（去掉姓氏前缀）
  List<String> _extractGivenNames(
    List<Map<String, dynamic>> names,
    String surname,
  ) {
    final Set<String> result = {};
    for (final item in names) {
      final fullName = item['name'] as String;
      String givenName = fullName;

      // 尝试去掉姓氏前缀
      if (surname.isNotEmpty && fullName.startsWith(surname)) {
        givenName = fullName.substring(surname.length);
      } else if (fullName.length >= 2) {
        // 取最后1-2个字作为名字
        givenName = fullName.length > 2 ? fullName.substring(1) : fullName.substring(1);
      }

      if (givenName.isNotEmpty) {
        result.add(givenName);
      }
    }
    return result.toList();
  }

  /// 加载用于名字生成的姓氏列表
  Future<List<String>> _loadSurnamesForGen() async {
    if (_surnamesForGenCache != null) return _surnamesForGenCache!;

    final text = await _loadAssetText('assets/data/surnames_for_gen.txt');
    if (text == null || text.isEmpty) {
      _surnamesForGenCache = List.from(_fallbackSurnamesForGen);
      return _surnamesForGenCache!;
    }

    final lines = const LineSplitter().convert(text);
    _surnamesForGenCache = lines
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    if (_surnamesForGenCache!.isEmpty) {
      _surnamesForGenCache = List.from(_fallbackSurnamesForGen);
    }

    return _surnamesForGenCache!;
  }

  // ==================== 姓氏相关 ====================

  /// 加载全部姓氏数据
  /// 返回 [{surname: '王', pinyin: 'W', rank: '1'}, ...]
  Future<List<Map<String, dynamic>>> loadSurnames() async {
    if (_surnamesCache != null) return _surnamesCache!;

    final text = await _loadAssetText('assets/data/surnames.txt');
    if (text == null || text.isEmpty) {
      _surnamesCache = List.from(_fallbackSurnames);
      return _surnamesCache!;
    }

    final lines = const LineSplitter().convert(text);
    _surnamesCache = <Map<String, dynamic>>[];

    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) continue;

      final parts = trimmed.split(',');
      if (parts.length >= 3) {
        _surnamesCache!.add({
          'surname': parts[0].trim(),
          'pinyin': parts[1].trim(),
          'rank': parts[2].trim(),
        });
      } else if (parts.length == 2) {
        _surnamesCache!.add({
          'surname': parts[0].trim(),
          'pinyin': parts[1].trim(),
          'rank': '-1',
        });
      } else if (parts.length == 1 && parts[0].trim().isNotEmpty) {
        _surnamesCache!.add({
          'surname': parts[0].trim(),
          'pinyin': '',
          'rank': '-1',
        });
      }
    }

    return _surnamesCache!;
  }

  /// 搜索姓氏（按姓氏 contains 匹配）
  Future<List<Map<String, dynamic>>> searchSurnames(String query) async {
    if (query.trim().isEmpty) return [];

    final surnames = await loadSurnames();
    final lowerQuery = query.trim().toLowerCase();

    return surnames
        .where((item) =>
            (item['surname'] as String).toLowerCase().contains(lowerQuery) ||
            (item['pinyin'] as String).toLowerCase().contains(lowerQuery))
        .toList();
  }

  // ==================== 成语相关 ====================

  /// 加载全部成语数据
  /// 返回 [{word: '一心一意'}, ...]
  Future<List<Map<String, dynamic>>> loadIdioms() async {
    if (_idiomsCache != null) return _idiomsCache!;

    final text = await _loadAssetText('assets/data/idioms.txt');
    if (text == null || text.isEmpty) {
      _idiomsCache = List.from(_fallbackIdioms);
      return _idiomsCache!;
    }

    final lines = const LineSplitter().convert(text);
    _idiomsCache = lines
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .map((line) => {'word': line})
        .toList();

    if (_idiomsCache!.isEmpty) {
      _idiomsCache = List.from(_fallbackIdioms);
    }

    return _idiomsCache!;
  }

  /// 搜索成语（contains 匹配）
  Future<List<Map<String, dynamic>>> searchIdioms(String query) async {
    if (query.trim().isEmpty) return [];

    final idioms = await loadIdioms();
    final lowerQuery = query.trim().toLowerCase();

    return idioms
        .where((item) =>
            (item['word'] as String).toLowerCase().contains(lowerQuery))
        .toList();
  }

  // ==================== 古代人名相关 ====================

  /// 加载古代人名（分页）
  /// 返回 [{name: '李白'}, ...]
  Future<List<Map<String, dynamic>>> loadAncientNames({
    int offset = 0,
    int limit = 50,
  }) async {
    if (_ancientNamesCache == null) {
      final text = await _loadAssetText('assets/data/ancient_names.txt');
      if (text == null || text.isEmpty) {
        _ancientNamesCache = List.from(_fallbackAncientNames);
      } else {
        final lines = const LineSplitter().convert(text);
        _ancientNamesCache = lines
            .map((line) => line.trim())
            .where((line) => line.isNotEmpty)
            .toList();

        if (_ancientNamesCache!.isEmpty) {
          _ancientNamesCache = List.from(_fallbackAncientNames);
        }
      }
    }

    final total = _ancientNamesCache!.length;
    final start = offset.clamp(0, total);
    final end = (offset + limit).clamp(0, total);

    return _ancientNamesCache!
        .sublist(start, end)
        .map((name) => {'name': name})
        .toList();
  }

  // ==================== 日本人名相关 ====================

  /// 加载日本人名（分页）
  /// 返回 [{name: '田中'}, ...]
  Future<List<Map<String, dynamic>>> loadJapaneseNames({
    int offset = 0,
    int limit = 50,
  }) async {
    if (_japaneseNamesCache == null) {
      final text = await _loadAssetText('assets/data/japanese_names.txt');
      if (text == null || text.isEmpty) {
        _japaneseNamesCache = List.from(_fallbackJapaneseNames);
      } else {
        final lines = const LineSplitter().convert(text);
        _japaneseNamesCache = lines
            .map((line) => line.trim())
            .where((line) => line.isNotEmpty)
            .toList();

        if (_japaneseNamesCache!.isEmpty) {
          _japaneseNamesCache = List.from(_fallbackJapaneseNames);
        }
      }
    }

    final total = _japaneseNamesCache!.length;
    final start = offset.clamp(0, total);
    final end = (offset + limit).clamp(0, total);

    return _japaneseNamesCache!
        .sublist(start, end)
        .map((name) => {'name': name})
        .toList();
  }

  // ==================== 英文译名相关 ====================

  /// 加载英文译名（分页）
  /// 返回 [{cn_name: '约翰', en_name: 'John', gender: 'M'}, ...]
  Future<List<Map<String, dynamic>>> loadEnglishNames({
    int offset = 0,
    int limit = 50,
  }) async {
    if (_englishNamesCache == null) {
      final text = await _loadAssetText('assets/data/english_names.txt');
      if (text == null || text.isEmpty) {
        _englishNamesCache = List.from(_fallbackEnglishNames);
      } else {
        final lines = const LineSplitter().convert(text);
        _englishNamesCache = <Map<String, dynamic>>[];

        for (final line in lines) {
          final trimmed = line.trim();
          if (trimmed.isEmpty) continue;

          final parts = trimmed.split('|');
          if (parts.length >= 3) {
            _englishNamesCache!.add({
              'cn_name': parts[0].trim(),
              'en_name': parts[1].trim(),
              'gender': parts[2].trim(),
            });
          } else if (parts.length == 2) {
            _englishNamesCache!.add({
              'cn_name': parts[0].trim(),
              'en_name': parts[1].trim(),
              'gender': '未知',
            });
          } else if (parts.length == 1 && parts[0].trim().isNotEmpty) {
            _englishNamesCache!.add({
              'cn_name': parts[0].trim(),
              'en_name': '',
              'gender': '未知',
            });
          }
        }

        if (_englishNamesCache!.isEmpty) {
          _englishNamesCache = List.from(_fallbackEnglishNames);
        }
      }
    }

    final total = _englishNamesCache!.length;
    final start = offset.clamp(0, total);
    final end = (offset + limit).clamp(0, total);

    return _englishNamesCache!.sublist(start, end);
  }

  // ==================== 数据统计 ====================

  /// 获取各类型数据总数
  /// [type] 支持: names, surnames, idioms, ancient, japanese, english
  Future<int> getTotalCount(String type) async {
    switch (type.toLowerCase()) {
      case 'names':
        final data = await loadNames();
        return data.length;
      case 'surnames':
        final data = await loadSurnames();
        return data.length;
      case 'idioms':
        final data = await loadIdioms();
        return data.length;
      case 'ancient':
        await loadAncientNames(offset: 0, limit: 1);
        return _ancientNamesCache?.length ?? 0;
      case 'japanese':
        await loadJapaneseNames(offset: 0, limit: 1);
        return _japaneseNamesCache?.length ?? 0;
      case 'english':
        await loadEnglishNames(offset: 0, limit: 1);
        return _englishNamesCache?.length ?? 0;
      default:
        return 0;
    }
  }

  // ==================== 缓存管理 ====================

  /// 清除所有缓存数据
  void clearCache() {
    _namesCache = null;
    _surnamesCache = null;
    _surnamesForGenCache = null;
    _idiomsCache = null;
    _ancientNamesCache = null;
    _japaneseNamesCache = null;
    _englishNamesCache = null;
  }
}
