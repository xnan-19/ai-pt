import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/main_viewmodel.dart';
import '../../models/masterpiece.dart';

/// 作品图库 Tab 页面
class GalleryTab extends StatefulWidget {
  const GalleryTab({Key? key}) : super(key: key);

  @override
  State<GalleryTab> createState() => _GalleryTabState();
}

class _GalleryTabState extends State<GalleryTab> {
  bool _showOnlyPublic = false;

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MainViewModel>(context);
    final masterpieces = viewModel.allMasterpieces;

    // 过滤列表逻辑
    final filteredList = _showOnlyPublic
        ? masterpieces.where((item) => !item.isPrivate).toList()
        : masterpieces;

    return SafeArea(
      child: Column(
        children: [
          // 头部过滤器栏
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "作品图库 极简版",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E2022),
                  ),
                ),
                // 筛选开关
                Row(
                  children: [
                    Text(
                      _showOnlyPublic ? "公开" : "全部",
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Switch(
                      value: _showOnlyPublic,
                      onChanged: (value) {
                        setState(() {
                          _showOnlyPublic = value;
                        });
                      },
                      activeColor: const Color(0xFF3B82F6),
                      activeTrackColor: const Color(0xFF3B82F6).withOpacity(0.4),
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: Colors.grey[300],
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 内容网格
          Expanded(
            child: filteredList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.photo_library,
                          size: 64,
                          color: Colors.lightGrey,
                        ),
                        SizedBox(height: 12),
                        Text(
                          "图库暂无作品，快去'创作'制作一个吧！",
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(16.0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.8, // 适合高宽比例以容纳图片与文本
                    ),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final item = filteredList[index];
                      return _GalleryMasterpieceCard(
                        item: item,
                        onClick: () {
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

/// 图库单件作品卡片
class _GalleryMasterpieceCard extends StatelessWidget {
  final Masterpiece item;
  final VoidCallback onClick;

  const _GalleryMasterpieceCard({
    Key? key,
    required this.item,
    required this.onClick,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onClick,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 主配图预览与锁状锁状态标识
            Expanded(
              child: Stack(
                children: [
                  Image.network(
                    item.imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        alignment: Alignment.center,
                        child: const Icon(Icons.image, color: Colors.grey),
                      );
                    },
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        item.isPrivate ? Icons.lock : Icons.public,
                        color: Colors.white,
                        size: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 文字介绍区
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E2022),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.toolType,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF3B82F6),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.prompt,
                    style: const TextStyle(
                      fontSize: 11,
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
    );
  }
}
