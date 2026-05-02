/**
 * Uruk Motors – Admin Dashboard API Routes
 * Base: /admin
 */
const router = require('express').Router();
const { authAdmin, requireDepartment } = require('../middleware/auth');
const upload = require('../middleware/upload');
const admin = require('../controllers/adminController');
const { fileUrl } = require('../utils/helpers');

// ── Auth (public) ──
router.post('/login', admin.login);

// All routes below require admin auth
router.use(authAdmin);

// ── Dashboard ──
router.get('/stats', admin.getDashboardStats);

// ── Users ──
// Only administration + finance can list all users (maintenance gets user names
// joined into accident reports; they don't need the full user directory).
router.get('/users', requireDepartment('administration', 'finance'), admin.getUsers);
router.get('/users/:userId', requireDepartment('administration', 'finance'), admin.getUserDetail);
router.patch('/users/:userId/status', requireDepartment('administration'), admin.updateUserStatus);

// ── Reports ──
router.get('/reports', requireDepartment('maintenance'), admin.getAllReports);
router.patch('/reports/:reportId/status', requireDepartment('maintenance'), admin.updateReportStatus);
router.post('/reports/:reportId/repair-entry', requireDepartment('maintenance'), admin.addRepairEntry);

// ── Appointments ──
router.get('/appointments', requireDepartment('maintenance'), admin.getAllAppointments);
router.post('/appointments', requireDepartment('maintenance'), admin.createAppointment);
router.patch('/appointments/:appointmentId', requireDepartment('maintenance'), admin.updateAppointment);

// ── Payments ──
router.get('/payments', requireDepartment('finance'), admin.getAllPayments);
router.post('/payments', requireDepartment('finance'), admin.createPayment);
router.patch('/payments/:paymentId/status', requireDepartment('finance'), admin.updatePaymentStatus);

// ── Oil Changes ──
router.get('/oil-changes', requireDepartment('maintenance'), admin.getAllOilChanges);
router.patch('/oil-changes/:oilId', requireDepartment('maintenance'), admin.updateOilChange);

// ── Requests ──
router.get('/requests', requireDepartment('administration', 'finance'), admin.getAllRequests);
router.patch('/requests/car-change/:requestId', requireDepartment('administration'), admin.reviewCarChangeRequest);
router.patch('/requests/upgrade/:requestId', requireDepartment('administration', 'finance'), admin.reviewUpgradeRequest);

// ── Notifications ──
// Admin-only: fetching the global notification log and broadcasting messages
// to users are sensitive operations that shouldn't be exposed to other depts.
router.get('/notifications', requireDepartment(), admin.getAllNotifications);
router.post('/notifications', requireDepartment(), admin.sendNotification);

// ── Employees ──
router.get('/employees', requireDepartment(), admin.getEmployees);  // admin only
router.post('/employees', requireDepartment(), admin.createEmployee);
router.patch('/employees/:empId', requireDepartment(), admin.updateEmployee);

// ── Settings / Config ──
router.get('/config/:key', requireDepartment(), admin.getConfig);
router.put('/config/:key', requireDepartment(), admin.updateConfig);
router.post('/branches', requireDepartment(), admin.createBranch);
router.patch('/branches/:branchId', requireDepartment(), admin.updateBranch);
router.delete('/branches/:branchId', requireDepartment(), admin.deleteBranch);
router.get('/banners', requireDepartment(), admin.getAllBanners);
router.get('/branches', requireDepartment(), admin.getAllBranches);
router.get('/plans', requireDepartment(), admin.getAllPlans);
router.post('/banners', requireDepartment(), admin.createBanner);
router.patch('/banners/:bannerId', requireDepartment(), admin.updateBanner);
router.delete('/banners/:bannerId', requireDepartment(), admin.deleteBanner);
router.patch('/plans/:planId', requireDepartment(), admin.updatePlan);

// ── File Upload (admin) ──
router.post('/upload/:folder', upload.array('files', 10), (req, res) => {
  try {
    const folder = req.params.folder;
    const urls = req.files.map(f => fileUrl(req, folder, f.filename));
    return res.json({ urls });
  } catch (err) {
    return res.status(500).json({ error: 'Upload failed' });
  }
});

module.exports = router;
