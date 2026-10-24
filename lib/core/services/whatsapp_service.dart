import 'package:url_launcher/url_launcher.dart';
import '../../models/models.dart';

class WhatsAppService {
  static String sanitizePhone(String phone) {
    String clean = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (clean.startsWith('01') && clean.length == 11) {
      // رقم مصري محلي -> إضافة مفتاح الدولة 2
      clean = '2$clean';
    }
    return clean;
  }

  static Future<bool> sendWhatsAppMessage({
    required String phone,
    required String message,
  }) async {
    final cleanPhone = sanitizePhone(phone);
    final encoded = Uri.encodeComponent(message);
    final url = Uri.parse('https://wa.me/$cleanPhone?text=$encoded');

    try {
      if (await canLaunchUrl(url)) {
        return await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        // Fallback
        return await launchUrl(url, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      return false;
    }
  }

  static Future<bool> sendDirectNotice({
    required String studentName,
    required String phone,
    required String teacherName,
  }) {
    final msg = '''
السلام عليكم ورحمة الله وبركاته
إشعار بمتابعة الطالب: ($studentName) في حصة اليوم.
نرجو متابعة كراسة الواجب وملاحظات الحصة مع الطالب.

تحياتي،
$teacherName
''';
    return sendWhatsAppMessage(phone: phone, message: msg.trim());
  }

  static String generateMonthlyReportText({
    required StudentModel student,
    required GroupModel group,
    required String month,
    required int totalSessions,
    required int presentCount,
    required int absentCount,
    required String homeworkRate,
    required int recitationScore,
    required int dictationScore,
    required int examScore,
    required bool isFeePaid,
    required String? feeDate,
    required String teacherName,
    required String notes,
  }) {
    final rating = (examScore >= 45 && presentCount >= 7)
        ? 'ممتاز (A+)'
        : (examScore >= 35 ? 'جيد جداً (B+)' : 'مقبول (C)');

    final feeStatus = isFeePaid
        ? 'تم السداد بتاريخ: ${feeDate ?? "أول الشهر"}'
        : 'غير مسدد (متأخر)';

    return '''
📊 *التقرير الشهري للطالب: ${student.name}*
🗓 عن شهر: $month
👥 المجموعة: ${group.name}
-----------------------------------
📌 *سجل الحضور والالتزام:*
• عدد الحصص المنعقدة: $totalSessions حصص
• الحضور: $presentCount | الغياب: $absentCount
• الالتزام بالواجبات: $homeworkRate

📝 *متوسط الدرجات:*
• التسميع: $recitationScore / 10
• الإملاء/الكويز: $dictationScore / 10
• الامتحان الشهري: $examScore / 50

💰 *المصروفات الشهرية:*
• الحالة: $feeStatus

🌟 *التقييم التراكمي:* $rating
💬 *ملاحظات المعلم:* ${notes.isNotEmpty ? notes : (student.notes.isNotEmpty ? student.notes : "طالب مجتهد ونتمنى له مزيداً من التفوق")}
-----------------------------------
إدارة: $teacherName
'''.trim();
  }
}
