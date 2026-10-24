import 'package:flutter/material.dart';
import '../core/database/db_helper.dart';
import '../models/models.dart';

class AppProvider extends ChangeNotifier {
  final DBHelper _db = DBHelper.instance;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  List<GroupModel> _groups = [];
  List<GroupModel> get groups => _groups;

  GroupModel? _selectedGroup;
  GroupModel? get selectedGroup => _selectedGroup;

  int? _currentSessionId;
  int? get currentSessionId => _currentSessionId;

  List<SessionStudentData> _sessionStudents = [];
  List<SessionStudentData> get sessionStudents => _sessionStudents;

  List<StudentModel> _groupStudents = [];
  List<StudentModel> get groupStudents => _groupStudents;

  List<FeeItemModel> _fees = [];
  List<FeeItemModel> get fees => _fees;

  String _currentMonth = 'أكتوبر 2026';
  String get currentMonth => _currentMonth;

  TeacherProfileModel _teacherProfile = TeacherProfileModel(
    teacherName: 'مستر أحمد الصاوي',
    subject: 'اللغة العربية والتربية الإسلامية',
    phone: '201012345678',
  );
  TeacherProfileModel get teacherProfile => _teacherProfile;

  String _studentSearchQuery = '';
  String get studentSearchQuery => _studentSearchQuery;

  AppProvider() {
    init();
  }

  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    await loadTeacherProfile();
    await loadGroups();

    _isLoading = false;
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode = (_themeMode == ThemeMode.light) ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> loadTeacherProfile() async {
    _teacherProfile = await _db.getTeacherProfile();
    notifyListeners();
  }

  Future<void> updateTeacherProfile(TeacherProfileModel profile) async {
    _teacherProfile = profile;
    await _db.saveTeacherProfile(profile);
    notifyListeners();
  }

  Future<void> loadGroups() async {
    _groups = await _db.getAllGroups();
    if (_groups.isNotEmpty) {
      if (_selectedGroup == null || !_groups.any((g) => g.id == _selectedGroup!.id)) {
        _selectedGroup = _groups.first;
      }
      await loadGroupData(_selectedGroup!.id!);
    }
    notifyListeners();
  }

  Future<void> selectGroup(GroupModel group) async {
    _selectedGroup = group;
    notifyListeners();
    await loadGroupData(group.id!);
  }

  Future<void> loadGroupData(int groupId) async {
    // 1. تحميل قائمة الطلاب
    _groupStudents = await _db.getStudentsByGroup(groupId);

    // 2. تحميل أو إنشاء حصة اليوم
    _currentSessionId = await _db.getOrCreateTodaySession(groupId);
    _sessionStudents = await _db.getSessionData(_currentSessionId!);

    // 3. تحميل المصروفات
    _fees = await _db.getFeesForGroup(groupId, _currentMonth);

    notifyListeners();
  }

  // --- دوال الحصة اليومية (Session) ---
  int get presentCount => _sessionStudents.where((s) => s.attendance == AttendanceStatus.present).length;
  int get absentCount => _sessionStudents.where((s) => s.attendance == AttendanceStatus.absent).length;
  int get lateCount => _sessionStudents.where((s) => s.attendance == AttendanceStatus.late).length;

  Future<void> setAttendance(int studentId, AttendanceStatus status) async {
    final idx = _sessionStudents.indexWhere((s) => s.studentId == studentId);
    if (idx != -1) {
      _sessionStudents[idx].attendance = status;
      notifyListeners();
      if (_currentSessionId != null) {
        await _db.updateSessionStudent(_currentSessionId!, _sessionStudents[idx]);
      }
    }
  }

  Future<void> setHomework(int studentId, HomeworkStatus status) async {
    final idx = _sessionStudents.indexWhere((s) => s.studentId == studentId);
    if (idx != -1) {
      _sessionStudents[idx].homework = status;
      notifyListeners();
      if (_currentSessionId != null) {
        await _db.updateSessionStudent(_currentSessionId!, _sessionStudents[idx]);
      }
    }
  }

  Future<void> modifyScore(int studentId, String scoreType, int delta) async {
    final idx = _sessionStudents.indexWhere((s) => s.studentId == studentId);
    if (idx != -1) {
      final s = _sessionStudents[idx];
      if (scoreType == 'recitation') {
        s.recitationScore = (s.recitationScore + delta).clamp(0, 10);
      } else if (scoreType == 'dictation') {
        s.dictationScore = (s.dictationScore + delta).clamp(0, 10);
      } else if (scoreType == 'exam') {
        s.examScore = (s.examScore + delta).clamp(0, 50);
      }
      notifyListeners();
      if (_currentSessionId != null) {
        await _db.updateSessionStudent(_currentSessionId!, s);
      }
    }
  }

  Future<void> updateNote(int studentId, String note) async {
    final idx = _sessionStudents.indexWhere((s) => s.studentId == studentId);
    if (idx != -1) {
      _sessionStudents[idx].note = note;
      if (_currentSessionId != null) {
        await _db.updateSessionStudent(_currentSessionId!, _sessionStudents[idx]);
      }
    }
  }

  // --- دوال المصروفات (Fees) ---
  double get totalFeesCollected => _fees.where((f) => f.isPaid).fold(0.0, (sum, f) => sum + f.amount);
  double get totalFeesPending => _fees.where((f) => !f.isPaid).fold(0.0, (sum, f) => sum + f.amount);
  int get paidStudentsCount => _fees.where((f) => f.isPaid).length;
  int get unpaidStudentsCount => _fees.where((f) => !f.isPaid).length;

  Future<void> toggleFeeStatus(int feeId, bool isPaid) async {
    final idx = _fees.indexWhere((f) => f.id == feeId);
    if (idx != -1) {
      final todayStr = isPaid ? 'اليوم (${DateTime.now().day}-${DateTime.now().month})' : null;
      _fees[idx] = _fees[idx].copyWith(
        isPaid: isPaid,
        paidDate: todayStr,
      );
      notifyListeners();
      await _db.updateFeeStatus(feeId, isPaid, todayStr);
    }
  }

  // --- دوال الطلاب (Students) ---
  void setSearchQuery(String q) {
    _studentSearchQuery = q;
    notifyListeners();
  }

  List<StudentModel> get filteredStudents {
    if (_studentSearchQuery.trim().isEmpty) return _groupStudents;
    return _groupStudents.where((s) => s.name.contains(_studentSearchQuery.trim())).toList();
  }

  Future<void> addNewStudent({
    required String name,
    required String parentPhone,
    String studentPhone = '',
    String notes = '',
  }) async {
    if (_selectedGroup == null) return;
    final newStudent = StudentModel(
      groupId: _selectedGroup!.id!,
      name: name,
      parentPhone: parentPhone,
      studentPhone: studentPhone,
      notes: notes,
    );
    await _db.addStudent(newStudent);
    await loadGroupData(_selectedGroup!.id!);
  }

  Future<void> removeStudent(int studentId) async {
    await _db.deleteStudent(studentId);
    if (_selectedGroup != null) {
      await loadGroupData(_selectedGroup!.id!);
    }
  }

  // --- النسخ الاحتياطي (Backup) ---
  Future<String> exportBackup() async {
    return await _db.exportDatabaseJson();
  }

  Future<void> importBackup(String jsonStr) async {
    await _db.importDatabaseJson(jsonStr);
    await init();
  }
}
