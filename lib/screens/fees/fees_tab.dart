import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/app_provider.dart';

class FeesTab extends StatelessWidget {
  const FeesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final fees = provider.fees;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 85),
      children: [
        // 1. كارت Hero العلوي (مطابق تماماً لنموذج 1.html fee-hero)
        Container(
          padding: const EdgeInsets.all(18),
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'إجمالي المحصل لشهر ${provider.currentMonth}:',
                style: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                '${provider.totalFeesCollected.toStringAsFixed(0)} ج.م',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.green,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      'سُدد لـ ${provider.paidStudentsCount} من أصل ${fees.length} طلاب',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (provider.totalFeesPending > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.red.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        'متبقي: ${provider.totalFeesPending.toStringAsFixed(0)} ج.م',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),

        // 2. بطاقة سجل سداد الطلاب
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'كشف سداد الطلاب',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 10),
                Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.borderLight),
                const SizedBox(height: 4),

                if (fees.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 30),
                    child: Center(
                      child: Text(
                        'لا يوجد طلاب في هذه المجموعة لتسجيل المصروفات',
                        style: TextStyle(color: AppColors.textMutedLight),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: fees.length,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      color: isDark ? AppColors.borderDark : AppColors.borderLight,
                    ),
                    itemBuilder: (context, index) {
                      final item = fees[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.studentName,
                                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item.isPaid
                                      ? 'سُددت: ${item.paidDate ?? "نعم"}'
                                      : 'غير مسدد (متأخر)',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: item.isPaid ? AppColors.green : AppColors.red,
                                  ),
                                ),
                              ],
                            ),
                            // مفتاح التبديل Switch
                            Switch.adaptive(
                              value: item.isPaid,
                              activeColor: AppColors.green,
                              onChanged: (val) {
                                provider.toggleFeeStatus(item.id!, val);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      val
                                          ? 'تم إثبات سداد المصروفات للطالب (${item.studentName})'
                                          : 'تم إلغاء سداد المصروفات للطالب (${item.studentName})',
                                    ),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
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
}
