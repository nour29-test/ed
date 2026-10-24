import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';

class StudentsTab extends StatelessWidget {
  const StudentsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final students = provider.filteredStudents;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 85),
      children: [
        // زر إضافة طالب جديد (مطابق لأسلوب 1.html dashed button)
        InkWell(
          onTap: () => _showAddStudentModal(context, provider),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E3A8A).withOpacity(0.2) : AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary,
                width: 1.2,
                style: BorderStyle.solid,
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_add_alt_1, color: AppColors.primary, size: 18),
                SizedBox(width: 8),
                Text(
                  '+ تسجيل طالب جديد في هذه المجموعة',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // شريط البحث السريع بالاسم
        TextField(
          onChanged: provider.setSearchQuery,
          decoration: InputDecoration(
            hintText: 'بحث عن طالب بالاسم...',
            prefixIcon: const Icon(Icons.search, size: 20),
            filled: true,
            fillColor: isDark ? AppColors.surfaceDark : Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
          ),
        ),

        const SizedBox(height: 14),

        // بطاقة قائمة الطلاب
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'الطلاب المسجلون (${students.length})',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                    ),
                    Text(
                      provider.selectedGroup?.name ?? '',
                      style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.borderLight),
                const SizedBox(height: 6),

                if (students.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: Center(
                      child: Text(
                        'لا يوجد طلاب مطابقين للبحث',
                        style: TextStyle(color: AppColors.textMutedLight),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: students.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                    itemBuilder: (context, index) {
                      final s = students[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: isDark
                                      ? AppColors.primaryDark.withOpacity(0.4)
                                      : AppColors.primaryLight,
                                  child: Text(
                                    s.name.isNotEmpty ? s.name[0] : '?',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      s.name,
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      'ولي الأمر: ${s.parentPhone}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppColors.red, size: 20),
                              onPressed: () => _confirmDelete(context, provider, s),
                              tooltip: 'حذف الطالب',
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showAddStudentModal(BuildContext context, AppProvider provider) {
    final nameCtrl = TextEditingController();
    final parentPhoneCtrl = TextEditingController();
    final studentPhoneCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'تسجيل طالب جديد',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'اسم الطالب رباعي',
                  hintText: 'مثال: يوسف محمد إبراهيم',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: parentPhoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'رقم هاتف ولي الأمر (WhatsApp)',
                  hintText: 'مثال: 01012345678',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: studentPhoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'رقم هاتف الطالب (اختياري)',
                  hintText: '01xxxxxxxxx',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () {
                        if (nameCtrl.text.trim().isEmpty || parentPhoneCtrl.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('يرجى ملء اسم الطالب ورقم ولي الأمر')),
                          );
                          return;
                        }
                        provider.addNewStudent(
                          name: nameCtrl.text.trim(),
                          parentPhone: parentPhoneCtrl.text.trim(),
                          studentPhone: studentPhoneCtrl.text.trim(),
                        );
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('تمت إضافة الطالب (${nameCtrl.text.trim()}) بنجاح')),
                        );
                      },
                      child: const Text('حفظ الطالب', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('إلغاء'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, AppProvider provider, StudentModel student) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف الطالب "${student.name}" من المجموعة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red, foregroundColor: Colors.white),
            onPressed: () {
              provider.removeStudent(student.id!);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('تم حذف الطالب "${student.name}"')),
              );
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
