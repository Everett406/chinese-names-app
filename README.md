# 萌名工具箱 (Chinese Names Toolkit)

基于 [Chinese-Names-Corpus](https://github.com/wainshine/Chinese-Names-Corpus) 语料库开发的 Android 应用，使用 Flutter 构建。

## 功能特性

- 🎲 **人名生成器** - 基于百万级中文人名语料，智能随机生成姓名
- 🔍 **人名搜索** - 在120万中文人名中搜索，支持性别标注
- 📖 **姓氏大全** - 浏览1000+中文姓氏
- 📚 **成语词典** - 收录5万中华成语
- 📜 **古代人名** - 25万古代人名语料
- 🇯🇵 **日文人名** - 18万日文人名语料

## 技术栈

- **框架**: Flutter 3.24+
- **语言**: Dart
- **状态管理**: Provider
- **构建**: GitHub Actions (自动构建 APK)
- **最低支持**: Android 5.0 (API 21)

## 数据来源

数据来自 [wainshine/Chinese-Names-Corpus](https://github.com/wainshine/Chinese-Names-Corpus) 项目，感谢原作者的整理工作。

## 构建

### 通过 GitHub Actions 自动构建

推送代码到 `main` 分支后，GitHub Actions 会自动构建 APK。构建完成后可在 Actions 页面下载。

### 本地构建

```bash
git clone https://github.com/Everett406/chinese-names-app.git
cd chinese-names-app
flutter pub get
flutter build apk --release
```

## 许可证

MIT License
