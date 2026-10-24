#!/usr/bin/env bash
set -e

echo "========================================================"
echo "  نظام إدارة المعلم الذكي - استخراج نسخة الأندرويد APK"
echo "========================================================"

if ! command -v flutter &> /dev/null; then
  echo "[!] لم يتم العثور على أداة flutter على جهازك."
  echo "يرجى تثبيت Flutter SDK أو رفع المشروع على GitHub لبناء الـ APK سحابياً مجاناً."
  exit 1
fi

echo "[1/3] استكمال ملفات أندرويد الأساسية..."
flutter create . --project-name smart_teacher_app --org com.smartteacher.app

echo "[2/3] تحميل الحزم والمكتبات (flutter pub get)..."
flutter pub get

echo "[3/3] بناء ملف APK النهائي (flutter build apk --release)..."
flutter build apk --release --no-tree-shake-icons

echo ""
echo "✅ تم استخراج ملف الـ APK بنجاح!"
echo "📁 المسار: build/app/outputs/flutter-apk/app-release.apk"
