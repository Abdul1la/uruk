const db = require('../config/database');
const { genId } = require('../utils/helpers');
const { formatCar } = require('./authController');

// ── Add Car ──
exports.addCar = async (req, res) => {
  try {
    const { make, model, year, color, plateNumber, imageUrl } = req.body;
    if (!make || !model || !year || !color || !plateNumber) {
      return res.status(400).json({ error: 'جميع بيانات السيارة مطلوبة' });
    }
    const id = genId('car');
    await db.query(
      `INSERT INTO cars (id, user_id, make, model, year, color, plate_number, image_url)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      [id, req.userId, make, model, year, color, plateNumber, imageUrl || null]
    );
    const [rows] = await db.query('SELECT * FROM cars WHERE id = ?', [id]);
    return res.status(201).json({ car: formatCar(rows[0]) });
  } catch (err) {
    console.error('addCar:', err);
    return res.status(500).json({ error: 'حدث خطأ' });
  }
};

// ── Update Car ──
exports.updateCar = async (req, res) => {
  try {
    const { carId } = req.params;
    const fields = req.body;
    const allowed = ['make', 'model', 'year', 'color', 'plate_number', 'image_url'];
    const updates = [];
    const values = [];
    for (const [key, val] of Object.entries(fields)) {
      const dbKey = key.replace(/([A-Z])/g, '_$1').toLowerCase();
      if (allowed.includes(dbKey)) {
        updates.push(`${dbKey} = ?`);
        values.push(val);
      }
    }
    if (updates.length === 0) return res.status(400).json({ error: 'لا توجد بيانات للتحديث' });
    values.push(carId, req.userId);
    await db.query(`UPDATE cars SET ${updates.join(', ')} WHERE id = ? AND user_id = ?`, values);
    const [rows] = await db.query('SELECT * FROM cars WHERE id = ?', [carId]);
    return res.json({ car: formatCar(rows[0]) });
  } catch (err) {
    console.error('updateCar:', err);
    return res.status(500).json({ error: 'حدث خطأ' });
  }
};

// ── Subscribe Car ──
exports.subscribeCar = async (req, res) => {
  try {
    const { carId } = req.params;
    const { subscription, paymentMonths, repairsAllowedPerMonth } = req.body;
    const expiry = new Date();
    expiry.setDate(expiry.getDate() + 30 * (paymentMonths || 1));

    await db.query(
      `UPDATE cars SET subscription = ?, subscription_start = NOW(), subscription_expiry = ?, payment_months = ?,
       repairs_allowed_per_month = ?, repairs_used_this_month = 0
       WHERE id = ? AND user_id = ?`,
      [subscription, expiry, paymentMonths || 1, repairsAllowedPerMonth || 0, carId, req.userId]
    );
    const [rows] = await db.query('SELECT * FROM cars WHERE id = ?', [carId]);
    return res.json({ car: formatCar(rows[0]) });
  } catch (err) {
    console.error('subscribeCar:', err);
    return res.status(500).json({ error: 'حدث خطأ' });
  }
};

// ── Increment Repairs ──
exports.incrementRepairs = async (req, res) => {
  try {
    const { carId } = req.params;
    await db.query(
      'UPDATE cars SET repairs_used_this_month = repairs_used_this_month + 1 WHERE id = ? AND user_id = ?',
      [carId, req.userId]
    );
    return res.json({ success: true });
  } catch (err) {
    console.error('incrementRepairs:', err);
    return res.status(500).json({ error: 'حدث خطأ' });
  }
};

// ── Get User Cars ──
exports.getUserCars = async (req, res) => {
  try {
    const [rows] = await db.query('SELECT * FROM cars WHERE user_id = ? ORDER BY created_at DESC', [req.userId]);
    return res.json({ cars: rows.map(formatCar) });
  } catch (err) {
    console.error('getUserCars:', err);
    return res.status(500).json({ error: 'حدث خطأ' });
  }
};
