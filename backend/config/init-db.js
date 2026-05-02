/**
 * Uruk Motors – MySQL Database Initialization
 * Run: node config/init-db.js
 */
const mysql = require('mysql2/promise');
const bcrypt = require('bcryptjs');
require('dotenv').config();

async function initDB() {
  const conn = await mysql.createConnection({
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT || '3306'),
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    multipleStatements: true,
    charset: 'utf8mb4',
  });

  const DB = process.env.DB_NAME || 'uruk_motors';

  console.log('🔧 Creating database...');
  await conn.query(`CREATE DATABASE IF NOT EXISTS \`${DB}\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci`);
  await conn.query(`USE \`${DB}\``);

  console.log('🔧 Creating tables...');

  // ── Users ──
  await conn.query(`
    CREATE TABLE IF NOT EXISTS users (
      id          VARCHAR(50) PRIMARY KEY,
      full_name   VARCHAR(255) NOT NULL,
      phone       VARCHAR(20)  NOT NULL UNIQUE,
      email       VARCHAR(255),
      password    VARCHAR(255) NOT NULL,
      id_front_url VARCHAR(500),
      id_back_url  VARCHAR(500),
      status      ENUM('pending','approved','rejected','suspended') DEFAULT 'pending',
      payment_due TINYINT(1) DEFAULT 0,
      created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at  DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      INDEX idx_phone (phone),
      INDEX idx_status (status)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  `);

  // ── Cars ──
  await conn.query(`
    CREATE TABLE IF NOT EXISTS cars (
      id                     VARCHAR(50) PRIMARY KEY,
      user_id                VARCHAR(50) NOT NULL,
      make                   VARCHAR(100) NOT NULL,
      model                  VARCHAR(100) NOT NULL,
      year                   INT NOT NULL,
      color                  VARCHAR(50) NOT NULL,
      plate_number           VARCHAR(50) NOT NULL,
      image_url              VARCHAR(500),
      subscription           ENUM('none','standard','shared','vip') DEFAULT 'none',
      subscription_expiry    DATETIME,
      payment_months         INT DEFAULT 1,
      repairs_allowed_per_month INT DEFAULT 0,
      repairs_used_this_month   INT DEFAULT 0,
      created_at             DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at             DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
      INDEX idx_user (user_id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  `);

  // ── Accident Reports ──
  await conn.query(`
    CREATE TABLE IF NOT EXISTS accident_reports (
      id                  VARCHAR(50) PRIMARY KEY,
      user_id             VARCHAR(50) NOT NULL,
      car_id              VARCHAR(50),
      accident_date       DATETIME NOT NULL,
      location            VARCHAR(500) NOT NULL,
      lat                 DOUBLE,
      lng                 DOUBLE,
      description         TEXT NOT NULL,
      photo_urls          JSON,
      other_party_involved TINYINT(1) DEFAULT 0,
      status              ENUM('pending','underReview','approved','inRepair','completed','rejected') DEFAULT 'pending',
      submitted_at        DATETIME DEFAULT CURRENT_TIMESTAMP,
      maintenance_notes   TEXT,
      repair_photo_urls   JSON,
      completed_at        DATETIME,
      appointment_id      VARCHAR(50),
      rejection_reason    TEXT,
      created_at          DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at          DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
      FOREIGN KEY (car_id) REFERENCES cars(id) ON DELETE SET NULL,
      INDEX idx_user (user_id),
      INDEX idx_status (status)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  `);

  // ── Repair Archive (per report) ──
  await conn.query(`
    CREATE TABLE IF NOT EXISTS repair_entries (
      id              VARCHAR(50) PRIMARY KEY,
      report_id       VARCHAR(50) NOT NULL,
      date            DATETIME NOT NULL,
      technician      VARCHAR(255) NOT NULL,
      description     TEXT NOT NULL,
      parts_replaced  JSON,
      photos          JSON,
      cost            INT DEFAULT 0,
      is_final        TINYINT(1) DEFAULT 0,
      created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (report_id) REFERENCES accident_reports(id) ON DELETE CASCADE,
      INDEX idx_report (report_id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  `);

  // ── Appointments ──
  await conn.query(`
    CREATE TABLE IF NOT EXISTS appointments (
      id               VARCHAR(50) PRIMARY KEY,
      user_id          VARCHAR(50) NOT NULL,
      report_id        VARCHAR(50),
      scheduled_date   DATETIME NOT NULL,
      time_slot        VARCHAR(50) NOT NULL,
      status           ENUM('scheduled','changeRequested','confirmed','completed','cancelled') DEFAULT 'scheduled',
      user_note        TEXT,
      maintenance_note TEXT,
      branch_name      VARCHAR(255),
      location_lat     DOUBLE,
      location_lng     DOUBLE,
      created_at       DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at       DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
      FOREIGN KEY (report_id) REFERENCES accident_reports(id) ON DELETE SET NULL,
      INDEX idx_user (user_id),
      INDEX idx_status (status)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  `);

  // ── Payments ──
  await conn.query(`
    CREATE TABLE IF NOT EXISTS payments (
      id              VARCHAR(50) PRIMARY KEY,
      user_id         VARCHAR(50) NOT NULL,
      car_id          VARCHAR(50),
      car_desc        VARCHAR(255),
      amount_iqd      INT NOT NULL,
      due_date        DATE NOT NULL,
      paid_date       DATE,
      status          ENUM('paid','unpaid','overdue') DEFAULT 'unpaid',
      method          ENUM('zaincash','superQi','other'),
      month           VARCHAR(50),
      proof_image_url VARCHAR(500),
      created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
      FOREIGN KEY (car_id) REFERENCES cars(id) ON DELETE SET NULL,
      INDEX idx_user (user_id),
      INDEX idx_status (status)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  `);

  // ── Oil Change Bookings ──
  await conn.query(`
    CREATE TABLE IF NOT EXISTS oil_changes (
      id              VARCHAR(50) PRIMARY KEY,
      user_id         VARCHAR(50) NOT NULL,
      car_id          VARCHAR(50),
      scheduled_date  DATETIME,
      time_slot       VARCHAR(50),
      branch_name     VARCHAR(255),
      location_lat    DOUBLE,
      location_lng    DOUBLE,
      status          ENUM('pending','confirmed','completed','cancelled') DEFAULT 'pending',
      notes           TEXT,
      price_iqd       INT DEFAULT 15000,
      created_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at      DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
      FOREIGN KEY (car_id) REFERENCES cars(id) ON DELETE SET NULL,
      INDEX idx_user (user_id),
      INDEX idx_status (status)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  `);

  // ── Notifications ──
  await conn.query(`
    CREATE TABLE IF NOT EXISTS notifications (
      id          VARCHAR(50) PRIMARY KEY,
      user_id     VARCHAR(50) NOT NULL,
      title       VARCHAR(500) NOT NULL,
      body        TEXT NOT NULL,
      type        ENUM('payment','appointment','report','subscription','general') DEFAULT 'general',
      is_read     TINYINT(1) DEFAULT 0,
      action_route VARCHAR(255),
      created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
      INDEX idx_user (user_id),
      INDEX idx_read (user_id, is_read)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  `);

  // ── Car Change Requests ──
  await conn.query(`
    CREATE TABLE IF NOT EXISTS car_change_requests (
      id                VARCHAR(50) PRIMARY KEY,
      user_id           VARCHAR(50) NOT NULL,
      type              ENUM('profileEdit','carChange') DEFAULT 'carChange',
      requested_changes JSON NOT NULL,
      status            ENUM('pending','approved','rejected') DEFAULT 'pending',
      submitted_at      DATETIME DEFAULT CURRENT_TIMESTAMP,
      reviewed_at       DATETIME,
      review_note       TEXT,
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
      INDEX idx_user (user_id),
      INDEX idx_status (status)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  `);

  // ── Upgrade Requests ──
  await conn.query(`
    CREATE TABLE IF NOT EXISTS upgrade_requests (
      id                      VARCHAR(50) PRIMARY KEY,
      user_id                 VARCHAR(50) NOT NULL,
      car_id                  VARCHAR(50),
      current_plan            ENUM('none','standard','shared','vip') NOT NULL,
      current_plan_price_iqd  INT NOT NULL,
      remaining_months        INT NOT NULL,
      credit_iqd              INT NOT NULL,
      requested_plan          ENUM('none','standard','shared','vip') NOT NULL,
      requested_plan_price_iqd INT NOT NULL,
      requested_months        INT NOT NULL,
      new_cost_iqd            INT NOT NULL,
      amount_due_iqd          INT NOT NULL,
      proof_image_url         VARCHAR(500),
      status                  ENUM('pending','approved','rejected') DEFAULT 'pending',
      submitted_at            DATETIME DEFAULT CURRENT_TIMESTAMP,
      reviewed_at             DATETIME,
      admin_note              TEXT,
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
      FOREIGN KEY (car_id) REFERENCES cars(id) ON DELETE SET NULL,
      INDEX idx_user (user_id),
      INDEX idx_status (status)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  `);

  // ── Branches ──
  await conn.query(`
    CREATE TABLE IF NOT EXISTS branches (
      id        VARCHAR(50) PRIMARY KEY,
      name      VARCHAR(255) NOT NULL,
      lat       DOUBLE NOT NULL,
      lng       DOUBLE NOT NULL,
      address   VARCHAR(500),
      phone     VARCHAR(50),
      is_active TINYINT(1) DEFAULT 1,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  `);

  // ── Employees (dashboard users) ──
  await conn.query(`
    CREATE TABLE IF NOT EXISTS employees (
      id          VARCHAR(50) PRIMARY KEY,
      full_name   VARCHAR(255) NOT NULL,
      email       VARCHAR(255) NOT NULL UNIQUE,
      phone       VARCHAR(50),
      password    VARCHAR(255) NOT NULL,
      department  ENUM('admin','finance','maintenance','administration') DEFAULT 'administration',
      is_active   TINYINT(1) DEFAULT 1,
      created_at  DATETIME DEFAULT CURRENT_TIMESTAMP,
      updated_at  DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
      INDEX idx_email (email)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  `);

  // ── App Config (key-value settings) ──
  await conn.query(`
    CREATE TABLE IF NOT EXISTS app_config (
      config_key   VARCHAR(100) PRIMARY KEY,
      config_value JSON NOT NULL,
      updated_at   DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  `);

  // ── Ad Banners ──
  await conn.query(`
    CREATE TABLE IF NOT EXISTS ad_banners (
      id              VARCHAR(50) PRIMARY KEY,
      title           VARCHAR(255) NOT NULL,
      subtitle        VARCHAR(500),
      bg_color        VARCHAR(20) DEFAULT '#1A3A8F',
      text_color      VARCHAR(20) DEFAULT '#FFFFFF',
      icon            VARCHAR(50) DEFAULT 'star',
      action_label    VARCHAR(100),
      action_route    VARCHAR(255),
      media_url       VARCHAR(500),
      media_type      ENUM('none','image','video') DEFAULT 'none',
      is_active       TINYINT(1) DEFAULT 1,
      sort_order      INT DEFAULT 0,
      created_at      DATETIME DEFAULT CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  `);

  // ── Subscription Plans ──
  await conn.query(`
    CREATE TABLE IF NOT EXISTS subscription_plans (
      id            VARCHAR(50) PRIMARY KEY,
      type          ENUM('standard','shared','vip') NOT NULL,
      name          VARCHAR(100) NOT NULL,
      price_iqd     INT NOT NULL,
      coverage_note VARCHAR(500),
      covered_parts JSON,
      repair_tiers  JSON,
      is_popular    TINYINT(1) DEFAULT 0,
      is_active     TINYINT(1) DEFAULT 1,
      sort_order    INT DEFAULT 0
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
  `);

  // ═══════════════════════════════════════
  // Seed default data
  // ═══════════════════════════════════════

  console.log('🌱 Seeding default data...');

  // Default admin employee
  const adminPass = await bcrypt.hash('123456', 10);
  await conn.query(`
    INSERT IGNORE INTO employees (id, full_name, email, phone, password, department)
    VALUES
      (UUID(), 'مدير النظام', 'admin@uruk.iq', '+964 770 000 0001', ?, 'admin'),
      (UUID(), 'موظف المالية', 'finance@uruk.iq', '+964 770 000 0002', ?, 'finance'),
      (UUID(), 'موظف الصيانة', 'maintenance@uruk.iq', '+964 770 000 0003', ?, 'maintenance'),
      (UUID(), 'موظف الإدارة', 'admin-dept@uruk.iq', '+964 770 000 0004', ?, 'administration')
  `, [adminPass, adminPass, adminPass, adminPass]);

  // Default branches
  await conn.query(`
    INSERT IGNORE INTO branches (id, name, lat, lng, address, phone) VALUES
      (UUID(), 'فرع الكرادة', 33.3025, 44.3950, 'شارع الكرادة الرئيسي، بغداد', '+964 770 111 1111'),
      (UUID(), 'فرع المنصور', 33.3152, 44.3561, 'شارع المنصور، بغداد', '+964 770 222 2222'),
      (UUID(), 'فرع زيونة', 33.3340, 44.4120, 'حي زيونة، بغداد', '+964 770 333 3333')
  `);

  // Default support info
  await conn.query(`
    INSERT IGNORE INTO app_config (config_key, config_value) VALUES
      ('support_info', ?),
      ('payment_accounts', ?),
      ('privacy_policy', ?),
      ('available_cities', ?)
  `, [
    JSON.stringify({
      phone: '+964 770 000 0000',
      email: 'support@urukmotors.iq',
      whatsapp: '+964 770 000 0000',
      address: 'بغداد، العراق',
      workingHours: 'السبت - الخميس: 9 صباحاً - 6 مساءً',
      instagram: 'https://instagram.com/urukmotors',
      facebook: 'https://facebook.com/urukmotors',
      telegram: 'https://t.me/urukmotors',
      website: 'https://uruk-services.com',
    }),
    JSON.stringify({ zainCash: '07801234567', superQi: '07901234567' }),
    JSON.stringify({
      updatedAt: '2026-04-18',
      content: [
        'مرحباً بك في تطبيق أوروك موتورز. نحن نهتم بخصوصيّتك ونلتزم بحماية بياناتك.',
        '',
        '١. المعلومات التي نجمعها',
        'عند تسجيلك في التطبيق نجمع: الاسم الكامل، رقم الهاتف، البريد الإلكتروني (اختياري)، صور الهوية للتحقّق، ومعلومات مركبتك.',
        '',
        '٢. كيف نستخدم معلوماتك',
        'نستخدم بياناتك لإنشاء حسابك، تفعيل الاشتراك، إدارة طلبات الصيانة والحوادث، والتواصل معك بشأن خدماتك.',
        '',
        '٣. مشاركة المعلومات',
        'لا نبيع أو نؤجّر بياناتك لأطراف ثالثة. قد نشاركها مع مزوّدي الخدمات الموثوقين (مثل خدمات الرسائل النصية) فقط لتقديم الخدمة لك.',
        '',
        '٤. الأمان',
        'نحمي بياناتك بتشفير كلمات المرور وبرتوكولات HTTPS الآمنة. لن يطّلع على بياناتك سوى فريق الدعم المصرّح له.',
        '',
        '٥. حقوقك',
        'يحقّ لك الاطلاع على بياناتك، تعديلها، أو طلب حذف حسابك في أيّ وقت عبر التواصل مع الدعم.',
        '',
        '٦. التواصل',
        'لأيّ استفسار أو طلب، تواصل معنا عبر: support@urukmotors.iq أو رقم الدعم في التطبيق.',
      ].join('\n'),
    }),
    JSON.stringify(['بغداد']),
  ]);

  // Default subscription plans
  await conn.query(`
    INSERT IGNORE INTO subscription_plans (id, type, name, price_iqd, coverage_note, covered_parts, repair_tiers, is_popular, sort_order) VALUES
      (UUID(), 'standard', 'الباقة الأساسية', 35000, 'سيارة المشترك فقط',
       '["الدعامية الأمامية","الدعامية الخلفية","الأبواب","جاملخ الاماميات","جاملخ الخلفيات للسيارة"]',
       '[{"label":"شهري","months":1,"repairsPerMonth":1},{"label":"3 أشهر","months":3,"repairsPerMonth":2},{"label":"6 أشهر","months":6,"repairsPerMonth":3},{"label":"سنوي","months":12,"repairsPerMonth":4}]',
       0, 1),
      (UUID(), 'shared', 'الباقة المشتركة', 60000, 'سيارة المشترك + سيارة الطرف الآخر',
       '["الدعامية الأمامية","الدعامية الخلفية","الأبواب","جاملخ الاماميات","جاملخ الخلفيات للسيارة"]',
       '[{"label":"شهري","months":1,"repairsPerMonth":1},{"label":"3 أشهر","months":3,"repairsPerMonth":2},{"label":"6 أشهر","months":6,"repairsPerMonth":3},{"label":"سنوي","months":12,"repairsPerMonth":4}]',
       1, 2),
      (UUID(), 'vip', 'باقة VIP', 150000, 'سيارة المشترك + سيارة الطرف الآخر',
       '["الدعامية الأمامية","الدعامية الخلفية","الأبواب","جاملخ الاماميات","جاملخ الخلفيات للسيارة","غطاء المحرك","صندوق السيارة"]',
       '[{"label":"شهري","months":1,"repairsPerMonth":3},{"label":"3 أشهر","months":3,"repairsPerMonth":5},{"label":"6 أشهر","months":6,"repairsPerMonth":7},{"label":"سنوي","months":12,"repairsPerMonth":10}]',
       0, 3)
  `);

  // Default ad banners
  await conn.query(`
    INSERT IGNORE INTO ad_banners (id, title, subtitle, bg_color, icon, action_label, action_route, sort_order) VALUES
      (UUID(), 'خصم 15% على الاشتراك', 'اشترك الآن واحصل على خصم خاص', '#1A3A8F', 'percent', 'اشترك الآن', '/subscription', 1),
      (UUID(), 'خدمة تبديل الزيت', 'تبديل زيت بسعر 15,000 د.ع فقط', '#16A34A', 'droplets', 'احجز الآن', '/oil-change', 2),
      (UUID(), 'فحص مجاني للسيارة', 'احصل على تقييم مجاني لحالة سيارتك', '#7C3AED', 'shield-check', 'المزيد', '/support', 3)
  `);

  console.log('✅ Database initialized successfully!');
  await conn.end();
}

initDB().catch(err => {
  console.error('❌ Database init failed:', err);
  process.exit(1);
});
