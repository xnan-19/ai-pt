/// 作品数据模型实体类
class Masterpiece {
  final int? id; // 主键自增ID，插入数据库前可为空
  final String title; // 作品标题
  final String prompt; // 创作提示词
  final String toolType; // 使用的AI工具类型 ("风格迁移", "换脸", "AI 扩图", "物体移除")
  final String imageUrl; // 作品图片链接
  final bool isPrivate; // 是否为私密保存（不显示到公共社区）
  final String authorName; // 作者署名
  final int createdAt; // 创建时间戳（毫秒数）

  Masterpiece({
    this.id,
    required this.title,
    required this.prompt,
    required this.toolType,
    required this.imageUrl,
    this.isPrivate = false,
    this.authorName = 'AI_Designer_01',
    int? createdAt,
  }) : this.createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch;

  /// 将实体对象转换成用于数据库插入的 Map 键值对
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'prompt': prompt,
      'toolType': toolType,
      'imageUrl': imageUrl,
      'isPrivate': isPrivate ? 1 : 0, // SQLite 中使用 0 和 1 代表布尔值
      'authorName': authorName,
      'createdAt': createdAt,
    };
  }

  /// 从数据库 Map 查询结果构建实体对象
  factory Masterpiece.fromMap(Map<String, dynamic> map) {
    return Masterpiece(
      id: map['id'] as int?,
      title: map['title'] as String,
      prompt: map['prompt'] as String,
      toolType: map['toolType'] as String,
      imageUrl: map['imageUrl'] as String,
      isPrivate: (map['isPrivate'] as int) == 1,
      authorName: map['authorName'] as String,
      createdAt: map['createdAt'] as int,
    );
  }
}
