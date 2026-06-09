import 'package:flutter/material.dart';

/// AI 创作中加载遮罩层
class CreationLoadingOverlay extends StatelessWidget {
  const CreationLoadingOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext buildContext) {
    return Container(
      // 半透明的黑色背景
      color: Colors.black.withOpacity(0.45),
      alignment: Alignment.center,
      child: Container(
        width: 180,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 深灰色指示器
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E2022)),
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'AI 正在创作灵感...',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E2022),
                decoration: TextDecoration.none, // 移除暗淡默认样式
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              '极速生成中...',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
