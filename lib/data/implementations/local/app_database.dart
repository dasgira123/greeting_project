import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();

  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getApplicationDocumentsDirectory();
    final path = join(dbPath.path, filePath);

    return await openDatabase(
      path,
      version: 7, // Tăng version lên 7 để thêm dob và avatar
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL UNIQUE,
        is_default INTEGER NOT NULL DEFAULT 0
      )
      ''');
      await _seedDefaultCategories(db);
    }
    if (oldVersion < 3) {
      await _seedDefaultTemplates(db);
    }
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE templates ADD COLUMN is_favorite INTEGER NOT NULL DEFAULT 0');
    }
    if (oldVersion < 5) {
      await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        phone TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        full_name TEXT NOT NULL
      )
      ''');
    }
    if (oldVersion < 6) {
      await db.execute('ALTER TABLE templates ADD COLUMN user_id TEXT');
      await db.execute('''
      CREATE TABLE user_favorites (
        user_id TEXT NOT NULL,
        template_id TEXT NOT NULL,
        PRIMARY KEY (user_id, template_id)
      )
      ''');
    }
    if (oldVersion < 7) {
      await db.execute('ALTER TABLE users ADD COLUMN dob TEXT');
      await db.execute('ALTER TABLE users ADD COLUMN avatar_path TEXT');
    }
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE categories (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL UNIQUE,
      is_default INTEGER NOT NULL DEFAULT 0
    )
    ''');
    
    await db.execute('''
    CREATE TABLE users (
      id TEXT PRIMARY KEY,
      phone TEXT NOT NULL UNIQUE,
      password TEXT NOT NULL,
      full_name TEXT NOT NULL,
      dob TEXT,
      avatar_path TEXT
    )
    ''');

    // Để tương thích với Entity có ID là kiểu String, chúng ta dùng TEXT PRIMARY KEY.
    await db.execute('''
    CREATE TABLE contacts (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      phone TEXT,
      category TEXT NOT NULL,
      status TEXT NOT NULL,
      last_contacted_epoch INTEGER
    )
    ''');

    await db.execute('''
    CREATE TABLE templates (
      id TEXT PRIMARY KEY,
      text TEXT NOT NULL,
      category TEXT NOT NULL,
      is_system INTEGER NOT NULL DEFAULT 0,
      usage_count INTEGER NOT NULL DEFAULT 0,
      is_favorite INTEGER NOT NULL DEFAULT 0,
      user_id TEXT
    )
    ''');

    await db.execute('''
    CREATE TABLE user_favorites (
      user_id TEXT NOT NULL,
      template_id TEXT NOT NULL,
      PRIMARY KEY (user_id, template_id)
    )
    ''');

    await db.execute('''
    CREATE TABLE user_greetings (
      id TEXT PRIMARY KEY,
      contact_id TEXT NOT NULL,
      template_id TEXT,
      template_text TEXT NOT NULL,
      method TEXT NOT NULL,
      sent_at_epoch INTEGER NOT NULL,
      FOREIGN KEY (contact_id) REFERENCES contacts (id) ON DELETE CASCADE,
      FOREIGN KEY (template_id) REFERENCES templates (id) ON DELETE SET NULL
    )
    ''');

    await _seedDefaultCategories(db);
    await _seedDefaultTemplates(db);
  }

  Future<void> _seedDefaultCategories(Database db) async {
    final defaults = ['Gia đình', 'Đồng nghiệp', 'Bạn bè', 'Chưa phân loại'];
    final batch = db.batch();
    for (int i = 0; i < defaults.length; i++) {
      batch.insert('categories', {
        'id': 'default_$i',
        'name': defaults[i],
        'is_default': 1,
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    await batch.commit(noResult: true);
  }

  Future<void> _seedDefaultTemplates(Database db) async {
    final templates = [
      // Trang trọng
      {'id': 'sys_1', 'text': 'Kính chúc anh/chị năm mới dồi dào sức khỏe, vạn sự như ý, công việc hanh thông và gia đạo bình an.', 'category': 'Trang trọng', 'is_system': 1, 'usage_count': 0},
      {'id': 'sys_2', 'text': 'Nhân dịp xuân về, chân thành gửi lời tri ân sâu sắc và kính chúc quý đối tác một năm an khang thịnh vượng.', 'category': 'Trang trọng', 'is_system': 1, 'usage_count': 0},
      {'id': 'sys_3', 'text': 'Năm cũ đi qua, năm mới đã đến, kính chúc Đại gia đình ta luôn hòa thuận, sum vầy và hạnh phúc viên mãn.', 'category': 'Trang trọng', 'is_system': 1, 'usage_count': 0},
      // Hài hước
      {'id': 'sys_4', 'text': 'Năm mới tiền vào như nước, tiền ra nhỏ giọt như cà phê phin. Không lo muộn phiền, chỉ lo đếm tiền!', 'category': 'Hài hước', 'is_system': 1, 'usage_count': 0},
      {'id': 'sys_5', 'text': 'Chúc mày năm mới vạn sự như ý, tỷ sự như mơ, làm việc như thơ, đời vui như nhạc!', 'category': 'Hài hước', 'is_system': 1, 'usage_count': 0},
      {'id': 'sys_6', 'text': 'Tết này vẫn giống Tết xưa. Vẫn đi xe số, vẫn chưa có bồ. Chúc bạn sớm thoát ế nha!', 'category': 'Hài hước', 'is_system': 1, 'usage_count': 0},
      {'id': 'sys_7', 'text': 'Năm mới chúc anh em dẻo dai bách chiến bách thắng, lương bổng nhảy múa, tinh thần sung mãn!', 'category': 'Hài hước', 'is_system': 1, 'usage_count': 0},
      // Chân thành
      {'id': 'sys_8', 'text': 'Mình chỉ mong năm mới mang đến cho bạn thật nhiều bình yên và sức khỏe để chinh phục mọi ước mơ.', 'category': 'Chân thành', 'is_system': 1, 'usage_count': 0},
      {'id': 'sys_9', 'text': 'Cảm ơn vì đã luôn ở bên cạnh nhau. Chúc chúng ta một năm tròn vẹn, rực rỡ và thành công nhé!', 'category': 'Chân thành', 'is_system': 1, 'usage_count': 0},
      {'id': 'sys_10', 'text': 'Xuân đã về, chúc tổ ấm của cậu luôn rộn vang tiếng cười, mãi hạnh phúc và ngập tràn tình yêu thương.', 'category': 'Chân thành', 'is_system': 1, 'usage_count': 0},
    ];

    final batch = db.batch();
    for (var template in templates) {
      batch.insert('templates', template, conflictAlgorithm: ConflictAlgorithm.ignore);
    }
    await batch.commit(noResult: true);
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
