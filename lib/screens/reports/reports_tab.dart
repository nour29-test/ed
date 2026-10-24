import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/whatsapp_service.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';

class ReportsTab extends StatefulWidget {
  const ReportsTab({super.key});

  @override
  State<ReportsTab> createState() => _ReportsTabState();
}

class _ReportsTabState extends State<ReportsTab> {
  int? _selectedStudentId;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final students = provider.groupStudents;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (students.isEmpty) {
      return const Center(
        child: Text(
          'لا يوجد طلاب في هذه المجموعة لتوليد تقارير لهم.',
          style: TextStyle(color: AppColors.textMutedLight),
        ),
      );
    }

    // إذا لم يتم تحديد طالب، نحدد الأول تلقائياً
    _selectedStudentId ??= students.first.id;
    final currentStudent = students.firstWhere(
      (s) => s.id == _selectedStudentId,
      orElse: () => students.first,
    );

    // استخراج بيانات الحصة والمصروفات الخاصة بالطالب
    final sessStudent = provider.sessionStudents.firstWhere(
      (s) => s.studentId == currentStudent.id,
      orElse: () => SessionStudentData(
        studentId: currentStudent.id!,
        studentName: currentStudent.name,
        parentPhone: currentStudent.parentPhone,
      ),
    );

    final feeItem = provider.fees.firstWhere(
      (f) => f.studentId == currentStudent.id,
      orElse: () => FeeItemModel(
        studentId: currentStudent.id!,
        studentName: currentStudent.name,
        parentPhone: currentStudent.parentPhone,
        month: provider.currentMonth,
        amount: provider.selectedGroup?.defaultFee ?? 250.0,
        isPaid: false,
      ),
    );

    final reportText = WhatsAppService.generateMonthlyReportText(
      student: currentStudent,
      group: provider.selectedGroup!,
      month: provider.currentMonth,
      totalSessions: 8,
      presentCount: sessStudent.attendance == AttendanceStatus.absent ? 6 : 8,
      absentCount: sessStudent.attendance == AttendanceStatus.absent ? 2 : 0,
      homeworkRate: sessStudent.homework == HomeworkStatus.done
          ? '100% ممتاز'
          : (sessStudent.homework == HomeworkStatus.partial ? '75% متوسط' : 'مقصر (لم يحل)'),
      recitationScore: sessStudent.recitationScore,
      dictationScore: sessStudent.dictationScore,
      examScore: sessStudent.examScore,
      isFeePaid: feeItem.isPaid,
      feeDate: feeItem.paidDate,
      teacherName: provider.teacherProfile.teacherName,
      notes: sessStudent.note,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 85),
      children: [
        // قائمة اختيار الطالب
        const Text(
          'اختيار الطالب للتقرير:',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              isExpanded: true,
              value: currentStudent.id,
              items: students.map((s) {
                return DropdownMenuItem<int>(
                  value: s.id,
                  child: Text(
                    s.name,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedStudentId = val);
                }
              },
            ),
          ),
        ),

        const SizedBox(height: 14),

        // فقاعة معاينة تقرير الواتساب (مطابقة لنموذج 1.html whatsapp-bubble)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF132E1B) : AppColors.waGreenBubble,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? const Color(0xFF166534) : AppColors.waGreenBubbleBorder,
            ),
          ),
          child: SelectableText(
            reportText,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.6,
              color: isDark ? const Color(0xFFDCFCE7) : const Color(0xFF1E293B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        const SizedBox(height: 14),

        // زر إرسال التقرير لولي الأمر عبر واتساب
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.waGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
          ),
          onPressed: () async {
            final ok = await WhatsAppService.sendWhatsAppMessage(
              phone: currentStudent.parentPhone,
              message: reportText,
            );
            if (!ok && context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تعذر فتح تطبيق WhatsApp، يرجى التأكد من تثبيته')),
              );
            }
          },
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.send_rounded, size: 20),
              SizedBox(width: 8),
              Text(
                'إرسال التقرير لولي الأمر عبر واتساب',
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
