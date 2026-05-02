const db = require('../config/database');
const { genId } = require('../utils/helpers');

function formatOilChange(o) {
  return {
    id: o.id,
    userId: o.user_id,
    carId: o.car_id,
    scheduledDate: o.scheduled_date,
    timeSlot: o.time_slot,
    branchName: o.branch_name,
    locationLat: o.location_lat,
    locationLng: o.location_lng,
    status: o.status,
    notes: o.notes,
    priceIQD: o.price_iqd,
    createdAt: o.created_at,
  };
}

exports.getBookings = async (req, res) => {
  try {
    const [rows] = await db.query(
      'SELECT * FROM oil_changes WHERE user_id = ? ORDER BY created_at DESC', [req.userId]
    );
    return res.json({ bookings: rows.map(formatOilChange) });
  } catch (err) {
    console.error('getOilBookings:', err);
    return res.status(500).json({ error: 'حدث خطأ' });
  }
};

exports.bookOilChange = async (req, res) => {
  try {
    const { carId, notes } = req.body;
    if (!carId) return res.status(400).json({ error: 'معرّف السيارة مطلوب' });
    const id = genId('oil');
    await db.query(
      'INSERT INTO oil_changes (id, user_id, car_id, notes) VALUES (?, ?, ?, ?)',
      [id, req.userId, carId, notes || null]
    );
    const [rows] = await db.query('SELECT * FROM oil_changes WHERE id = ?', [id]);
    return res.status(201).json({ booking: formatOilChange(rows[0]) });
  } catch (err) {
    console.error('bookOilChange:', err);
    return res.status(500).json({ error: 'حدث خطأ' });
  }
};
