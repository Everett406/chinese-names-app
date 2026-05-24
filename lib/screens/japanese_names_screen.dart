import 'package:flutter/material.dart';
import '../services/data_service.dart';

/// 日文人名浏览页面
class JapaneseNamesScreen extends StatefulWidget {
  const JapaneseNamesScreen({super.key});

  @override
  State<JapaneseNamesScreen> createState() => _JapaneseNamesScreenState();
}

class _JapaneseNamesScreenState extends State<JapaneseNamesScreen> {
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _names = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _errorMessage;
  int _currentPage = 0;
  static const int _pageSize = 50;

  @override
  void initState() {
    super.initState();
    _loadNames();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && !_isLoadingMore && _hasMore) {
      _loadMore();
    }
  }

  Future<void> _loadNames() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final names = await DataService.loadJapaneseNames(offset: 0, limit: _pageSize);
      setState(() { _names = names; _isLoading = false; _currentPage = 1; _hasMore = names.length >= _pageSize; });
    } catch (e) {
      setState(() { _isLoading = false; _errorMessage = '加载失败：$e'; });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() => _isLoadingMore = true);
    try {
      final offset = _currentPage * _pageSize;
      final moreNames = await DataService.loadJapaneseNames(offset: offset, limit: _pageSize);
      setState(() { _names.addAll(moreNames); _currentPage++; _hasMore = moreNames.length >= _pageSize; _isLoadingMore = false; });
    } catch (e) {
      setState(() => _isLoadingMore = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('加载更多失败：$e')));
    }
  }

  void _showNameDetail(Map<String, dynamic> nameData) {
    final theme = Theme.of(context);
    final nameKanji = nameData['name_kanji'] as String? ?? '';
    final nameHiragana = nameData['name_hiragana'] as String? ?? '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(nameKanji),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (nameHiragana.isNotEmpty) ...[
              Text('假名', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(nameHiragana, style: theme.textTheme.bodyMedium),
            ],
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('关闭'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('日文人名'), centerTitle: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.error_outline, size: 48, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text(_errorMessage!, style: TextStyle(color: colorScheme.error)),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _loadNames, child: const Text('重试')),
                ]))
              : ListView.builder(
                  controller: _scrollController,
                  itemCount: _names.length + (_hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= _names.length) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(child: _isLoadingMore
                            ? const CircularProgressIndicator()
                            : Text('已加载全部 ${_names.length} 条记录',
                                style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant))),
                      );
                    }
                    final nameData = _names[index];
                    final nameKanji = nameData['name_kanji'] as String? ?? '';
                    final nameHiragana = nameData['name_hiragana'] as String? ?? '';
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: colorScheme.tertiaryContainer,
                        child: Text(nameKanji.isNotEmpty ? nameKanji[0] : '?',
                            style: TextStyle(color: colorScheme.onTertiaryContainer, fontWeight: FontWeight.bold)),
                      ),
                      title: Text(nameKanji, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                      subtitle: nameHiragana.isNotEmpty
                          ? Text(nameHiragana, style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant))
                          : null,
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _showNameDetail(nameData),
                    );
                  },
                ),
    );
  }
}
