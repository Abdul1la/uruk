const db = require('../config/database');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { genId, safeJson } = require('../utils/helpers');
const { formatUser, formatCar } = require('./authController');
const { formatReport } = require('./accidentsController');
const { formatAppointment } = require('./appointmentsController');
const { formatPayment } = require('./paymentsController');
const { formatNotification } = require('./notificationsController');

// ════════════════════════════════════════
// AUTH
// ════════════════════════════════════════

exports.login = async (req, res) => {
  try {
    let { email, password } = req.body || {};
    // Normalize inputs to avoid intermittent failures from autofill / keyboards:
    // - trim whitespace (autofill sometimes appends a trailing space)
    // - email is treated case-insensitive
    // - do NOT trim the password on the RIGHT to preserve intentional trailing spaces,
    //   only remove zero-width and non-printing chars that some mobile keyboards inject.
    if (typeof email === 'string') email = email.trim().toLowerCase();
    if (typeof password === 'string') {
      password = password.replace(/[\u200B-\u200D\uFEFF\u00A0]/g, '').trim();
    }
    if (!email || !password) return res.status(400).json({ error: 'Email and password required' });

    // Case-insensitive email lookup
    const [rows] = await db.query(
      'SELECT * FROM employees WHERE LOWER(email) = ? AND is_active = 1',
      [email]
    );
    if (rows.length === 0) return res.status(401).json({ error: 'Invalid credentials' });

    const emp = rows[0];
    const match = await bcrypt.compare(password, emp.password);
    if (!match) return res.status(401).json({ error: 'Invalid credentials' });

    const token = jwt.sign(
      { employeeId: emp.id, department: emp.department },
      process.env.ADMIN_JWT_SECRET,
      { expiresIn: process.env.ADMIN_JWT_EXPIRES_IN || '8h' }
    );

    return res.json({
      token,
      employee: {
        id: emp.id, fullName: emp.full_name, email: emp.email,
        phone: emp.phone, department: emp.department,
      },
    });
  } catch (err) {
    console.error('adminLogin:', err);
    return res.status(500).json({ error: 'Server error' });
  }
};

// ════════════════════════════════════════
// USERS MANAGEMENT
// ════════════════════════════════════════

exports.getUsers = async (req, res) => {
  try {
    const { status } = req.query;
    let q = 'SELECT * FROM users';
    const params = [];
    if (status) { q += ' WHERE status = ?'; params.push(status); }
    q += ' ORDER BY created_at DESC';
    const [rows] = await db.query(q, params);

    const users = [];
    for (const u of rows) {
      const [cars] = await db.query('SELECT * FROM cars WHERE user_id = ?', [u.id]);
      users.push(formatUser(u, cars));
    }
    return res.json({ users });
  } catch (err) {
    console.error('getUsers:', err);
    return res.status(500).json({ error: 'Server error' });
  }
};

exports.getUserDetail = async (req, res) => {
  try {
    const { userId } = req.params;
    const [rows] = await db.query('SELECT * FROM users WHERE id = ?', [userId]);
    if (rows.length === 0) return res.status(404).json({ error: 'User not found' });
    const [cars] = await db.query('SELECT * FROM cars WHERE user_id = ?', [userId]);
    return res.json({ user: formatUser(rows[0], cars) });
  } catch (err) {
    console.error('getUserDetail:', err);
    return res.status(500).json({ error: 'Server error' });
  }
};

exports.updateUserStatus = async (req, res) => {
  try {
    const { userId } = req.params;
    const { status } = req.body;
    const allowed = ['pending', 'approved', 'rejected', 'suspended'];
    if (!allowed.includes(status)) return res.status(400).json({ error: 'Invalid status' });

    // Rejection = free the phone for re-registration. Notify first (so any
    // active session catches it) then wipe the user + related data.
    if (status === 'rejected') {
      try {
        await db.query(
          'INSERT INTO notifications (id, user_id, title, body, type) VALUES (?, ?, ?, ?, ?)',
          [genId('ntf'), userId, 'تم رفض طلب حسابك',
           'تم رفض طلب إنشاء حسابك. يمكنك إعادة التسجيل إن رغبت.', 'general']
        );
      } catch (_) { /* ignore — notification is best-effort */ }

      // Mirror the re-registration cleanup used by authController.register
      await db.query('DELETE FROM notifications WHERE user_id = ?', [userId]).catch(() => {});
      await db.query('DELETE FROM cars WHERE user_id = ?', [userId]).catch(() => {});
      await db.query('DELETE FROM payments WHERE user_id = ?', [userId]).catch(() => {});
      await db.query('DELETE FROM car_change_requests WHERE user_id = ?', [userId]).catch(() => {});
      await db.query('DELETE FROM upgrade_requests WHERE user_id = ?', [userId]).catch(() => {});
      await db.query('DELETE FROM accident_reports WHERE user_id = ?', [userId]).catch(() => {});
      await db.query('DELETE FROM oil_change_bookings WHERE user_id = ?', [userId]).catch(() => {});
      await db.query('DELETE FROM appointments WHERE user_id = ?', [userId]).catch(() => {});
      await db.query('DELETE FROM users WHERE id = ?', [userId]);
      return res.json({ success: true, deleted: true });
    }

    await db.query('UPDATE users SET status = ? WHERE id = ?', [status, userId]);

    // Notification for approved / suspended (rejected is handled above)
    const titles = {
      approved: 'تمت الموافقة على حسابك',
      suspended: 'تم تعليق حسابك',
    };
    if (titles[status]) {
      await db.query(
        'INSERT INTO notifications (id, user_id, title, body, type) VALUES (?, ?, ?, ?, ?)',
        [genId('ntf'), userId, titles[status], titles[status], 'general']
      );
    }

    return res.json({ success: true });
  } catch (err) {
    console.error('updateUserStatus:', err);
    return res.status(500).json({ error: 'Server error' });
  }
};

