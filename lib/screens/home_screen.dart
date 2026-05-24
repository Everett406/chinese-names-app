import 'package:flutter/material.dart';

/// 首页 - 萌名工具箱功能入口
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final List<Map<String, String>> features = [
      {'icon': '🎲', 'title': '人名生成器', 'subtitle': '随机生成好听的中文名字', 'route': '/generator'},
      {'icon': '🔍', 'title': '人名搜索', 'subtitle': '搜索姓名的含义和来源', 'route': '/search'},
      {'icon': '📖', 'title': '姓氏大全', 'subtitle': '浏览百家姓及稀有姓氏', 'route': '/surnames'},
      {'icon': '📚', 'title': '成语词典', 'subtitle': '查询成语释义和典故', 'route': '/idioms'},
      {'icon': '📜', 'title': '古代人名', 'subtitle': '探索历史名人的姓名', 'route': '/ancient'},
      {'icon': '🇯🇵', 'title': '日文人名', 'subtitle': '了解日本姓名文化', 'route': '/japanese'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('萌名工具箱'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            final feature = features[index];
            return Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  Navigator.pushNamed(context, feature['route']!);
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(feature['icon']!, style: const TextStyle(fontSize: 40)),
                      const SizedBox(height: 12),
                      Text(
                        feature['title']!,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        feature['subtitle']!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
