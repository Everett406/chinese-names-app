import 'package:flutter/material.dart';
import '../services/data_service.dart';

/// 姓氏列表页面
/// 按拼音首字母分组展示姓氏，支持搜索、下拉刷新、粘性标题
class SurnameListScreen extends StatefulWidget {
  const SurnameListScreen({super.key});

  @override
  State<SurnameListScreen> createState() => _SurnameListScreenState();
}

class _SurnameListScreenState extends State<SurnameListScreen> {
  List<Map<String, dynamic>> _allSurnames = [];
  List<Map<String, dynamic>> _filteredSurnames = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  /// 百家姓集合（常见单姓 + 复姓）
  static const Set<String> _hundredFamilyNames = {
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
    '姚', '邵', '湛', '汪', '祁', '毛', '禹', '狄', '米', '贝',
    '明', '臧', '计', '伏', '成', '戴', '谈', '宋', '茅', '庞',
    '熊', '纪', '舒', '屈', '项', '祝', '董', '梁', '杜', '阮',
    '蓝', '闵', '席', '季', '麻', '强', '贾', '路', '娄', '危',
    '江', '童', '颜', '郭', '梅', '盛', '林', '刁', '钟', '徐',
    '邱', '骆', '高', '夏', '蔡', '田', '樊', '胡', '凌', '霍',
    '虞', '万', '支', '柯', '昝', '管', '卢', '莫', '经', '房',
    '裘', '缪', '干', '解', '应', '宗', '丁', '宣', '贲', '邓',
    '郁', '单', '杭', '洪', '包', '诸', '左', '石', '崔', '吉',
    '钮', '龚', '程', '嵇', '邢', '滑', '裴', '陆', '荣', '翁',
    '荀', '羊', '於', '惠', '甄', '曲', '家', '封', '芮', '羿',
    '储', '靳', '汲', '邴', '糜', '松', '井', '段', '富', '巫',
    '乌', '焦', '巴', '弓', '牧', '隗', '山', '谷', '车', '侯',
    '宓', '蓬', '全', '郗', '班', '仰', '秋', '仲', '伊', '宫',
    '宁', '仇', '栾', '暴', '甘', '钭', '厉', '戎', '祖', '武',
    '符', '刘', '景', '詹', '束', '龙', '叶', '幸', '司', '韶',
    '郜', '黎', '蓟', '溥', '印', '宿', '白', '怀', '蒲', '邰',
    '从', '鄂', '索', '咸', '籍', '赖', '卓', '蔺', '屠', '蒙',
    '池', '乔', '阴', '郁', '胥', '能', '苍', '双', '闻', '莘',
    '党', '翟', '谭', '贡', '劳', '逄', '姬', '申', '扶', '堵',
    '冉', '宰', '郦', '雍', '却', '璩', '桑', '桂', '濮', '牛',
    '寿', '通', '边', '扈', '燕', '冀', '浦', '尚', '农', '温',
    '别', '庄', '晏', '柴', '瞿', '阎', '充', '慕', '连', '茹',
    '习', '宦', '艾', '鱼', '容', '向', '古', '易', '慎', '戈',
    '廖', '庾', '终', '暨', '居', '衡', '步', '都', '耿', '满',
    '弘', '匡', '国', '文', '寇', '广', '禄', '阙', '东', '欧',
    '殳', '沃', '利', '蔚', '越', '夔', '隆', '师', '巩', '厍',
    '聂', '晁', '勾', '敖', '融', '冷', '訾', '辛', '阚', '那',
    '简', '饶', '空', '曾', '毋', '沙', '乜', '养', '鞠', '须',
    '丰', '巢', '关', '蒯', '相', '查', '后', '荆', '红', '游',
    '竺', '权', '逯', '盖', '益', '桓', '公',
  };

