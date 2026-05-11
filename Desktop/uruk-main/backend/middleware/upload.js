const multer = require('multer');
const path = require('path');
const fs = require('fs');
const { v4: uuidv4 } = require('uuid');

const UPLOAD_DIR = process.env.UPLOAD_DIR || './uploads';
const ALLOWED_FOLDERS = ['ids', 'cars', 'accidents', 'repairs', 'payments', 'banners', 'general'];

// Eagerly ensure all upload folders exist at startup so multer never fails with ENOENT.
try {
  for (const f of ALLOWED_FOLDERS) {
    fs.mkdirSync(path.join(UPLOAD_DIR, f), { recursive: true });
  }
} catch (e) { console.warn('upload mkdir:', e.message); }

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    const folder = req.params.folder || req.body.folder || 'general';
    const target = ALLOWED_FOLDERS.includes(folder) ? folder : 'general';
    const dir = path.join(UPLOAD_DIR, target);
    try { fs.mkdirSync(dir, { recursive: true }); } catch(_) {}
    cb(null, dir);
  },
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname);
    cb(null, `${uuidv4()}${ext}`);
  },
});

const fileFilter = (req, file, cb) => {
  // Images + PDFs everywhere. Videos are only allowed when uploading to the
  // 'banners' folder (the admin panel's ad-banner media picker).
  const imagePattern = /jpeg|jpg|png|webp|heic|heif|pdf|gif/;
  const videoPattern = /mp4|mov|webm|m4v/;
  const ext = path.extname(file.originalname).toLowerCase();
  const mime = (file.mimetype || '').toLowerCase();
  const folder = req.params && req.params.folder;

  const isImage = imagePattern.test(ext) || imagePattern.test(mime);
  const isVideo = videoPattern.test(ext) || mime.startsWith('video/');

  if (isImage) return cb(null, true);
  if (isVideo && folder === 'banners') return cb(null, true);
  return cb(new Error('نوع الملف غير مدعوم'), false);
};

const upload = multer({
  storage,
  fileFilter,
  limits: { fileSize: parseInt(process.env.MAX_FILE_SIZE || '10485760') },
});

module.exports = upload;
