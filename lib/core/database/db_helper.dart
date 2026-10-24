import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import '../../models/models.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('app_edu_v1.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. المراحل الدراسية
    await db.execute('''
      CREATE TABLE stages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    // 2. المجموعات
    await db.execute('''
      CREATE TABLE groups_table (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        stage_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        schedule TEXT NOT NULL,
        default_fee REAL NOT NULL DEFAULT 250.0,
        FOREIGN KEY (stage_id) REFERENCES stages (id) ON DELETE CASCADE
      )
    ''');

    // 3. الطلاب
    await db.execute('''
      CREATE TABLE students (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        group_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        parent_phone TEXT NOT NULL,
        student_phone TEXT,
        notes TEXT,
        FOREIGN KEY (group_id) REFERENCES groups_table (id) ON DELETE CASCADE
      )
    ''');

    // 4. الحصص
    await db.execute('''
      CREATE TABLE sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        group_id INTEGER NOT NULL,
        session_date TEXT NOT NULL,
        title TEXT,
        FOREIGN KEY (group_id) REFERENCES groups_table (id) ON DELETE CASCADE
      )
    ''');

    // 5. سجل الحضور والواجب والدرجات للحصة
    await db.execute('''
      CREATE TABLE session_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_id INTEGER NOT NULL,
        student_id INTEGER NOT NULL,
        attendance TEXT NOT NULL,
        homework TEXT NOT NULL,
        recitation_score INTEGER NOT NULL DEFAULT 10,
        dictation_score INTEGER NOT NULL DEFAULT 10,
        exam_score INTEGER NOT NULL DEFAULT 50,
        note TEXT,
        FOREIGN KEY (session_id) REFERENCES sessions (id) ON DELETE CASCADE,
        FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE CASCADE
      )
    ''');

    // 6. المصروفات الشهرية
    await db.execute('''
      CREATE TABLE monthly_fees (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        student_id INTEGER NOT NULL,
        month TEXT NOT NULL,
        amount REAL NOT NULL,
        is_paid INTEGER NOT NULL DEFAULT 0,
        paid_date TEXT,
        FOREIGN KEY (student_id) REFERENCES students (id) ON DELETE CASCADE
      )
    ''');

    // 7. إعدادات المعلم والقوالب
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    // بيانات أولية تجريبية مطابقة لنموذج 1.html
    await _seedDemoData(db);
  }

  Future<void> _seedDemoData(Database db) async {
    // إعدادات المعلم الافتراضية
    await db.insert('settings', {'key': 'teacher_name', 'value': 'مستر أحمد الصاوي'});
    await db.insert('settings', {'key': 'subject', 'value': 'اللغة العربية والتربية الإسلامية'});
    await db.insert('settings', {'key': 'phone', 'value': '201012345678'});

    // مرحلة إعدادية وثانوية
    final stage1Id = await db.insert('stages', {'name': 'المرحلة الإعدادية'});
    final stage2Id = await db.insert('stages', {'name': 'المرحلة الثانوية'});

    // المجموعات
    final g1Id = await db.insert('groups_table', {
      'stage_id': stage1Id,
      'name': '3 إعدادي (السبت والثلاثاء 4م)',
      'schedule': 'السبت والثلاثاء - 4:00 عصراً',
      'default_fee': 250.0,
    });
    await db.insert('groups_table', {
      'stage_id': stage2Id,
      'name': '1 ثانوي (الأحد والأربعاء 6م)',
      'schedule': 'الأحد والأربعاء - 6:00 مساءً',
      'default_fee': 300.0,
    });

    // الطلاب (كما في 1.html)
    final s1 = await db.insert('students', {
      'group_id': g1Id,
      'name': 'أحمد محمود العوضي',
      'parent_phone': '01012345678',
      'student_phone': '01011111111',
      'notes': 'متفوق ونشيط جداً ويستحق التشجيع.',
    });
    final s2 = await db.insert('students', {
      'group_id': g1Id,
      'name': 'عمر خالد المنشاوي',
      'parent_phone': '01123456789',
      'student_phone': '01122222222',
      'notes': 'يحتاج لمتابعة مستمرة في حل الواجب.',
    });
    final s3 = await db.insert('students', {
      'group_id': g1Id,
      'name': 'سارة إبراهيم حسن',
      'parent_phone': '01234567890',
      'student_phone': '01233333333',
      'notes': 'ممتازة في التسميع الشفهي.',
    });

    // إنشاء حصة اليوم الافتراضية
    final sessId = await db.insert('sessions', {
      'group_id': g1Id,
      'session_date': DateTime.now().toIso8601String().substring(0, 10),
      'title': 'حصة اليوم',
    });

    // سجل حضور الحصة
    await db.insert('session_records', {
      'session_id': sessId,
      'student_id': s1,
      'attendance': 'present',
      'homework': 'done',
      'recitation_score': 9,
      'dictation_score': 10,
      'exam_score': 49,
      'note': 'ممتاز ومشارك بإيجابية',
    });

    await db.insert('session_records', {
      'session_id': sessId,
      'student_id': s2,
      'attendance': 'absent',
      'homework': 'notDone',
      'recitation_score': 5,
      'dictation_score': 6,
      'exam_score': 35,
      'note': 'غائب اليوم',
    });

    await db.insert('session_records', {
      'session_id': sessId,
      'student_id': s3,
      'attendance': 'present',
      'homework': 'done',
      'recitation_score': 10,
      'dictation_score': 10,
      'exam_score': 50,
      'note': 'أداء رائع ومتميز',
    });

    // سجل المصروفات لشهر أكتوبر 2026
    await db.insert('monthly_fees', {
      'student_id': s1,
      'month': 'أكتوبر 2026',
      'amount': 250.0,
      'is_paid': 1,
      'paid_date': '01-10-2026',
    });
    await db.insert('monthly_fees', {
      'student_id': s2,
      'month': 'أكتوبر 2026',
      'amount': 250.0,
      'is_paid': 0,
      'paid_date': null,
    });
    await db.insert('monthly_fees', {
      'student_id': s3,
      'month': 'أكتوبر 2026',
      'amount': 250.0,
      'is_paid': 1,
      'paid_date': '02-10-2026',
    });
  }

  // عمليات الاستعلام (Queries)
  Future<List<GroupModel>> getAllGroups() async {
    final db = await database;
    final res = await db.query('groups_table');
    return res.map((e) => GroupModel.fromMap(e)).toList();
  }

  Future<int> addGroup(GroupModel group) async {
    final db = await database;
    return await db.insert('groups_table', group.toMap());
  }

  Future<List<StudentModel>> getStudentsByGroup(int groupId) async {
    final db = await database;
    final res = await db.query(
      'students',
      where: 'group_id = ?',
      whereArgs: [groupId],
      orderBy: 'name ASC',
    );
    return res.map((e) => StudentModel.fromMap(e)).toList();
  }

  Future<int> addStudent(StudentModel student) async {
    final db = await database;
    return await db.insert('students', student.toMap());
  }

  Future<int> deleteStudent(int studentId) async {
    final db = await database;
    return await db.delete('students', where: 'id = ?', whereArgs: [studentId]);
  }

  Future<int> getOrCreateTodaySession(int groupId) async {
    final db = await database;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final existing = await db.query(
      'sessions',
      where: 'group_id = ? AND session_date = ?',
      whereArgs: [groupId, today],
    );

    int sessId;
    if (existing.isNotEmpty) {
      sessId = existing.first['id'] as int;
    } else {
      sessId = await db.insert('sessions', {
        'group_id': groupId,
        'session_date': today,
        'title': 'حصة $today',
      });
    }

    // التأكد من وجود سجلات للطلاب المسجلين في المجموعة
    final students = await getStudentsByGroup(groupId);
    for (var s in students) {
      final rec = await db.query(
        'session_records',
        where: 'session_id = ? AND student_id = ?',
        whereArgs: [sessId, s.id],
      );
      if (rec.isEmpty) {
        await db.insert('session_records', {
          'session_id': sessId,
          'student_id': s.id,
          'attendance': 'present',
          'homework': 'done',
          'recitation_score': 10,
          'dictation_score': 10,
          'exam_score': 50,
          'note': '',
        });
      }
    }
    return sessId;
  }

  Future<List<SessionStudentData>> getSessionData(int sessionId) async {
    final db = await database;
    final sql = '''
      SELECT sr.*, s.name as student_name, s.parent_phone
      FROM session_records sr
      JOIN students s ON sr.student_id = s.id
      WHERE sr.session_id = ?
      ORDER BY s.name ASC
    ''';
    final rows = await db.rawQuery(sql, [sessionId]);
    return rows.map((r) => SessionStudentData.fromMap(
      r,
      r['student_name'] as String,
      r['parent_phone'] as String,
    )).toList();
  }

  Future<void> updateSessionStudent(int sessionId, SessionStudentData data) async {
    final db = await database;
    await db.update(
      'session_records',
      data.toMap(sessionId),
      where: 'session_id = ? AND student_id = ?',
      whereArgs: [sessionId, data.studentId],
    );
  }

  Future<List<FeeItemModel>> getFeesForGroup(int groupId, String month) async {
    final db = await database;
    final students = await getStudentsByGroup(groupId);
    final group = (await getAllGroups()).firstWhere((g) => g.id == groupId);

    for (var s in students) {
      final existing = await db.query(
        'monthly_fees',
        where: 'student_id = ? AND month = ?',
        whereArgs: [s.id, month],
      );
      if (existing.isEmpty) {
        await db.insert('monthly_fees', {
          'student_id': s.id,
          'month': month,
          'amount': group.defaultFee,
          'is_paid': 0,
          'paid_date': null,
        });
      }
    }

    final sql = '''
      SELECT mf.*, s.name as student_name, s.parent_phone
      FROM monthly_fees mf
      JOIN students s ON mf.student_id = s.id
      WHERE s.group_id = ? AND mf.month = ?
      ORDER BY s.name ASC
    ''';
    final rows = await db.rawQuery(sql, [groupId, month]);
    return rows.map((r) => FeeItemModel.fromMap(
      r,
      r['student_name'] as String,
      r['parent_phone'] as String,
    )).toList();
  }

  Future<void> updateFeeStatus(int feeId, bool isPaid, String? paidDate) async {
    final db = await database;
    await db.update(
      'monthly_fees',
      {
        'is_paid': isPaid ? 1 : 0,
        'paid_date': isPaid ? (paidDate ?? 'اليوم') : null,
      },
      where: 'id = ?',
      whereArgs: [feeId],
    );
  }

  Future<TeacherProfileModel> getTeacherProfile() async {
    final db = await database;
    final rows = await db.query('settings');
    final map = <String, dynamic>{};
    for (var r in rows) {
      map[r['key'] as String] = r['value'];
    }
    return TeacherProfileModel.fromMap(map);
  }

  Future<void> saveTeacherProfile(TeacherProfileModel profile) async {
    final db = await database;
    await db.insert('settings', {'key': 'teacher_name', 'value': profile.teacherName},
        conflictAlgorithm: ConflictAlgorithm.replace);
    await db.insert('settings', {'key': 'subject', 'value': profile.subject},
        conflictAlgorithm: ConflictAlgorithm.replace);
    await db.insert('settings', {'key': 'phone', 'value': profile.phone},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Backup & Restore
  Future<String> exportDatabaseJson() async {
    final db = await database;
    final stages = await db.query('stages');
    final groups = await db.query('groups_table');
    final students = await db.query('students');
    final sessions = await db.query('sessions');
    final sessionRecords = await db.query('session_records');
    final monthlyFees = await db.query('monthly_fees');
    final settings = await db.query('settings');

    final exportData = {
      'version': 1,
      'exported_at': DateTime.now().toIso8601String(),
      'stages': stages,
      'groups_table': groups,
      'students': students,
      'sessions': sessions,
      'session_records': sessionRecords,
      'monthly_fees': monthlyFees,
      'settings': settings,
    };

    return const JsonEncoder.withIndent('  ').convert(exportData);
  }

  Future<void> importDatabaseJson(String jsonStr) async {
    final db = await database;
    final Map<String, dynamic> data = jsonDecode(jsonStr);

    await db.transaction((txn) async {
      await txn.delete('session_records');
      await txn.delete('sessions');
      await txn.delete('monthly_fees');
      await txn.delete('students');
      await txn.delete('groups_table');
      await txn.delete('stages');
      await txn.delete('settings');

      for (var row in (data['stages'] as List? ?? [])) {
        await txn.insert('stages', Map<String, dynamic>.from(row));
      }
      for (var row in (data['groups_table'] as List? ?? [])) {
        await txn.insert('groups_table', Map<String, dynamic>.from(row));
      }
      for (var row in (data['students'] as List? ?? [])) {
        await txn.insert('students', Map<String, dynamic>.from(row));
      }
      for (var row in (data['sessions'] as List? ?? [])) {
        await txn.insert('sessions', Map<String, dynamic>.from(row));
      }
      for (var row in (data['session_records'] as List? ?? [])) {
        await txn.insert('session_records', Map<String, dynamic>.from(row));
      }
      for (var row in (data['monthly_fees'] as List? ?? [])) {
        await txn.insert('monthly_fees', Map<String, dynamic>.from(row));
      }
      for (var row in (data['settings'] as List? ?? [])) {
        await txn.insert('settings', Map<String, dynamic>.from(row));
      }
    });
  }
}
