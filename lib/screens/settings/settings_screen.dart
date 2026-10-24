import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/models.dart';
import '../../providers/app_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _subjectCtrl;
  late TextEditingController _phoneCtrl;

  @override
  void initState() {
    super.initState();
    final p = context.read<AppProvider>().teacherProfile;
    _nameCtrl = TextEditingController(text: p.teacherName);
    _subjectCtrl = TextEditingController(text: p.subject);
    _phoneCtrl = TextEditingController(text: p.phone);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _subjectCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات والنسخ الاحتياطي'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. قسم بيانات المعلم
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.badge_outlined, color: AppColors.primary, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'الملف التعريفي للمعلم',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'تظهر هذه البيانات كتوقيع رسمي في جميع تقارير ورسائل الواتساب المرسلة لأولياء الأمور.',
                    style: TextStyle(fontSize: 11, color: AppColors.textMutedLight),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'اسم المعلم / اللقب',
                      hintText: 'مثال: مستر أحمد الصاوي',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _subjectCtrl,
                    decoration: const InputDecoration(
                      labelText: 'المادة الدراسية',
                      hintText: 'مثال: اللغة العربية',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'رقم هاتف المعلم',
                      hintText: '01xxxxxxxxx',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(45),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      provider.updateTeacherProfile(
                        TeacherProfileModel(
                          teacherName: _nameCtrl.text.trim(),
                          subject: _subjectCtrl.text.trim(),
                          phone: _phoneCtrl.text.trim(),
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم حفظ بيانات المعلم بنجاح')),
                      );
                    },
                    child: const Text('حفظ التعديلات', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 2. المظهر (الوضع الليلي)
          Card(
            child: ListTile(
              leading: Icon(
                provider.themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
                color: AppColors.primary,
              ),
              title: const Text('المظهر الداكن (Dark Mode)', style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(
                provider.themeMode == ThemeMode.dark ? 'مفعل' : 'معطل (الوضع الفاتح)',
                style: const TextStyle(fontSize: 11),
              ),
              trailing: Switch.adaptive(
                value: provider.themeMode == ThemeMode.dark,
                activeColor: AppColors.primary,
                onChanged: (_) => provider.toggleTheme(),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 3. النسخ الاحتياطي والاستعادة
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.backup_outlined, color: AppColors.primary, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'النسخ الاحتياطي ونقل البيانات',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'لحماية بيانات الطلاب والدرجات وسجلات الحضور ونقلها بسهولة لأي هاتف آخر.',
                    style: TextStyle(fontSize: 11, color: AppColors.textMutedLight),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.file_download_outlined),
                          label: const Text('نسخ البيانات (Export)'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () async {
                            final jsonStr = await provider.exportBackup();
                            await Clipboard.setData(ClipboardData(text: jsonStr));
                            if (context.mounted) {
                              showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('تم تصدير النسخة الاحتياطية'),
                                  content: const Text(
                                    'تم نسخ كود البيانات الاحتياطي بالكامل إلى الحافظة (Clipboard).\nيمكنك لصقه وحفظه في ملف أو إرساله لنفسك على واتساب.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: const Text('حسناً'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.file_upload_outlined),
                          label: const Text('استعادة (Restore)'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => _showRestoreDialog(context, provider),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog(BuildContext context, AppProvider provider) {
    final inputCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('استعادة نسخة احتياطية'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'الصق كود النسخة الاحتياطية JSON في الحقل التالي:',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: inputCtrl,
              maxLines: 6,
              style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
              decoration: const InputDecoration(
                hintText: '{"version": 1, ...}',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red, foregroundColor: Colors.white),
            onPressed: () async {
              final text = inputCtrl.text.trim();
              if (text.isEmpty) return;
              try {
                await provider.importBackup(text);
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تمت استعادة البيانات بنجاح!')),
                  );
                }
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text('فشل في استعادة البيانات: $e')),
                  );
                }
              }
            },
            child: const Text('استعادة الآن'),
          ),
        ],
      ),
    );
  }
}
