const db = require('../config/database');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { genId, normalizePhone } = require('../utils/helpers');
const { sendOtp, verifyOtp } = require('../utils/twilio');

// ── Send OTP ──
exports.sendOtp = async (req, res) => {
  try {
    const { phone } = req.body;
    if (!phone) return res.status(400).json({ error: 'رقم الهاتف مطلوب' });

    // Short-circuit: if the phone is already registered (and not rejected),
    // tell the client immediately instead of wasting an SMS and an OTP page.
    // Rejected users are allowed to retry registration (matches register logic).
    const normalized = normalizePhone(phone);
    const [existing] = await db.query(
      'SELECT id, status FROM users WHERE phone = ?',
      [normalized]
    );
    if (existing.length > 0 && existing[0].status !== 'rejected') {
      return res.status(409).json({
        error: 'رقم الهاتف مسجّل مسبقاً. يرجى تسجيل الدخول',
        alreadyRegistered: true,
      });
    }

    const result = await sendOtp(phone);
    if (result.success) {
      return res.json({ success: true, dev: result.dev || false });
    }
    return res.status(500).json({ error: result.error || 'فشل إرسال الرمز' });
  } catch (err) {
    console.error('sendOtp:', err);
    return res.status(500).json({ error: 'حدث خطأ' });
  }
};

// ── Verify OTP ──
exports.verifyOtp = async (req, res) => {
  try {
    const { phone, code } = req.body;
    if (!phone || !code) return res.status(400).json({ error: 'الهاتف والرمز مطلوبان' });
    const result = await verifyOtp(phone, code);
    return res.json({
      success: result.success,
      dev: result.dev || false,
      expired: result.expired || false,
      error: result.success ? undefined : (result.error || 'الرمز غير صحيح'),
    });
  } catch (err) {
    console.error('verifyOtp:', err);
    return res.status(500).json({ error: 'حدث خطأ' });
  }
};

// ── Register ──
exports.register = async (req, res) => {
  try {
    const { fullName, password, email } = req.body;
    const phone = normalizePhone(req.body.phone);
    if (!fullName || !phone || !password) {
      return res.status(400).json({ error: 'الاسم والهاتف وكلمة المرور مطلوبة' });
    }

    // Check duplicate phone — allow re-registration only if previously rejected
    const [existing] = await db.query(
      'SELECT id, status FROM users WHERE phone = ?',
      [phone]
    );
    if (existing.length > 0) {
      if (existing[0].status === 'rejected') {
        // Clean up the old rejected record + related data before re-registering
        const oldId = existing[0].id;
        await db.query('DELETE FROM notifications WHERE user_id = ?', [oldId]);
        await db.query('DELETE FROM cars WHERE user_id = ?', [oldId]);
        await db.query('DELETE FROM payments WHERE user_id = ?', [oldId]);
        await db.query('DELETE FROM users WHERE id = ?', [oldId]);
      } else {
        return res.status(409).json({
          error: 'رقم الهاتف مسجّل مسبقاً',
          alreadyRegistered: true,
        });
      }
    }

    const id = genId('usr');
    const hash = await bcrypt.hash(password, 10);

    await db.query(
      'INSERT INTO users (id, full_name, phone, email, password, status) VALUES (?, ?, ?, ?, ?, ?)',
      [id, fullName, phone, email || null, hash, 'pending']
    );

    const token = jwt.sign({ userId: id }, process.env.JWT_SECRET, {
      expiresIn: process.env.JWT_EXPIRES_IN || '30d',
    });

    return res.status(201).json({
      token,
      user: { id, fullName, phone, email, status: 'pending', cars: [], createdAt: new Date() },
    });
  } catch (err) {
    console.error('register:', err);
    return res.status(500).json({ error: 'حدث خطأ' });
  }
};

