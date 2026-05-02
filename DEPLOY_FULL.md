# دليل النشر الكامل — Uruk Motors

## نظرة عامة
- **الدومين:** uruk-services.com (Spaceship Supreme)
- **Backend:** Node.js + MySQL عبر cPanel
- **Flutter:** نسخة Web على الدومين الرئيسي
- **Admin Dashboard:** /dashboard على نفس الدومين

## البنية النهائية على السيرفر

```
uruk-services.com/              → Flutter Web (public_html/)
uruk-services.com/dashboard     → لوحة التحكم (public_html/dashboard/)
uruk-services.com/api/*         → Node.js API endpoints
uruk-services.com/uploads/*     → ملفات المرفوعة (صور وفيديو)
```

---

## المرحلة 1: إنشاء قاعدة بيانات MySQL

1. سجّل دخول إلى cPanel الخاص بـ Spaceship Supreme
2. ابحث عن **MySQL® Databases** تحت قسم Databases
3. أنشئ قاعدة بيانات جديدة:
   - اسم: `uruk_motors` (سيُضاف بادئة تلقائياً مثل `cpuser_uruk_motors`)
   - انسخ الاسم الكامل
4. أنشئ مستخدم MySQL جديد:
   - اسم المستخدم: `uruk_admin`
   - كلمة مرور قوية (استخدم Password Generator)
   - انسخ الاسم الكامل وكلمة المرور
5. اربط المستخدم بقاعدة البيانات:
   - في قسم "Add User To Database"
   - اختر المستخدم والقاعدة
   - امنح جميع الصلاحيات (ALL PRIVILEGES)
6. **احفظ هذه المعلومات:**
   - DB_NAME (الاسم الكامل مع البادئة)
   - DB_USER (الاسم الكامل مع البادئة)
   - DB_PASSWORD

---

## المرحلة 2: إنشاء Node.js Application

1. في cPanel، ابحث عن **Setup Node.js App**
2. اضغط **Create Application**:
   - **Node.js version:** 18 أو 20 (الأحدث المتاح)
   - **Application mode:** Production
   - **Application root:** `api` (سيُنشأ مجلد `/home/cpuser/api`)
   - **Application URL:** اترك فارغاً أو اختر `uruk-services.com/api`
   - **Application startup file:** `server.js`
3. اضغط Create
4. ستحصل على:
   - مسار التطبيق (مثلاً: `/home/cpuser/api`)
   - أمر لتفعيل البيئة الافتراضية

---

## المرحلة 3: رفع ملفات Backend

1. من cPanel، افتح **File Manager**
2. اذهب لمجلد `/home/cpuser/api` (المُنشأ في الخطوة السابقة)
3. ارفع محتويات مجلد `backend/` بالكامل:
   - controllers/
   - config/
   - middleware/
   - routes/
   - utils/
   - server.js
   - package.json
   - .htaccess
4. أنشئ ملف `.env` جديد في نفس المجلد وألصق فيه:

```env
PORT=3000
NODE_ENV=production
BASE_URL=https://uruk-services.com

# من المرحلة 1
DB_HOST=localhost
DB_PORT=3306
DB_USER=cpuser_uruk_admin
DB_PASSWORD=كلمة_المرور_التي_أنشأتها
DB_NAME=cpuser_uruk_motors

# توليد مفاتيح عشوائية قوية (استخدم موقع: randomkeygen.com)
JWT_SECRET=ضع_مفتاح_عشوائي_طويل_هنا_64_حرف
JWT_EXPIRES_IN=30d

ADMIN_JWT_SECRET=ضع_مفتاح_آخر_عشوائي_هنا
ADMIN_JWT_EXPIRES_IN=8h

# Twilio
TWILIO_ACCOUNT_SID=ضع_معرف_حساب_تويليو_هنا
TWILIO_AUTH_TOKEN=ضع_رمز_تويليو_هنا
TWILIO_VERIFY_SERVICE_SID=ضع_معرف_خدمة_التحقق_هنا

UPLOAD_DIR=./uploads
MAX_FILE_SIZE=10485760
```

5. أنشئ مجلد `uploads` داخل `api` وامنحه صلاحيات 755

---

## المرحلة 4: تثبيت المكتبات وتشغيل التهيئة

1. ارجع لصفحة **Setup Node.js App**
2. اضغط على التطبيق الخاص بك
3. انسخ الأمر تحت "Enter to the virtual environment" (شيء مثل):
   ```
   source /home/cpuser/nodevenv/api/18/bin/activate && cd /home/cpuser/api
   ```
4. افتح **Terminal** من cPanel (أو SSH)
5. نفّذ الأمر المنسوخ
6. ثبّت المكتبات:
   ```bash
   npm install
   ```
7. شغّل تهيئة قاعدة البيانات (إنشاء الجداول والبيانات الأولية):
   ```bash
   node config/init-db.js
   ```
   ستظهر رسائل مثل:
   - ✓ Created users table
   - ✓ Created cars table
   - ... (15 جدول)
   - ✓ Seeded default admin employees
   - ✓ Database initialized successfully
