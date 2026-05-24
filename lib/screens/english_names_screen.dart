import 'package:flutter/material.dart';
import '../services/data_service.dart';

class EnglishNamesScreen extends StatefulWidget {
  const EnglishNamesScreen({super.key});

  @override
  State<EnglishNamesScreen> createState() => _EnglishNamesScreenState();
}

class _EnglishNamesScreenState extends State<EnglishNamesScreen> {
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _names = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  int _offset = 0;
  int _totalCount = 0;
  static const int _pageSize = 50;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadInitialData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMore) {
      _loadMore();
    }
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final count = await DataService().getTotalCount('english');
      final data = await DataService().loadEnglishNames(
        offset: 0,
        limit: _pageSize,
      );

      setState(() {
        _totalCount = count;
        _names.clear();
        _names.addAll(data);
        _offset = data.length;
        _hasMore = data.length >= _pageSize;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载失败: $e')),
        );
      }
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final data = await DataService().loadEnglishNames(
        offset: _offset,
        limit: _pageSize,
      );

      setState(() {
        _names.addAll(data);
        _offset += data.length;
        _hasMore = data.length >= _pageSize;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载更多失败: $e')),
        );
      }
    }
  }

  Color _getGenderColor(String? gender) {
    if (gender == 'M' || gender == '男') return Colors.blue;
    if (gender == 'F' || gender == '女') return Colors.pink;
    return Colors.grey;
  }

  String _getGenderLabel(String? gender) {
    if (gender == 'M' || gender == '男') return '男';
    if (gender == 'F' || gender == '女') return '女';
    return '未知';
  }

  void _showNameDetail(Map<String, dynamic> nameData) {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        final gender = nameData['gender'] as String?;
        final genderColor = _getGenderColor(gender);

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            '英文译名',
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 英文名
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      nameData['en_name'] as String? ?? '',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onPrimaryContainer,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 1,
                      width: 60,
                      color: colorScheme.onPrimaryContainer.withOpacity(0.2),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      nameData['cn_name'] as String? ?? '',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onPrimaryContainer,
                        letterSpacing: 4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 性别标签
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: genderColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: genderColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      gender == 'M' || gender == '男'
                          ? Icons.male
                          : Icons.female,
                      size: 16,
                      color: genderColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getGenderLabel(gender),
                      style: TextStyle(
                        color: genderColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('关闭'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('英文译名'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 顶部统计
          if (_totalCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: colorScheme.surfaceContainerLow,
              child: Row(
                children: [
                  Icon(
                    Icons.translate,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '共 $_totalCount 条记录',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '已加载 ${_names.length} 条',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

          // 列表
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _names.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.language,
                              size: 64,
                              color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '暂无英文译名数据',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount:
                            _names.length + (_hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= _names.length) {
                            return Padding(
                              padding: const EdgeInsets.all(16),
                              child: Center(
                                child: _isLoadingMore
                                    ? const CircularProgressIndicator()
                                    : const Text('没有更多数据了'),
                              ),
                            );
                          }

                          final nameData = _names[index];
                          final cnName =
                              nameData['cn_name'] as String? ?? '';
                          final enName =
                              nameData['en_name'] as String? ?? '';
                          final gender = nameData['gender'] as String?;
                          final genderColor = _getGenderColor(gender);

                          return InkWell(
                            onTap: () => _showNameDetail(nameData),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: colorScheme.outlineVariant
                                        .withOpacity(0.5),
                                    width: 0.5,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  // 性别图标
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: genderColor.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        gender == 'M' || gender == '男'
                                            ? Icons.male
                                            : Icons.female,
                                        color: genderColor,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),

                                  // 中文名
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          cnName,
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w600,
                                            color: colorScheme.onSurface,
                                            letterSpacing: 2,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          enName,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // 性别标签
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: genderColor.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _getGenderLabel(gender),
                                      style: TextStyle(
                                        color: genderColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.chevron_right,
                                    size: 20,
                                    color: colorScheme.onSurfaceVariant
                                        .withOpacity(0.5),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
