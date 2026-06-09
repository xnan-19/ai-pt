import 'package:flutter/material.dart';

/// API 设置弹窗
class ApiSettingsDialog extends StatelessWidget {
  final VoidCallback onDismiss;

  const ApiSettingsDialog({Key? key, required this.onDismiss}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      title: const Text(
        "API 密钥设置",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "系统采用安全管理。密钥通过后台 .env 文件安全注入为 BuildConfig.GEMINI_API_KEY，无需在客户端明文硬编码保护数据隐私。",
            style: TextStyle(fontSize: 14, color: Color(0xFF475569)),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              "当前配置状态: 已激活 (Inject System Key)",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F766E),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onDismiss,
          child: const Text("关闭", style: TextStyle(color: Color(0xFF3B82F6))),
        ),
      ],
    );
  }
}

/// 账号管理弹窗
class AccountMgmtDialog extends StatelessWidget {
  final VoidCallback onDismiss;

  const AccountMgmtDialog({Key? key, required this.onDismiss}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      title: const Text(
        "账号管理",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "用户名: AI_Designer_01",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text("用户类型: 开发者测试账号"),
          SizedBox(height: 4),
          Text("创作点数: ♾️ 无限能量"),
          SizedBox(height: 8),
          Text(
            "系统已在AI Studio沙盒中保持自动同步。",
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onDismiss,
          child: const Text("确定", style: TextStyle(color: Color(0xFF3B82F6))),
        ),
      ],
    );
  }
}

/// 关于应用弹窗
class AboutDialog extends StatelessWidget {
  final VoidCallback onDismiss;

  const AboutDialog({Key? key, required this.onDismiss}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Colors.white,
      title: const Text(
        "关于 AI 实验室",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "AI 实验室 极简版 (淡色) v1.0",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          SizedBox(height: 6),
          Text(
            "基于 Google AI Studio 平台开发，由先进的 Gemini 3.5 Flash 智能大模型驱动。让每个人都能轻松享受智能照片修改、图像风格艺术分析与生成的乐趣。",
            style: TextStyle(fontSize: 14, height: 1.4),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: onDismiss,
          child: const Text("好", style: TextStyle(color: Color(0xFF3B82F6))),
        ),
      ],
    );
  }
}
