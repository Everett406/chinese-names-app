import 'dart:async';
import 'package:flutter/material.dart';
import '../services/data_service.dart';

/// 人名搜索页面
class NameSearchScreen extends StatefulWidget {
  const NameSearchScreen({super.key});

  @override
  State<NameSearchScreen> createState() => _NameSearchScreenState();
}

class _NameSearchScreenState extends State<NameSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounceTimer;

  List<Map<String, dynamic>> _results = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _performSearch(_searchController.text.trim());
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() { _results = []; _hasSearched = false; _errorMessage = null; });
      return;
    }
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final results = await DataService.searchNames(query);
      setState(() { _results = results; _isLoading = false; _hasSearched = true; });
    } catch (e) {
      setState(() { _isLoading = false; _hasSearched = true; _errorMessage = '搜索出错：$e'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('人名搜索'), centerTitle: true),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '输入姓名搜索...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear), onPressed: () {
                        _searchController.clear();
                        setState(() { _results = []; _hasSearched = false; });
                      })
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
              ),
            ),
          ),
          if (_hasSearched && !_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text('找到 ${_results.length} 个结果',
                  style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
            ),
          if (_errorMessage != null)
            Padding(padding: const EdgeInsets.all(16.0), child: Text(_errorMessage!, style: TextStyle(color: colorScheme.error))),
          if (_isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator())),
          if (!_isLoading && _hasSearched && _results.isEmpty && _errorMessage == null)
            Expanded(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.search_off, size: 64, color: colorScheme.onSurfaceVariant.withOpacity(0.5)),
              const SizedBox(height: 16),
              Text('未找到相关姓名', style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant)),
            ]))),
          if (!_isLoading && _results.isNotEmpty)
            Expanded(child: ListView.builder(
              controller: _scrollController,
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final item = _results[index];
                final name = item['name'] as String? ?? '';
                final gender = item['gender'] as String? ?? '';
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: gender == '男' ? Colors.blue.shade100 : gender == '女' ? Colors.pink.shade100 : Colors.grey.shade100,
                    child: Text(name.isNotEmpty ? name[0] : '?',
                        style: TextStyle(
                          color: gender == '男' ? Colors.blue.shade800 : gender == '女' ? Colors.pink.shade800 : Colors.grey.shade800,
                          fontWeight: FontWeight.bold)),
                  ),
                  title: Text(name, style: theme.textTheme.titleMedium),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: gender == '男' ? Colors.blue.shade50 : gender == '女' ? Colors.pink.shade50 : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: gender == '男' ? Colors.blue.shade200 : gender == '女' ? Colors.pink.shade200 : Colors.grey.shade200),
                    ),
                    child: Text(gender, style: TextStyle(fontSize: 12,
                      color: gender == '男' ? Colors.blue.shade700 : gender == '女' ? Colors.pink.shade700 : Colors.grey.shade700,
                      fontWeight: FontWeight.w500)),
                  ),
                );
              },
            )),
          if (!_hasSearched && !_isLoading)
            Expanded(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.manage_search, size: 64, color: colorScheme.onSurfaceVariant.withOpacity(0.5)),
              const SizedBox(height: 16),
              Text('输入姓名开始搜索', style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurfaceVariant)),
            ]))),
        ],
      ),
    );
  }
}