// ════════════════════════════════════════
// REPORTS MANAGEMENT
// ════════════════════════════════════════

exports.getAllReports = async (req, res) => {
  try {
    const { status, from, to } = req.query;
    let q = `SELECT r.*, u.full_name as user_name, u.phone as user_phone
             FROM accident_reports r JOIN users u ON r.user_id = u.id`;
    const params = [];
    const where = [];
    if (status) { where.push('r.status = ?'); params.push(status); }
    if (from)   { where.push('DATE(r.submitted_at) >= ?'); params.push(from); }
    if (to)     { where.push('DATE(r.submitted_at) <= ?'); params.push(to); }
    if (where.length) q += ' WHERE ' + where.join(' AND ');
    q += ' ORDER BY r.submitted_at DESC';
    const [rows] = await db.query(q, params);

    const reports = [];
    for (const r of rows) {
      const report = formatReport(r);
      report.userName = r.user_name;
      report.userPhone = r.user_phone;
      // Get car desc
      if (r.car_id) {
        const [cars] = await db.query('SELECT * FROM cars WHERE id = ?', [r.car_id]);
        if (cars.length) report.carDesc = `${cars[0].make} ${cars[0].model} ${cars[0].year}`;
      }
      // Get repair entries
      const [entries] = await db.query('SELECT * FROM repair_entries WHERE report_id = ? ORDER BY date', [r.id]);
      report.repairArchive = entries.map(e => ({
        date: e.date, technician: e.technician, description: e.description,
        partsReplaced: safeJson(e.parts_replaced, []), photos: safeJson(e.photos, []),
        cost: e.cost, isFinal: !!e.is_final,
      }));
      reports.push(report);
    }
    return res.json({ reports });
  } catch (err) {
    console.error('getAllReports:', err);
    return res.status(500).json({ error: 'Server error' });
  }
};

const REPORT_STATUS_FLOW = {
  pending: ['underReview', 'rejected'],
  underReview: ['approved', 'rejected'],
  approved: ['inRepair', 'rejected'],
  inRepair: ['completed'],
  completed: [],
  rejected: [],
};

exports.updateReportStatus = async (req, res) => {
  try {
    const { reportId } = req.params;
    const { status, maintenanceNotes, rejectionReason } = req.body;
    const allowedStatuses = ['pending', 'underReview', 'approved', 'inRepair', 'completed', 'rejected'];

    // Load current report once
    const [cur] = await db.query('SELECT status FROM accident_reports WHERE id = ?', [reportId]);
    if (!cur.length) return res.status(404).json({ error: 'Report not found' });
    const currentStatus = cur[0].status;

    // Validate status transition only if a new status is provided AND differs from current
    if (status !== undefined && status !== null) {
      if (!allowedStatuses.includes(status)) {
        return res.status(400).json({ error: 'Invalid status' });
      }
      if (currentStatus !== status) {
        const allowedNext = REPORT_STATUS_FLOW[currentStatus] || [];
        if (!allowedNext.includes(status)) {
          return res.status(400).json({
            error: `Invalid transition from ${currentStatus} to ${status}`,
            allowedNext,
          });
        }
      }
    }

    const updates = [];
    const values = [];
    if (status !== undefined && status !== null) { updates.push('status = ?'); values.push(status); }
    if (maintenanceNotes !== undefined) { updates.push('maintenance_notes = ?'); values.push(maintenanceNotes); }
    if (rejectionReason !== undefined) { updates.push('rejection_reason = ?'); values.push(rejectionReason); }
    if (status === 'completed') { updates.push('completed_at = NOW()'); }
    if (!updates.length) return res.json({ success: true, noop: true });
    values.push(reportId);
    await db.query(`UPDATE accident_reports SET ${updates.join(', ')} WHERE id = ?`, values);

    // Notify user
    const [report] = await db.query('SELECT user_id FROM accident_reports WHERE id = ?', [reportId]);
    if (report.length) {
      const statusLabels = {
        underReview: 'تقريرك قيد المراجعة', approved: 'تمت الموافقة على تقريرك',
        inRepair: 'سيارتك في الصيانة', completed: 'اكتملت صيانة سيارتك',
        rejected: 'تم رفض تقريرك',
      };
      if (statusLabels[status]) {
        await db.query(
          'INSERT INTO notifications (id, user_id, title, body, type, action_route) VALUES (?, ?, ?, ?, ?, ?)',
          [genId('ntf'), report[0].user_id, statusLabels[status], statusLabels[status], 'report', `/accidents/${reportId}`]
        );
      }
    }
    return res.json({ success: true });
  } catch (err) {
    console.error('updateReportStatus:', err);
    return res.status(500).json({ error: 'Server error' });
  }
};

