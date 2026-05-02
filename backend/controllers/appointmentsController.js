const db = require('../config/database');
const { genId } = require('../utils/helpers');

function formatAppointment(a) {
  return {
    id: a.id,
    userId: a.user_id,
    reportId: a.report_id,
    scheduledDate: a.scheduled_date,
    timeSlot: a.time_slot,
    status: a.status,
    userNote: a.user_note,
    maintenanceNote: a.maintenance_note,
    branchName: a.branch_name,
    locationLat: a.location_lat,
    locationLng: a.location_lng,
    createdAt: a.created_at,
  };
}

// ── Get Appointments ──
exports.getAppointments = async (req, res) => {
  try {
    const [rows] = await db.query(
      'SELECT * FROM appointments WHERE user_id = ? ORDER BY scheduled_date DESC',
      [req.userId]
    );
    return res.json({ appointments: rows.map(formatAppointment) });
  } catch (err) {
    console.error('getAppointments:', err);
    return res.status(500).json({ error: 'حدث خطأ' });
  }
};

// ── Request Appointment Change ──
exports.requestChange = async (req, res) => {
  try {
    const { appointmentId } = req.params;
    const { note } = req.body;
    await db.query(
      `UPDATE appointments SET status = 'changeRequested', user_note = ? WHERE id = ? AND user_id = ?`,
      [note || '', appointmentId, req.userId]
    );
    return res.json({ success: true });
  } catch (err) {
    console.error('requestChange:', err);
    return res.status(500).json({ error: 'حدث خطأ' });
  }
};

exports.formatAppointment = formatAppointment;
