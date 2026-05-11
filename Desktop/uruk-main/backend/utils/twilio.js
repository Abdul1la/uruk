/**
 * Twilio Verify – OTP Module
 * ──────────────────────────
 * Ready to activate once TWILIO_ACCOUNT_SID, TWILIO_AUTH_TOKEN,
 * and TWILIO_VERIFY_SERVICE_SID are set in .env
 *
 * Until then, falls back to a dev-mode bypass (OTP = 123456).
 */
require('dotenv').config();

const SID   = process.env.TWILIO_ACCOUNT_SID;
const TOKEN = process.env.TWILIO_AUTH_TOKEN;
const VSID  = process.env.TWILIO_VERIFY_SERVICE_SID;

let client = null;
if (SID && TOKEN && VSID) {
  const twilio = require('twilio');
  client = twilio(SID, TOKEN);
  console.log('📱 Twilio Verify connected');
} else {
  console.log('⚠️  Twilio not configured – using dev-mode OTP (123456)');
}

/**
 * Convert any accepted phone format to E.164 for Twilio.
 * Iraqi numbers (07XXXXXXXXX, 7XXXXXXXXX, 00964..., +964...) → +9647XXXXXXXXX
 */
function toE164(phone) {
  if (!phone) return phone;
  let digits = String(phone).replace(/\D/g, '');
  if (digits.startsWith('00964')) digits = digits.substring(5);
  else if (digits.startsWith('964')) digits = digits.substring(3);
  if (digits.startsWith('0')) digits = digits.substring(1);
  // At this point digits should look like 7XXXXXXXXX (Iraqi mobile without country code).
  return '+964' + digits;
}

/**
 * Send OTP to phone number
 * @param {string} phone – accepts 07XXXXXXXXX, +964..., or any normalized form
 */
async function sendOtp(phone) {
  if (!client) {
    // Dev-mode: always succeed
    return { success: true, dev: true };
  }
  try {
    const to = toE164(phone);
    const verification = await client.verify.v2
      .services(VSID)
      .verifications.create({ to, channel: 'sms' });
    return { success: verification.status === 'pending', dev: false };
  } catch (err) {
    console.error('Twilio sendOtp error:', err.message);
    return { success: false, error: err.message };
  }
}

/**
 * Verify OTP code
 * @param {string} phone
 * @param {string} code – 6-digit OTP
 */
async function verifyOtp(phone, code) {
  if (!client) {
    // Dev-mode: accept 123456 or any 6-digit code
    return { success: code === '123456' || (code && code.length === 6), dev: true };
  }
  try {
    const to = toE164(phone);
    const check = await client.verify.v2
      .services(VSID)
      .verificationChecks.create({ to, code });
    return { success: check.status === 'approved', dev: false };
  } catch (err) {
    // 404 means: no active verification for this number. Either expired (>10 min),
    // already consumed, or never sent. Surface a clear error instead of a generic one.
    if (err.status === 404 || err.code === 20404) {
      console.warn('Twilio verifyOtp: no active verification for', phone, '— expired or already used');
      return { success: false, error: 'انتهت صلاحية الرمز — اطلب رمزاً جديداً', expired: true };
    }
    console.error('Twilio verifyOtp error:', err.message);
    return { success: false, error: err.message };
  }
}

module.exports = { sendOtp, verifyOtp };