exports.addRepairEntry = async (req, res) => {
  try {
    const { reportId } = req.params;
    const { date, technician, description, partsReplaced, photos, cost, isFinal } = req.body;
    const id = genId('rep');
    // MySQL DATETIME won't accept the raw ISO-8601 string ("2026-04-14T…Z").
    // Parse it into a JS Date so the driver serializes to "YYYY-MM-DD HH:MM:SS".
    // Fall back to "now" if the payload is missing / invalid.
    let entryDate = new Date(date);
    if (Number.isNaN(entryDate.getTime())) entryDate = new Date();
    await db.query(
      `INSERT INTO repair_entries (id, report_id, date, technician, description, parts_replaced, photos, cost, is_final)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [id, reportId, entryDate, technician, description,
       JSON.stringify(partsReplaced || []), JSON.stringify(photos || []),
       cost || 0, isFinal ? 1 : 0]
    );
    return res.status(201).json({ success: true, entryId: id });
  } catch (err) {
    console.error('addRepairEntry:', err);
    return res.status(500).json({ error: 'Server error' });
  }
};

// ════════════════════════════════════════
// APPOINTMENTS MANAGEMENT
// ════════════════════════════════════════

exports.getAllAppointments = async (req, res) => {
  try {
    const { from, to, status } = req.query;
    let q = `SELECT a.*, u.full_name as user_name, u.phone as user_phone
             FROM appointments a JOIN users u ON a.user_id = u.id`;
    const params = [];
    const where = [];
    if (status) { where.push('a.status = ?'); params.push(status); }
    if (from)   { where.push('a.scheduled_date >= ?'); params.push(from); }
    if (to)     { where.push('a.scheduled_date <= ?'); params.push(to); }
    if (where.length) q += ' WHERE ' + where.join(' AND ');
    q += ' ORDER BY a.scheduled_date DESC';
    const [rows] = await db.query(q, params);
    return res.json({
      appointments: rows.map(a => ({
        ...formatAppointment(a), userName: a.user_name, userPhone: a.user_phone,
      })),
    });
  } catch (err) {
    console.error('getAllAppointments:', err);
    return res.status(500).json({ error: 'Server error' });
  }
};

exports.createAppointment = async (req, res) => {
  try {
    const { userId, reportId, scheduledDate, timeSlot, branchName, locationLat, locationLng, maintenanceNote } = req.body;
    const id = genId('apt');
    await db.query(
      `INSERT INTO appointments (id, user_id, report_id, scheduled_date, time_slot, branch_name, location_lat, location_lng, maintenance_note)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [id, userId, reportId || null, scheduledDate, timeSlot, branchName || null,
       locationLat || null, locationLng || null, maintenanceNote || null]
    );
    // Link to report if provided
    if (reportId) {
      await db.query('UPDATE accident_reports SET appointment_id = ? WHERE id = ?', [id, reportId]);
    }
    // Notify user
    await db.query(
      'INSERT INTO notifications (id, user_id, title, body, type, action_route) VALUES (?, ?, ?, ?, ?, ?)',
      [genId('ntf'), userId, 'تم تحديد موعد لك', `موعدك بتاريخ ${scheduledDate} - ${timeSlot}`, 'appointment', '/appointments']
    );
    return res.status(201).json({ success: true, appointmentId: id });
  } catch (err) {
    console.error('createAppointment:', err);
    return res.status(500).json({ error: 'Server error' });
  }
};

const APT_STATUS_FLOW = {
  scheduled: ['confirmed', 'cancelled', 'changeRequested'],
  changeRequested: ['confirmed', 'scheduled', 'cancelled'],
  confirmed: ['completed', 'cancelled'],
  completed: [],
  cancelled: [],
};

exports.updateAppointment = async (req, res) => {
  try {
    const { appointmentId } = req.params;
    const { status, maintenanceNote, scheduledDate, timeSlot, branchName, locationLat, locationLng } = req.body;
    if (status) {
      const allowed = ['scheduled', 'changeRequested', 'confirmed', 'completed', 'cancelled'];
      if (!allowed.includes(status)) return res.status(400).json({ error: 'Invalid status' });
      const [cur] = await db.query('SELECT status FROM appointments WHERE id = ?', [appointmentId]);
      if (!cur.length) return res.status(404).json({ error: 'Appointment not found' });
      const currentStatus = cur[0].status;
      const allowedNext = APT_STATUS_FLOW[currentStatus] || [];
      if (currentStatus !== status && !allowedNext.includes(status)) {
        return res.status(400).json({
          error: `Invalid transition from ${currentStatus} to ${status}`,
          allowedNext,
        });
      }
    }
    const updates = [];
    const values = [];
    if (status) { updates.push('status = ?'); values.push(status); }
    if (maintenanceNote !== undefined) { updates.push('maintenance_note = ?'); values.push(maintenanceNote); }
    if (scheduledDate) { updates.push('scheduled_date = ?'); values.push(scheduledDate); }
    if (timeSlot) { updates.push('time_slot = ?'); values.push(timeSlot); }
    if (branchName) { updates.push('branch_name = ?'); values.push(branchName); }
    if (locationLat) { updates.push('location_lat = ?'); values.push(locationLat); }
    if (locationLng) { updates.push('location_lng = ?'); values.push(locationLng); }
    if (updates.length === 0) return res.status(400).json({ error: 'No updates' });
    values.push(appointmentId);
    await db.query(`UPDATE appointments SET ${updates.join(', ')} WHERE id = ?`, values);
    return res.json({ success: true });
  } catch (err) {
    console.error('updateAppointment:', err);
    return res.status(500).json({ error: 'Server error' });
  }
};

// ════════════════════════════════════════
// PAYMENTS MANAGEMENT
// ════════════════════════════════════════

exports.getAllPayments = async (req, res) => {
  try {
    const { status, from, to } = req.query;
    let q = `SELECT p.*, u.full_name as user_name FROM payments p JOIN users u ON p.user_id = u.id`;
    const params = [];
    const where = [];
    if (status) { where.push('p.status = ?'); params.push(status); }
    if (from)   { where.push('p.due_date >= ?'); params.push(from); }
    if (to)     { where.push('p.due_date <= ?'); params.push(to); }
    if (where.length) q += ' WHERE ' + where.join(' AND ');
    q += ' ORDER BY p.due_date DESC';
    const [rows] = await db.query(q, params);
    return res.json({
      payments: rows.map(p => ({ ...formatPayment(p), userName: p.user_name })),
    });
  } catch (err) {
    console.error('getAllPayments:', err);
    return res.status(500).json({ error: 'Server error' });
  }
};

