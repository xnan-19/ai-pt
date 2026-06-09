import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/main_viewmodel.dart';

/// AI 创作选项卡页面
class CreateTab extends StatefulWidget {
  const CreateTab({Key? key}) : super(key: key);

  @override
  State<CreateTab> createState() => _CreateTabState();
}

class _CreateTabState extends State<CreateTab> {
  late TextEditingController _promptController;

  @override
  void initState() {
    super.initState();
    _promptController = TextEditingController();
    // 监听 ViewModel 更改并同步 TextField 的值（例如从社区同步过来的提示词）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<MainViewModel>(context, listen: false);
      _promptController.text = viewModel.prompt;
      viewModel.addListener(_onViewModelChange);
    });
  }

  void _onViewModelChange() {
    final viewModel = Provider.of<MainViewModel>(context, listen: false);
    if (_promptController.text != viewModel.prompt) {
      _promptController.text = viewModel.prompt;
    }
  }

  @override
  void dispose() {
    final viewModel = Provider.of<MainViewModel>(context, listen: false);
    viewModel.removeListener(_onViewModelChange);
    _promptController.dispose();
    super.dispose();
  }

  /// 对应原生根据选中工具动态分配的大图资源
  String _getBackdropUrl(String tool) {
    switch (tool) {
      case "风格迁移":
        return "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=600";
      case "换脸":
        return "https://images.unsplash.com/photo-1544005313-94ddf0286df2?q=80&w=600";
      case "AI 扩图":
        return "https://images.unsplash.com/photo-1511556532299-8f662fc26c06?q=80&w=600";
      default:
        return "https://images.unsplash.com/photo-1507525428034-b723cf961d3e?q=80&w=600";
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MainViewModel>(context);

    // 定义 4 种智能修图工具
    final tools = [
      _ToolItem("风格迁移", Icons.brush),
      _ToolItem("换脸", Icons.face),
      _ToolItem("AI 扩图", Icons.aspect_ratio),
      _ToolItem("物体移除", Icons.content_cut),
    ];

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 大标题
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  "AI 实验室 极简版 (淡色)",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E2022),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            // 背景视觉大图卡片
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  children: [
                    Image.network(
                      _getBackdropUrl(viewModel.selectedTool),
                      height: 240,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 240,
                          color: Colors.grey[300],
                          alignment: Alignment.center,
                          child: const Icon(Icons.image, size: 50, color: Colors.grey),
                        );
                      },
                    ),
                    // 底部覆盖正在编辑提示徽章
                    Positioned(
                      left: 16,
                      bottom: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "正在编辑：${viewModel.selectedTool}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            // 中部标题
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 6.0),
              child: Text(
                "智能修改",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E2022),
                ),
              ),
            ),
            // 2x2 工具选择网格
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.2, // 高度约为 80dp
                children: tools.map((tool) {
                  final isSelected = viewModel.selectedTool == tool.name;
                  return InkWell(
                    onTap: () {
                      viewModel.setTool(tool.name);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFEFF6FF) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected
                            ? Border.all(color: const Color(0xFF3B82F6), width: 1.5)
                            : null,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            tool.icon,
                            color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF64748B),
                            size: 28,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            tool.name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? const Color(0xFF1E3A8A) : const Color(0xFF334155),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
            // 底部配置输入卡片
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                color: Colors.white,
                elevation: 1,
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // 头部配置与同步开关
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "创作配置与范围",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF475569),
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                viewModel.isPrivate ? "私密保存" : "公开同步 (社区)",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Switch(
                                value: viewModel.isPrivate,
                                onChanged: (value) {
                                  viewModel.setPrivate(value);
                                },
                                activeColor: const Color(0xFF3B82F6),
                                activeTrackColor: const Color(0xFF3B82F6).withOpacity(0.4),
                                inactiveThumbColor: Colors.white,
                                inactiveTrackColor: Colors.grey[300],
                              ),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 10),
                      // 提示词文本框
                      TextField(
                        controller: _promptController,
                        onChanged: (text) {
                          viewModel.setPrompt(text);
                        },
                        onSubmitted: (text) {
                          viewModel.performAiEdit();
                        },
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: "输入提示词，AI 助你创作...",
                          hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                          filled: true,
                          fillColor: const Color(0xFFF8FAFC),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 12),
                      // AI修图触发按钮
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            viewModel.performAiEdit();
                          },
                          icon: const Icon(Icons.auto_awesome, size: 18),
                          label: const Text(
                            "AI 修图",
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E2022),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _ToolItem {
  final String name;
  final IconData icon;
  _ToolItem(this.name, this.icon);
}
