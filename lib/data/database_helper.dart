import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/masterpiece.dart';

/// SQLite 数据库助手类
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('masterpieces.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final pathString = join(dbPath, filePath);

    return await openDatabase(
      pathString,
      version: 1,
      onCreate: _createDB,
    );
  }

  /// 创建作品数据表并填充预设初始数据
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE masterpieces (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        prompt TEXT NOT NULL,
        toolType TEXT NOT NULL,
        imageUrl TEXT NOT NULL,
        isPrivate INTEGER NOT NULL,
        authorName TEXT NOT NULL,
        createdAt INTEGER NOT NULL
      )
    ''');

    // 填充与原生 Room 数据库完全一致的 8 个初始演示艺术杰作
    final initialList = [
      Masterpiece(
        title: "梦幻森林",
        prompt: "梦幻般的精灵森林，晨雾与金色阳光穿过古老树木",
        toolType: "风格迁移",
        imageUrl: "https://images.unsplash.com/photo-1502082553048-f009c37129b9?q=80&w=600",
        isPrivate: false,
        authorName: "AI_Designer_01"
      ),
      Masterpiece(
        title: "未来城市",
        prompt: "赛博朋克风格未来都市，高耸入云的全息霓虹大厦",
        toolType: "AI 扩图",
        imageUrl: "https://images.unsplash.com/photo-1549611016-3a70d82b5040?q=80&w=600",
        isPrivate: false,
        authorName: "AI_Designer_01"
      ),
      Masterpiece(
        title: "抽象艺术",
        prompt: "现代抽象艺术泼墨，缤纷艳丽的色彩斑驳交融",
        toolType: "风格迁移",
        imageUrl: "https://images.unsplash.com/photo-1541701494587-cb58502866ab?q=80&w=600",
        isPrivate: false,
        authorName: "AI_Designer_01"
      ),
      Masterpiece(
        title: "卡通肖像",
        prompt: "卡通黏土风小男孩头像，温暖和善的微笑，亮橘色高领卫衣",
        toolType: "换脸",
        imageUrl: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=600",
        isPrivate: false,
        authorName: "AI_Designer_01"
      ),
      Masterpiece(
        title: "复古油画",
        prompt: "17世纪巴洛克古典仕女肖像，柔和光影，油画质感细腻",
        toolType: "风格迁移",
        imageUrl: "https://images.unsplash.com/photo-1579783900882-c0d3dad7b119?q=80&w=600",
        isPrivate: true,
        authorName: "AI_Designer_01"
      ),
      Masterpiece(
        title: "极光夜景",
        prompt: "绿色极光飞舞掠过冬日星空，厚厚雪地上照耀出璀璨光芒",
        toolType: "物体移除",
        imageUrl: "https://images.unsplash.com/photo-1483168527879-c66136b56105?q=80&w=600",
        isPrivate: true,
        authorName: "AI_Designer_01"
      ),
      Masterpiece(
        title: "赛博朋克日落",
        prompt: "赛博朋克日落下的宏伟未来建筑群，飞船在摩天大楼间穿梭",
        toolType: "AI 扩图",
        imageUrl: "https://images.unsplash.com/photo-1515621061946-eff1c2a352bd?q=80&w=600",
        isPrivate: false,
        authorName: "AI艺术家_李"
      ),
      Masterpiece(
        title: "极光山脉",
        prompt: "雄伟雪山在夜幕下矗立，绚烂极光在山顶舞动，倒映在宁静的冰湖中",
        toolType: "风格迁移",
        imageUrl: "https://images.unsplash.com/photo-1483168527879-c66136b56105?q=80&w=600",
        isPrivate: false,
        authorName: "视觉创造者"
      )
    ];

    for (var item in initialList) {
      await db.insert('masterpieces', item.toMap());
    }
  }

  /// 插入一个杰作作品
  Future<int> insertMasterpiece(Masterpiece masterpiece) async {
    final db = await instance.database;
    return await db.insert('masterpieces', masterpiece.toMap());
  }

  /// 根据ID彻底删除某个作品
  Future<int> deleteMasterpieceById(int id) async {
    final db = await instance.database;
    return await db.delete(
      'masterpieces',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// 查询所有杰作（按创建时间倒序）
  Future<List<Masterpiece>> getAllMasterpieces() async {
    final db = await instance.database;
    final result = await db.query('masterpieces', orderBy: 'createdAt DESC');
    return result.map((json) => Masterpiece.fromMap(json)).toList();
  }

  /// 查询所有公开（非私密）的作品用于社区流
  Future<List<Masterpiece>> getPublicMasterpieces() async {
    final db = await instance.database;
    final result = await db.query(
      'masterpieces',
      where: 'isPrivate = 0',
      orderBy: 'createdAt DESC',
    );
    return result.map((json) => Masterpiece.fromMap(json)).toList();
  }

  /// 关闭数据库
  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
