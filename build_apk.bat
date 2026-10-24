@echo off
chcp 65001 >nul
echo ========================================================
echo   نظام إدارة المعلم الذكي - استخراج نسخة الأندرويد APK
echo ========================================================
echo.

where flutter >nul 2>nul
if %errorlevel% neq 0 (
    echo [!] لم يتم العثور على Flutter في متغيرات النظام PATH.
    echo يرجى التأكد من تثبيت Flutter SDK أو استخدام GitHub Actions المرفق في المجلد.
    pause
    exit /b 1
)

echo [1/3] استكمال ملفات أندرويد الأساسية...
call flutter create . --project-name smart_teacher_app --org com.smartteacher.app

echo [2/3] تحميل الحزم والمكتبات (flutter pub get)...
call flutter pub get

echo [3/3] بناء ملف APK النهائي (flutter build apk --release)...
call flutter build apk --release --no-tree-shake-icons

echo.
echo ========================================================
echo   تم استخراج ملف الـ APK بنجاح!
echo   المسار: build\app\outputs\flutter-apk\app-release.apk
echo ========================================================
explorer "build\app\outputs\flutter-apk"
pause
