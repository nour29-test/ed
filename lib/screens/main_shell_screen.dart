import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../models/models.dart';
import '../providers/app_provider.dart';
import 'fees/fees_tab.dart';
import 'reports/reports_tab.dart';
import 'session/session_tab.dart';
import 'settings/settings_screen.dart';
import 'students/students_tab.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = const [
    SessionTab(),
    StudentsTab(),
    FeesTab(),
    ReportsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('نظام المعلم الذكي'),
        actions: [
          // قائمة المجموعات السريعة (مطابقة لنموذج 1.html في الهيدر)
          if (provider.groups.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: provider.selectedGroup?.id,
                  icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                  items: provider.groups.map((g) {
                    return DropdownMenuItem<int>(
                      value: g.id,
                      child: Text(
                        g.name,
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      final target = provider.groups.firstWhere((g) => g.id == val);
                      provider.selectGroup(target);
                    }
                  },
                ),
              ),
            ),
          const SizedBox(width: 4),

          // زر الانتقال للإعدادات والملف الشخصي
          IconButton(
            icon: const Icon(Icons.settings_outlined, size: 22),
            tooltip: 'الإعدادات والملف الشخصي',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_turned_in_outlined),
            activeIcon: Icon(Icons.assignment_turned_in),
            label: 'الحصة',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt_outlined),
            activeIcon: Icon(Icons.people_alt),
            label: 'الطلاب',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on_outlined),
            activeIcon: Icon(Icons.monetization_on),
            label: 'المصاريف',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            activeIcon: Icon(Icons.description),
            label: 'التقارير',
          ),
        ],
      ),
    );
  }
}
