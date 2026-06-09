import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/main_viewmodel.dart';

/// 智能帮助台 Q&A 问答弹窗
class HelpDeskQADialog extends StatefulWidget {
  final VoidCallback onDismiss;

  const HelpDeskQADialog({Key? key, required this.onDismiss}) : super(key: key);

  @override
  State<HelpDeskQADialog> createState() => _HelpDeskQADialogState();
}

class _HelpDeskQADialogState extends State<HelpDeskQADialog> {
  final TextEditingController _controller = TextEditingController();

  final List<String> _quickQuestions = [
    "什么是AI扩图？",
    "为什么生成图像有时手部不自然？",
    "什么是风格迁移技术？"
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext buildContext) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(buildContext).size.height * 0.85,
        ),
        child: Consumer<MainViewModel>(
          builder: (context, viewModel, child) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 顶部标题栏
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "智能帮助台",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E2022),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: widget.onDismiss,
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // 可滚动的主体区域
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "热门问题快速解答：",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          // 快速问题按钮组
                          ..._quickQuestions.map((q) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () {
                                  _controller.text = q;
                                  viewModel.askHelpQuestion(q);
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  alignment: Alignment.centerLeft,
                                ),
                                child: Text(
                                  q,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF475569),
                                  ),
                                ),
                              ),
                            ),
                          )),
                          const SizedBox(height: 16),
                          // 智能客服回答盒
                          if (viewModel.helpAnswer.isNotEmpty || viewModel.helpLoading) ...[
                            const Text(
                              "AI 助理解答：",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: viewModel.helpLoading
                                  ? const Row(
                                      children: [
                                        SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation(Colors.grey),
                                          ),
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          "思考回答中...",
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey,
                                          ),
                                        )
                                      ],
                                    )
                                  : Text(
                                      viewModel.helpAnswer,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF334155),
                                        height: 1.4,
                                      ),
                                    ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // 底部自定义输入区域
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                          hintText: "输入自定义AI技术问题...",
                          hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                          filled: true,
                          fillColor: const Color(0xFFF1F5F9),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        style: const TextStyle(fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: () {
                            final question = _controller.text.trim();
                            if (question.isNotEmpty) {
                              viewModel.askHelpQuestion(question);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E2022),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "向AI提问",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
