const express = require('express');
const cors = require('cors');
const path = require('path');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Trust the reverse proxy (nginx/Cloudflare) so req.protocol reflects the
// original scheme. Without this, fileUrl() builds http:// URLs for uploads
// and the browser blocks them as mixed content on https:// pages.
app.set('trust proxy', 1);

// ── Middleware ──
app.use(cors());
app.use(express.json({ limit: '20mb' }));
app.use(express.urlencoded({ extended: true, limit: '20mb' }));

// ── Static files (uploaded images) ──
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// ── Serve admin dashboard (HTML/JS) ──
app.use('/dashboard', express.static(path.join(__dirname, '..', 'website')));

// ── Serve Flutter web customer app ──
const FLUTTER_WEB_DIR = path.join(__dirname, '..', 'build', 'web');
app.use('/app', express.static(FLUTTER_WEB_DIR));

// ── API Routes ──
app.use('/api', require('./routes/api'));
app.use('/admin', require('./routes/admin'));
app.use('/api/admin', require('./routes/admin'));

// ── Health check ──
app.get('/health', (req, res) => {
  res.json({ status: 'ok', time: new Date().toISOString() });
});

// ── Flutter web SPA fallback: any /app/* route that isn't a file goes to index.html
//     so go_router deep links (/app/login, /app/garage, …) work on refresh.
app.get('/app/*', (req, res) => {
  res.sendFile(path.join(FLUTTER_WEB_DIR, 'index.html'));
});

// ── Root: redirect to the admin dashboard for convenience ──
app.get('/', (req, res) => res.redirect('/dashboard/'));

// ── 404 ──
app.use((req, res) => {
  res.status(404).json({ error: 'Not found' });
});

// ── Error handler ──
app.use((err, req, res, next) => {
  console.error('Unhandled error:', err);
  if (err.code === 'LIMIT_FILE_SIZE') {
    return res.status(413).json({ error: 'الملف كبير جداً (الحد الأقصى 10 ميجا)' });
  }
  return res.status(500).json({ error: 'حدث خطأ في الخادم' });
});

// ── Start ──
app.listen(PORT, () => {
  console.log(`🚀 Uruk Motors API running on port ${PORT}`);
  console.log(`📊 Dashboard: http://localhost:${PORT}/dashboard`);
  console.log(`🔌 API base: http://localhost:${PORT}/api`);
  console.log(`👔 Admin API: http://localhost:${PORT}/admin`);
});
