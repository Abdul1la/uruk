const db = require('../config/database');
const { genId } = require('../utils/helpers');

// ── Car Change Requests ──
function formatCCR(r) {
  const changes = typeof r.requested_changes === 'string'
    ? JSON.parse(r.requested_changes) : r.requested_changes;
  return {
    id: r.id,
    userId: r.user_id,
    type: r.type,
    requestedChanges: changes,
    status: r.status,
    submittedAt: r.submitted_at,
    reviewedAt: r.reviewed_at,
    reviewNote: r.review_note,
  };
}

exports.getCarChangeRequests = async (req, res) => {
  try {
    const [rows] = await db.query(
      'SELECT * FROM car_change_requests WHERE user_id = ? ORDER BY submitted_at DESC',
      [req.userId]
    );
    return res.json({ requests: rows.map(formatCCR) });
  } catch (err) {
    console.error('getCarChangeRequests:', err);
    return res.status(500).json({ error: 'حدث خطأ' });
  }
};

exports.submitCarChangeRequest = async (req, res) => {
  try {
    const { requestedChanges, type } = req.body;
    if (!requestedChanges) return res.status(400).json({ error: 'التغييرات مطلوبة' });
    const id = genId('ccr');
    await db.query(
      'INSERT INTO car_change_requests (id, user_id, type, requested_changes) VALUES (?, ?, ?, ?)',
      [id, req.userId, type || 'carChange', JSON.stringify(requestedChanges)]
    );
    const [rows] = await db.query('SELECT * FROM car_change_requests WHERE id = ?', [id]);
    return res.status(201).json({ request: formatCCR(rows[0]) });
  } catch (err) {
    console.error('submitCarChangeRequest:', err);
    return res.status(500).json({ error: 'حدث خطأ' });
  }
};

// ── Upgrade Requests ──
function formatUpgrade(r) {
  return {
    id: r.id,
    userId: r.user_id,
    carId: r.car_id,
    currentPlan: r.current_plan,
    currentPlanPriceIQD: r.current_plan_price_iqd,
    remainingMonths: r.remaining_months,
    creditIQD: r.credit_iqd,
    requestedPlan: r.requested_plan,
    requestedPlanPriceIQD: r.requested_plan_price_iqd,
    requestedMonths: r.requested_months,
    newCostIQD: r.new_cost_iqd,
    amountDueIQD: r.amount_due_iqd,
    proofImageUrl: r.proof_image_url,
    status: r.status,
    submittedAt: r.submitted_at,
    reviewedAt: r.reviewed_at,
    adminNote: r.admin_note,
  };
}

exports.getUpgradeRequests = async (req, res) => {
  try {
    const [rows] = await db.query(
      'SELECT * FROM upgrade_requests WHERE user_id = ? ORDER BY submitted_at DESC',
      [req.userId]
    );
    return res.json({ requests: rows.map(formatUpgrade) });
  } catch (err) {
    console.error('getUpgradeRequests:', err);
    return res.status(500).json({ error: 'حدث خطأ' });
  }
};

exports.submitUpgradeRequest = async (req, res) => {
  try {
    const { carId, currentPlan, currentPlanPriceIQD, remainingMonths, creditIQD,
            requestedPlan, requestedPlanPriceIQD, requestedMonths, newCostIQD, amountDueIQD,
            proofImageUrl } = req.body;
    const id = genId('upg');
    await db.query(
      `INSERT INTO upgrade_requests
       (id, user_id, car_id, current_plan, current_plan_price_iqd, remaining_months, credit_iqd,
        requested_plan, requested_plan_price_iqd, requested_months, new_cost_iqd, amount_due_iqd,
        proof_image_url)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [id, req.userId, carId, currentPlan, currentPlanPriceIQD, remainingMonths, creditIQD,
       requestedPlan, requestedPlanPriceIQD, requestedMonths, newCostIQD, amountDueIQD,
       proofImageUrl || null]
    );
    const [rows] = await db.query('SELECT * FROM upgrade_requests WHERE id = ?', [id]);
    return res.status(201).json({ request: formatUpgrade(rows[0]) });
  } catch (err) {
    console.error('submitUpgradeRequest:', err);
    return res.status(500).json({ error: 'حدث خطأ' });
  }
};