exports.createPayment = async (req, res) => {
  try {
    const { userId, carId, carDesc, amountIQD, dueDate, month } = req.body;
    const id = genId('pay');
    await db.query(
      `INSERT INTO payments (id, user_id, car_id, car_desc, amount_iqd, due_date, month)
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [id, userId, carId || null, carDesc || null, amountIQD, dueDate, month || null]
    );
    // Notify user
    await db.query(
      'INSERT INTO notifications (id, user_id, title, body, type, action_route) VALUES (?, ?, ?, ?, ?, ?)',
      [genId('ntf'), userId, 'دفعة جديدة مستحقة', `مبلغ ${amountIQD.toLocaleString()} د.ع مستحق بتاريخ ${dueDate}`, 'payment', '/payment']
    );
    return res.status(201).json({ success: true, paymentId: id });
  } catch (err) {
    console.error('createPayment:', err);
    return res.status(500).json({ error: 'Server error' });
  }
};

exports.updatePaymentStatus = async (req, res) => {
  try {
    const { paymentId } = req.params;
    const { status } = req.body;
    const allowed = ['paid', 'unpaid', 'overdue'];
    if (!allowed.includes(status)) return res.status(400).json({ error: 'Invalid status' });
    const setPaid = status === 'paid' ? ', paid_date = CURDATE()' : '';
    await db.query(`UPDATE payments SET status = ?${setPaid} WHERE id = ?`, [status, paymentId]);
    // Notify user on paid
    if (status === 'paid') {
      const [p] = await db.query('SELECT user_id, amount_iqd, month FROM payments WHERE id = ?', [paymentId]);
      if (p.length) {
        await db.query(
          'INSERT INTO notifications (id, user_id, title, body, type) VALUES (?, ?, ?, ?, ?)',
          [genId('ntf'), p[0].user_id, 'تم تأكيد دفعتك', `تم تأكيد دفعة ${p[0].month || ''}`, 'payment']
        );
      }
    }
    return res.json({ success: true });
  } catch (err) {
    console.error('updatePaymentStatus:', err);
    return res.status(500).json({ error: 'Server error' });
  }
};

// ════════════════════════════════════════
// OIL CHANGES
// ════════════════════════════════════════

exports.getAllOilChanges = async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT o.*, u.full_name as user_name, c.make, c.model, c.year
       FROM oil_changes o JOIN users u ON o.user_id = u.id LEFT JOIN cars c ON o.car_id = c.id
       ORDER BY o.created_at DESC`
    );
    return res.json({
      bookings: rows.map(o => ({
        id: o.id, userId: o.user_id, userName: o.user_name,
        carId: o.car_id, carDesc: o.make ? `${o.make} ${o.model} ${o.year}` : null,
        scheduledDate: o.scheduled_date, timeSlot: o.time_slot, branchName: o.branch_name,
        status: o.status, notes: o.notes, priceIQD: o.price_iqd, createdAt: o.created_at,
      })),
    });
  } catch (err) {
    console.error('getAllOilChanges:', err);
    return res.status(500).json({ error: 'Server error' });
  }
};

const OIL_STATUS_FLOW = {
  pending: ['confirmed', 'cancelled'],
  confirmed: ['completed', 'cancelled'],
  completed: [],
  cancelled: [],
};

exports.updateOilChange = async (req, res) => {
  try {
    const { oilId } = req.params;
    const { status, scheduledDate, timeSlot, branchName, locationLat, locationLng } = req.body;
    if (status) {
      const allowed = ['pending', 'confirmed', 'completed', 'cancelled'];
      if (!allowed.includes(status)) return res.status(400).json({ error: 'Invalid status' });
      const [cur] = await db.query('SELECT status FROM oil_changes WHERE id = ?', [oilId]);
      if (!cur.length) return res.status(404).json({ error: 'Oil change not found' });
      const currentStatus = cur[0].status;
      const allowedNext = OIL_STATUS_FLOW[currentStatus] || [];
      if (currentStatus !== status && !allowedNext.includes(status)) {
        return res.status(400).json({
          error: `Invalid transition from ${currentStatus} to ${status}`,
          allowedNext,
        });
      }
    }
    const updates = [];
    const values = [];
    if (status) { updates.push('status = ?'); values.push(status); }
    if (scheduledDate) { updates.push('scheduled_date = ?'); values.push(scheduledDate); }
    if (timeSlot) { updates.push('time_slot = ?'); values.push(timeSlot); }
    if (branchName) { updates.push('branch_name = ?'); values.push(branchName); }
    if (locationLat) { updates.push('location_lat = ?'); values.push(locationLat); }
    if (locationLng) { updates.push('location_lng = ?'); values.push(locationLng); }
    if (updates.length === 0) return res.status(400).json({ error: 'No updates' });
    values.push(oilId);
    await db.query(`UPDATE oil_changes SET ${updates.join(', ')} WHERE id = ?`, values);
    return res.json({ success: true });
  } catch (err) {
    console.error('updateOilChange:', err);
    return res.status(500).json({ error: 'Server error' });
  }
};

// ════════════════════════════════════════
// REQUESTS (Car Change + Upgrade)
// ════════════════════════════════════════

