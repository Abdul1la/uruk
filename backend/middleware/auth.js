const jwt = require('jsonwebtoken');
require('dotenv').config();

/** Mobile app user auth */
function authUser(req, res, next) {
  const header = req.headers.authorization;
  if (!header || !header.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'غير مصرّح – يرجى تسجيل الدخول' });
  }
  try {
    const token = header.split(' ')[1];
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.userId = decoded.userId;
    next();
  } catch {
    return res.status(401).json({ error: 'رمز غير صالح أو منتهي الصلاحية' });
  }
}

/** Dashboard employee auth */
function authAdmin(req, res, next) {
  const header = req.headers.authorization;
  if (!header || !header.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Unauthorized' });
  }
  try {
    const token = header.split(' ')[1];
    const decoded = jwt.verify(token, process.env.ADMIN_JWT_SECRET);
    req.employeeId = decoded.employeeId;
    req.department = decoded.department;
    next();
  } catch {
    return res.status(401).json({ error: 'Invalid or expired admin token' });
  }
}

/** Check department access */
function requireDepartment(...allowed) {
  return (req, res, next) => {
    if (allowed.includes(req.department) || req.department === 'admin') {
      return next();
    }
    return res.status(403).json({ error: 'Access denied for your department' });
  };
}

module.exports = { authUser, authAdmin, requireDepartment };
