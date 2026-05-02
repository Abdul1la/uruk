const db = require('../config/database');

function formatNotification(n) {
  return {
    id: n.id,
    userId: n.user_id,
    title: n.title,
    body: n.body,
    type: n.type,
    isRead: !!n.is_read,
    actionRoute: n.action_route,
    createdAt: n.created_at,
  };
}

exports.getNotifications = async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT * FROM notifications WHERE user_id = ? OR user_id = 'all'
       ORDER BY created_at DESC LIMIT 100`,
      [req.userId]
    );
    return res.json({ notifications: rows.map(formatNotification) });
  } catch (err) {
    console.error('getNotifications:', err);
    return res.status(500).json({ error: 'حدث خطأ' });
  }
};

exports.markRead = async (req, res) => {
  try {
    const { notifId } = req.params;
    await db.query('UPDATE notifications SET is_read = 1 WHERE id = ? AND (user_id = ? OR user_id = ?)',
      [notifId, req.userId, 'all']);
    return res.json({ success: true });
  } catch (err) {
    console.error('markRead:', err);
    return res.status(500).json({ error: 'حدث خطأ' });
  }
};

exports.markAllRead = async (req, res) => {
  try {
    await db.query('UPDATE notifications SET is_read = 1 WHERE user_id = ? OR user_id = ?',
      [req.userId, 'all']);
    return res.json({ success: true });
  } catch (err) {
    console.error('markAllRead:', err);
    return res.status(500).json({ error: 'حدث خطأ' });
  }
};

exports.formatNotification = formatNotification;
