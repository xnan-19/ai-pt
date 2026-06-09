import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/main_viewmodel.dart';
import '../dialogs/profile_dialogs.dart';
import '../dialogs/help_desk_qa_dialog.dart';

/// 个人中心 Tab 页面
class ProfileTab extends StatelessWidget {
  const ProfileTab({Key? key}) : super(key: key);

  /// 弹出帮助客服话框的方法
  void _showHelpDesk(BuildContext context, MainViewModel viewModel) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => HelpDeskQADialog(
        onDismiss: () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<MainViewModel>(context);
    final masterpiecesCount = viewModel.allMasterpieces.length;

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // 顶标题和修改资料按钮
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Text(
                    "个人中心",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E2022),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFF555555)),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AccountMgmtDialog(onDismiss: () => Navigator.pop(ctx)),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 10),
            // 圆形精美头像与名称信息
            Column(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                      )
                    ],
                    gradient: const RadialGradient(
                      colors: [Color(0xFFE0E7FF), Color(0xFFC7D2FE)],
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.account_circle,
                    color: Color(0xFF4F46E5),
                    size: 70,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      "AI_Designer_01",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E2022),
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.verified,
                      color: Color(0xFF2563EB),
                      size: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  "系统默认AI智能设计师",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // 统计信息模块面板
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                color: Colors.white,
                elevation: 1,
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem("$masterpiecesCount", "编辑"),
                      _buildDivider(),
                      _buildStatItem("89.2k", "喜欢"),
                      _buildDivider(),
                      _buildStatItem("540", "关注"),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // 2x2 控制卡片网格
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.6, // 高度为 94dp
                children: [
                  _buildMenuCard(
                    context,
                    "API设置",
                    Icons.settings,
                    () => showDialog(
                      context: context,
                      builder: (ctx) => ApiSettingsDialog(onDismiss: () => Navigator.pop(ctx)),
                    ),
                  ),
                  _buildMenuCard(
                    context,
                    "账号管理",
                    Icons.manage_accounts,
                    () => showDialog(
                      context: context,
                      builder: (ctx) => AccountMgmtDialog(onDismiss: () => Navigator.pop(ctx)),
                    ),
                  ),
                  _buildMenuCard(
                    context,
                    "关于",
                    Icons.info,
                    () => showDialog(
                      context: context,
                      builder: (ctx) => AboutDialog(onDismiss: () => Navigator.pop(ctx)),
                    ),
                  ),
                  _buildMenuCard(
                    context,
                    "帮助中心",
                    Icons.help_center,
                    () => _showHelpDesk(context, viewModel),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  /// 构建单个统计项
  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E2022),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  /// 统计项之间的分切线
  Widget _buildDivider() {
    return Container(
      height: 24,
      width: 1,
      color: const Color(0xFFE2E8F0),
    );
  }

  /// 构建菜单子卡片
  Widget _buildMenuCard(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      elevation: 1,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: const Color(0xFF555555),
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF334155),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
