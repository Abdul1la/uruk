/* ═══════════════════════════════════════════════════════════════════════════
   URUK MOTORS — Admin Dashboard API Client
   Replaces all MockData reads/writes with real backend calls.
   ═══════════════════════════════════════════════════════════════════════════ */

function _buildQuery(params) {
  if (!params) return '';
  if (typeof params === 'string') return params ? `?status=${params}` : '';
  const parts = [];
  Object.entries(params).forEach(([k, v]) => {
    if (v !== undefined && v !== null && v !== '') parts.push(`${encodeURIComponent(k)}=${encodeURIComponent(v)}`);
  });
  return parts.length ? '?' + parts.join('&') : '';
}

const API = {
  // Base URL — admin API is at /api/admin (Node.js app is mounted at /api on cPanel)
  baseUrl: (function() {
    const origin = window.location.origin;
    return origin + '/api/admin';
  })(),

  token: localStorage.getItem('admin_token') || null,

  // ── HTTP Helpers ──────────────────────────────────────────────────────────

  headers() {
    const h = { 'Content-Type': 'application/json' };
    if (this.token) h['Authorization'] = `Bearer ${this.token}`;
    return h;
  },

  // Unified fetch with retry, timeout, error parsing, and offline cache.
  async _req(method, path, body, { retries = 2, timeout = 15000, cacheKey = null } = {}) {
    const url = this.baseUrl + path;
    let lastErr = null;
    for (let attempt = 0; attempt <= retries; attempt++) {
      const controller = new AbortController();
      const timer = setTimeout(() => controller.abort(), timeout);
      try {
        const opts = { method, headers: this.headers(), signal: controller.signal };
        if (body !== undefined && body !== null) opts.body = JSON.stringify(body);
        const res = await fetch(url, opts);
        clearTimeout(timer);
        if (res.status === 401) { this.onUnauthorized(); throw new Error('Unauthorized'); }
        const text = await res.text();
        const data = text ? JSON.parse(text) : {};
        if (!res.ok) {
          const msg = data.error || data.message || `HTTP ${res.status}`;
          const err = new Error(msg);
          err.status = res.status;
          err.data = data;
          // 4xx is not retried, only 5xx / network
          if (res.status < 500) throw err;
          lastErr = err;
        } else {
          // Cache successful GETs for offline fallback
          if (method === 'GET' && cacheKey) {
            try { localStorage.setItem('apic:' + cacheKey, JSON.stringify({ t: Date.now(), data })); } catch(_){}
          }
          return data;
        }
      } catch (e) {
        clearTimeout(timer);
        if (e.name === 'AbortError') { lastErr = new Error('انتهت مهلة الاتصال'); lastErr.offline = true; }
        else if (e.status && e.status < 500) throw e;
        else { lastErr = e; lastErr.offline = !e.status; }
      }
      if (attempt < retries) {
        await new Promise(r => setTimeout(r, 400 * Math.pow(2, attempt)));
      }
    }
    // All retries exhausted — try cache for GETs
    if (method === 'GET' && cacheKey) {
      try {
        const cached = localStorage.getItem('apic:' + cacheKey);
        if (cached) {
          const parsed = JSON.parse(cached);
          if (typeof showToast === 'function') {
            showToast('warning', 'لا يوجد اتصال — عرض بيانات محفوظة من ' + new Date(parsed.t).toLocaleTimeString('ar-IQ'));
          }
          return parsed.data;
        }
      } catch(_){}
    }
    if (typeof showToast === 'function') {
      showToast('error', lastErr?.message || 'فشل الاتصال بالخادم');
    }
    throw lastErr || new Error('Network error');
  },

  get(path, opts)           { return this._req('GET',    path, null, { ...opts, cacheKey: opts?.cacheKey || path }); },
  post(path, body, opts)    { return this._req('POST',   path, body, { retries: 0, ...opts }); },
  patch(path, body, opts)   { return this._req('PATCH',  path, body, { retries: 0, ...opts }); },
  put(path, body, opts)     { return this._req('PUT',    path, body, { retries: 0, ...opts }); },
  del(path, opts)           { return this._req('DELETE', path, null, { retries: 0, ...opts }); },

  async uploadFiles(files, folder) {
    if (!files || !files.length) return { urls: [] };
    const formData = new FormData();
    for (const f of files) formData.append('files', f);
    const controller = new AbortController();
    const timer = setTimeout(() => controller.abort(), 60000);
    try {
      const res = await fetch(this.baseUrl + `/upload/${folder}`, {
        method: 'POST',
        headers: { 'Authorization': `Bearer ${this.token}` },
        body: formData,
        signal: controller.signal,
      });
      clearTimeout(timer);
      if (res.status === 401) { this.onUnauthorized(); throw new Error('Unauthorized'); }
      const data = await res.json();
      if (!res.ok) throw new Error(data.error || 'فشل رفع الملفات');
      return data;
    } catch(e) {
      clearTimeout(timer);
      if (typeof showToast === 'function') showToast('error', e.message || 'فشل رفع الملفات');
      throw e;
    }
  },

  onUnauthorized() {
    this.token = null;
    localStorage.removeItem('admin_token');
    // Trigger logout in app.js
    if (typeof showLogin === 'function') showLogin();
  },

  // ── Auth ──────────────────────────────────────────────────────────────────

  async login(email, password) {
    // Bypass _req wrapper: we don't want 401 to trigger the global "unauthorized" redirect here,
    // and we want to surface the server-side error message intact.
    try {
      const res = await fetch(this.baseUrl + '/login', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, password }),
      });
      const data = await res.json().catch(() => ({}));
      if (data.token) {
        this.token = data.token;
        localStorage.setItem('admin_token', data.token);
      }
      return data;
    } catch (e) {
      return { error: 'فشل الاتصال بالخادم' };
    }
  },

  logout() {
    this.token = null;
    localStorage.removeItem('admin_token');
  },

  // ── Dashboard ────────────────────────────────────────────────────────────

  getStats() { return this.get('/stats'); },

  // ── Users ────────────────────────────────────────────────────────────────

  getUsers(status) { return this.get('/users' + (status ? `?status=${status}` : '')); },
  getUserDetail(id) { return this.get(`/users/${id}`); },
  updateUserStatus(id, status) { return this.patch(`/users/${id}/status`, { status }); },

  // ── Reports ──────────────────────────────────────────────────────────────

  getReports(params) {
    const qs = _buildQuery(params);
    return this.get('/reports' + qs);
  },
  updateReportStatus(id, data) { return this.patch(`/reports/${id}/status`, data); },
  addRepairEntry(reportId, entry) { return this.post(`/reports/${reportId}/repair-entry`, entry); },

  // ── Appointments ─────────────────────────────────────────────────────────

  getAppointments(params) { return this.get('/appointments' + _buildQuery(params)); },
  createAppointment(data) { return this.post('/appointments', data); },
  updateAppointment(id, data) { return this.patch(`/appointments/${id}`, data); },

  // ── Payments ─────────────────────────────────────────────────────────────

  getPayments(params) { return this.get('/payments' + _buildQuery(params)); },
  createPayment(data) { return this.post('/payments', data); },
  updatePaymentStatus(id, status) { return this.patch(`/payments/${id}/status`, { status }); },

  // ── Oil Changes ──────────────────────────────────────────────────────────

  getOilChanges() { return this.get('/oil-changes'); },
  updateOilChange(id, data) { return this.patch(`/oil-changes/${id}`, data); },

  // ── Requests ─────────────────────────────────────────────────────────────

  getRequests() { return this.get('/requests'); },
  reviewCarChange(id, data) { return this.patch(`/requests/car-change/${id}`, data); },
  reviewUpgrade(id, data) { return this.patch(`/requests/upgrade/${id}`, data); },

  // ── Notifications ────────────────────────────────────────────────────────

  getNotifications() { return this.get('/notifications'); },
  sendNotification(data) { return this.post('/notifications', data); },

  // ── Employees ────────────────────────────────────────────────────────────

  getEmployees() { return this.get('/employees'); },
  createEmployee(data) { return this.post('/employees', data); },
  updateEmployee(id, data) { return this.patch(`/employees/${id}`, data); },

  // ── Config ───────────────────────────────────────────────────────────────

  getConfig(key) { return this.get(`/config/${key}`); },
  updateConfig(key, value) { return this.put(`/config/${key}`, { value }); },

  // ── Branches ─────────────────────────────────────────────────────────────

  getBranches() { return this.get('/branches'); },
  createBranch(data) { return this.post('/branches', data); },
  updateBranch(id, data) { return this.patch(`/branches/${id}`, data); },
  deleteBranch(id) { return this.del(`/branches/${id}`); },

  // ── Banners ──────────────────────────────────────────────────────────────

  getBanners() { return this.get('/banners'); },
  createBanner(data) { return this.post('/banners', data); },
  updateBanner(id, data) { return this.patch(`/banners/${id}`, data); },
  deleteBanner(id) { return this.del(`/banners/${id}`); },

  // ── Plans ────────────────────────────────────────────────────────────────

  getPlans() { return this.get('/plans'); },
  updatePlan(id, data) { return this.patch(`/plans/${id}`, data); },

  // ── Public config (no auth needed) ───────────────────────────────────────

  async getPublicConfig() {
    const origin = window.location.origin;
    const base = origin + '/api';
    const [support, branches, plans, banners, cities, privacy, accounts] = await Promise.all([
      fetch(base + '/config/support').then(r => r.json()),
      fetch(base + '/config/branches').then(r => r.json()),
      fetch(base + '/config/plans').then(r => r.json()),
      fetch(base + '/config/banners').then(r => r.json()),
      fetch(base + '/config/cities').then(r => r.json()),
      fetch(base + '/config/privacy').then(r => r.json()),
      fetch(base + '/payments/accounts').then(r => r.json()).catch(() => ({})),
    ]);
    return { support, branches, plans, banners, cities, privacy, accounts };
  },
};
