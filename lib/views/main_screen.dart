import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/main_viewmodel.dart';
import 'tabs/discover_tab.dart';
import 'tabs/create_tab.dart';
import 'tabs/gallery_tab.dart';
import 'tabs/profile_tab.dart';
import 'dialogs/creation_loading_overlay.dart';
import 'dialogs/creation_success_dialog.dart';
import 'dialogs/masterpiece_detail_dialog.dart';

/// 主页面容器（含底栏导航及全局响应式弹窗层）
class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  /// 依据 Tab ID 构建不同的面板页面
  Widget _buildTabContent(String tab) {
    switch (tab) {
      case 'discover':
        return const DiscoverTab(key: ValueKey('discover'));
      case 'create':
        return const CreateTab(key: ValueKey('create'));
      case 'gallery':
        return const GalleryTab(key: ValueKey('gallery'));
      case 'profile':
        return const ProfileTab(key: ValueKey('profile'));
      default:
        return const DiscoverTab(key: ValueKey('discover'));
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MainViewModel>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA), // 淡雅背景
      bottomNavigationBar: _buildBottomNavigationBar(context, viewModel),
      body: Stack(
        children: [
          // 1. 主页面 Tab 内容（伴有过渡动画）
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: _buildTabContent(viewModel.activeTab),
            ),
          ),

          // 2. 全局修图加载等待层
          if (viewModel.editUiState.status == EditStatus.loading)
            const Positioned.fill(child: CreationLoadingOverlay()),

          // 3. 全局修图成功弹窗层
          if (viewModel.editUiState.status == EditStatus.success)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                alignment: Alignment.center,
                child: CreationSuccessDialog(
                  masterpiece: viewModel.editUiState.masterpiece!,
                  commentary: viewModel.editUiState.feedback!,
                  onDismiss: () => viewModel.clearEditState(),
                ),
              ),
            ),

          // 4. 全局修图失败弹窗层
          if (viewModel.editUiState.status == EditStatus.error)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                alignment: Alignment.center,
                child: AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  backgroundColor: Colors.white,
                  title: const Text("创作反馈", style: TextStyle(fontWeight: FontWeight.bold)),
                  content: Text(viewModel.editUiState.errorMessage!),
                  actions: [
                    TextButton(
                      onPressed: () => viewModel.clearEditState(),
                      child: const Text("确定", style: TextStyle(color: Color(0xFF1E2022))),
                    ),
                  ],
                ),
              ),
            ),

          // 5. 全局杰作作品详情弹窗层
          if (viewModel.selectedMasterpiece != null)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                alignment: Alignment.center,
                child: MasterpieceDetailDialog(
                  item: viewModel.selectedMasterpiece!,
                  onDismiss: () => viewModel.selectMasterpiece(null),
                  onDelete: () {
                    viewModel.deleteMasterpiece(viewModel.selectedMasterpiece!.id!);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("作品已删除"),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 底部导航栏实现
  Widget _buildBottomNavigationBar(BuildContext context, MainViewModel viewModel) {
    // 适配刘海屏/下巴安全距离
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    final tabs = [
      _TabNavItem('discover', '发现', Icons.explore_outlined, Icons.explore),
      _TabNavItem('create', '创作', Icons.brush_outlined, Icons.brush),
      _TabNavItem('gallery', '画廊', Icons.photo_library_outlined, Icons.photo_library),
      _TabNavItem('profile', '我的', Icons.person_outline, Icons.person),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          )
        ],
      ),
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: SizedBox(
        height: 64,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: tabs.map((item) {
            final isSelected = viewModel.activeTab == item.id;
            return Expanded(
              child: InkWell(
                onTap: () => viewModel.setTab(item.id),
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isSelected ? item.activeIcon : item.inactiveIcon,
                      color: isSelected ? const Color(0xFF1E2022) : const Color(0xFF8E959E),
                      size: 24,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? const Color(0xFF1E2022) : const Color(0xFF8E959E),
                      ),
                    ),
                    // 激活时小蓝圆点指示器
                    if (isSelected)
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: Color(0xFF3B82F6),
                          shape: BoxShape.circle,
                        ),
                      )
                    else
                      const SizedBox(height: 6),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _TabNavItem {
  final String id;
  final String label;
  final IconData inactiveIcon;
  final IconData activeIcon;

  _TabNavItem(this.id, this.label, this.inactiveIcon, this.activeIcon);
}