exports.getAllRequests = async (req, res) => {
  try {
    const [ccrs] = await db.query(
      `SELECT r.*, u.full_name as user_name FROM car_change_requests r JOIN users u ON r.user_id = u.id ORDER BY r.submitted_at DESC`
    );
    const [upgrades] = await db.query(
      `SELECT r.*, u.full_name as user_name FROM upgrade_requests r JOIN users u ON r.user_id = u.id ORDER BY r.submitted_at DESC`
    );
    return res.json({
      carChangeRequests: ccrs.map(r => {
        const changes = safeJson(r.requested_changes, {});
        return {
          id: r.id, userId: r.user_id, userName: r.user_name, type: r.type,
          requestedChanges: changes, status: r.status, submittedAt: r.submitted_at,
          reviewedAt: r.reviewed_at, reviewNote: r.review_note,
        };
      }),
      upgradeRequests: upgrades.map(r => ({
        id: r.id, userId: r.user_id, userName: r.user_name, carId: r.car_id,
        currentPlan: r.current_plan, currentPlanPriceIQD: r.current_plan_price_iqd,
        remainingMonths: r.remaining_months, creditIQD: r.credit_iqd,
        requestedPlan: r.requested_plan, requestedPlanPriceIQD: r.requested_plan_price_iqd,
        requestedMonths: r.requested_months, newCostIQD: r.new_cost_iqd,
        amountDueIQD: r.amount_due_iqd,
        proofImageUrl: r.proof_image_url,
        status: r.status,
        submittedAt: r.submitted_at, reviewedAt: r.reviewed_at, adminNote: r.admin_note,
      })),
    });
  } catch (err) {
    console.error('getAllRequests:', err);
    return res.status(500).json({ error: 'Server error' });
  }
};

exports.reviewCarChangeRequest = async (req, res) => {
  try {
    const { requestId } = req.params;
    const { status, reviewNote } = req.body;

    // 1) Mark the request as reviewed
    await db.query(
      'UPDATE car_change_requests SET status = ?, review_note = ?, reviewed_at = NOW() WHERE id = ?',
      [status, reviewNote || null, requestId]
    );

    // 2) Load the request so we can apply changes / notify the user
    const [reqRows] = await db.query(
      'SELECT * FROM car_change_requests WHERE id = ?',
      [requestId]
    );
    if (!reqRows.length) {
      return res.status(404).json({ error: 'الطلب غير موجود' });
    }
    const reqRow = reqRows[0];

    // 3) Apply the requested changes to the underlying table on approval.
    //    Without this, the admin approves the request but the user never sees
    //    their data update.
    if (status === 'approved') {
      let changes = reqRow.requested_changes;
      if (typeof changes === 'string') {
        try { changes = JSON.parse(changes); } catch (_) { changes = {}; }
      }
      changes = changes || {};

      if (reqRow.type === 'profileEdit') {
        // Map Flutter camelCase → DB snake_case for the users table
        const COL_MAP = {
          fullName: 'full_name',
          full_name: 'full_name',
          phone: 'phone',
          email: 'email',
        };
        const sets = [];
        const vals = [];
        for (const k of Object.keys(changes)) {
          const col = COL_MAP[k];
          if (col) { sets.push(`${col} = ?`); vals.push(changes[k]); }
        }
        if (sets.length) {
          vals.push(reqRow.user_id);
          await db.query(
            `UPDATE users SET ${sets.join(', ')} WHERE id = ?`,
            vals
          );
        }
      } else {
        // carChange — each user has a single car (user.car), so match by user_id
        const COL_MAP = {
          make: 'make',
          model: 'model',
          year: 'year',
          color: 'color',
          plateNumber: 'plate_number',
          plate_number: 'plate_number',
          imageUrl: 'image_url',
          image_url: 'image_url',
        };
        const sets = [];
        const vals = [];
        for (const k of Object.keys(changes)) {
          const col = COL_MAP[k];
          if (col) { sets.push(`${col} = ?`); vals.push(changes[k]); }
        }
        if (sets.length) {
          vals.push(reqRow.user_id);
          await db.query(
            `UPDATE cars SET ${sets.join(', ')} WHERE user_id = ?`,
            vals
          );
        }
      }
    }

    // 4) Notify the user of the decision
    const msg = status === 'approved' ? 'تمت الموافقة على طلب التعديل' : 'تم رفض طلب التعديل';
    await db.query(
      'INSERT INTO notifications (id, user_id, title, body, type) VALUES (?, ?, ?, ?, ?)',
      [genId('ntf'), reqRow.user_id, msg, msg, 'general']
    );

    return res.json({ success: true });
  } catch (err) {
    console.error('reviewCCR:', err);
    return res.status(500).json({ error: 'Server error' });
  }
};

