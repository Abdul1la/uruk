const { v4: uuidv4 } = require('uuid');

/** Generate prefixed UUID: e.g. usr_xxxx, rpt_xxxx */
function genId(prefix = '') {
  const id = uuidv4();
  return prefix ? `${prefix}_${id}` : id;
}

/** Build public URL for uploaded file */
function fileUrl(req, folder, filename) {
  const base = process.env.BASE_URL || `${req.protocol}://${req.get('host')}`;
  return `${base}/uploads/${folder}/${filename}`;
}

/** Normalize Iraqi phone numbers to 07XXXXXXXXX format */
function normalizePhone(phone) {
  if (!phone) return phone;
  let digits = phone.replace(/\D/g, '');
  if (digits.startsWith('00964') && digits.length >= 13) digits = '0' + digits.substring(5);
  else if (digits.startsWith('964') && digits.length >= 13) digits = '0' + digits.substring(3);
  else if (digits.length === 10 && !digits.startsWith('0')) digits = '0' + digits;
  return digits;
}

/** Parse JSON safely */
function safeJson(val, fallback = null) {
  if (!val) return fallback;
  if (typeof val === 'object') return val;
  try { return JSON.parse(val); } catch { return fallback; }
}

module.exports = { genId, fileUrl, safeJson, normalizePhone };
