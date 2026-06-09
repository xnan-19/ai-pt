import 'package:flutter/material.dart';
import '../../models/masterpiece.dart';

/// AI 创作成功弹窗
class CreationSuccessDialog extends StatelessWidget {
  final Masterpiece masterpiece; // 生成的作品数据对象
  final String commentary; // Gemini 评析文本
  final VoidCallback onDismiss; // 关闭按钮回调

  const CreationSuccessDialog({
    Key? key,
    required this.masterpiece,
    required this.commentary,
    required this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext buildContext) {
    return Dialog(
      shape: RoundedCornerShape(24),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(buildContext).size.height * 0.85,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 庆祝星星图标
              const Icon(
                Icons.auto_awesome,
                color: Color(0xFFEAB308),
                size: 36,
              ),
              const SizedBox(height: 4),
              const Text(
                '智能修图成功！',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF15803D),
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                '作品已自动归档至【作品图库】',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              // 生成的图像预览及工具类型徽章
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    Image.network(
                      masterpiece.imageUrl,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200,
                          color: Colors.grey[300],
                          alignment: Alignment.center,
                          child: const Icon(Icons.image, color: Colors.grey),
                        );
                      },
                    ),
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          masterpiece.toolType,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // AI 艺术评析标题
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Gemini AI 艺术赏析描述：',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              // AI 评析卡片
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  commentary,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF334155),
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // 返回并继续创作按钮
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: onDismiss,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E2022),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    '返回并继续创作',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 辅助圆角方法
BorderRadius RoundedCornerShape(double radius) => BorderRadius.circular(radius);
