import 'package:flutter/material.dart';
import '../services/data_service.dart';

/// 名字搜索页面
/// 使用 SearchDelegate 实现搜索，支持实时过滤、高亮匹配、名字卡片展示
class NameSearchScreen extends StatefulWidget {
  const NameSearchScreen({super.key});

  @override
  State<NameSearchScreen> createState() => _NameSearchScreenState();
}

class _NameSearchScreenState extends State<NameSearchScreen> {
  List<Map<String, dynamic>> _allNames = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNames();
  }

  Future<void> _loadNames() async {
    try {
      final names = await DataService().loadNames();
      if (mounted) {
        setState(() {
          _allNames = names;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('名字搜索'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: '搜索名字',
            onPressed: () {
              showSearch(
                context: context,
                delegate: _NameSearchDelegate(allNames: _allNames),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _allNames.isEmpty
              ? _buildEmptyState('暂无名字数据，请稍后重试')
              : _buildNameList(),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.grey[600], fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildNameList() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _allNames.length,
      itemBuilder: (context, index) {
        final item = _allNames[index];
        return _NameCard(
          name: item['name'] as String? ?? '',
          gender: item['gender'] as String? ?? '',
          onTap: () => _showNameDetail(context, item),
        );
      },
    );
  }

  void _showNameDetail(BuildContext context, Map<String, dynamic> item) {
    final name = item['name'] as String? ?? '';
    final gender = item['gender'] as String? ?? '未知';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          name,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            _GenderChip(gender: gender),
            const SizedBox(height: 16),
            Text(
              '这是一个${gender == '男' ? '男性' : gender == '女' ? '女性' : ''}名字',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}

/// 名字卡片组件
class _NameCard extends StatelessWidget {
  final String name;
  final String gender;
  final VoidCallback onTap;

  const _NameCard({
    required this.name,
    required this.gender,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: theme.colorScheme.surfaceContainerLow,
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              // 名字首字头像
              CircleAvatar(
                radius: 24,
                backgroundColor: _genderColor(gender).withOpacity(0.12),
                child: Text(
                  name.isNotEmpty ? name[0] : '?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _genderColor(gender),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // 名字
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
              // 性别标签
              _GenderChip(gender: gender),
            ],
          ),
        ),
      ),
    );
  }

  Color _genderColor(String gender) {
    switch (gender) {
      case '男':
        return Colors.blue;
      case '女':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }
}

/// 性别标签组件
class _GenderChip extends StatelessWidget {
  final String gender;

  const _GenderChip({required this.gender});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    String label;

    switch (gender) {
      case '男':
        bgColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue;
        label = '男';
        break;
      case '女':
        bgColor = Colors.pink.withOpacity(0.1);
        textColor = Colors.pink;
        label = '女';
        break;
      default:
        bgColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey;
        label = '未知';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }
}

/// 搜索委托
class _NameSearchDelegate extends SearchDelegate<String> {
  final List<Map<String, dynamic>> allNames;
  List<Map<String, dynamic>> _searchResults = [];
  List<Map<String, dynamic>> _suggestions = [];

  _NameSearchDelegate({required this.allNames});

  @override
  List<Widget> buildActions(BuildContext context) {
    if (query.isNotEmpty) {
      return [
        IconButton(
          icon: const Icon(Icons.clear),
          tooltip: '清除',
          onPressed: () {
            query = '';
            showSuggestions(context);
          },
        ),
      ];
    }
    return [];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      tooltip: '返回',
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (_searchResults.isEmpty) {
      return _buildEmptyState('未找到匹配的名字');
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final item = _searchResults[index];
        return _NameCard(
          name: item['name'] as String? ?? '',
          gender: item['gender'] as String? ?? '',
          onTap: () {
            _showNameDetail(context, item);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    _suggestions = _filterNames(query);
    if (query.isEmpty) {
      return _buildEmptyState('输入名字进行搜索');
    }
    if (_suggestions.isEmpty) {
      return _buildEmptyState('未找到匹配的名字');
    }
    return ListView.builder(
      itemCount: _suggestions.length,
      itemBuilder: (context, index) {
        final item = _suggestions[index];
        final name = item['name'] as String? ?? '';
        return ListTile(
          leading: CircleAvatar(
            radius: 18,
            backgroundColor: _genderColor(item['gender'] as String? ?? '').withOpacity(0.12),
            child: Text(
              name.isNotEmpty ? name[0] : '?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: _genderColor(item['gender'] as String? ?? ''),
              ),
            ),
          ),
          title: _buildHighlightedText(name, query),
          trailing: _GenderChip(gender: item['gender'] as String? ?? ''),
          onTap: () {
            query = name;
            showResults(context);
          },
        );
      },
    );
  }

  @override
  void showResults(BuildContext context) {
    _searchResults = _filterNames(query);
    super.showResults(context);
  }

  List<Map<String, dynamic>> _filterNames(String query) {
    if (query.isEmpty) return [];
    final lowerQuery = query.toLowerCase();
    return allNames.where((item) {
      final name = (item['name'] as String? ?? '').toLowerCase();
      return name.contains(lowerQuery);
    }).toList();
  }

  /// 高亮匹配文字：匹配部分加粗黑色，其余灰色
  Widget _buildHighlightedText(String text, String query) {
    if (query.isEmpty) {
      return Text(text, style: const TextStyle(fontSize: 16));
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final matchIndex = lowerText.indexOf(lowerQuery);

    if (matchIndex < 0) {
      return Text(text, style: TextStyle(fontSize: 16, color: Colors.grey[600]));
    }

    final before = text.substring(0, matchIndex);
    final match = text.substring(matchIndex, matchIndex + query.length);
    final after = text.substring(matchIndex + query.length);

    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 16),
        children: [
          TextSpan(
            text: before,
            style: TextStyle(color: Colors.grey[600]),
          ),
          TextSpan(
            text: match,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (after.isNotEmpty)
            TextSpan(
              text: after,
              style: TextStyle(color: Colors.grey[600]),
            ),
        ],
      ),
    );
  }

  Color _genderColor(String gender) {
    switch (gender) {
      case '男':
        return Colors.blue;
      case '女':
        return Colors.pink;
      default:
        return Colors.grey;
    }
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off, size: 56, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(message, style: TextStyle(color: Colors.grey[600], fontSize: 15)),
        ],
      ),
    );
  }

  void _showNameDetail(BuildContext context, Map<String, dynamic> item) {
    final name = item['name'] as String? ?? '';
    final gender = item['gender'] as String? ?? '未知';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          name,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            _GenderChip(gender: gender),
            const SizedBox(height: 16),
            Text(
              '这是一个${gender == '男' ? '男性' : gender == '女' ? '女性' : ''}名字',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}