8. ارجع لصفحة Setup Node.js App واضغط **Restart**

---

## المرحلة 5: اختبار Backend

افتح في المتصفح:
- `https://uruk-services.com/api/` — يجب أن يعطي رسالة ترحيب
- `https://uruk-services.com/api/config/cities` — يجب أن ترجع قائمة المدن

إذا لم تعمل، راجع **Application Logs** من Node.js App.

---

## المرحلة 6: بناء Flutter Web (على جهازك)

**على جهازك الشخصي** (ليس على السيرفر)، افتح terminal في مجلد المشروع:

```bash
cd /path/to/uruk-main

# تأكد من تثبيت المكتبات
flutter pub get

# فعّل دعم web (مرة واحدة فقط)
flutter config --enable-web

# ابنِ النسخة للإنتاج
flutter build web --release --web-renderer canvaskit
```

بعد الانتهاء، ستجد المجلد: `build/web/` — هذا ما سنرفعه للسيرفر.

---

## المرحلة 7: رفع Flutter Web إلى public_html

1. من cPanel، افتح **File Manager**
2. اذهب لمجلد `public_html/`
3. **احذف** الملفات الافتراضية (مثل `index.html` و `cgi-bin` إذا كانت فارغة)
   - ⚠️ إذا كان عندك website dashboard مرفوع هناك، انقله لمجلد `public_html/dashboard` أولاً
4. ارفع **محتويات** `build/web/` (ليس المجلد نفسه):
   - index.html
   - main.dart.js
   - flutter.js
   - manifest.json
   - assets/
   - canvaskit/
   - icons/
   - ...إلخ
5. أضف ملف `.htaccess` في `public_html/` للتوجيه الصحيح:

```apache
# public_html/.htaccess
<IfModule mod_rewrite.c>
  RewriteEngine On

  # اترك /api يصل للـ backend
  RewriteCond %{REQUEST_URI} ^/api [OR]
  RewriteCond %{REQUEST_URI} ^/uploads [OR]
  RewriteCond %{REQUEST_URI} ^/dashboard
  RewriteRule ^ - [L]

  # وجّه كل شيء آخر للـ Flutter Web (SPA)
  RewriteCond %{REQUEST_FILENAME} !-f
  RewriteCond %{REQUEST_FILENAME} !-d
  RewriteRule ^ index.html [L]
</IfModule>
```

---

## المرحلة 8: رفع لوحة التحكم (Dashboard)

1. في `public_html/`، أنشئ مجلد `dashboard`
2. ارفع محتويات `website/` بالكامل إلى `public_html/dashboard/`:
   - index.html
   - js/
   - css/
   - ...إلخ
3. تأكد من أن `js/api.js` يشير للـ base URL الصحيح

---

## المرحلة 9: الاختبار النهائي

افتح:
1. `https://uruk-services.com` → يجب أن يظهر تطبيق Flutter Web (شاشة الترحيب/الدخول)
2. `https://uruk-services.com/dashboard` → لوحة التحكم (دخول بـ `admin@uruk.iq` / `123456`)
3. جرّب:
   - تسجيل مستخدم جديد برقم عراقي
   - استلام OTP عبر SMS (يتطلب رقم verified caller ID في trial)
   - تسجيل الدخول
   - إضافة سيارة
   - من لوحة التحكم: قبول المستخدم

---

## بيانات الدخول الافتراضية للموظفين

| البريد | كلمة المرور | القسم |
|---|---|---|
| admin@uruk.iq | 123456 | admin |
| finance@uruk.iq | 123456 | finance |
| maintenance@uruk.iq | 123456 | maintenance |
| admin-dept@uruk.iq | 123456 | administration |

**⚠️ غيّر هذه كلمات المرور فوراً بعد أول تسجيل دخول!**

---

## حل المشاكل الشائعة

### 1. `Cannot connect to database`
- تحقق من DB_USER/DB_PASSWORD/DB_NAME في `.env`
- تأكد أن المستخدم مرتبط بالقاعدة مع ALL PRIVILEGES

### 2. `Application failed to start`
- افتح Application Logs من Node.js App
- تحقق من أن `server.js` هو startup file
- تأكد من `npm install` تم بنجاح

### 3. Flutter web يظهر شاشة بيضاء
- افتح Console في المتصفح (F12) وشاهد الأخطاء
- تحقق أن `.htaccess` مرفوع في `public_html/`
- تحقق من مسار الـ API في Flutter (`https://uruk-services.com/api`)

### 4. CORS errors
- الـ backend بالفعل مُعد مع CORS مفتوح
- إذا استمرت المشكلة، أضف في `.htaccess`:
  ```
  Header set Access-Control-Allow-Origin "*"
  ```

### 5. Twilio `Error sending code`
- تأكد أن Iraq مفعّلة في Geo Permissions ✓ (تم)
- في trial account: الرقم المستقبل يجب أن يكون verified
- اذهب لـ Phone Numbers → Verified Caller IDs وأضف الرقم

---

تم. بعد اتباع هذه الخطوات، التطبيق والـ API وقاعدة البيانات كلها ستعمل معاً على Spaceship.
