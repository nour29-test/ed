class StageModel {
  final int? id;
  final String name;

  StageModel({this.id, required this.name});

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
  };

  factory StageModel.fromMap(Map<String, dynamic> map) => StageModel(
    id: map['id'] as int?,
    name: map['name'] as String,
  );
}

class GroupModel {
  final int? id;
  final int stageId;
  final String name; // مثال: 3 إعدادي (السبت والثلاثاء 4م)
  final String schedule; // السبت والثلاثاء 4م
  final double defaultFee;

  GroupModel({
    this.id,
    required this.stageId,
    required this.name,
    required this.schedule,
    this.defaultFee = 250.0,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'stage_id': stageId,
    'name': name,
    'schedule': schedule,
    'default_fee': defaultFee,
  };

  factory GroupModel.fromMap(Map<String, dynamic> map) => GroupModel(
    id: map['id'] as int?,
    stageId: map['stage_id'] as int,
    name: map['name'] as String,
    schedule: map['schedule'] as String,
    defaultFee: (map['default_fee'] as num).toDouble(),
  );
}

class StudentModel {
  final int? id;
  final int groupId;
  final String name;
  final String parentPhone;
  final String studentPhone;
  final String notes;

  StudentModel({
    this.id,
    required this.groupId,
    required this.name,
    required this.parentPhone,
    this.studentPhone = '',
    this.notes = '',
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'group_id': groupId,
    'name': name,
    'parent_phone': parentPhone,
    'student_phone': studentPhone,
    'notes': notes,
  };

  factory StudentModel.fromMap(Map<String, dynamic> map) => StudentModel(
    id: map['id'] as int?,
    groupId: map['group_id'] as int,
    name: map['name'] as String,
    parentPhone: map['parent_phone'] as String,
    studentPhone: map['student_phone'] as String? ?? '',
    notes: map['notes'] as String? ?? '',
  );

  StudentModel copyWith({
    int? id,
    int? groupId,
    String? name,
    String? parentPhone,
    String? studentPhone,
    String? notes,
  }) {
    return StudentModel(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      name: name ?? this.name,
      parentPhone: parentPhone ?? this.parentPhone,
      studentPhone: studentPhone ?? this.studentPhone,
      notes: notes ?? this.notes,
    );
  }
}

enum AttendanceStatus { present, absent, late }
enum HomeworkStatus { done, partial, notDone }

class SessionStudentData {
  final int studentId;
  final String studentName;
  final String parentPhone;
  AttendanceStatus attendance;
  HomeworkStatus homework;
  int recitationScore; // تسميع
  int dictationScore;  // إملاء/كويز
  int examScore;       // امتحان شهري
  String note;

  SessionStudentData({
    required this.studentId,
    required this.studentName,
    required this.parentPhone,
    this.attendance = AttendanceStatus.present,
    this.homework = HomeworkStatus.done,
    this.recitationScore = 10,
    this.dictationScore = 10,
    this.examScore = 50,
    this.note = '',
  });

  Map<String, dynamic> toMap(int sessionId) => {
    'session_id': sessionId,
    'student_id': studentId,
    'attendance': attendance.name,
    'homework': homework.name,
    'recitation_score': recitationScore,
    'dictation_score': dictationScore,
    'exam_score': examScore,
    'note': note,
  };

  factory SessionStudentData.fromMap(Map<String, dynamic> map, String name, String phone) => SessionStudentData(
    studentId: map['student_id'] as int,
    studentName: name,
    parentPhone: phone,
    attendance: AttendanceStatus.values.firstWhere(
      (e) => e.name == map['attendance'],
      orElse: () => AttendanceStatus.present,
    ),
    homework: HomeworkStatus.values.firstWhere(
      (e) => e.name == map['homework'],
      orElse: () => HomeworkStatus.done,
    ),
    recitationScore: map['recitation_score'] as int? ?? 10,
    dictationScore: map['dictation_score'] as int? ?? 10,
    examScore: map['exam_score'] as int? ?? 50,
    note: map['note'] as String? ?? '',
  );
}

class FeeItemModel {
  final int? id;
  final int studentId;
  final String studentName;
  final String parentPhone;
  final String month; // مثال: "أكتوبر 2026"
  final double amount;
  final bool isPaid;
  final String? paidDate;

  FeeItemModel({
    this.id,
    required this.studentId,
    required this.studentName,
    required this.parentPhone,
    required this.month,
    required this.amount,
    required this.isPaid,
    this.paidDate,
  });

  FeeItemModel copyWith({
    int? id,
    int? studentId,
    String? studentName,
    String? parentPhone,
    String? month,
    double? amount,
    bool? isPaid,
    String? paidDate,
  }) {
    return FeeItemModel(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      parentPhone: parentPhone ?? this.parentPhone,
      month: month ?? this.month,
      amount: amount ?? this.amount,
      isPaid: isPaid ?? this.isPaid,
      paidDate: paidDate ?? this.paidDate,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'student_id': studentId,
    'month': month,
    'amount': amount,
    'is_paid': isPaid ? 1 : 0,
    'paid_date': paidDate,
  };

  factory FeeItemModel.fromMap(Map<String, dynamic> map, String name, String phone) => FeeItemModel(
    id: map['id'] as int?,
    studentId: map['student_id'] as int,
    studentName: name,
    parentPhone: phone,
    month: map['month'] as String,
    amount: (map['amount'] as num).toDouble(),
    isPaid: (map['is_paid'] as int) == 1,
    paidDate: map['paid_date'] as String?,
  );
}

class TeacherProfileModel {
  final String teacherName;
  final String subject;
  final String phone;

  TeacherProfileModel({
    required this.teacherName,
    required this.subject,
    required this.phone,
  });

  Map<String, dynamic> toMap() => {
    'teacher_name': teacherName,
    'subject': subject,
    'phone': phone,
  };

  factory TeacherProfileModel.fromMap(Map<String, dynamic> map) => TeacherProfileModel(
    teacherName: map['teacher_name'] as String? ?? 'مستر أحمد الصاوي',
    subject: map['subject'] as String? ?? 'اللغة العربية والتربية الإسلامية',
    phone: map['phone'] as String? ?? '201012345678',
  );
}
