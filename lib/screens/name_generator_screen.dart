import 'package:flutter/material.dart';
import '../services/data_service.dart';

/// 人名生成器页面
class NameGeneratorScreen extends StatefulWidget {
  const NameGeneratorScreen({super.key});

  @override
  State<NameGeneratorScreen> createState() => _NameGeneratorScreenState();
}

class _NameGeneratorScreenState extends State<NameGeneratorScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _surnameController = TextEditingController();
  String _genderPreference = '不限';
  String? _currentName;
  bool _isLoading = false;
  final List<String> _history = [];

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
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
    setState(() => _isLoading = true);
    try {
      final surname = _surnameController.text.trim();
      final name = await DataService.generateRandomName(
        surname: surname.isEmpty ? null : surname,
        gender: _genderPreference == '不限' ? null : _genderPreference,
      );
      setState(() {
        _currentName = name;
        _isLoading = false;
        _history.insert(0, name);
        if (_history.length > 10) _history.removeLast();
      });
      _animationController.reset();
      _animationController.forward();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('生成失败：$e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('人名生成器'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _surnameController,
              decoration: InputDecoration(
                labelText: '输入姓氏（可选）',
                hintText: '留空则随机生成',
                prefixIcon: const Icon(Icons.person_outline),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
              ),
            ),
            const SizedBox(height: 20),
            Text('性别偏好', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: ['男', '女', '不限'].map((gender) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(gender),
                      selected: _genderPreference == gender,
                      onSelected: (selected) {
                        setState(() => _genderPreference = gender);
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _generateName,
              icon: _isLoading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.auto_awesome),
              label: Text(_isLoading ? '生成中...' : '生成姓名', style: const TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            if (_currentName != null) ...[
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorScheme.primaryContainer, colorScheme.secondaryContainer],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: Text(
                        _currentName!,
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                          letterSpacing: 8,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: _isLoading ? null : _generateName,
                      icon: const Icon(Icons.refresh),
                      label: const Text('换一个'),
                    ),
                  ],
                ),
              ),
            ],
            if (_history.isNotEmpty) ...[
              const SizedBox(height: 32),
              Text('生成历史', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _history.map((name) {
                  return Chip(
                    label: Text(name),
                    onDeleted: () {
                      setState(() => _history.remove(name));
                    },
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
