const db = require('../config/database');
const { genId } = require('../utils/helpers');

function formatPayment(p) {
  return {
    id: p.id,
    userId: p.user_id,
    carId: p.car_id,
    carDesc: p.car_desc,
    amountIQD: p.amount_iqd,
    dueDate: p.due_date,
    paidDate: p.paid_date,
    status: p.status,
    method: p.method,
    month: p.month,
    proofImageUrl: p.proof_image_url,
  };
}

// ── Get Payment History ──
exports.getPayments = async (req, res) => {
  try {
    const [rows] = await db.query(
      'SELECT * FROM payments WHERE user_id = ? ORDER BY due_date DESC',
      [req.userId]
    );
    return res.json({ payments: rows.map(formatPayment) });
  } catch (err) {
    console.error('getPayments:', err);
    return res.status(500).json({ error: 'حدث خطأ' });
  }
};

// ── Mark Payment Made ──
// A user uploads a payment proof and marks their own payment as paid. The
// finance team still needs to verify via the admin panel, but the record
// flips to 'paid' so the user isn't billed twice. Idempotent: a second call
// on an already-paid payment is a no-op (not an error).
exports.markPaymentMade = async (req, res) => {
  try {
    const { paymentId } = req.params;
    const { method, proofImageUrl } = req.body;
    // Only transition if the payment belongs to this user AND isn't already paid.
    // This prevents a double-submit race with the admin updating the same row.
    const [result] = await db.query(
      `UPDATE payments SET status = 'paid', method = ?, proof_image_url = ?, paid_date = CURDATE()
       WHERE id = ? AND user_id = ? AND status != 'paid'`,
      [method || null, proofImageUrl || null, paymentId, req.userId]
    );
    // result.affectedRows is 0 if payment wasn't found, wasn't theirs, or was already paid.
    // We still return success for idempotency — the caller shouldn't care.
    if (result && result.affectedRows > 0) {
      // Broadcast a notification so finance staff sees the new receipt to review.
      try {
        await db.query(
          'INSERT INTO notifications (id, user_id, title, body, type, action_route) VALUES (?, ?, ?, ?, ?, ?)',
          [genId('ntf'), 'all', 'دفعة جديدة بانتظار المراجعة',
           'قام مستخدم بتحميل إيصال دفع جديد — يرجى المراجعة من لوحة التحكم.',
           'payment', '/admin/payments']
        );
      } catch (_) {}
    }
    return res.json({ success: true });
  } catch (err) {
    console.error('markPaymentMade:', err);
    return res.status(500).json({ error: 'حدث خطأ' });
  }
};

// ── Get Payment Accounts ──
exports.getPaymentAccounts = async (req, res) => {
  try {
    const [rows] = await db.query(
      "SELECT config_value FROM app_config WHERE config_key = 'payment_accounts'"
    );
    if (rows.length === 0) return res.json({ zainCash: '', superQi: '' });
    const val = typeof rows[0].config_value === 'string'
      ? JSON.parse(rows[0].config_value) : rows[0].config_value;
    return res.json(val);
  } catch (err) {
    console.error('getPaymentAccounts:', err);
    return res.status(500).json({ error: 'حدث خطأ' });
  }
};

exports.formatPayment = formatPayment;
