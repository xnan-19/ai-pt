import 'package:flutter/material.dart';
import '../models/masterpiece.dart';
import '../data/database_helper.dart';
import '../api/gemini_client.dart';

/// AI 创作状态枚举
enum EditStatus { idle, loading, success, error }

/// AI 创作响应状态封装
class EditUiState {
  final EditStatus status;
  final Masterpiece? masterpiece;
  final String? feedback;
  final String? errorMessage;

  EditUiState.idle()
      : status = EditStatus.idle,
        masterpiece = null,
        feedback = null,
        errorMessage = null;

  EditUiState.loading()
      : status = EditStatus.loading,
        masterpiece = null,
        feedback = null,
        errorMessage = null;

  EditUiState.success(this.masterpiece, this.feedback)
      : status = EditStatus.success,
        errorMessage = null;

  EditUiState.error(this.errorMessage)
      : status = EditStatus.error,
        masterpiece = null,
        feedback = null;
}

/// 核心状态控制中心 ViewModel
class MainViewModel extends ChangeNotifier {
  // 当前高亮的Tab项: "discover", "create", "gallery", "profile"
  String _activeTab = 'discover';
  String get activeTab => _activeTab;

  // AI 创作 Prompt 提示词输入内容
  String _prompt = '';
  String get prompt => _prompt;

  // 是否私密保存（控制是否同步在社区发现流里显示）
  bool _isPrivate = false;
  bool get isPrivate => _isPrivate;

  // 当前选中的修图智能修改工具
  String _selectedTool = '风格迁移';
  String get selectedTool => _selectedTool;

  // AI 创作成图的 UI 状态
  EditUiState _editUiState = EditUiState.idle();
  EditUiState get editUiState => _editUiState;

  // 全局选中的单个作品（用于在详情对话框/模态框显示）
  Masterpiece? _selectedMasterpiece;
  Masterpiece? get selectedMasterpiece => _selectedMasterpiece;

  // 杰作作品集合数据
  List<Masterpiece> _allMasterpieces = [];
  List<Masterpiece> get allMasterpieces => _allMasterpieces;

  List<Masterpiece> _publicMasterpieces = [];
  List<Masterpiece> get publicMasterpieces => _publicMasterpieces;

  // 帮助中心客服问答回答及加载中状态
  String _helpAnswer = '';
  String get helpAnswer => _helpAnswer;

  bool _helpLoading = false;
  bool get helpLoading => _helpLoading;

  MainViewModel() {
    // 构造函数中加载数据库已有数据并完成绑定
    loadMasterpieces();
  }

  /// 重新加载本地数据库中的所有作品和公开作品流
  Future<void> loadMasterpieces() async {
    _allMasterpieces = await DatabaseHelper.instance.getAllMasterpieces();
    _publicMasterpieces = await DatabaseHelper.instance.getPublicMasterpieces();
    notifyListeners();
  }

  /// 设置当前 Tab 页面并触发通知
  void setTab(String tab) {
    _activeTab = tab;
    notifyListeners();
  }

  /// 更改 Prompt 输入内容
  void setPrompt(String text) {
    _prompt = text;
    notifyListeners();
  }

  /// 更改公开/私密同步开关
  void setPrivate(bool value) {
    _isPrivate = value;
    notifyListeners();
  }

  /// 更改当前选中的智能工具名称
  void setTool(String tool) {
    _selectedTool = tool;
    notifyListeners();
  }

  /// 设置选中的艺术作品详情，传 null 表示关闭弹窗
  void selectMasterpiece(Masterpiece? item) {
    _selectedMasterpiece = item;
    notifyListeners();
  }

  /// 重置创作状态回 Idle 闲置
  void clearEditState() {
    _editUiState = EditUiState.idle();
    notifyListeners();
  }

  /// 删除指定 ID 的作品
  Future<void> deleteMasterpiece(int id) async {
    await DatabaseHelper.instance.deleteMasterpieceById(id);
    if (_selectedMasterpiece?.id == id) {
      _selectedMasterpiece = null;
    }
    await loadMasterpieces(); // 重新拉取
  }

