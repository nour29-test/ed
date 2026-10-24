import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/whatsapp_service.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';

class SessionTab extends StatelessWidget {
  const SessionTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final students = provider.sessionStudents;

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 85),
      children: [
        // 1. بطاقة إحصائيات الحصة (مطابقة لنموذج 1.html)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.light
                ? AppColors.primaryLight
                : const Color(0xFF1E3A8A).withOpacity(0.3),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Theme.of(context).brightness == Brightness.light
                  ? const Color(0xFFBFDBFE)
                  : const Color(0xFF1E40AF),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.people_alt, color: Color(0xFF1E3A8A), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'الحاضرين: ${provider.presentCount} من أصل ${students.length}',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'غائب: ${provider.absentCount}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),

        // 2. قائمة بطاقات الطلاب
        if (students.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text(
                'لا يوجد طلاب مسجلين في هذه المجموعة حتى الآن.\nيمكنك إضافة طلاب من تبويب "الطلاب".',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMutedLight),
              ),
            ),
          )
        else
          ...students.map((student) => _buildStudentSessionCard(context, provider, student)),
      ],
    );
  }

  Widget _buildStudentSessionCard(
    BuildContext context,
    AppProvider provider,
    SessionStudentData s,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // نمط الصورة الرمزية حسب الحضور
    Color avatarBg;
    Color avatarFg;
    IconData avatarIcon;
    switch (s.attendance) {
      case AttendanceStatus.present:
        avatarBg = AppColors.greenLight;
        avatarFg = AppColors.greenDark;
        avatarIcon = Icons.person;
        break;
      case AttendanceStatus.absent:
        avatarBg = AppColors.redLight;
        avatarFg = AppColors.redDark;
        avatarIcon = Icons.person_off;
        break;
      case AttendanceStatus.late:
        avatarBg = AppColors.amberLight;
        avatarFg = AppColors.amberDark;
        avatarIcon = Icons.access_time_filled;
        break;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // رأس بطاقة الطالب: الاسم، رقم الهاتف، وزر المراسلة الفورية عبر واتساب
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: avatarBg,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(avatarIcon, color: avatarFg, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.studentName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.textMainDark : AppColors.textMainLight,
                          ),
                        ),
                        Text(
                          s.parentPhone,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // زر إرسال إشعار فوري لولي الأمر
                InkWell(
                  onTap: () {
                    WhatsAppService.sendDirectNotice(
                      studentName: s.studentName,
                      phone: s.parentPhone,
                      teacherName: provider.teacherProfile.teacherName,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('تم فتح واتساب لإرسال إشعار متابعة للطالب (${s.studentName})'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F8EE),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFC3E6CB)),
                    ),
                    child: const Icon(Icons.chat_bubble_outline, color: AppColors.waGreen, size: 18),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.borderLight),
            const SizedBox(height: 10),

            // 1. أزرار الحضور والانصراف المجزأة (حاضر / غائب / متأخر)
            const Text(
              'الحضور والانصراف:',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 5),
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  _buildSegButton(
                    context: context,
                    title: 'حاضر',
                    isActive: s.attendance == AttendanceStatus.present,
                    activeColor: AppColors.green,
                    onTap: () => provider.setAttendance(s.studentId, AttendanceStatus.present),
                  ),
                  _buildSegButton(
                    context: context,
                    title: 'غائب',
                    isActive: s.attendance == AttendanceStatus.absent,
                    activeColor: AppColors.red,
                    onTap: () => provider.setAttendance(s.studentId, AttendanceStatus.absent),
                  ),
                  _buildSegButton(
                    context: context,
                    title: 'متأخر',
                    isActive: s.attendance == AttendanceStatus.late,
                    activeColor: AppColors.amber,
                    onTap: () => provider.setAttendance(s.studentId, AttendanceStatus.late),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // 2. الواجب المدرسي (شرائح تفاعلية)
            const Text(
              'الواجب المدرسي:',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                _buildHomeworkChip(
                  title: 'تم الحل',
                  isActive: s.homework == HomeworkStatus.done,
                  bgActive: AppColors.greenLight,
                  fgActive: AppColors.greenDark,
                  onTap: () => provider.setHomework(s.studentId, HomeworkStatus.done),
                ),
                const SizedBox(width: 6),
                _buildHomeworkChip(
                  title: 'حل جزئي',
                  isActive: s.homework == HomeworkStatus.partial,
                  bgActive: AppColors.amberLight,
                  fgActive: AppColors.amberDark,
                  onTap: () => provider.setHomework(s.studentId, HomeworkStatus.partial),
                ),
                const SizedBox(width: 6),
                _buildHomeworkChip(
                  title: 'لم يحل',
                  isActive: s.homework == HomeworkStatus.notDone,
                  bgActive: AppColors.redLight,
                  fgActive: AppColors.redDark,
                  onTap: () => provider.setHomework(s.studentId, HomeworkStatus.notDone),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // 3. شبكة الدرجات (تسميع، كويز/إملاء، امتحان شهري)
            const Text(
              'الدرجات والتقييمات:',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  child: _buildScoreControl(
                    label: 'تسميع (10)',
                    value: s.recitationScore,
                    onMinus: () => provider.modifyScore(s.studentId, 'recitation', -1),
                    onPlus: () => provider.modifyScore(s.studentId, 'recitation', 1),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildScoreControl(
                    label: 'إملاء / كويز (10)',
                    value: s.dictationScore,
                    onMinus: () => provider.modifyScore(s.studentId, 'dictation', -1),
                    onPlus: () => provider.modifyScore(s.studentId, 'dictation', 1),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _buildScoreControl(
                    label: 'امتحان شهري (50)',
                    value: s.examScore,
                    onMinus: () => provider.modifyScore(s.studentId, 'exam', -5),
                    onPlus: () => provider.modifyScore(s.studentId, 'exam', 5),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // 4. حقل ملاحظات الحصة
            TextFormField(
              initialValue: s.note,
              onChanged: (val) => provider.updateNote(s.studentId, val),
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                hintText: 'ملاحظات المعلم على الطالب في الحصة...',
                hintStyle: TextStyle(
                  fontSize: 11,
                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                fillColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSegButton({
    required BuildContext context,
    required String title,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isActive
                ? (isDark ? AppColors.surfaceDark : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    )
                  ]
                : null,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
              color: isActive
                  ? activeColor
                  : (isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeworkChip({
    required String title,
    required bool isActive,
    required Color bgActive,
    required Color fgActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? bgActive : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? fgActive.withOpacity(0.4) : AppColors.borderLight,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isActive ? fgActive : AppColors.textMutedLight,
          ),
        ),
      ),
    );
  }

  Widget _buildScoreControl({
    required String label,
    required int value,
    required VoidCallback onMinus,
    required VoidCallback onPlus,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textMutedLight,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: onMinus,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: const Center(
                    child: Text('-', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              Text(
                '$value',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textMainLight,
                ),
              ),
              GestureDetector(
                onTap: onPlus,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: const Center(
                    child: Text('+', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
