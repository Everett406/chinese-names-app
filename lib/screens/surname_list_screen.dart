import 'package:flutter/material.dart';
import '../services/data_service.dart';

/// 姓氏大全页面
class SurnameListScreen extends StatefulWidget {
  const SurnameListScreen({super.key});

  @override
  State<SurnameListScreen> createState() => _SurnameListScreenState();
}

class _SurnameListScreenState extends State<SurnameListScreen> {
  List<String> _surnames = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSurnames();
  }

  Future<void> _loadSurnames() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final surnames = await DataService.loadSurnames();
      setState(() { _surnames = surnames; _isLoading = false; });
    } catch (e) {
      setState(() { _isLoading = false; _errorMessage = '加载失败：$e'; });
    }
  }

  void _showSurnameDetail(String surname) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(surname),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('姓氏：$surname', style: theme.textTheme.bodyLarge),
            const SizedBox(height: 8),
            Text('排名：第 ${_surnames.indexOf(surname) + 1} 位',
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
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
      appBar: AppBar(title: const Text('姓氏大全'), centerTitle: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.error_outline, size: 48, color: colorScheme.error),
                  const SizedBox(height: 16),
                  Text(_errorMessage!, style: TextStyle(color: colorScheme.error), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _loadSurnames, child: const Text('重试')),
                ]))
              : ListView.builder(
                  itemCount: _surnames.length,
                  itemBuilder: (context, index) {
                    final surname = _surnames[index];
                    final showHeader = index % 10 == 0;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showHeader)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                            child: Text('${index + 1} - ${index + 10 > _surnames.length ? _surnames.length : index + 10}',
                                style: theme.textTheme.labelMedium?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold)),
                          ),
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: colorScheme.primaryContainer,
                            child: Text(surname, style: TextStyle(color: colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold)),
                          ),
                          title: Text(surname),
                          subtitle: Text('第 ${index + 1} 姓', style: theme.textTheme.bodySmall),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _showSurnameDetail(surname),
                        ),
                      ],
                    );
                  },
                ),
    );
  }
}