// ── Login ──
exports.login = async (req, res) => {
  try {
    const { password } = req.body;
    const phone = normalizePhone(req.body.phone);
    if (!phone || !password) {
      return res.status(400).json({ error: 'الهاتف وكلمة المرور مطلوبان' });
    }

    const [rows] = await db.query('SELECT * FROM users WHERE phone = ?', [phone]);
    if (rows.length === 0) {
      return res.status(401).json({ error: 'بيانات الدخول غير صحيحة' });
    }

    const user = rows[0];
    const match = await bcrypt.compare(password, user.password);
    if (!match) {
      return res.status(401).json({ error: 'بيانات الدخول غير صحيحة' });
    }

    // Fetch user's cars
    const [cars] = await db.query('SELECT * FROM cars WHERE user_id = ?', [user.id]);

    const token = jwt.sign({ userId: user.id }, process.env.JWT_SECRET, {
      expiresIn: process.env.JWT_EXPIRES_IN || '30d',
    });

    return res.json({
      token,
      user: {
        id: user.id,
        fullName: user.full_name,
        phone: user.phone,
        email: user.email,
        idFrontUrl: user.id_front_url,
        idBackUrl: user.id_back_url,
        status: user.status,
        paymentDue: !!user.payment_due,
        cars: cars.map(formatCar),
        createdAt: user.created_at,
      },
    });
  } catch (err) {
    console.error('login:', err);
    return res.status(500).json({ error: 'حدث خطأ' });
  }
};

// ── Upload ID Images ──
exports.uploadIdImages = async (req, res) => {
  try {
    const { frontUrl, backUrl } = req.body;
    if (!frontUrl || !backUrl) {
      return res.status(400).json({ error: 'صور الهوية مطلوبة' });
    }
    await db.query(
      'UPDATE users SET id_front_url = ?, id_back_url = ? WHERE id = ?',
      [frontUrl, backUrl, req.userId]
    );
    const [rows] = await db.query('SELECT * FROM users WHERE id = ?', [req.userId]);
    const [cars] = await db.query('SELECT * FROM cars WHERE user_id = ?', [req.userId]);
    return res.json({ user: formatUser(rows[0], cars) });
  } catch (err) {
    console.error('uploadIdImages:', err);
    return res.status(500).json({ error: 'حدث خطأ' });
  }
};

// ── Get Profile ──
exports.getProfile = async (req, res) => {
  try {
    const [rows] = await db.query('SELECT * FROM users WHERE id = ?', [req.userId]);
    if (rows.length === 0) return res.status(404).json({ error: 'المستخدم غير موجود' });
    const [cars] = await db.query('SELECT * FROM cars WHERE user_id = ?', [req.userId]);
    return res.json({ user: formatUser(rows[0], cars) });
  } catch (err) {
    console.error('getProfile:', err);
    return res.status(500).json({ error: 'حدث خطأ' });
  }
};

// ── Refresh User (status check) ──
exports.refreshUser = async (req, res) => {
  try {
    const [rows] = await db.query('SELECT * FROM users WHERE id = ?', [req.userId]);
    if (rows.length === 0) return res.status(404).json({ error: 'المستخدم غير موجود' });
    const [cars] = await db.query('SELECT * FROM cars WHERE user_id = ?', [req.userId]);
    return res.json({ user: formatUser(rows[0], cars) });
  } catch (err) {
    console.error('refreshUser:', err);
    return res.status(500).json({ error: 'حدث خطأ' });
  }
};

// ── Helpers ──
function formatCar(c) {
  return {
    id: c.id,
    make: c.make,
    model: c.model,
    year: c.year,
    color: c.color,
    plateNumber: c.plate_number,
    imageUrl: c.image_url,
    subscription: c.subscription,
    subscriptionStart: c.subscription_start,
    subscriptionExpiry: c.subscription_expiry,
    paymentMonths: c.payment_months,
    repairsAllowedPerMonth: c.repairs_allowed_per_month,
    repairsUsedThisMonth: c.repairs_used_this_month,
  };
}

function formatUser(u, cars) {
  return {
    id: u.id,
    fullName: u.full_name,
    phone: u.phone,
    email: u.email,
    idFrontUrl: u.id_front_url,
    idBackUrl: u.id_back_url,
    status: u.status,
    paymentDue: !!u.payment_due,
    cars: (cars || []).map(formatCar),
    createdAt: u.created_at,
  };
}

exports.formatUser = formatUser;
exports.formatCar = formatCar;
