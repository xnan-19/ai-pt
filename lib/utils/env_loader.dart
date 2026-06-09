import 'package:flutter/services.dart';

/// 环境变量加载辅助类
class EnvLoader {
  static final Map<String, String> _env = {};

  /// 加载并解析位于 assets 中的 .env 配置文件
  static Future<void> load() async {
    try {
      // 从资源包中读取 .env 文件内容
      final content = await rootBundle.loadString('.env');
      final lines = content.split('\n');
      
      for (var line in lines) {
        line = line.trim();
        // 忽略空行和注释行
        if (line.isEmpty || line.startsWith('#')) continue;
        
        final parts = line.split('=');
        if (parts.length >= 2) {
          final key = parts[0].trim();
          // 合并后面可能包含 "=" 的部分值
          final value = parts.sublist(1).join('=').trim();
          _env[key] = value;
        }
      }
    } catch (e) {
      // 如果文件加载失败（比如尚未创建 .env），打印警告但程序不崩溃，留待界面提示 ApiKeyError
      print("Warning: Failed to load .env file: $e");
    }
  }

  /// 获取环境变量值，如果未配置则返回默认值
  static String get(String key, {String defaultValue = ''}) {
    return _env[key] ?? defaultValue;
  }
}
