const db = require('../config/database');
const { genId, safeJson } = require('../utils/helpers');

function formatReport(r) {
  return {
    id: r.id,
    userId: r.user_id,
    carId: r.car_id,
    accidentDate: r.accident_date,
    location: r.location,
    lat: r.lat,
    lng: r.lng,
    description: r.description,
    photoUrls: safeJson(r.photo_urls, []),
    otherPartyInvolved: !!r.other_party_involved,
    status: r.status,
    submittedAt: r.submitted_at,
    maintenanceNotes: r.maintenance_notes,
    repairPhotoUrls: safeJson(r.repair_photo_urls, []),
    completedAt: r.completed_at,
    appointmentId: r.appointment_id,
    rejectionReason: r.rejection_reason,
    repairArchive: [],  // filled below if needed
  };
}

// ── Get Reports ──
exports.getReports = async (req, res) => {
  try {
    const [rows] = await db.query(
      'SELECT * FROM accident_reports WHERE user_id = ? ORDER BY submitted_at DESC',
      [req.userId]
    );
    const reports = [];
    for (const r of rows) {
      const report = formatReport(r);
      const [entries] = await db.query(
        'SELECT * FROM repair_entries WHERE report_id = ? ORDER BY date ASC', [r.id]
      );
      report.repairArchive = entries.map(e => ({
        date: e.date,
        technician: e.technician,
        description: e.description,
        partsReplaced: safeJson(e.parts_replaced, []),
        photos: safeJson(e.photos, []),
        cost: e.cost,
        isFinal: !!e.is_final,
      }));
      reports.push(report);
    }
    return res.json({ reports });
  } catch (err) {
    console.error('getReports:', err);
    return res.status(500).json({ error: 'حدث خطأ' });
  }
};

// ── Submit Report ──
exports.submitReport = async (req, res) => {
  try {
    const { carId, accidentDate, location, lat, lng, description, otherPartyInvolved, photoUrls } = req.body;
    if (!accidentDate || !location || !description) {
      return res.status(400).json({ error: 'البيانات الأساسية مطلوبة' });
    }
    const id = genId('rpt');
    await db.query(
      `INSERT INTO accident_reports
       (id, user_id, car_id, accident_date, location, lat, lng, description, photo_urls, other_party_involved)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [id, req.userId, carId || null, accidentDate, location, lat || null, lng || null,
       description, JSON.stringify(photoUrls || []), otherPartyInvolved ? 1 : 0]
    );
    // Auto-increment the car's repair usage counter for this month.
    if (carId) {
      await db.query(
        'UPDATE cars SET repairs_used_this_month = repairs_used_this_month + 1 WHERE id = ? AND user_id = ?',
        [carId, req.userId]
      );
    }
    const [rows] = await db.query('SELECT * FROM accident_reports WHERE id = ?', [id]);
    return res.status(201).json({ report: formatReport(rows[0]) });
  } catch (err) {
    console.error('submitReport:', err);
    return res.status(500).json({ error: 'حدث خطأ' });
  }
};

// ── Submit Repair Photos ──
exports.submitRepairPhotos = async (req, res) => {
  try {
    const { reportId } = req.params;
    const { photoUrls } = req.body;
    const [existing] = await db.query('SELECT repair_photo_urls FROM accident_reports WHERE id = ?', [reportId]);
    if (existing.length === 0) return res.status(404).json({ error: 'التقرير غير موجود' });
    const current = safeJson(existing[0].repair_photo_urls, []);
    const updated = [...current, ...(photoUrls || [])];
    await db.query('UPDATE accident_reports SET repair_photo_urls = ? WHERE id = ?',
      [JSON.stringify(updated), reportId]);
    return res.json({ success: true });
  } catch (err) {
    console.error('submitRepairPhotos:', err);
    return res.status(500).json({ error: 'حدث خطأ' });
  }
};

exports.formatReport = formatReport;
