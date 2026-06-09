import 'package:flutter/material.dart';
import '../../models/masterpiece.dart';

/// 作品详情模态框
class MasterpieceDetailDialog extends StatelessWidget {
  final Masterpiece item; // 作品实体
  final VoidCallback onDismiss; // 关闭回调
  final VoidCallback onDelete; // 删除回调

  const MasterpieceDetailDialog({
    Key? key,
    required this.item,
    required this.onDismiss,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext buildContext) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(buildContext).size.height * 0.88,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 顶部关闭与可见度栏
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          item.isPrivate ? Icons.lock : Icons.public,
                          color: Colors.grey,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          item.isPrivate ? "私密保存" : "公开作品",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: onDismiss,
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              // 主图预览（带工具名称标签）
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      Image.network(
                        item.imageUrl,
                        height: 280,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 280,
                            color: Colors.grey[300],
                            alignment: Alignment.center,
                            child: const Icon(Icons.image, size: 48, color: Colors.grey),
                          );
                        },
                      ),
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.toolType,
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
              ),
              // 文案与操作区
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E2022),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "作者: ${item.authorName}",
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 提示词
                    const Text(
                      "创作提示词：",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item.prompt,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF334155),
                          fontWeight: FontWeight.medium,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 评析文案
                    const Text(
                      "AI 艺术评析（大师视界）：",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "通过【${item.toolType}】的奇妙作用，提示词「${item.prompt}」展现出了不可思议的张力。画面色彩运用大胆，整体色调具有高级数码材质的渲染细节，明暗线条流畅，呈现出一个精美而虚幻的独立艺术世界，将科技与艺术的情感完美交融。",
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF334155),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // 删除按钮 (若作者为 AI_Designer_01 则可删除)
                    if (item.authorName == "AI_Designer_01")
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: TextButton(
                          onPressed: onDelete,
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFFFECACA),
                            foregroundColor: const Color(0xFFDC2626),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.delete, size: 16),
                              SizedBox(width: 6),
                              Text(
                                "从图库彻底删除作品",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