  /// 常见复姓集合
  static const Set<String> _compoundSurnames = {
    '欧阳', '太史', '端木', '上官', '司马', '东方', '独孤', '南宫',
    '万俟', '闻人', '夏侯', '诸葛', '尉迟', '公羊', '赫连', '澹台',
    '皇甫', '宗政', '濮阳', '公冶', '太叔', '申屠', '公孙', '慕容',
    '仲孙', '钟离', '长孙', '宇文', '司徒', '鲜于', '司空', '闾丘',
    '子车', '亓官', '司寇', '巫马', '公西', '颛孙', '壤驷', '公良',
    '漆雕', '乐正', '宰父', '谷梁', '拓跋', '夹谷', '轩辕', '令狐',
    '段干', '百里', '呼延', '东郭', '南门', '羊舌', '微生', '公户',
    '公玉', '公仪', '梁丘', '公仲', '公上', '公门', '公山', '公坚',
    '左丘', '公伯', '西门', '公祖', '第五', '公乘', '贯丘', '公皙',
    '南荣', '东里', '东宫', '仲长', '子书', '子桑', '即墨', '达奚',
    '褚师',
  };

  @override
  void initState() {
    super.initState();
    _loadSurnames();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSurnames() async {
    setState(() => _isLoading = true);
    try {
      final surnames = await DataService().loadSurnames();
      if (mounted) {
        setState(() {
          _allSurnames = surnames;
          _filteredSurnames = surnames;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// 按拼音首字母分组
  Map<String, List<Map<String, dynamic>>> _groupSurnames(
      List<Map<String, dynamic>> surnames) {
    final Map<String, List<Map<String, dynamic>>> grouped = {};

    for (final item in surnames) {
      final pinyin = (item['pinyin'] as String? ?? '').toUpperCase();
      String letter;
      if (pinyin.isEmpty) {
        letter = '#';
      } else {
        final firstChar = pinyin[0];
        letter = (firstChar.codeUnitAt(0) >= 65 && firstChar.codeUnitAt(0) <= 90)
            ? firstChar
            : '#';
      }
      grouped.putIfAbsent(letter, () => []).add(item);
    }

    // 按字母排序
    final sortedKeys = grouped.keys.toList()..sort();
    final sortedGrouped = <String, List<Map<String, dynamic>>>{};
    for (final key in sortedKeys) {
      sortedGrouped[key] = grouped[key]!;
    }
    return sortedGrouped;
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() => _filteredSurnames = _allSurnames);
    } else {
      final lowerQuery = query.toLowerCase();
      setState(() {
        _filteredSurnames = _allSurnames.where((item) {
          final surname = (item['surname'] as String? ?? '').toLowerCase();
          final pinyin = (item['pinyin'] as String? ?? '').toLowerCase();
          return surname.contains(lowerQuery) || pinyin.contains(lowerQuery);
        }).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final grouped = _groupSurnames(_filteredSurnames);
    final groupKeys = grouped.keys.toList();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadSurnames,
        child: CustomScrollView(
          slivers: [
            // 顶部搜索栏
            SliverAppBar(
              floating: true,
              pinned: true,
              elevation: 0,
              scrolledUnderElevation: 1,
              backgroundColor: theme.colorScheme.surface,
              surfaceTintColor: Colors.transparent,
              title: Text(
                '姓氏大全',
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(64),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: '搜索姓氏或拼音...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 20),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide(
                          color: theme.colorScheme.primary.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      isDense: true,
                    ),
                  ),
                ),
              ),
            ),

            // 加载状态
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),

            // 空状态
            if (!_isLoading && _filteredSurnames.isEmpty)
              SliverFillRemaining(
                child: _buildEmptyState(
                  _searchController.text.isNotEmpty
                      ? '未找到匹配的姓氏'
                      : '暂无姓氏数据，请下拉刷新',
                ),
              ),

            // 姓氏分组列表：每个分组由一个粘性标题 SliverPersistentHeader + 一个 SliverList 组成
            if (!_isLoading && _filteredSurnames.isNotEmpty)
              for (final letter in groupKeys)
                ..._buildGroupSlivers(letter, grouped[letter]!),

            // 底部留白
            const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
          ],
        ),
      ),
    );
  }

  /// 为每个分组生成粘性标题 + 列表 sliver
  List<Widget> _buildGroupSlivers(
      String letter, List<Map<String, dynamic>> items) {
    return [
      // 粘性分组标题
      SliverPersistentHeader(
        pinned: true,
        delegate: _StickyHeaderDelegate(
          letter: letter,
          count: items.length,
        ),
      ),
      // 该分组下的姓氏列表
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final item = items[index];
            return _SurnameItem(
              surname: item['surname'] as String? ?? '',
              pinyin: item['pinyin'] as String? ?? '',
              rank: int.tryParse(item['rank'] as String? ?? '') ?? 0,
              onTap: () => _showSurnameDetail(context, item),
            );
          },
          childCount: items.length,
        ),
      ),
    ];
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.library_books_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.grey[600], fontSize: 15)),
        ],
      ),
    );
  }

  void _showSurnameDetail(BuildContext context, Map<String, dynamic> item) {
    final surname = item['surname'] as String? ?? '';
    final pinyin = (item['pinyin'] as String? ?? '').toUpperCase();
    final rank = int.tryParse(item['rank'] as String? ?? '') ?? 0;
    final isHundredFamily = _hundredFamilyNames.contains(surname);
    final isCompound = _compoundSurnames.contains(surname);

    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 姓氏大字
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              alignment: Alignment.center,
              child: Text(
                surname,
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 拼音首字母
            _DetailRow(
              icon: Icons.translate,
              label: '拼音首字母',
              value: pinyin.isNotEmpty ? pinyin[0] : '-',
              valueColor: theme.colorScheme.primary,
            ),
            const SizedBox(height: 12),

            // 排名
            _DetailRow(
              icon: Icons.format_list_numbered,
              label: '排名',
              value: rank > 0 ? '第 $rank 名' : '未收录',
              valueColor: rank > 0 && rank <= 100 ? Colors.orange : Colors.grey,
            ),
            const SizedBox(height: 12),

            // 是否百家姓
            _DetailRow(
              icon: Icons.auto_stories,
              label: '百家姓',
              value: isHundredFamily ? '是' : '否',
              valueColor: isHundredFamily ? Colors.green : Colors.grey,
            ),
            const SizedBox(height: 12),

            // 是否复姓
            _DetailRow(
              icon: Icons.text_fields,
              label: '复姓',
              value: isCompound ? '是' : '否',
              valueColor: isCompound ? Colors.purple : Colors.grey,
            ),

            const SizedBox(height: 24),

            // 关闭按钮
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('关闭'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 粘性分组标题的 SliverPersistentHeaderDelegate
class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String letter;
  final int count;

  _StickyHeaderDelegate({required this.letter, required this.count});

  @override
  double get minExtent => 40;

  @override
  double get maxExtent => 40;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final theme = Theme.of(context);
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            letter,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$count个',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _StickyHeaderDelegate oldDelegate) {
    return letter != oldDelegate.letter || count != oldDelegate.count;
  }
}

/// 姓氏列表项
class _SurnameItem extends StatelessWidget {
  final String surname;
  final String pinyin;
  final int rank;
  final VoidCallback onTap;

  const _SurnameItem({
    required this.surname,
    required this.pinyin,
    required this.rank,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            // 姓氏字
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Text(
                surname,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // 拼音 + 姓氏
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pinyin,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    surname,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // 排名标签
            _RankBadge(rank: rank),
          ],
        ),
      ),
    );
  }
}

/// 排名标签
class _RankBadge extends StatelessWidget {
  final int rank;

  const _RankBadge({required this.rank});

  @override
  Widget build(BuildContext context) {
    if (rank > 0 && rank <= 100) {
      Color bgColor;
      Color textColor;

      if (rank <= 10) {
        bgColor = Colors.orange.withValues(alpha: 0.12);
        textColor = Colors.orange;
      } else if (rank <= 50) {
        bgColor = Colors.blue.withValues(alpha: 0.1);
        textColor = Colors.blue;
      } else {
        bgColor = Colors.teal.withValues(alpha: 0.1);
        textColor = Colors.teal;
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '#$rank',
          style: TextStyle(
            color: textColor,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '稀有',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }
  }
}

/// 详情行组件
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[500]),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 15, color: Colors.grey[700]),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