  /// 执行 AI 修图生成逻辑
  Future<void> performAiEdit() async {
    final currentPrompt = _prompt.trim();
    final currentTool = _selectedTool;
    final currentPrivate = _isPrivate;

    if (currentPrompt.isEmpty) {
      _editUiState = EditUiState.error('请输入创作提示词后进行AI修图');
      notifyListeners();
      return;
    }

    // 设置状态为加载中并刷新界面
    _editUiState = EditUiState.loading();
    notifyListeners();

    // 根据输入提示词和选择的工具，选择精选的本地或网络配图资源
    final imageUrl = _selectCuratedImage(currentPrompt, currentTool);

    // 组装传给 Gemini 3.5 Flash 的系统艺术评析指令
    final systemInstruction = '''
你是一个资深的艺术评论家和艺术故事述说者。
请根据用户选择的修图工具【$currentTool】和创作提示词【$currentPrompt】，写一段对所生成的数字美术作品的优美、诗意艺术描述。
你需要描述这件作品的视觉效果、光影变幻、色彩搭配、笔触纹理以及隐藏的艺术概念寓意。
语言要深邃优雅，极具艺术大师感，务必使用中文。
段落控制在两段以内，总字数不要超过180字。
'''.trim();

    final promptCommand = "请为使用了【$currentTool】工具、基于提示词【$currentPrompt】生成的艺术作品撰写视觉分析。";

    // 请求 Gemini API
    final feedbackText = await GeminiClient.generate(
      promptCommand,
      systemInstruction: systemInstruction,
    );

    if (feedbackText == 'ApiKeyError') {
      _editUiState = EditUiState.error(
        "API Key未设置。请在'我的-API设置'或后台Secrets控制面板中配置您的GEMINI_API_KEY。",
      );
      notifyListeners();
      return;
    }

    if (feedbackText.startsWith('Error:')) {
      _editUiState = EditUiState.error(feedbackText.replaceFirst('Error:', '').trim());
      notifyListeners();
      return;
    }

    // 成功获取艺术赏析！截取标题作为作品名
    final autoTitle = currentPrompt.length > 8 ? '${currentPrompt.substring(0, 8)}...' : currentPrompt;

    final newWork = Masterpiece(
      title: autoTitle,
      prompt: currentPrompt,
      toolType: currentTool,
      imageUrl: imageUrl,
      isPrivate: currentPrivate,
      authorName: 'AI_Designer_01',
    );

    // 存储作品并重载数据库流
    await DatabaseHelper.instance.insertMasterpiece(newWork);
    await loadMasterpieces();

    // 设置成功状态
    _editUiState = EditUiState.success(newWork, feedbackText);
    notifyListeners();
  }

  /// 提问客服解答问题接口
  Future<void> askHelpQuestion(String question) async {
    _helpLoading = true;
    _helpAnswer = '';
    notifyListeners();

    final systemInstruction = '''
你是一个AI实验室的智能客服专家，专门负责解答用户关于人工智能、生成式AI、图像修图、深度仿冒、AI扩图、风格迁移等技术问题的疑惑。
你的回答应该专业、亲切、简单易懂，并且通俗化，避免过多的英文技术名词，必须用中文回答。
回答内容简明扼要，控制在150字以内。
'''.trim();

    final answer = await GeminiClient.generate(
      question,
      systemInstruction: systemInstruction,
    );

    if (answer == 'ApiKeyError') {
      _helpAnswer = "抱歉，由于缺少您的 API Key，请先到「我的 - API设置」中配置您的 GEMINI_API_KEY 才能获取AI实时解答。";
    } else {
      _helpAnswer = answer;
    }

    _helpLoading = false;
    notifyListeners();
  }

  /// 精选图片匹配推荐逻辑
  String _selectCuratedImage(String promptText, String toolName) {
    final p = promptText.toLowerCase();
    
    if (p.contains('森林') || p.contains('树') || p.contains('精灵') || p.contains('forest') || p.contains('green')) {
      return 'https://images.unsplash.com/photo-1502082553048-f009c37129b9?q=80&w=600';
    }
    if (p.contains('城市') || p.contains('赛博') || p.contains('霓虹') || p.contains('科幻') || p.contains('cyber') || p.contains('city')) {
      return 'https://images.unsplash.com/photo-1549611016-3a70d82b5040?q=80&w=600';
    }
    if (p.contains('油画') || p.contains('复古') || p.contains('古典') || p.contains('巴洛克') || p.contains('vintage') || p.contains('paint')) {
      return 'https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?q=80&w=600';
    }
    if (p.contains('动漫') || p.contains('卡通') || p.contains('黏土') || p.contains('萌') || p.contains('avatar') || p.contains('cartoon')) {
      return 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=600';
    }
    if (p.contains('极光') || p.contains('星空') || p.contains('极夜') || p.contains('aurora') || p.contains('sky')) {
      return 'https://images.unsplash.com/photo-1483168527879-c66136b56105?q=80&w=600';
    }
    if (p.contains('抽象') || p.contains('泼墨') || p.contains('色彩') || p.contains('abstract')) {
      return 'https://images.unsplash.com/photo-1541701494587-cb58502866ab?q=80&w=600';
    }

    // 后备方案
    switch (toolName) {
      case '风格迁移':
        return 'https://images.unsplash.com/photo-1541701494587-cb58502866ab?q=80&w=600';
      case '换脸':
        return 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=600';
      case 'AI 扩图':
        return 'https://images.unsplash.com/photo-1515621061946-eff1c2a352bd?q=80&w=600';
      case '物体移除':
        return 'https://images.unsplash.com/photo-1483168527879-c66136b56105?q=80&w=600';
      default:
        return 'https://images.unsplash.com/photo-1549611016-3a70d82b5040?q=80&w=600';
    }
  }
}