exports.reviewUpgradeRequest = async (req, res) => {
  try {
    const { requestId } = req.params;
    const { status, adminNote } = req.body;
    await db.query(
      'UPDATE upgrade_requests SET status = ?, admin_note = ?, reviewed_at = NOW() WHERE id = ?',
      [status, adminNote || null, requestId]
    );
    // If approved, activate the new plan on the car.
    if (status === 'approved') {
      const [upg] = await db.query('SELECT * FROM upgrade_requests WHERE id = ?', [requestId]);
      if (upg.length) {
        const u = upg[0];
        const expiry = new Date();
        expiry.setDate(expiry.getDate() + 30 * u.requested_months);

        // Look up how many repairs/month the plan gives for the selected payment tier.
        // The tier table lives in subscription_plans.repair_tiers as a JSON array of
        // `{months, repairsPerMonth}`. Fall back to the longest-period tier that is
        // <= requested_months (so 1→shortest, 12→longest), and to 0 if nothing matches.
        let repairsAllowed = 0;
        const [plans] = await db.query(
          'SELECT repair_tiers FROM subscription_plans WHERE type = ?',
          [u.requested_plan]
        );
        if (plans.length) {
          const tiers = safeJson(plans[0].repair_tiers, []);
          if (Array.isArray(tiers) && tiers.length) {
            // Exact match first
            const exact = tiers.find(t => Number(t.months) === Number(u.requested_months));
            if (exact) {
              repairsAllowed = Number(exact.repairsPerMonth) || 0;
            } else {
              // Otherwise the largest tier whose months <= requested_months
              const sorted = [...tiers].sort((a, b) => Number(a.months) - Number(b.months));
              const match = sorted.reverse().find(t => Number(t.months) <= Number(u.requested_months));
              if (match) repairsAllowed = Number(match.repairsPerMonth) || 0;
            }
          }
        }

        await db.query(
          `UPDATE cars SET subscription = ?, subscription_start = NOW(), subscription_expiry = ?, payment_months = ?,
           repairs_allowed_per_month = ?, repairs_used_this_month = 0 WHERE id = ?`,
          [u.requested_plan, expiry, u.requested_months, repairsAllowed, u.car_id]
        );
      }
    }
    // Notify
    const [r] = await db.query('SELECT user_id FROM upgrade_requests WHERE id = ?', [requestId]);
    if (r.length) {
      const msg = status === 'approved' ? 'تمت الموافقة على طلب الترقية' : 'تم رفض طلب الترقية';
      await db.query(
        'INSERT INTO notifications (id, user_id, title, body, type) VALUES (?, ?, ?, ?, ?)',
        [genId('ntf'), r[0].user_id, msg, msg, 'subscription']
      );
    }
    return res.json({ success: true });
  } catch (err) {
    console.error('reviewUpgrade:', err);
    return res.status(500).json({ error: 'Server error' });
  }
};

// ════════════════════════════════════════
// NOTIFICATIONS (admin send)
// ════════════════════════════════════════

exports.sendNotification = async (req, res) => {
  try {
    const { userId, title, body, type, actionRoute } = req.body;
    if (!title || !body) return res.status(400).json({ error: 'Title and body required' });
    const id = genId('ntf');
    await db.query(
      'INSERT INTO notifications (id, user_id, title, body, type, action_route) VALUES (?, ?, ?, ?, ?, ?)',
      [id, userId || 'all', title, body, type || 'general', actionRoute || null]
    );
    return res.status(201).json({ success: true, notificationId: id });
  } catch (err) {
    console.error('sendNotification:', err);
    return res.status(500).json({ error: 'Server error' });
  }
};

exports.getAllNotifications = async (req, res) => {
  try {
    const [rows] = await db.query('SELECT * FROM notifications ORDER BY created_at DESC LIMIT 200');
    return res.json({ notifications: rows.map(formatNotification) });
  } catch (err) {
    console.error('getAllNotifications:', err);
    return res.status(500).json({ error: 'Server error' });
  }
};

// ════════════════════════════════════════
// EMPLOYEES
// ════════════════════════════════════════

exports.getEmployees = async (req, res) => {
  try {
    const [rows] = await db.query('SELECT id, full_name, email, phone, department, is_active, created_at FROM employees ORDER BY created_at DESC');
    return res.json({
      employees: rows.map(e => ({
        id: e.id, fullName: e.full_name, email: e.email, phone: e.phone,
        department: e.department, isActive: !!e.is_active, createdAt: e.created_at,
      })),
    });
  } catch (err) {
    console.error('getEmployees:', err);
    return res.status(500).json({ error: 'Server error' });
  }
};

exports.createEmployee = async (req, res) => {
  try {
    const { fullName, email, phone, password, department } = req.body;
    if (!fullName || !email || !password) return res.status(400).json({ error: 'Name, email, password required' });
    const id = genId('emp');
    const hash = await bcrypt.hash(password, 10);
    await db.query(
      'INSERT INTO employees (id, full_name, email, phone, password, department) VALUES (?, ?, ?, ?, ?, ?)',
      [id, fullName, email, phone || null, hash, department || 'administration']
    );
    return res.status(201).json({ success: true, employeeId: id });
  } catch (err) {
    console.error('createEmployee:', err);
    if (err.code === 'ER_DUP_ENTRY') return res.status(409).json({ error: 'Email already exists' });
    return res.status(500).json({ error: 'Server error' });
  }
};

exports.updateEmployee = async (req, res) => {
  try {
    const { empId } = req.params;
    const { fullName, phone, department, isActive, password } = req.body;
    const updates = [];
    const values = [];
    if (fullName) { updates.push('full_name = ?'); values.push(fullName); }
    if (phone !== undefined) { updates.push('phone = ?'); values.push(phone); }
    if (department) { updates.push('department = ?'); values.push(department); }
    if (isActive !== undefined) { updates.push('is_active = ?'); values.push(isActive ? 1 : 0); }
    if (password) { updates.push('password = ?'); values.push(await bcrypt.hash(password, 10)); }
    if (updates.length === 0) return res.status(400).json({ error: 'No updates' });
    values.push(empId);
    await db.query(`UPDATE employees SET ${updates.join(', ')} WHERE id = ?`, values);
    return res.json({ success: true });
  } catch (err) {
    console.error('updateEmployee:', err);
    return res.status(500).json({ error: 'Server error' });
  }
};

// ════════════════════════════════════════
// SETTINGS (config updates)
// ════════════════════════════════════════

// Only these config keys can be written/read through the admin config API.
// Everything else is out-of-band (schema migrations, .env, etc).
const ALLOWED_CONFIG_KEYS = new Set([
  'support_info',
  'payment_accounts',
  'privacy_policy',
  'available_cities',
  'onboarding_pages',
]);

