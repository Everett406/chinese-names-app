import 'dart:async';
import 'package:flutter/material.dart';
import '../services/data_service.dart';

/// 成语词典页面
class IdiomDictionaryScreen extends StatefulWidget {
  const IdiomDictionaryScreen({super.key});

  @override
  State<IdiomDictionaryScreen> createState() => _IdiomDictionaryScreenState();
}

class _IdiomDictionaryScreenState extends State<IdiomDictionaryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounceTimer;

  List<Map<String, dynamic>> _idioms = [];
  List<Map<String, dynamic>> _filteredIdioms = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadIdioms();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadIdioms() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final idioms = await DataService.loadIdioms();
      setState(() { _idioms = idioms; _filteredIdioms = idioms; _isLoading = false; });
    } catch (e) {
      setState(() { _isLoading = false; _errorMessage = '加载失败：$e'; });
    }
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _filterIdioms(_searchController.text.trim());
    });
  }

  Future<void> _filterIdioms(String query) async {
    if (query.isEmpty) {
      setState(() { _filteredIdioms = _idioms; _searchQuery = ''; });
      return;
    }
    setState(() => _searchQuery = query);
    try {
      final results = await DataService.searchIdioms(query);
      setState(() => _filteredIdioms = results);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('搜索失败：$e')));
    }
  }

  void _showIdiomDetail(Map<String, dynamic> idiom) {
    final theme = Theme.of(context);
    final word = idiom['word'] as String? ?? '';
    final explanation = idiom['explanation'] as String? ?? '';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(word),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (explanation.isNotEmpty) ...[
              Text('释义', style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(explanation, style: theme.textTheme.bodyMedium),
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
      appBar: AppBar(title: const Text('成语词典'), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索成语...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('找到 ${_filteredIdioms.length} 个成语',
                    style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.error_outline, size: 48, color: colorScheme.error),
                        const SizedBox(height: 16),
                        Text(_errorMessage!, style: TextStyle(color: colorScheme.error)),
                        const SizedBox(height: 16),
                        ElevatedButton(onPressed: _loadIdioms, child: const Text('重试')),
                      ]))
                    : _filteredIdioms.isEmpty
                        ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                            Icon(Icons.menu_book, size: 64, color: colorScheme.onSurfaceVariant.withOpacity(0.5)),
                            const SizedBox(height: 16),
                            Text(_searchQuery.isNotEmpty ? '未找到匹配的成语' : '暂无成语数据',
                                style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant)),
                          ]))
                        : ListView.builder(
                            controller: _scrollController,
                            itemCount: _filteredIdioms.length,
                            itemBuilder: (context, index) {
                              final idiom = _filteredIdioms[index];
                              final word = idiom['word'] as String? ?? '';
                              final explanation = idiom['explanation'] as String? ?? '';
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: colorScheme.tertiaryContainer,
                                  child: Text(word.isNotEmpty ? word[0] : '?',
                                      style: TextStyle(color: colorScheme.onTertiaryContainer, fontWeight: FontWeight.bold)),
                                ),
                                title: Text(word, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                                subtitle: Text(explanation, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodySmall),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => _showIdiomDetail(idiom),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
