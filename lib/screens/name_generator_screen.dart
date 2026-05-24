import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/data_service.dart';

class NameGeneratorScreen extends StatefulWidget {
  const NameGeneratorScreen({super.key});

  @override
  State<NameGeneratorScreen> createState() => _NameGeneratorScreenState();
}

class _NameGeneratorScreenState extends State<NameGeneratorScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _surnameController = TextEditingController();
  String _selectedGender = '不限';
  bool _isGenerating = false;
  String? _generatedName;
  final List<String> _history = [];

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    );
  }

  @override
  void dispose() {
    _surnameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _generateName() async {
    setState(() {
      _isGenerating = true;
      _generatedName = null;
      _animationController.reset();
    });

    try {
      final surname = _surnameController.text.trim().isEmpty
          ? null
          : _surnameController.text.trim();
      final gender =
          _selectedGender == '不限' ? null : _selectedGender;

      final name = await DataService().generateRandomName(
        surname: surname,
        gender: gender,
      );

      setState(() {
        _generatedName = name;
        _isGenerating = false;
        _animationController.forward();

        // 添加到历史记录（去重，最多20条）
        if (!_history.contains(name)) {
          _history.insert(0, name);
          if (_history.length > 20) {
            _history.removeLast();
          }
        }
      });
    } catch (e) {
      setState(() {
        _isGenerating = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('生成失败: $e')),
        );
      }
    }
  }

  void _copyName(String name) {
    Clipboard.setData(ClipboardData(text: name));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('已复制到剪贴板'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('随机取名'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 姓氏输入框
            TextField(
              controller: _surnameController,
              decoration: InputDecoration(
                labelText: '姓氏（可选）',
                hintText: '输入姓氏，留空则随机',
                prefixIcon: const Icon(Icons.person_outline),
                suffixIcon: _surnameController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _surnameController.clear();
                          setState(() {});
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 20),

            // 性别选择
            Text(
              '性别选择',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              children: ['男', '女', '不限'].map((gender) {
                return ChoiceChip(
                  label: Text(gender),
                  selected: _selectedGender == gender,
                  onSelected: (selected) {
                    setState(() {
                      _selectedGender = gender;
                    });
                  },
                  avatar: _getGenderIcon(gender),
                  selectedColor: colorScheme.primaryContainer,
                  labelStyle: TextStyle(
                    color: _selectedGender == gender
                        ? colorScheme.onPrimaryContainer
                        : colorScheme.onSurfaceVariant,
                    fontWeight: _selectedGender == gender
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // 生成按钮
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isGenerating ? null : _generateName,
                icon: _isGenerating
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onPrimary,
                        ),
                      )
                    : const Icon(Icons.casino, size: 24),
                label: Text(
                  _isGenerating ? '生成中...' : '生成名字',
                  style: const TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // 生成结果
            if (_generatedName != null)
              ScaleTransition(
                scale: _scaleAnimation,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 28,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorScheme.primaryContainer,
                        colorScheme.secondaryContainer,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        '为您生成',
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onPrimaryContainer.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _generatedName!,
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                          letterSpacing: 8,
                        ),
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () => _copyName(_generatedName!),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.copy,
                                size: 14,
                                color: colorScheme.onPrimaryContainer,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '点击复制',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // 历史记录
            if (_history.isNotEmpty) ...[
              const SizedBox(height: 32),
              Row(
                children: [
                  Text(
                    '历史记录',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_history.length}/20',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  if (_history.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _history.clear();
                        });
                      },
                      child: const Text('清空'),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _history.map((name) {
                  return ActionChip(
                    label: Text(name),
                    avatar: const Icon(Icons.history, size: 16),
                    onPressed: () => _copyName(name),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget? _getGenderIcon(String gender) {
    switch (gender) {
      case '男':
        return const Icon(Icons.male, color: Colors.blue, size: 18);
      case '女':
        return const Icon(Icons.female, color: Colors.pink, size: 18);
      default:
        return const Icon(Icons.shuffle, size: 18);
    }
  }
}