exports.updateConfig = async (req, res) => {
  try {
    const { key } = req.params;
    if (!ALLOWED_CONFIG_KEYS.has(key)) {
      return res.status(400).json({ error: 'Invalid config key' });
    }
    const { value } = req.body;
    await db.query(
      'INSERT INTO app_config (config_key, config_value) VALUES (?, ?) ON DUPLICATE KEY UPDATE config_value = ?',
      [key, JSON.stringify(value), JSON.stringify(value)]
    );
    return res.json({ success: true });
  } catch (err) {
    console.error('updateConfig:', err);
    return res.status(500).json({ error: 'Server error' });
  }
};

exports.getConfig = async (req, res) => {
  try {
    const { key } = req.params;
    if (!ALLOWED_CONFIG_KEYS.has(key)) {
      return res.status(400).json({ error: 'Invalid config key' });
    }
    const [rows] = await db.query('SELECT config_value FROM app_config WHERE config_key = ?', [key]);
    if (rows.length === 0) return res.json({ value: null });
    return res.json({ value: safeJson(rows[0].config_value) });
  } catch (err) {
    console.error('getConfig:', err);
    return res.status(500).json({ error: 'Server error' });
  }
};

// ── Branches CRUD ──
exports.createBranch = async (req, res) => {
  try {
    const { name, lat, lng, address, phone } = req.body;
    const id = genId('brn');
    await db.query(
      'INSERT INTO branches (id, name, lat, lng, address, phone) VALUES (?, ?, ?, ?, ?, ?)',
      [id, name, lat, lng, address || null, phone || null]
    );
    return res.status(201).json({ success: true, branchId: id });
  } catch (err) {
    console.error('createBranch:', err);
    return res.status(500).json({ error: 'Server error' });
  }
};

exports.updateBranch = async (req, res) => {
  try {
    const { branchId } = req.params;
    const { name, lat, lng, address, phone, isActive } = req.body;
    const updates = [];
    const values = [];
    if (name) { updates.push('name = ?'); values.push(name); }
    if (lat !== undefined) { updates.push('lat = ?'); values.push(lat); }
    if (lng !== undefined) { updates.push('lng = ?'); values.push(lng); }
    if (address !== undefined) { updates.push('address = ?'); values.push(address); }
    if (phone !== undefined) { updates.push('phone = ?'); values.push(phone); }
    if (isActive !== undefined) { updates.push('is_active = ?'); values.push(isActive ? 1 : 0); }
    if (updates.length === 0) return res.status(400).json({ error: 'No updates' });
    values.push(branchId);
    await db.query(`UPDATE branches SET ${updates.join(', ')} WHERE id = ?`, values);
    return res.json({ success: true });
  } catch (err) {
    console.error('updateBranch:', err);
    return res.status(500).json({ error: 'Server error' });
  }
};

exports.deleteBranch = async (req, res) => {
  try {
    await db.query('DELETE FROM branches WHERE id = ?', [req.params.branchId]);
    return res.json({ success: true });
  } catch (err) {
    console.error('deleteBranch:', err);
    return res.status(500).json({ error: 'Server error' });
  }
};

// ── Banners CRUD ──
exports.getAllBanners = async (req, res) => {
  try {
    const [rows] = await db.query('SELECT * FROM ad_banners ORDER BY sort_order, id');
    return res.json({
      banners: rows.map(b => ({
        id: b.id, title: b.title, subtitle: b.subtitle,
        bgColor: b.bg_color, textColor: b.text_color, icon: b.icon,
        actionLabel: b.action_label, actionRoute: b.action_route,
        mediaUrl: b.media_url, mediaType: b.media_type || 'none',
        isActive: !!b.is_active, sortOrder: b.sort_order,
      })),
    });
  } catch (err) {
    console.error('getAllBanners:', err);
    return res.status(500).json({ error: 'Server error' });
  }
};

exports.getAllBranches = async (req, res) => {
  try {
    const [rows] = await db.query('SELECT * FROM branches ORDER BY name');
    return res.json({
      branches: rows.map(b => ({
        id: b.id, name: b.name, address: b.address, phone: b.phone,
        lat: b.lat, lng: b.lng, isActive: !!b.is_active,
      })),
    });
  } catch (err) {
    console.error('getAllBranches:', err);
    return res.status(500).json({ error: 'Server error' });
  }
};

exports.getAllPlans = async (req, res) => {
  try {
    const [rows] = await db.query('SELECT * FROM subscription_plans ORDER BY price_iqd');
    return res.json({
      plans: rows.map(p => ({
        id: p.id, type: p.type || p.id, name: p.name, priceIQD: p.price_iqd,
        coverageNote: p.coverage_note, coveredParts: safeJson(p.covered_parts, []),
        repairTiers: safeJson(p.repair_tiers, []), isPopular: !!p.is_popular,
      })),
    });
  } catch (err) {
    console.error('getAllPlans:', err);
    return res.status(500).json({ error: 'Server error' });
  }
};

