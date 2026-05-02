/**
 * Uruk Motors – Mobile App API Routes
 * Base: /api
 */
const router = require('express').Router();
const { authUser } = require('../middleware/auth');
const upload = require('../middleware/upload');

const auth = require('../controllers/authController');
const cars = require('../controllers/carsController');
const accidents = require('../controllers/accidentsController');
const appointments = require('../controllers/appointmentsController');
const payments = require('../controllers/paymentsController');
const oil = require('../controllers/oilChangeController');
const notif = require('../controllers/notificationsController');
const requests = require('../controllers/requestsController');
const config = require('../controllers/configController');
const { fileUrl } = require('../utils/helpers');

// ── Auth (public) ──
router.post('/auth/send-otp', auth.sendOtp);
router.post('/auth/verify-otp', auth.verifyOtp);
router.post('/auth/register', auth.register);
router.post('/auth/login', auth.login);

// ── Auth (protected) ──
router.get('/auth/profile', authUser, auth.getProfile);
router.get('/auth/refresh', authUser, auth.refreshUser);
router.post('/auth/id-images', authUser, auth.uploadIdImages);

// ── File Upload (protected) ──
router.post('/upload/:folder', authUser, upload.array('files', 10), (req, res) => {
  try {
    const folder = req.params.folder;
    const urls = req.files.map(f => fileUrl(req, folder, f.filename));
    return res.json({ urls });
  } catch (err) {
    console.error('upload:', err);
    return res.status(500).json({ error: 'فشل رفع الملف' });
  }
});

// ── Cars ──
router.get('/cars', authUser, cars.getUserCars);
router.post('/cars', authUser, cars.addCar);
router.patch('/cars/:carId', authUser, cars.updateCar);
router.post('/cars/:carId/subscribe', authUser, cars.subscribeCar);
router.post('/cars/:carId/increment-repairs', authUser, cars.incrementRepairs);

// ── Accident Reports ──
router.get('/reports', authUser, accidents.getReports);
router.post('/reports', authUser, accidents.submitReport);
router.post('/reports/:reportId/repair-photos', authUser, accidents.submitRepairPhotos);

// ── Appointments ──
router.get('/appointments', authUser, appointments.getAppointments);
router.post('/appointments/:appointmentId/request-change', authUser, appointments.requestChange);

// ── Payments ──
router.get('/payments', authUser, payments.getPayments);
router.post('/payments/:paymentId/mark-paid', authUser, payments.markPaymentMade);
router.get('/payments/accounts', authUser, payments.getPaymentAccounts);

// ── Oil Changes ──
router.get('/oil-changes', authUser, oil.getBookings);
router.post('/oil-changes', authUser, oil.bookOilChange);

// ── Notifications ──
router.get('/notifications', authUser, notif.getNotifications);
router.post('/notifications/:notifId/read', authUser, notif.markRead);
router.post('/notifications/read-all', authUser, notif.markAllRead);

// ── Requests ──
router.get('/car-change-requests', authUser, requests.getCarChangeRequests);
router.post('/car-change-requests', authUser, requests.submitCarChangeRequest);
router.get('/upgrade-requests', authUser, requests.getUpgradeRequests);
router.post('/upgrade-requests', authUser, requests.submitUpgradeRequest);

// ── Config (public, read-only) ──
router.get('/config/support', config.getSupportInfo);
router.get('/config/privacy', config.getPrivacyPolicy);
router.get('/config/cities', config.getCities);
router.get('/config/branches', config.getBranches);
router.get('/config/plans', config.getPlans);
router.get('/config/banners', config.getBanners);
router.get('/config/onboarding', config.getOnboardingPages);

module.exports = router;
