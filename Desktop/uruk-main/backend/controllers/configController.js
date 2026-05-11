const db = require('../config/database');
const { safeJson } = require('../utils/helpers');

// ── Generic config getter ──
async function getConfig(key) {
  const [rows] = await db.query('SELECT config_value FROM app_config WHERE config_key = ?', [key]);
  if (rows.length === 0) return null;
  return safeJson(rows[0].config_value);
}

// ── Support Info ──
exports.getSupportInfo = async (req, res) => {
  try {
    const val = await getConfig('support_info');
    return res.json(val || {});
  } catch (err) {
    console.error('getSupportInfo:', err);
    return res.status(500).json({ error: 'حدث خطأ' });
  }
};

// ── Privacy Policy ──
exports.getPrivacyPolicy = async (req, res) => {
  try {
    const val = await getConfig('privacy_policy');
    return res.json(val || { content: '', updatedAt: '' });
  } catch (err) {
    console.error('getPrivacyPolicy:', err);
    return res.status(500).json({ error: 'حدث خطأ' });
  }
};

// ── Available Cities ──
exports.getCities = async (req, res) => {
  try {
    const val = await getConfig('available_cities');
    return res.json({ cities: val || [] });
  } catch (err) {
    console.error('getCities:', err);
    return res.status(500).json({ error: 'حدث خطأ' });
  }
};

// ── Branches ──
exports.getBranches = async (req, res) => {
  try {
    const [rows] = await db.query('SELECT * FROM branches WHERE is_active = 1');
    return res.json({
      branches: rows.map(b => ({
        id: b.id,
        name: b.name,
        lat: b.lat,
        lng: b.lng,
        address: b.address,
        phone: b.phone,
        isActive: !!b.is_active,
      })),
    });
  } catch (err) {
    console.error('getBranches:', err);
    return res.status(500).json({ error: 'حدث خطأ' });
  }
};

// ── Subscription Plans ──
exports.getPlans = async (req, res) => {
  try {
    const [rows] = await db.query('SELECT * FROM subscription_plans WHERE is_active = 1 ORDER BY sort_order');
    return res.json({
      plans: rows.map(p => ({
        id: p.id,
        type: p.type,
        name: p.name,
        priceIQD: p.price_iqd,
        coverageNote: p.coverage_note,
        coveredParts: safeJson(p.covered_parts, []),
        repairTiers: safeJson(p.repair_tiers, []),
        isPopular: !!p.is_popular,
      })),
    });
  } catch (err) {
    console.error('getPlans:', err);
    return res.status(500).json({ error: 'حدث خطأ' });
  }
};

// ── Onboarding Pages (public — shown before login) ──
// Each page has { title, desc, imageUrl? }. imageUrl is optional; if absent the
// customer app falls back to its built-in icon for that slide.
exports.getOnboardingPages = async (req, res) => {
  try {
    const val = await getConfig('onboarding_pages');
    return res.json({ pages: Array.isArray(val) ? val : [] });
  } catch (err) {
    console.error('getOnboardingPages:', err);
    return res.status(500).json({ error: 'حدث خطأ' });
  }
};

// ── Ad Banners ──
exports.getBanners = async (req, res) => {
  try {
    const [rows] = await db.query('SELECT * FROM ad_banners WHERE is_active = 1 ORDER BY sort_order');
    return res.json({
      banners: rows.map(b => ({
        id: b.id,
        title: b.title,
        subtitle: b.subtitle,
        backgroundColor: b.bg_color,
        textColor: b.text_color,
        icon: b.icon,
        actionLabel: b.action_label,
        actionRoute: b.action_route,
        mediaUrl: b.media_url,
        mediaType: b.media_type || 'none',
        isActive: !!b.is_active,
      })),
    });
  } catch (err) {
    console.error('getBanners:', err);
    return res.status(500).json({ error: 'حدث خطأ' });
  }
};

exports.getConfig = getConfig;