exports.createBanner = async (req, res) => {
  try {
    const { title, subtitle, bgColor, textColor, icon, actionLabel, actionRoute,
            mediaUrl, mediaType, isActive, sortOrder } = req.body;
    if (!title) return res.status(400).json({ error: 'Title required' });
    const validMedia = ['none', 'image', 'video'];
    const mt = validMedia.includes(mediaType) ? mediaType : (mediaUrl ? 'image' : 'none');
    const id = genId('bnr');
    await db.query(
      `INSERT INTO ad_banners (id, title, subtitle, bg_color, text_color, icon,
        action_label, action_route, media_url, media_type, is_active, sort_order)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [id, title, subtitle || null, bgColor || '#1A3A8F', textColor || '#FFFFFF',
       icon || 'star', actionLabel || null, actionRoute || null,
       mediaUrl || null, mt,
       isActive === false ? 0 : 1, Number.isInteger(sortOrder) ? sortOrder : 0]
    );
    return res.status(201).json({ success: true, bannerId: id });
  } catch (err) {
    console.error('createBanner:', err);
    return res.status(500).json({ error: 'Server error' });
  }
};

exports.updateBanner = async (req, res) => {
  try {
    const { bannerId } = req.params;
    const { title, subtitle, bgColor, textColor, icon, actionLabel, actionRoute,
            mediaUrl, mediaType, isActive, sortOrder } = req.body;
    const updates = [];
    const values = [];
    if (title) { updates.push('title = ?'); values.push(title); }
    if (subtitle !== undefined) { updates.push('subtitle = ?'); values.push(subtitle); }
    if (bgColor) { updates.push('bg_color = ?'); values.push(bgColor); }
    if (textColor) { updates.push('text_color = ?'); values.push(textColor); }
    if (icon) { updates.push('icon = ?'); values.push(icon); }
    if (actionLabel !== undefined) { updates.push('action_label = ?'); values.push(actionLabel); }
    if (actionRoute !== undefined) { updates.push('action_route = ?'); values.push(actionRoute); }
    if (mediaUrl !== undefined) { updates.push('media_url = ?'); values.push(mediaUrl || null); }
    if (mediaType !== undefined) {
      const validMedia = ['none', 'image', 'video'];
      updates.push('media_type = ?');
      values.push(validMedia.includes(mediaType) ? mediaType : 'none');
    }
    if (isActive !== undefined) { updates.push('is_active = ?'); values.push(isActive ? 1 : 0); }
    if (sortOrder !== undefined) { updates.push('sort_order = ?'); values.push(sortOrder); }
    if (updates.length === 0) return res.status(400).json({ error: 'No updates' });
    values.push(bannerId);
    await db.query(`UPDATE ad_banners SET ${updates.join(', ')} WHERE id = ?`, values);
    return res.json({ success: true });
  } catch (err) {
    console.error('updateBanner:', err);
    return res.status(500).json({ error: 'Server error' });
  }
};

exports.deleteBanner = async (req, res) => {
  try {
    await db.query('DELETE FROM ad_banners WHERE id = ?', [req.params.bannerId]);
    return res.json({ success: true });
  } catch (err) {
    console.error('deleteBanner:', err);
    return res.status(500).json({ error: 'Server error' });
  }
};

// ── Plans CRUD ──
exports.updatePlan = async (req, res) => {
  try {
    const { planId } = req.params;
    const { name, priceIQD, coverageNote, coveredParts, repairTiers, isPopular } = req.body;
    const updates = [];
    const values = [];
    if (name) { updates.push('name = ?'); values.push(name); }
    if (priceIQD !== undefined) { updates.push('price_iqd = ?'); values.push(priceIQD); }
    if (coverageNote) { updates.push('coverage_note = ?'); values.push(coverageNote); }
    if (coveredParts) { updates.push('covered_parts = ?'); values.push(JSON.stringify(coveredParts)); }
    if (repairTiers) { updates.push('repair_tiers = ?'); values.push(JSON.stringify(repairTiers)); }
    if (isPopular !== undefined) { updates.push('is_popular = ?'); values.push(isPopular ? 1 : 0); }
    if (updates.length === 0) return res.status(400).json({ error: 'No updates' });
    values.push(planId);
    await db.query(`UPDATE subscription_plans SET ${updates.join(', ')} WHERE id = ?`, values);
    return res.json({ success: true });
  } catch (err) {
    console.error('updatePlan:', err);
    return res.status(500).json({ error: 'Server error' });
  }
};

// ── Dashboard Stats ──
exports.getDashboardStats = async (req, res) => {
  try {
    const [[{ pendingUsers }]] = await db.query("SELECT COUNT(*) as pendingUsers FROM users WHERE status = 'pending'");
    const [[{ totalUsers }]] = await db.query("SELECT COUNT(*) as totalUsers FROM users");
    const [[{ pendingReports }]] = await db.query("SELECT COUNT(*) as pendingReports FROM accident_reports WHERE status = 'pending'");
    const [[{ inRepair }]] = await db.query("SELECT COUNT(*) as inRepair FROM accident_reports WHERE status = 'inRepair'");
    const [[{ overduePayments }]] = await db.query("SELECT COUNT(*) as overduePayments FROM payments WHERE status = 'overdue'");
    const [[{ unpaidPayments }]] = await db.query("SELECT COUNT(*) as unpaidPayments FROM payments WHERE status = 'unpaid'");
    const [[{ pendingOil }]] = await db.query("SELECT COUNT(*) as pendingOil FROM oil_changes WHERE status = 'pending'");
    const [[{ pendingCCR }]] = await db.query("SELECT COUNT(*) as pendingCCR FROM car_change_requests WHERE status = 'pending'");
    const [[{ pendingUpgrades }]] = await db.query("SELECT COUNT(*) as pendingUpgrades FROM upgrade_requests WHERE status = 'pending'");

    return res.json({
      pendingUsers, totalUsers, pendingReports, inRepair,
      overduePayments, unpaidPayments, pendingOil,
      pendingRequests: pendingCCR + pendingUpgrades,
    });
  } catch (err) {
    console.error('getDashboardStats:', err);
    return res.status(500).json({ error: 'Server error' });
  }
};
