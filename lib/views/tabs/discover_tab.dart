import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/main_viewmodel.dart';
import '../../models/masterpiece.dart';

/// 社区发现 Tab 页面
class DiscoverTab extends StatelessWidget {
  const DiscoverTab({Key? key}) : super(key: key);

  final List<String> trendingTags = const [
    "赛博朋克日落", "极光山脉", "未来主义城市", "抽象人像", "深海探险", "古风墨韵", "废土美学"
  ];

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MainViewModel>(context);
    final publicItems = viewModel.publicMasterpieces;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 顶标题
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Text(
              "社区发现",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w200, // Light
                color: Color(0xFF1E2022),
              ),
            ),
          ),
          // 热门提示词列表
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
                child: Text(
                  "Trending Prompts",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A5568),
                  ),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                child: Row(
                  children: trendingTags.map((tag) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ActionChip(
                      label: Text(
                        tag,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF4A5568),
                        ),
                      ),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      onPressed: () {
                        viewModel.setPrompt(tag);
                        viewModel.setTab("create");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('已载入提示词 "$tag"'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    ),
                  )).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 社区内容流
          Expanded(
            child: publicItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.cloud_queue,
                          size: 48,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 8),
                        Text(
                          "暂无社区动态",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                    itemCount: publicItems.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 20),
                    itemBuilder: (context, index) {
                      final item = publicItems[index];
                      return _CommunityArtworkCard(
                        item: item,
                        onUsePrompt: () {
                          viewModel.setPrompt(item.prompt);
                          viewModel.setTool(item.toolType);
                          viewModel.setTab("create");
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('已复制提示词并进入创作'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        onViewDetail: () {
                          viewModel.selectMasterpiece(item);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// 社区作品卡片组件
class _CommunityArtworkCard extends StatelessWidget {
  final Masterpiece item;
  final VoidCallback onUsePrompt;
  final VoidCallback onViewDetail;

  const _CommunityArtworkCard({
    Key? key,
    required this.item,
    required this.onUsePrompt,
    required this.onViewDetail,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white,
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onViewDetail,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 主图展示与修图工具徽章
            Stack(
              children: [
                Image.network(
                  item.imageUrl,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 220,
                      color: Colors.grey[300],
                      alignment: Alignment.center,
                      child: const Icon(Icons.image, size: 40, color: Colors.grey),
                    );
                  },
                ),
                Positioned(
                  top: 12,
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
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // 用户信息及动作按钮栏
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        // 用户渐变头像框
                        Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [Color(0xFFE0F2FE), Color(0xFFBAE6FD)],
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.person,
                            color: Color(0xFF0284C7),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Text(
                                    "AI_Designer_01",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E2022),
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(
                                    Icons.verified,
                                    color: Color(0xFF3B82F6),
                                    size: 14,
                                  ),
                                ],
                              ),
                              Text(
                                item.title,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  // 使用此提示词按钮
                  ElevatedButton.icon(
                    onPressed: onUsePrompt,
                    icon: const Icon(Icons.add, size: 14),
                    label: const Text(
                      "使用此提示词",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF1F5F9),
                      foregroundColor: const Color(0xFF334155),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
