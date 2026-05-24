import 'package:flutter/material.dart';
import '../services/data_service.dart';

class JapaneseNamesScreen extends StatefulWidget {
  const JapaneseNamesScreen({super.key});

  @override
  State<JapaneseNamesScreen> createState() => _JapaneseNamesScreenState();
}

class _JapaneseNamesScreenState extends State<JapaneseNamesScreen> {
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
      final count = await DataService().getTotalCount('japanese');
      final data = await DataService().loadJapaneseNames(
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
      final data = await DataService().loadJapaneseNames(
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

  void _showNameDetail(Map<String, dynamic> nameData) {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            '日本人名',
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  nameData['name'] as String,
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                    letterSpacing: 6,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '来源：日本常见姓名数据库',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 13,
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
        title: const Text('日本人名'),
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
                    Icons.flag,
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
                              Icons.translate,
                              size: 64,
                              color: colorScheme.onSurfaceVariant.withOpacity(0.4),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '暂无日本人名数据',
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
                          final name = nameData['name'] as String;

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
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: colorScheme.secondaryContainer,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        name.characters.first,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              colorScheme.onSecondaryContainer,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      name,
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w500,
                                        color: colorScheme.onSurface,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: colorScheme.onSurfaceVariant
                                          .withOpacity(0.5),
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
