/* ═══════════════════════════════════════════════════════════════════════════
   URUK MOTORS — Admin Panel — Complete Integration
   ═══════════════════════════════════════════════════════════════════════════ */

let currentUser = null;
let currentPage = 'dashboard';

// ── Utility ──────────────────────────────────────────────────────────────────

/**
 * HTML-escape a string so user-controlled data (names, descriptions, report
 * text, request values, …) is safe to interpolate into innerHTML template
 * literals. Always use this for any value that originated in the database.
 */
function esc(v) {
  if (v === null || v === undefined) return '';
  return String(v)
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

// Toast notifications — shown top-center, auto-dismiss
function showToast(type, message, ms) {
  let host = document.getElementById('toast-host');
  if (!host) {
    host = document.createElement('div');
    host.id = 'toast-host';
    host.className = 'toast-host';
    document.body.appendChild(host);
  }
  const el = document.createElement('div');
  el.className = `toast toast-${type||'info'}`;
  const icons = { success: 'check-circle', error: 'alert-circle', warning: 'alert-triangle', info: 'info' };
  el.innerHTML = `<i data-lucide="${icons[type]||'info'}"></i><span>${message}</span>`;
  host.appendChild(el);
  refreshIcons();
  // Entrance animation trigger
  requestAnimationFrame(() => el.classList.add('show'));
  const hold = ms || (type === 'error' ? 5000 : 3000);
  setTimeout(() => {
    el.classList.remove('show');
    setTimeout(() => el.remove(), 300);
  }, hold);
}

// Wraps an async API call with try/catch + toast on success or failure
async function withToast(promiseFn, successMsg) {
  try {
    const result = await promiseFn();
    if (successMsg) showToast('success', successMsg);
    return result;
  } catch (e) {
    // api._req already showed error toast on failure; re-throw so caller can bail
    throw e;
  }
}

function badge(type, label) { return `<span class="badge badge-${type}">${label}</span>`; }
/** Safe first-letter for avatars — handles null/empty/non-string names. */
function initial(name) { return (name && String(name).trim()[0]) || '?'; }
/** Inline Lucide icon. Pass an icon name (e.g. "car"). Optional size in px. */
function ic(name, size) {
  const style = size ? ` style="width:${size}px;height:${size}px"` : '';
  return `<i data-lucide="${name}"${style}></i>`;
}
function iconBox(name, bg, fg) { return `<div class="list-icon" style="background:${bg};color:${fg}">${ic(name)}</div>`; }
/** Refresh all <i data-lucide> tags into SVG. Call after every innerHTML update. */
function refreshIcons() { if (window.lucide) window.lucide.createIcons(); }
function fmtDate(d) { if(!d) return '—'; const dt=new Date(d); return `${dt.getFullYear()}/${String(dt.getMonth()+1).padStart(2,'0')}/${String(dt.getDate()).padStart(2,'0')}`; }
function fmtDateTime(d) { if(!d) return '—'; const dt=new Date(d); return fmtDate(d)+` ${String(dt.getHours()).padStart(2,'0')}:${String(dt.getMinutes()).padStart(2,'0')}`; }
function fmtIQD(n) { return n.toString().replace(/\B(?=(\d{3})+(?!\d))/g,',')+' د.ع'; }

function photoGrid(urls, label) {
  if (!urls || !urls.length) return '';
  return `<div class="detail-section">
    <div class="detail-section-title">${ic('camera')} ${label} (${urls.length})</div>
    <div class="photo-grid">${urls.map(u=>`<img src="${esc(u)}" class="photo-thumb" onclick="openLightbox('${esc(u)}')">`).join('')}</div>
  </div>`;
}

function openLightbox(src) {
  const lb = document.createElement('div');
  lb.className = 'lightbox';
  lb.innerHTML = `<img src="${src}">`;
  lb.onclick = () => lb.remove();
  document.body.appendChild(lb);
}

function showModal(title, bodyHtml, actions) {
  const ov = document.createElement('div');
  ov.className = 'modal-overlay';
  ov.innerHTML = `<div class="modal"><div class="modal-title">${title}</div>${bodyHtml}<div class="modal-actions">${actions}</div></div>`;
  ov.onclick = e => { if(e.target===ov) ov.remove(); };
  document.body.appendChild(ov);
  refreshIcons();
  return ov;
}

function closeModal() { document.querySelector('.modal-overlay')?.remove(); }

function pipeline(statuses, current) {
  const order = Object.keys(statuses);
  const ci = order.indexOf(current);
  return `<div class="pipeline">${order.map((s,i)=>`<div class="pipeline-step ${i<ci?'done':i===ci?'active':''}">${statuses[s]}</div>`).join('')}</div>`;
}

// ── Auth ─────────────────────────────────────────────────────────────────────

async function login() {
  // Aggressively normalize inputs so autofill / keyboard quirks cannot cause
  // "looks right but fails" rejections. The backend also normalizes these,
  // but trimming on the client gives the user instant visual feedback.
  const rawEmail = document.getElementById('login-email').value || '';
  const rawPass  = document.getElementById('login-pass').value || '';
  const email = rawEmail.trim().toLowerCase();
  // Strip zero-width / non-breaking chars from the password (some mobile
  // keyboards inject them), then trim.
  const pass = rawPass.replace(/[\u200B-\u200D\uFEFF\u00A0]/g, '').trim();
  const err   = document.getElementById('login-error');
  if (!email || !pass) {
    err.textContent = 'أدخل بريد إلكتروني وكلمة مرور';
    err.classList.remove('hidden');
    return;
  }
  try {
    const data = await API.login(email, pass);
    if (data.token && data.employee) {
      currentUser = data.employee;
      err.classList.add('hidden');
      showApp();
    } else {
      err.textContent = data.error || 'بيانات الدخول غير صحيحة أو الحساب معطّل';
      err.classList.remove('hidden');
    }
  } catch(e) {
    // Surface the real server error if available — helps debug the
    // intermittent failures the client has been reporting.
    err.textContent = (e && e.message) ? e.message : 'خطأ في الاتصال بالخادم';
    err.classList.remove('hidden');
  }
}

function showLogin() { currentUser=null; document.getElementById('login-page').classList.remove('hidden'); document.getElementById('app-page').classList.add('hidden'); }
function logout() { API.logout(); showLogin(); }

// ── App Shell ────────────────────────────────────────────────────────────────

function showApp() {
  document.getElementById('login-page').classList.add('hidden');
  document.getElementById('app-page').classList.remove('hidden');
  renderSidebar(); renderTopbar(); navigate('dashboard');
  refreshIcons();
}

function renderSidebar() {
  const d = currentUser.department;
  const items = [{ icon:'layout-dashboard', label:'لوحة التحكم', page:'dashboard' }];

  if (d==='admin'||d==='administration') items.push({ icon:'users', label:'المستخدمون', page:'users' });
  if (d==='admin') items.push({ icon:'id-card', label:'الموظفون', page:'employees' });
  if (d==='admin'||d==='maintenance') {
    items.push({ icon:'siren', label:'بلاغات الحوادث', page:'reports' });
    items.push({ icon:'calendar', label:'المواعيد', page:'appointments' });
    items.push({ icon:'wrench', label:'تغيير الزيت', page:'oilChanges' });
  }
  if (d==='admin'||d==='finance') {
    items.push({ icon:'credit-card', label:'المدفوعات', page:'payments' });
    items.push({ icon:'clipboard-list', label:'الاشتراكات', page:'subscriptions' });
  }
  if (d==='admin'||d==='administration'||d==='finance') items.push({ icon:'inbox', label:'الطلبات', page:'requests' });
  // Analytics reports — available to ALL departments
  items.push({ icon:'bar-chart-3', label:'التقارير', page:'analytics' });

  if (d==='admin') {
    items.push({ icon:'bell', label:'الإشعارات', page:'notifications' });
    items.push({ icon:'settings', label:'الإعدادات', page:'settings' });
  }

  document.getElementById('sidebar-nav').innerHTML = items.map(it => `
    <div class="sidebar-item" data-page="${it.page}" onclick="navigate('${it.page}')">
      <i data-lucide="${it.icon}" class="icon"></i><span>${it.label}</span>
    </div>`).join('');
  document.getElementById('sidebar-logout').onclick = logout;
}

function renderTopbar() {
  const d = currentUser.department;
  const dept = document.getElementById('topbar-dept');
  dept.textContent = DeptLabels[d]; dept.style.background = DeptBg[d]; dept.style.color = DeptColors[d];
  document.getElementById('topbar-avatar').textContent = initial(currentUser.fullName);
  document.getElementById('topbar-name').textContent = currentUser.fullName;
}

async function navigate(page, opts) {
  // opts.replace = true → don't add a new history entry (used when restoring
  // from popstate so we don't keep stacking duplicates).
  const fromHistory = opts && opts.fromHistory;
  currentPage = page;
  if (!fromHistory) {
    // Push a new entry so the browser/phone back button takes the user
    // to the previous dashboard page instead of leaving the website.
    try {
      const url = '#' + page;
      if (location.hash !== url) {
        history.pushState({ page }, '', url);
      }
    } catch (_) { /* pushState can fail in sandboxed contexts; ignore */ }
  }
  document.querySelectorAll('.sidebar-item').forEach(el => el.classList.toggle('active', el.dataset.page===page));
  const el = document.getElementById('page-content');
  el.innerHTML = '<div class="empty-state">جارٍ التحميل...</div>';
  // Refresh data from API before rendering each page
  try { await refreshPageData(page); } catch(e) { console.warn('Data refresh failed, using cached:', e); }
  const pages = { dashboard:pgDashboard, users:pgUsers, employees:pgEmployees, reports:pgReports, appointments:pgAppointments, payments:pgPayments, subscriptions:pgSubscriptions, oilChanges:pgOilChanges, requests:pgRequests, notifications:pgNotifications, settings:pgSettings, analytics:pgAnalytics };
  (pages[page]||pgNotFound)(el);
  refreshIcons();
}

// When the user presses the phone/browser back button, restore the previous
// page from the history state instead of letting the browser leave the site.
window.addEventListener('popstate', (ev) => {
  const page = (ev.state && ev.state.page) || (location.hash || '#dashboard').replace(/^#/, '');
  if (typeof navigate === 'function' && page) {
    navigate(page, { fromHistory: true });
  }
});

/** Fetch live data from backend and update MockData in-place so rendering code stays compatible */
async function refreshPageData(page) {
  try {
    switch(page) {
      case 'dashboard': {
        // Only admin sees the employees stat card, so only fetch it then.
        const isAdmin = currentUser?.department === 'admin';
        const calls = [
          API.getUsers(), API.getReports(), API.getPayments(), API.getOilChanges(), API.getRequests(),
        ];
        if (isAdmin) calls.push(API.getEmployees());
        const [usersData, reportsData, paymentsData, oilData, requestsData, empData] = await Promise.all(calls);
        MockData.users = usersData.users || MockData.users;
        MockData.reports = reportsData.reports || MockData.reports;
        MockData.payments = paymentsData.payments || MockData.payments;
        MockData.oilChanges = oilData.bookings || MockData.oilChanges;
        if (empData?.employees) MockData.employees = empData.employees;
        // Merge requests
        const ccrs = (requestsData.carChangeRequests||[]).map(r => ({...r, type: r.type||'carChange', userName: r.userName, changes: r.requestedChanges}));
        const upgs = (requestsData.upgradeRequests||[]).map(r => ({...r, type:'upgrade', userName: r.userName, changes:{}}));
        MockData.requests = [...ccrs, ...upgs];
        break;
      }
      case 'users': {
        const data = await API.getUsers();
        MockData.users = data.users || MockData.users;
        break;
      }
      case 'employees': {
        const data = await API.getEmployees();
        MockData.employees = data.employees || MockData.employees;
        break;
      }
      case 'reports': {
        const data = await API.getReports();
        MockData.reports = data.reports || MockData.reports;
        break;
      }
      case 'appointments': {
        const data = await API.getAppointments();
        MockData.appointments = data.appointments || MockData.appointments;
        break;
      }
      case 'payments': {
        const data = await API.getPayments();
        MockData.payments = data.payments || MockData.payments;
        break;
      }
      case 'oilChanges': {
        const data = await API.getOilChanges();
        MockData.oilChanges = data.bookings || MockData.oilChanges;
        break;
      }
      case 'requests': {
        const data = await API.getRequests();
        const ccrs = (data.carChangeRequests||[]).map(r => ({...r, type: r.type||'carChange', userName: r.userName, changes: r.requestedChanges}));
        const upgs = (data.upgradeRequests||[]).map(r => ({...r, type:'upgrade', userName: r.userName, changes:{}}));
        MockData.requests = [...ccrs, ...upgs];
        break;
      }
      case 'notifications': {
        const data = await API.getNotifications();
        MockData.notifications = data.notifications || MockData.notifications;
        break;
      }
      case 'analytics': {
        const range = { from: analyticsFrom, to: analyticsTo };
        const [usersData, reportsData, paymentsData, oilData, requestsData, aptsData] = await Promise.all([
          API.getUsers(), API.getReports(range), API.getPayments(range), API.getOilChanges(), API.getRequests(), API.getAppointments(range),
        ]);
        MockData.users = usersData.users || MockData.users;
        MockData.reports = reportsData.reports || MockData.reports;
        MockData.payments = paymentsData.payments || MockData.payments;
        MockData.oilChanges = oilData.bookings || MockData.oilChanges;
        MockData.appointments = aptsData.appointments || MockData.appointments;
        const ccrs = (requestsData.carChangeRequests||[]).map(r => ({...r, type: r.type||'carChange', userName: r.userName, changes: r.requestedChanges}));
        const upgs = (requestsData.upgradeRequests||[]).map(r => ({...r, type:'upgrade', userName: r.userName, changes:{}}));
        MockData.requests = [...ccrs, ...upgs];
        break;
      }
      case 'settings': {
        // Admin endpoints return ALL records (active + inactive), unlike public /api/config/*
        const [branches, plans, banners] = await Promise.all([
          API.getBranches().catch(() => ({})),
          API.getPlans().catch(() => ({})),
          API.getBanners().catch(() => ({})),
        ]);
        if (branches.branches) MockData.branches = branches.branches;
        if (plans.plans) MockData.plans = plans.plans;
        if (banners.banners) MockData.adBanners = banners.banners;
        // Load config values
        const [support, accounts, privacy, cities, onboarding] = await Promise.all([
          API.getConfig('support_info'), API.getConfig('payment_accounts'),
          API.getConfig('privacy_policy'), API.getConfig('available_cities'),
          API.getConfig('onboarding_pages'),
        ]);
        if (support.value) MockData.supportInfo = support.value;
        if (accounts.value) MockData.paymentAccounts = accounts.value;
        if (privacy.value) MockData.privacyPolicy = privacy.value;
        // Cities: always normalize to an array so .map() below never crashes.
        MockData.cities = Array.isArray(cities.value) ? cities.value : (MockData.cities || []);
        MockData.onboardingPages = Array.isArray(onboarding.value) ? onboarding.value : [];
        break;
      }
    }
  } catch(e) { console.warn('refreshPageData error:', e); }
}

function pgNotFound(el) { el.innerHTML='<div class="empty-state">الصفحة غير موجودة</div>'; }

// ═════════════════════════════════════════════════════════════════════════════
// DASHBOARD
// ═════════════════════════════════════════════════════════════════════════════

function pgDashboard(el) {
  const d = currentUser.department, D = MockData;

  // Compute stats
  const pendingUsers = D.users.filter(u=>u.status==='pending').length;
  const totalUsers = D.users.length;
  const approvedUsers = D.users.filter(u=>u.status==='approved').length;
  const pendingReports = D.reports.filter(r=>r.status==='pending').length;
  const inRepairReports = D.reports.filter(r=>r.status==='inRepair').length;
  const reviewReports = D.reports.filter(r=>r.status==='underReview').length;
  const pendingRequests = D.requests.filter(r=>r.status==='pending').length;
  const unpaidPay = D.payments.filter(p=>p.status==='unpaid').length;
  const overduePay = D.payments.filter(p=>p.status==='overdue').length;
  const paidPay = D.payments.filter(p=>p.status==='paid').length;
  const activeSubs = D.users.flatMap(u=>u.cars||[]).filter(c=>c.subscription&&c.subscription!=='none').length;
  const pendingOil = D.oilChanges.filter(o=>o.status==='pending').length;
  const totalRevenue = D.payments.filter(p=>p.status==='paid').reduce((s,p)=>s+p.amountIQD,0);
  const activeEmps = D.employees.filter(e=>e.isActive).length;

  // Time-based greeting
  const hour = new Date().getHours();
  const greeting = hour < 12 ? 'صباح الخير' : hour < 17 ? 'مساء الخير' : 'مساء الخير';

  // Today's date formatted
  const today = new Date();
  const dateStr = today.toLocaleDateString('ar-IQ', { weekday:'long', year:'numeric', month:'long', day:'numeric' });

  // Build stat cards per department
  let statsHtml = '';
  const statCard = (icon, title, value, sub, color, page) =>
    `<div class="dash-stat" onclick="navigate('${page}')" style="cursor:pointer">
      <div class="dash-stat-icon" style="background:${color}12;color:${color}">${icon}</div>
      <div class="dash-stat-body">
        <div class="dash-stat-value" style="color:${color}">${value}</div>
        <div class="dash-stat-title">${title}</div>
        <div class="dash-stat-sub">${sub}</div>
      </div>
    </div>`;

  if (d==='admin'||d==='administration') {
    statsHtml += statCard(ic('users'),'المستخدمون',totalUsers,`${pendingUsers} بانتظار الموافقة`,'var(--primary)','users');
    statsHtml += statCard(ic('inbox'),'طلبات معلقة',pendingRequests,'تحتاج مراجعة','var(--administration)','requests');
  }
  if (d==='admin'||d==='maintenance') {
    statsHtml += statCard(ic('siren'),'بلاغات الحوادث',pendingReports+reviewReports,`${pendingReports} جديد · ${inRepairReports} قيد الإصلاح`,'var(--maintenance)','reports');
    statsHtml += statCard(ic('wrench'),'تغيير الزيت',pendingOil,'بانتظار الجدولة','#065F46','oilChanges');
  }
  if (d==='admin'||d==='finance') {
    statsHtml += statCard(ic('credit-card'),'المدفوعات',unpaidPay+overduePay,`${overduePay} متأخرة · ${paidPay} مسددة`,'var(--error)','payments');
    statsHtml += statCard(ic('clipboard-list'),'الاشتراكات',activeSubs,'اشتراك فعّال','var(--finance)','subscriptions');
  }
  if (d==='admin') {
    statsHtml += statCard(ic('id-card'),'الموظفون',activeEmps,'حساب نشط','var(--info)','employees');
    statsHtml += statCard(ic('wallet'),'الإيرادات المحصّلة',fmtIQD(totalRevenue),'إجمالي المسدد','var(--success)','payments');
  }

  // Recent activity feed
  let activityHtml = '';
  const activities = [];

  if (d==='admin'||d==='maintenance') {
    D.reports.filter(r=>r.status!=='completed'&&r.status!=='rejected').slice(0,3).forEach(r => {
      activities.push({ time:r.submittedAt, icon:'siren', color:'var(--maintenance)',
        title:`بلاغ حادث — ${esc(r.userName)}`, sub:`${esc(r.carDesc)} · ${esc(r.location)}`,
        badge:ReportStatusLabels[r.status], badgeType:ReportStatusBadge[r.status], page:'reports' });
    });
  }
  if (d==='admin'||d==='finance') {
    D.payments.filter(p=>p.status!=='paid').slice(0,3).forEach(p => {
      activities.push({ time:p.dueDate, icon:'credit-card', color:'var(--error)',
        title:`دفعة ${p.month} — ${esc(p.userName)}`, sub:`${fmtIQD(p.amountIQD)} · ${esc(p.carDesc)}`,
        badge:PayStatusLabels[p.status], badgeType:PayStatusBadge[p.status], page:'payments' });
    });
  }
  if (d==='admin'||d==='administration') {
    D.requests.filter(r=>r.status==='pending').slice(0,3).forEach(r => {
      activities.push({ time:r.submittedAt, icon:RequestTypeIcons[r.type], color:'var(--administration)',
        title:`${RequestTypeLabels[r.type]} — ${esc(r.userName)}`, sub:fmtDate(r.submittedAt),
        badge:'معلق', badgeType:'warning', page:'requests' });
    });
  }
  if (d==='admin'||d==='administration') {
    D.users.filter(u=>u.status==='pending').slice(0,2).forEach(u => {
      activities.push({ time:u.createdAt, icon:'user', color:'var(--primary)',
        title:`تسجيل جديد — ${esc(u.fullName)}`, sub:u.phone,
        badge:'بانتظار الموافقة', badgeType:'warning', page:'users' });
    });
  }

  activities.sort((a,b) => new Date(b.time)-new Date(a.time));

  if (activities.length) {
    activityHtml = `
      <div class="dash-section">
        <div class="dash-section-header">
          <span>${ic('zap')} النشاط الأخير</span>
          <span class="text-hint fs-12">${activities.length} عنصر يحتاج انتباهك</span>
        </div>
        ${activities.slice(0,6).map(a => `
          <div class="dash-activity" onclick="navigate('${a.page}')">
            <div class="dash-activity-icon" style="background:${a.color}12;color:${a.color}">${ic(a.icon)}</div>
            <div class="dash-activity-body">
              <div class="dash-activity-title">${a.title}</div>
              <div class="dash-activity-sub">${a.sub}</div>
            </div>
            ${badge(a.badgeType, a.badge)}
          </div>
        `).join('')}
      </div>`;
  }

  // Quick actions
  let quickHtml = '';
  const actions = [];
  if (d==='admin'||d==='administration') actions.push({ icon:'users', label:'المستخدمون الجدد', page:'users', count:pendingUsers });
  if (d==='admin'||d==='maintenance') actions.push({ icon:'siren', label:'البلاغات الجديدة', page:'reports', count:pendingReports });
  if (d==='admin'||d==='finance') actions.push({ icon:'credit-card', label:'مدفوعات بانتظار التأكيد', page:'payments', count:unpaidPay });
  if (d==='admin'||d==='maintenance') actions.push({ icon:'wrench', label:'طلبات زيت جديدة', page:'oilChanges', count:pendingOil });
  if (d==='admin'||d==='administration'||d==='finance') actions.push({ icon:'inbox', label:'طلبات معلقة', page:'requests', count:pendingRequests });

  if (actions.filter(a=>a.count>0).length) {
    quickHtml = `
      <div class="dash-section">
        <div class="dash-section-header"><span>${ic('target')} إجراءات سريعة</span></div>
        <div class="dash-quick-grid">
          ${actions.filter(a=>a.count>0).map(a => `
            <div class="dash-quick-card" onclick="navigate('${a.page}')">
              <span class="dash-quick-icon">${ic(a.icon)}</span>
              <span class="dash-quick-count">${a.count}</span>
              <span class="dash-quick-label">${a.label}</span>
            </div>
          `).join('')}
        </div>
      </div>`;
  }

  el.innerHTML = `
    <!-- Welcome Banner -->
    <div class="dash-welcome">
      <div class="dash-welcome-text">
        <div class="dash-welcome-greeting">${greeting}، ${currentUser.fullName}</div>
        <div class="dash-welcome-date">${dateStr}</div>
        <div class="dash-welcome-dept">${DeptLabels[d]}</div>
      </div>
      <div class="dash-welcome-logo">URUK<br>MOTORS</div>
    </div>

    <!-- Stats Grid -->
    <div class="dash-stats-grid">${statsHtml}</div>

    <!-- Two column: Activity + Quick Actions -->
    <div class="dash-bottom-grid">
      <div>${activityHtml}</div>
      <div>${quickHtml}</div>
    </div>
  `;
}

// ═════════════════════════════════════════════════════════════════════════════
// USERS — Full profile with ID images, cars, subscriptions
// ═════════════════════════════════════════════════════════════════════════════

function pgUsers(el) {
  el.innerHTML=`<div class="page-header"><h2 class="page-title">المستخدمون</h2></div>
    <div class="tabs" id="user-tabs"></div><div id="users-list"></div>`;
  renderUserTabs(); filterUsers('all');
}

function renderUserTabs() {
  const counts = { all:MockData.users.length, pending:MockData.users.filter(u=>u.status==='pending').length, approved:MockData.users.filter(u=>u.status==='approved').length, suspended:MockData.users.filter(u=>u.status==='suspended').length };
  document.getElementById('user-tabs').innerHTML = [
    ['all','الكل'],['pending','بانتظار الموافقة'],['approved','معتمدون'],['suspended','موقوفون']
  ].map(([k,l])=>`<div class="tab" data-f="${k}" onclick="filterUsers('${k}')">${l} (${counts[k]})</div>`).join('');
}

function filterUsers(f) {
  document.querySelectorAll('#user-tabs .tab').forEach(t=>t.classList.toggle('active',t.dataset.f===f));
  const list = f==='all' ? MockData.users : MockData.users.filter(u=>u.status===f);
  document.getElementById('users-list').innerHTML = !list.length ? '<div class="empty-state">لا يوجد مستخدمون</div>' :
    list.map(u=>renderUserCard(u)).join('');
  refreshIcons();
}

function renderUserCard(u) {
  const carsHtml = (u.cars||[]).map(c=>`<span class="chip" style="background:var(--${SubBadge[c.subscription]||'info'}-light,var(--bg));color:var(--${SubBadge[c.subscription]||'info'},var(--text-secondary))">${c.make} ${c.model} · ${SubLabels[c.subscription]||'—'}</span>`).join(' ');
  return `<div class="list-card" style="cursor:pointer" onclick="showUserDetail('${u.id}')">
    <div class="topbar-avatar">${initial(u.fullName)}</div>
    <div class="list-info">
      <div class="list-title">${esc(u.fullName)}</div>
      <div class="list-sub">${esc(u.phone)} ${u.email?'· '+esc(u.email):''}</div>
      <div style="margin-top:4px">${carsHtml}</div>
    </div>
    ${badge(UserStatusBadge[u.status], UserStatusLabels[u.status])}
    <div class="list-actions">
      ${u.status==='pending'?`<button class="icon-btn icon-btn-success" title="قبول" onclick="event.stopPropagation();updateUser('${u.id}','approved')">${ic('check')}</button><button class="icon-btn icon-btn-error" title="رفض" onclick="event.stopPropagation();updateUser('${u.id}','rejected')">${ic('x')}</button>`:''}
      ${u.status==='approved'?`<button class="icon-btn icon-btn-warning" title="إيقاف" onclick="event.stopPropagation();updateUser('${u.id}','suspended')">${ic('ban')}</button>`:''}
      ${u.status==='suspended'?`<button class="icon-btn icon-btn-success" title="إعادة" onclick="event.stopPropagation();updateUser('${u.id}','approved')">${ic('rotate-ccw')}</button>`:''}
    </div>
  </div>`;
}

async function updateUser(id,status) {
  try {
    await API.updateUserStatus(id,status);
    showToast('success','تم تحديث حالة المستخدم');
  } catch(e){ return; }
  navigate('users');
}

function showUserDetail(id) {
  const u = MockData.users.find(u=>u.id===id);
  if(!u) return;
  const el = document.getElementById('page-content');

  // Cars
  const carsHtml = (u.cars||[]).map(c=>{
    const rem = (c.repairsAllowed||0)-(c.repairsUsed||0);
    const tot = c.repairsAllowed||0;
    const pct = tot>0?(rem/tot*100):0;
    const pctColor = pct>50?'var(--success)':pct>20?'var(--warning)':'var(--error)';
    return `<div class="card" style="margin-bottom:12px">
      <div class="flex gap-12" style="align-items:center;margin-bottom:12px">
        ${c.imageUrl?`<img src="${esc(c.imageUrl)}" style="width:80px;height:60px;object-fit:cover;border-radius:8px">`:`<div class="list-icon" style="background:var(--primary-surface);color:var(--primary)">${ic('car')}</div>`}
        <div class="list-info">
          <div class="list-title">${c.make} ${c.model} ${c.year}</div>
          <div class="list-sub">${c.color} · ${c.plateNumber}</div>
        </div>
        ${badge(SubBadge[c.subscription]||'info',SubLabels[c.subscription]||'—')}
      </div>
      ${c.subscription&&c.subscription!=='none'?`
        <div class="detail-row"><div class="detail-label">الاشتراك</div><div class="detail-value">${SubLabels[c.subscription]} — ${fmtIQD(SubPrices[c.subscription]||0)}/شهرياً</div></div>
        <div class="detail-row"><div class="detail-label">مدة الدفع</div><div class="detail-value">${c.paymentMonths} ${c.paymentMonths===1?'شهر':'أشهر'}</div></div>
        <div class="detail-row"><div class="detail-label">ينتهي</div><div class="detail-value">${c.subscriptionExpiry||'—'}</div></div>
        <div class="detail-row"><div class="detail-label">التصليحات</div><div class="detail-value">${c.repairsUsed||0} / ${tot} <span style="color:${pctColor};font-weight:700">(${rem} متبقي)</span></div></div>
        <div style="height:6px;background:var(--bg);border-radius:3px;margin-top:6px"><div style="height:100%;width:${pct}%;background:${pctColor};border-radius:3px"></div></div>
      `:'<div class="text-secondary fs-12">لا يوجد اشتراك</div>'}
    </div>`;
  }).join('');

  el.innerHTML = `
    <button class="btn btn-outline btn-sm mb-16" onclick="navigate('users')">${ic('arrow-right')} العودة للمستخدمون</button>
    <div class="detail-panel">
      <div class="detail-header">
        <div class="topbar-avatar" style="width:56px;height:56px;font-size:22px">${initial(u.fullName)}</div>
        <div style="flex:1">
          <h2 style="margin-bottom:2px">${esc(u.fullName)}</h2>
          <div class="text-secondary">${esc(u.phone)} ${u.email?'· '+esc(u.email):''}</div>
          <div class="text-hint fs-11">عضو منذ: ${u.createdAt}</div>
        </div>
        ${badge(UserStatusBadge[u.status], UserStatusLabels[u.status])}
        <div class="list-actions">
          ${u.status==='pending'?`<button class="btn btn-sm btn-success" onclick="updateUser('${u.id}','approved');showUserDetail('${u.id}')">قبول</button><button class="btn btn-sm btn-error" onclick="updateUser('${u.id}','rejected');showUserDetail('${u.id}')">رفض</button>`:''}
          ${u.status==='approved'?`<button class="btn btn-sm btn-warning" onclick="updateUser('${u.id}','suspended');showUserDetail('${u.id}')">إيقاف</button>`:''}
          ${u.status==='suspended'?`<button class="btn btn-sm btn-success" onclick="updateUser('${u.id}','approved');showUserDetail('${u.id}')">إعادة تفعيل</button>`:''}
        </div>
      </div>

      <div class="two-col">
        <div>
          <div class="detail-section">
            <div class="detail-section-title">${ic('id-card')} الهوية الوطنية</div>
            ${u.idFrontUrl||u.idBackUrl?`<div class="photo-grid">
              ${u.idFrontUrl?`<div><img src="${esc(u.idFrontUrl)}" class="photo-thumb" onclick="openLightbox('${esc(u.idFrontUrl)}')"><div class="fs-11 text-center text-secondary">الوجه الأمامي</div></div>`:'<div class="text-hint fs-12">الأمامي: لم يُرفع</div>'}
              ${u.idBackUrl?`<div><img src="${esc(u.idBackUrl)}" class="photo-thumb" onclick="openLightbox('${esc(u.idBackUrl)}')"><div class="fs-11 text-center text-secondary">الوجه الخلفي</div></div>`:'<div class="text-hint fs-12">الخلفي: لم يُرفع</div>'}
            </div>`:'<div class="text-hint">لم يتم رفع صور الهوية</div>'}
          </div>
        </div>
        <div>
          <div class="detail-section">
            <div class="detail-section-title">${ic('car')} السيارات (${(u.cars||[]).length})</div>
            ${(u.cars||[]).length?carsHtml:'<div class="text-hint">لا توجد سيارات مسجلة</div>'}
          </div>
        </div>
      </div>

      ${renderUserActivity(u.id)}
    </div>`;
  refreshIcons();
}

// Renders all of a user's activity (reports / payments / appointments / oil / requests)
// inside the user detail page so admins can see everything in one place.
function renderUserActivity(userId) {
  const reports     = MockData.reports.filter(r=>r.userId===userId);
  const payments    = MockData.payments.filter(p=>p.userId===userId);
  const appointments= MockData.appointments.filter(a=>a.userId===userId);
  const oilChanges  = MockData.oilChanges.filter(o=>o.userId===userId);
  const requests    = MockData.requests.filter(r=>r.userId===userId);

  const section = (title, iconName, count, body) => `
    <div class="detail-section" style="margin-top:16px">
      <div class="detail-section-title">${ic(iconName)} ${title} (${count})</div>
      ${count===0 ? '<div class="text-hint fs-12">لا يوجد</div>' : body}
    </div>`;

  const reportsBody = reports.map(r=>`
    <div class="list-card" style="margin-bottom:8px;cursor:pointer" onclick="showReportDetail('${r.id}')">
      <div class="list-icon" style="background:var(--${ReportStatusBadge[r.status]}-light,var(--warning-light));color:var(--${ReportStatusBadge[r.status]},var(--warning))">${ic('siren')}</div>
      <div class="list-info">
        <div class="list-title">${esc(r.carDesc)}</div>
        <div class="list-sub">${esc(r.location)} · ${fmtDate(r.accidentDate)}</div>
      </div>
      ${badge(ReportStatusBadge[r.status], ReportStatusLabels[r.status])}
    </div>`).join('');

  const paymentsBody = payments.map(p=>`
    <div class="list-card" style="margin-bottom:8px;cursor:pointer" onclick="showPayDetail('${p.id}')">
      <div class="list-icon" style="background:var(--${PayStatusBadge[p.status]}-light,var(--warning-light));color:var(--${PayStatusBadge[p.status]},var(--warning))">${ic('credit-card')}</div>
      <div class="list-info">
        <div class="list-title">${fmtIQD(p.amountIQD)} — ${p.month}</div>
        <div class="list-sub">${p.carDesc||'—'} · استحقاق: ${fmtDate(p.dueDate)}</div>
      </div>
      ${badge(PayStatusBadge[p.status], PayStatusLabels[p.status])}
    </div>`).join('');

  const appointmentsBody = appointments.map(a=>`
    <div class="list-card" style="margin-bottom:8px;cursor:pointer" onclick="showAptDetail('${a.id}')">
      <div class="list-icon" style="background:var(--${AptStatusBadge[a.status]}-light,var(--primary-surface));color:var(--${AptStatusBadge[a.status]},var(--primary))">${ic('calendar')}</div>
      <div class="list-info">
        <div class="list-title">${fmtDate(a.scheduledDate)} · ${a.timeSlot}</div>
        <div class="list-sub">${a.branchName||'—'}</div>
      </div>
      ${badge(AptStatusBadge[a.status], AptStatusLabels[a.status])}
    </div>`).join('');

  const oilBody = oilChanges.map(o=>`
    <div class="list-card" style="margin-bottom:8px;cursor:pointer" onclick="showOilDetail('${o.id}')">
      <div class="list-icon" style="background:var(--${OilStatusBadge[o.status]}-light,var(--warning-light));color:var(--${OilStatusBadge[o.status]},var(--warning))">${ic('wrench')}</div>
      <div class="list-info">
        <div class="list-title">${esc(o.carDesc)}</div>
        <div class="list-sub">${o.scheduledDate?fmtDate(o.scheduledDate)+' · '+(o.timeSlot||''):'لم يُجدول بعد'} · ${o.branchName||'—'}</div>
      </div>
      ${badge(OilStatusBadge[o.status], OilStatusLabels[o.status])}
    </div>`).join('');

  const requestsBody = requests.map(r=>`
    <div class="list-card" style="margin-bottom:8px">
      <div class="list-icon" style="background:var(--administration-light);color:var(--administration)">${ic(RequestTypeIcons[r.type]||'inbox')}</div>
      <div class="list-info">
        <div class="list-title">${RequestTypeLabels[r.type]}</div>
        <div class="list-sub">${fmtDate(r.submittedAt)}</div>
      </div>
      ${badge(RequestStatusBadge[r.status], RequestStatusLabels[r.status])}
    </div>`).join('');

  return `
    <div class="two-col" style="margin-top:8px">
      <div>
        ${section('بلاغات الحوادث', 'siren', reports.length, reportsBody)}
        ${section('المواعيد', 'calendar', appointments.length, appointmentsBody)}
        ${section('طلبات تغيير الزيت', 'wrench', oilChanges.length, oilBody)}
      </div>
      <div>
        ${section('المدفوعات', 'credit-card', payments.length, paymentsBody)}
        ${section('الطلبات الإدارية', 'inbox', requests.length, requestsBody)}
      </div>
    </div>`;
}

// ═════════════════════════════════════════════════════════════════════════════
// EMPLOYEES
// ═════════════════════════════════════════════════════════════════════════════

function pgEmployees(el) {
  el.innerHTML = `<div class="page-header"><h2 class="page-title">الموظفون</h2><button class="btn btn-primary" onclick="modalAddEmployee()">+ إضافة موظف</button></div>
    <table class="data-table"><thead><tr><th>الاسم</th><th>البريد</th><th>الهاتف</th><th>القسم</th><th>الحالة</th><th>إجراء</th></tr></thead><tbody>
    ${MockData.employees.map(e=>`<tr><td>${esc(e.fullName)}</td><td style="direction:ltr;text-align:right">${esc(e.email)}</td><td style="direction:ltr;text-align:right">${esc(e.phone)}</td>
      <td><span class="badge" style="background:${DeptBg[e.department]};color:${DeptColors[e.department]}">${DeptLabels[e.department]}</span></td>
      <td>${badge(e.isActive?'success':'error',e.isActive?'نشط':'معطّل')}</td>
      <td style="white-space:nowrap">
        <button class="btn btn-sm btn-outline" onclick="modalEditEmployee('${e.id}')">${ic('pencil')} تعديل</button>
        <button class="btn btn-sm ${e.isActive?'btn-outline-error':'btn-success'}" onclick="toggleEmp('${e.id}')">${e.isActive?'تعطيل':'تفعيل'}</button>
      </td></tr>`).join('')}
    </tbody></table>`;
}

async function toggleEmp(id) {
  const e = MockData.employees.find(e=>e.id===id);
  if (!e) return;
  try {
    await API.updateEmployee(id, {isActive: !e.isActive});
    showToast('success', e.isActive ? 'تم تعطيل الموظف' : 'تم تفعيل الموظف');
  } catch(ex){ return; }
  navigate('employees');
}

function modalAddEmployee() {
  showModal('إضافة موظف جديد', `
    <div class="form-group"><label class="form-label">الاسم الكامل</label><input class="form-input" id="emp-name"></div>
    <div class="form-group"><label class="form-label">البريد الإلكتروني (اسم المستخدم)</label><input class="form-input" id="emp-email" dir="ltr" placeholder="user@uruk.iq"></div>
    <div class="form-group"><label class="form-label">رقم الهاتف</label><input class="form-input" id="emp-phone" dir="ltr"></div>
    <div class="form-group"><label class="form-label">كلمة المرور</label>
      <input class="form-input" id="emp-password" type="text" dir="ltr" value="123456" placeholder="6 أحرف على الأقلّ">
      <div class="text-hint fs-11 mt-6">يستعمل الموظّف هذه الكلمة مع البريد الإلكترونيّ لتسجيل الدخول.</div>
    </div>
    <div class="form-group"><label class="form-label">القسم (الصلاحيّات)</label><select class="form-select" id="emp-dept">
      <option value="finance">المالية — يدير المدفوعات والإيصالات</option>
      <option value="maintenance">الصيانة — يدير البلاغات وتغيير الزيت</option>
      <option value="administration">الإدارة — صلاحيّات عامّة (المستخدمون، المواعيد)</option>
    </select></div>`,
    `<button class="btn btn-outline" onclick="closeModal()">إلغاء</button>
     <button class="btn btn-primary" onclick="addEmp()">إضافة</button>`);
}

async function addEmp() {
  const n = document.getElementById('emp-name').value.trim();
  const email = document.getElementById('emp-email').value.trim();
  const password = document.getElementById('emp-password').value.trim();
  if (!n) { showToast('warning','أدخل اسم الموظف'); return; }
  if (!email) { showToast('warning','أدخل البريد الإلكترونيّ'); return; }
  if (!password || password.length < 6) { showToast('warning','كلمة المرور يجب أن تكون 6 أحرف على الأقلّ'); return; }
  try {
    await API.createEmployee({
      fullName: n,
      email,
      phone: document.getElementById('emp-phone').value.trim(),
      password,
      department: document.getElementById('emp-dept').value,
    });
    showToast('success','تمت إضافة الموظف بنجاح');
  } catch(e){ return; }
  closeModal(); navigate('employees');
}

function modalEditEmployee(id) {
  const e = MockData.employees.find(x => x.id === id);
  if (!e) { showToast('error','الموظّف غير موجود'); return; }
  showModal('تعديل موظف: ' + esc(e.fullName), `
    <div class="form-group"><label class="form-label">الاسم الكامل</label>
      <input class="form-input" id="emp-edit-name" value="${esc(e.fullName)}"></div>
    <div class="form-group"><label class="form-label">البريد الإلكترونيّ</label>
      <input class="form-input" value="${esc(e.email)}" dir="ltr" disabled>
      <div class="text-hint fs-11 mt-6">لا يمكن تغيير البريد الإلكترونيّ بعد الإنشاء.</div>
    </div>
    <div class="form-group"><label class="form-label">رقم الهاتف</label>
      <input class="form-input" id="emp-edit-phone" dir="ltr" value="${esc(e.phone||'')}"></div>
    <div class="form-group"><label class="form-label">القسم (الصلاحيّات)</label>
      <select class="form-select" id="emp-edit-dept">
        <option value="finance" ${e.department==='finance'?'selected':''}>المالية</option>
        <option value="maintenance" ${e.department==='maintenance'?'selected':''}>الصيانة</option>
        <option value="administration" ${e.department==='administration'?'selected':''}>الإدارة</option>
      </select>
    </div>
    <div class="form-group"><label class="form-label">كلمة مرور جديدة (اختياريّ)</label>
      <input class="form-input" id="emp-edit-password" type="text" dir="ltr" placeholder="اتركها فارغة للاحتفاظ بالحاليّة">
      <div class="text-hint fs-11 mt-6">إن أدخلت كلمة هنا، ستحلّ محلّ الكلمة الحاليّة (٦ أحرف على الأقلّ).</div>
    </div>`,
    `<button class="btn btn-outline" onclick="closeModal()">إلغاء</button>
     <button class="btn btn-primary" onclick="saveEditEmp('${e.id}')">${ic('save')} حفظ</button>`);
}

async function saveEditEmp(id) {
  const updates = {
    fullName: document.getElementById('emp-edit-name').value.trim(),
    phone: document.getElementById('emp-edit-phone').value.trim(),
    department: document.getElementById('emp-edit-dept').value,
  };
  const newPwd = document.getElementById('emp-edit-password').value.trim();
  if (newPwd) {
    if (newPwd.length < 6) { showToast('warning','كلمة المرور يجب أن تكون 6 أحرف على الأقلّ'); return; }
    updates.password = newPwd;
  }
  try {
    await API.updateEmployee(id, updates);
    showToast('success','تم حفظ تعديلات الموظف');
  } catch (e) { return; }
  closeModal(); navigate('employees');
}

// ═════════════════════════════════════════════════════════════════════════════
// REPORTS — Full detail with photos, notes, repair archive, status pipeline
// ═════════════════════════════════════════════════════════════════════════════

function pgReports(el) {
  const statuses = [null,'pending','underReview','approved','inRepair','completed','rejected'];
  const labels = ['الكل','جديد','قيد المراجعة','معتمد','قيد الإصلاح','مكتمل','مرفوض'];
  el.innerHTML=`<div class="page-header"><h2 class="page-title">بلاغات الحوادث</h2></div>
    <div class="tabs" id="report-tabs">${labels.map((l,i)=>`<div class="tab ${i===0?'active':''}" data-f="${statuses[i]||'all'}" onclick="filterReports('${statuses[i]||'all'}')">${l} (${statuses[i]?MockData.reports.filter(r=>r.status===statuses[i]).length:MockData.reports.length})</div>`).join('')}</div>
    <div id="reports-list"></div>`;
  filterReports('all');
}

function filterReports(f) {
  document.querySelectorAll('#report-tabs .tab').forEach(t=>t.classList.toggle('active',t.dataset.f===f));
  const list = f==='all'?MockData.reports:MockData.reports.filter(r=>r.status===f);
  document.getElementById('reports-list').innerHTML = !list.length?'<div class="empty-state">لا توجد بلاغات</div>':list.map(r=>`
    <div class="list-card" style="cursor:pointer" onclick="showReportDetail('${r.id}')">
      <div class="list-icon" style="background:var(--${ReportStatusBadge[r.status]}-light,var(--warning-light));color:var(--${ReportStatusBadge[r.status]},var(--warning))">${ic('siren')}</div>
      <div class="list-info">
        <div class="list-title">${esc(r.userName)}</div>
        <div class="list-sub">${esc(r.carDesc)} · ${esc(r.location)}</div>
        <div class="list-hint">${fmtDate(r.accidentDate)} · ${r.photoUrls.length} صور ${r.otherPartyInvolved?'· طرف آخر':''}</div>
      </div>
      ${badge(ReportStatusBadge[r.status], ReportStatusLabels[r.status])}
    </div>`).join('');
  refreshIcons();
}

function showReportDetail(id) {
  const r = MockData.reports.find(r=>r.id===id);
  if(!r) return;
  const el = document.getElementById('page-content');
  const pipeSteps = { pending:'جديد', underReview:'مراجعة', approved:'معتمد', inRepair:'إصلاح', completed:'مكتمل' };
  const nextStatuses = ReportStatusFlow[r.status]||[];

  el.innerHTML = `
    <button class="btn btn-outline btn-sm mb-16" onclick="navigate('reports')">${ic('arrow-right')} العودة للبلاغات</button>
    <div class="detail-panel">
      <div class="detail-header">
        <div class="list-icon" style="background:var(--${ReportStatusBadge[r.status]}-light,var(--warning-light));color:var(--${ReportStatusBadge[r.status]},var(--warning));width:56px;height:56px">${ic('siren', 28)}</div>
        <div style="flex:1">
          <h2 style="margin-bottom:2px">بلاغ حادث — ${r.id}</h2>
          <div class="text-secondary">${esc(r.userName)} · ${esc(r.carDesc)}</div>
        </div>
        ${badge(ReportStatusBadge[r.status], ReportStatusLabels[r.status])}
      </div>

      ${r.status!=='rejected'?pipeline(pipeSteps, r.status):''}

      <div class="two-col">
        <div>
          <div class="detail-section">
            <div class="detail-section-title">${ic('clipboard-list')} تفاصيل البلاغ</div>
            <div class="detail-row"><div class="detail-label">تاريخ الحادث</div><div class="detail-value">${fmtDate(r.accidentDate)}</div></div>
            <div class="detail-row"><div class="detail-label">الموقع</div><div class="detail-value">${esc(r.location)}</div></div>
            <div class="detail-row"><div class="detail-label">الإحداثيات</div><div class="detail-value" style="direction:ltr;text-align:right">${r.lat}, ${r.lng}</div></div>
            <div class="detail-row"><div class="detail-label">طرف آخر</div><div class="detail-value">${r.otherPartyInvolved?'<span style="color:var(--warning);font-weight:600">نعم</span>':'لا'}</div></div>
            <div class="detail-row"><div class="detail-label">تاريخ الإرسال</div><div class="detail-value">${fmtDateTime(r.submittedAt)}</div></div>
            ${r.completedAt?`<div class="detail-row"><div class="detail-label">تاريخ الإكمال</div><div class="detail-value">${fmtDate(r.completedAt)}</div></div>`:''}
          </div>

          <div class="detail-section">
            <div class="detail-section-title">${ic('file-text')} وصف الحادث</div>
            <p style="font-size:13px;line-height:1.6;color:var(--text)">${esc(r.description)}</p>
          </div>

          ${r.lat?`<div class="detail-section">
            <div class="detail-section-title">${ic('map-pin')} موقع الحادث</div>
            <div class="map-placeholder">
              <a href="https://www.google.com/maps?q=${r.lat},${r.lng}" target="_blank" style="color:var(--primary);text-decoration:underline">فتح في خرائط جوجل ${ic('external-link')}</a>
            </div>
          </div>`:''}
        </div>

        <div>
          ${photoGrid(r.photoUrls, 'صور الحادث (من المستخدم)')}
          ${photoGrid(r.repairPhotoUrls, 'صور الإصلاح (أرشيف الصيانة)')}

          ${r.maintenanceNotes?`<div class="detail-section">
            <div class="detail-section-title">${ic('wrench')} ملاحظات الصيانة</div>
            <div class="card" style="background:var(--bg)">${esc(r.maintenanceNotes)}</div>
          </div>`:''}
        </div>
      </div>

      <!-- Repair Archive -->
      ${(r.repairArchive&&r.repairArchive.length)?`<div class="detail-section" style="border-top:1px solid var(--divider);padding-top:16px">
        <div class="detail-section-title">${ic('archive')} أرشيف الإصلاح (${r.repairArchive.length} عملية)</div>
        ${r.repairArchive.map((entry,i)=>`
          <div class="card" style="margin-bottom:12px;border:1px solid var(--success);border-right:4px solid var(--success)">
            <div class="flex gap-12" style="align-items:center;margin-bottom:10px">
              <span style="color:var(--success)">${ic('wrench', 20)}</span>
              <div style="flex:1">
                <div class="fw-600">عملية إصلاح #${i+1}</div>
                <div class="text-secondary fs-12">${fmtDate(entry.date)} — ${entry.technician}</div>
              </div>
            </div>
            <p style="font-size:13px;line-height:1.6;margin-bottom:10px">${entry.description}</p>
            ${entry.partsReplaced&&entry.partsReplaced.length?`<div style="margin-bottom:10px">
              <div class="fs-12 fw-600 text-secondary" style="margin-bottom:4px">القطع المستبدلة:</div>
              <div class="flex gap-8" style="flex-wrap:wrap">${entry.partsReplaced.map(p=>`<span class="chip" style="background:var(--success-light);color:var(--success)">${p}</span>`).join('')}</div>
            </div>`:''}
            ${entry.photos&&entry.photos.length?`<div>
              <div class="fs-12 fw-600 text-secondary" style="margin-bottom:6px">صور الإصلاح (${entry.photos.length}):</div>
              <div class="photo-grid">${entry.photos.map(u=>`<img src="${esc(u)}" class="photo-thumb" onclick="openLightbox('${esc(u)}')">`).join('')}</div>
            </div>`:''}
          </div>
        `).join('')}
      </div>`:''}

      <!-- Actions -->
      <div style="border-top:1px solid var(--divider);padding-top:16px;display:flex;gap:8px;flex-wrap:wrap;align-items:center">
        ${nextStatuses.map(ns => {
          if(ns==='completed') return `<button class="btn btn-success" onclick="modalCompleteReport('${r.id}')">${ic('check')} إكمال الإصلاح</button>`;
          if(ns==='rejected') return `<button class="btn btn-error" onclick="modalRejectReport('${r.id}')">${ic('x')} رفض البلاغ</button>`;
          return `<button class="btn btn-primary" onclick="setReportStatus('${r.id}','${ns}')">${ReportNextAction[r.status]||ns}</button>`;
        }).join('')}

        ${r.status==='inRepair'||r.status==='approved'?`<button class="btn btn-outline" onclick="modalAddRepairEntry('${r.id}')">${ic('archive')} إضافة عملية إصلاح</button>`:''}
        ${r.status==='inRepair'||r.status==='approved'?`<button class="btn btn-outline" onclick="modalAddRepairPhotos('${r.id}')">${ic('camera')} إضافة صور</button>`:''}
        ${r.status!=='completed'&&r.status!=='rejected'&&!r.maintenanceNotes?`<button class="btn btn-outline" onclick="modalAddNotes('${r.id}')">${ic('file-text')} إضافة ملاحظات</button>`:''}
        ${!r.appointmentId&&(r.status==='approved'||r.status==='inRepair')?`<button class="btn btn-outline" onclick="modalCreateAppointment('${r.id}','${r.userId}','${esc(r.userName)}')">${ic('calendar')} إنشاء موعد</button>`:''}
      </div>
    </div>`;
  refreshIcons();
}

async function setReportStatus(id,status) {
  try {
    await API.updateReportStatus(id, {status});
    showToast('success','تم تحديث حالة البلاغ');
  } catch(e){ return; }
  try { const data = await API.getReports(); MockData.reports = data.reports || MockData.reports; } catch(e){}
  showReportDetail(id);
}

function modalRejectReport(id) {
  showModal('رفض بلاغ الحادث', `
    <p class="text-secondary fs-12 mb-16">سيتم رفض البلاغ وإرسال إشعار للمستخدم بالسبب.</p>
    <div class="form-group">
      <label class="form-label">سبب الرفض *</label>
      <textarea class="form-input" id="rep-reject-note" rows="4" placeholder="وضّح للمستخدم سبب رفض البلاغ..."></textarea>
    </div>`,
    `<button class="btn btn-outline" onclick="closeModal()">إلغاء</button>
     <button class="btn btn-error" onclick="rejectReport('${id}')">${ic('x')} تأكيد الرفض</button>`);
}

async function rejectReport(id) {
  const note = document.getElementById('rep-reject-note').value.trim();
  if (!note) { showToast('warning','أدخل سبب الرفض'); return; }
  try {
    await API.updateReportStatus(id, {status:'rejected', rejectionReason:note, maintenanceNotes: note});
    showToast('success','تم رفض البلاغ');
  } catch(e){ return; }
  try { const data = await API.getReports(); MockData.reports = data.reports || MockData.reports; } catch(e){}
  closeModal(); showReportDetail(id);
}

function modalCompleteReport(id) {
  showModal('إكمال الإصلاح وتسليم السيارة', `
    <div style="background:var(--success-light);padding:10px;border-radius:8px;margin-bottom:16px;font-size:12px;color:var(--success);display:flex;align-items:center;gap:8px">
      ${ic('alert-triangle')} <span>يجب إضافة تفاصيل الإصلاح النهائية وصور السيارة بعد الصيانة قبل الإكمال. هذه البيانات ستُحفظ في الأرشيف وتظهر للعميل.</span>
    </div>
    <div class="form-group"><label class="form-label">وصف الإصلاح النهائي *</label><textarea class="form-input" id="complete-desc" rows="4" placeholder="وصف تفصيلي لكل الإصلاحات التي تمت على السيارة..."></textarea></div>
    <div class="form-group"><label class="form-label">القطع المستبدلة (مفصولة بفاصلة)</label><input class="form-input" id="complete-parts" placeholder="مثال: مصد أمامي، طلاء أبيض، براغي تثبيت"></div>
    <div class="form-group"><label class="form-label">صور السيارة بعد الإصلاح *</label>
      <div class="upload-area" id="complete-upload-area" onclick="document.getElementById('complete-upload').click()">
        ${ic('camera')} اضغط لاختيار صور السيارة بعد الإصلاح<br><span class="fs-11">صور واضحة للمنطقة التي تم إصلاحها</span>
      </div>
      <input type="file" id="complete-upload" accept="image/*" multiple hidden onchange="onCompletePhotosSelected(this)">
      <div id="complete-photo-count" class="hidden" style="margin-top:8px;color:var(--success);font-size:12px;font-weight:600"></div>
    </div>
    <div class="form-group"><label class="form-label">ملاحظات إضافية للعميل</label><input class="form-input" id="complete-notes" placeholder="مثال: يُرجى فحص الطلاء بعد أسبوع..."></div>`,
    `<button class="btn btn-outline" onclick="closeModal()">إلغاء</button>
     <button class="btn btn-success" onclick="completeReport('${id}')">${ic('check')} إكمال وحفظ الأرشيف</button>`);
}

function onCompletePhotosSelected(input) {
  const n = input.files ? input.files.length : 0;
  const countEl = document.getElementById('complete-photo-count');
  const areaEl = document.getElementById('complete-upload-area');
  if (n > 0) {
    countEl.textContent = `تم اختيار ${n} صورة`;
    countEl.classList.remove('hidden');
    areaEl.style.borderColor = 'var(--success)';
    areaEl.style.background = 'var(--success-light)';
    areaEl.innerHTML = `${ic('check-circle')} ${n} صورة محددة — اضغط لتغيير`;
    refreshIcons();
  }
}

async function completeReport(id) {
  const r = MockData.reports.find(r=>r.id===id);
  if(!r) return;

  const desc = document.getElementById('complete-desc').value.trim();
  if(!desc) { showToast('warning','يرجى كتابة وصف الإصلاح النهائي'); return; }

  // Read the file input directly — avoids stale-global-state bugs.
  const fileInput = document.getElementById('complete-upload');
  const files = fileInput && fileInput.files ? fileInput.files : null;
  if (!files || files.length === 0) {
    showToast('warning','يرجى رفع صور السيارة بعد الإصلاح');
    return;
  }

  const parts = document.getElementById('complete-parts').value.trim().split('،').map(p=>p.trim()).filter(Boolean);
  const extraNotes = document.getElementById('complete-notes').value.trim();

  try {
    // 1. Upload files to server → get URLs
    const upload = await API.uploadFiles(files, 'repairs');
    const photoUrls = upload.urls || [];
    // 2. Add repair entry via API with real URLs
    await API.addRepairEntry(id, {
      date: new Date().toISOString(),
      technician: currentUser.fullName,
      description: desc,
      partsReplaced: parts,
      photos: photoUrls,
      cost: 0,
      isFinal: true,
    });
    // 3. Update status to completed (workflow-enforced)
    await API.updateReportStatus(id, {
      status: 'completed',
      maintenanceNotes: desc + (extraNotes ? '\n' + extraNotes : ''),
    });
    showToast('success', 'اكتمل الإصلاح وحُفظ في الأرشيف');
  } catch(e) { return; /* toast already shown */ }

  try { const data = await API.getReports(); MockData.reports = data.reports || MockData.reports; } catch(e){}
  closeModal();
  showReportDetail(id);
}

function modalAddRepairPhotos(id) {
  showModal('إضافة صور الإصلاح', `
    <div class="upload-area" id="repair-upload-area" onclick="document.getElementById('repair-upload').click()">
      ${ic('camera')} اضغط لاختيار صور الإصلاح<br><span class="fs-11">يمكنك اختيار عدة صور</span>
    </div>
    <input type="file" id="repair-upload" accept="image/*" multiple hidden onchange="onRepairPhotosSelected(this)">
    <div id="repair-photo-count" class="hidden" style="margin-top:8px;color:var(--success);font-size:12px;font-weight:600"></div>
    <p class="text-hint fs-11 mt-16">صور الإصلاح ستُرفع للخادم وتظهر للمستخدم كأرشيف في تفاصيل البلاغ.</p>`,
    `<button class="btn btn-outline" onclick="closeModal()">إلغاء</button>
     <button class="btn btn-primary" onclick="addRepairPhotos('${id}')">حفظ</button>`);
}

function onRepairPhotosSelected(input) {
  const n = input.files.length;
  const countEl = document.getElementById('repair-photo-count');
  const area = document.getElementById('repair-upload-area');
  if (n > 0) {
    countEl.textContent = `تم اختيار ${n} صورة`;
    countEl.classList.remove('hidden');
    area.style.borderColor = 'var(--success)';
    area.style.background = 'var(--success-light)';
    area.innerHTML = `${ic('check-circle')} ${n} صورة محددة — اضغط لتغيير`;
    refreshIcons();
  }
}

async function addRepairPhotos(id) {
  const input = document.getElementById('repair-upload');
  if (!input.files || !input.files.length) { showToast('warning','اختر صوراً أولاً'); return; }
  try {
    const upload = await API.uploadFiles(input.files, 'repairs');
    const urls = upload.urls || [];
    // Persist against report via addRepairEntry with no description — or append to repairPhotoUrls.
    // Backend exposes repair-entry; we'll create a lightweight entry holding just the photos.
    await API.addRepairEntry(id, {
      date: new Date().toISOString(),
      technician: currentUser.fullName,
      description: 'صور إضافية',
      partsReplaced: [],
      photos: urls,
      cost: 0,
      isFinal: false,
    });
    showToast('success', `تم رفع ${urls.length} صورة`);
  } catch(e){ return; }
  try { const data = await API.getReports(); MockData.reports = data.reports || MockData.reports; } catch(e){}
  closeModal(); showReportDetail(id);
}

function modalAddNotes(id) {
  showModal('إضافة ملاحظات صيانة', `
    <div class="form-group"><label class="form-label">ملاحظات</label><textarea class="form-input" id="maint-notes" rows="4" placeholder="تفاصيل الإصلاح أو ملاحظات للمستخدم..."></textarea></div>`,
    `<button class="btn btn-outline" onclick="closeModal()">إلغاء</button>
     <button class="btn btn-primary" onclick="saveNotes('${id}')">حفظ</button>`);
}

async function saveNotes(id) {
  const n = document.getElementById('maint-notes').value.trim();
  if (!n) { showToast('warning','أدخل نص الملاحظات'); return; }
  try {
    // Only update the notes — status stays as-is (backend allows partial update).
    await API.updateReportStatus(id, { maintenanceNotes: n });
    showToast('success', 'تم حفظ الملاحظات');
  } catch(e) { return; }
  try { const data = await API.getReports(); MockData.reports = data.reports || MockData.reports; } catch(e){}
  closeModal(); showReportDetail(id);
}

function modalAddRepairEntry(id) {
  showModal('إضافة عملية إصلاح للأرشيف', `
    <p class="text-secondary fs-12 mb-16">هذه البيانات ستظهر في أرشيف الإصلاح للمستخدم والإدارة</p>
    <div class="form-group"><label class="form-label">وصف الإصلاح</label><textarea class="form-input" id="repair-desc" rows="4" placeholder="وصف تفصيلي للإصلاحات التي تمت..."></textarea></div>
    <div class="form-group"><label class="form-label">القطع المستبدلة (مفصولة بفاصلة)</label><input class="form-input" id="repair-parts" placeholder="مثال: مصد أمامي، طلاء أبيض، براغي تثبيت"></div>
    <div class="form-group"><label class="form-label">صور الإصلاح</label>
      <div class="upload-area" id="archive-upload-area" onclick="document.getElementById('archive-upload').click()">
        ${ic('camera')} اضغط لاختيار صور<br><span class="fs-11">صور قبل وأثناء وبعد الإصلاح</span>
      </div>
      <input type="file" id="archive-upload" accept="image/*" multiple hidden onchange="onArchivePhotosSelected(this)">
      <div id="archive-photo-count" class="hidden" style="margin-top:8px;color:var(--success);font-size:12px;font-weight:600"></div>
    </div>`,
    `<button class="btn btn-outline" onclick="closeModal()">إلغاء</button>
     <button class="btn btn-success" onclick="saveRepairEntry('${id}')">${ic('save')} حفظ في الأرشيف</button>`);
}

function onArchivePhotosSelected(input) {
  const n = input.files.length;
  const countEl = document.getElementById('archive-photo-count');
  const area = document.getElementById('archive-upload-area');
  if (n > 0) {
    countEl.textContent = `تم اختيار ${n} صورة`;
    countEl.classList.remove('hidden');
    area.style.borderColor = 'var(--success)';
    area.style.background = 'var(--success-light)';
    area.innerHTML = `${ic('check-circle')} ${n} صورة محددة`;
    refreshIcons();
  }
}

async function saveRepairEntry(id) {
  const desc = document.getElementById('repair-desc').value.trim();
  if(!desc) { showToast('warning','أدخل وصف الإصلاح'); return; }
  const parts = document.getElementById('repair-parts').value.trim().split('،').map(p=>p.trim()).filter(Boolean);
  const input = document.getElementById('archive-upload');

  try {
    let photoUrls = [];
    if (input.files && input.files.length) {
      const upload = await API.uploadFiles(input.files, 'repairs');
      photoUrls = upload.urls || [];
    }
    await API.addRepairEntry(id, {
      date: new Date().toISOString(),
      technician: currentUser.fullName,
      description: desc,
      partsReplaced: parts,
      photos: photoUrls,
      cost: 0,
      isFinal: false,
    });
    showToast('success', 'تمت إضافة عملية الإصلاح للأرشيف');
  } catch(e){ return; }
  try { const data = await API.getReports(); MockData.reports = data.reports || MockData.reports; } catch(e){}
  closeModal(); showReportDetail(id);
}

function modalCreateAppointment(reportId, userId, userName) {
  showModal('إنشاء موعد صيانة', `
    <div class="form-group"><label class="form-label">الفرع</label><select class="form-select" id="apt-branch">
      ${MockData.branches.filter(b=>b.isActive!==false).map(b=>`<option value="${esc(b.name)}">${esc(b.name)}</option>`).join('')}
    </select></div>
    <div class="form-row">
      <div class="form-group"><label class="form-label">التاريخ</label><input class="form-input" type="date" id="apt-date"></div>
      <div class="form-group"><label class="form-label">الوقت</label><select class="form-select" id="apt-time">
        ${MockData.timeSlots.map(t=>`<option>${t}</option>`).join('')}
      </select></div>
    </div>
    <div class="form-group"><label class="form-label">ملاحظة للمستخدم</label><input class="form-input" id="apt-note" placeholder="مثال: يرجى الحضور قبل 10 دقائق"></div>`,
    `<button class="btn btn-outline" onclick="closeModal()">إلغاء</button>
     <button class="btn btn-primary" onclick="createAppointment('${reportId}','${userId}','${userName}')">إنشاء الموعد</button>`);
}

async function createAppointment(reportId, userId, userName) {
  const date = document.getElementById('apt-date').value;
  if (!date) { showToast('warning','اختر تاريخ الموعد'); return; }
  const branch = MockData.branches.find(b=>b.name===document.getElementById('apt-branch').value);
  try {
    await API.createAppointment({
      userId, reportId,
      scheduledDate: date,
      timeSlot: document.getElementById('apt-time').value,
      branchName: branch?.name||'',
      locationLat: branch?.lat,
      locationLng: branch?.lng,
      maintenanceNote: document.getElementById('apt-note').value.trim()||null,
    });
    showToast('success','تم إنشاء الموعد وإرسال إشعار للمستخدم');
  } catch(e){ return; }
  try { const data = await API.getReports(); MockData.reports = data.reports || MockData.reports; } catch(e){}
  closeModal(); showReportDetail(reportId);
}

// ═════════════════════════════════════════════════════════════════════════════
// APPOINTMENTS — Full scheduling with branch, location, notes
// ═════════════════════════════════════════════════════════════════════════════

function pgAppointments(el) {
  const list = MockData.appointments;
  el.innerHTML = `<div class="page-header"><h2 class="page-title">المواعيد</h2></div>
    ${!list.length?'<div class="empty-state">لا توجد مواعيد</div>':list.map(a=>{
      const sc=AptStatusBadge[a.status];
      return `<div class="list-card" style="cursor:pointer" onclick="showAptDetail('${a.id}')">
        <div class="list-icon" style="background:var(--${sc}-light,var(--primary-surface));color:var(--${sc},var(--primary))">${ic('calendar')}</div>
        <div class="list-info">
          <div class="list-title">${esc(a.userName)}</div>
          <div class="list-sub">${fmtDate(a.scheduledDate)} · ${a.timeSlot}</div>
          ${a.branchName?`<div class="list-hint">${ic('map-pin')} ${a.branchName}</div>`:''}
          ${a.userNote?`<div class="list-hint" style="color:var(--warning)">${ic('message-circle')} ${esc(a.userNote)}</div>`:''}
        </div>
        ${badge(sc, AptStatusLabels[a.status])}
        <div class="list-actions" onclick="event.stopPropagation()">
          ${a.status==='scheduled'||a.status==='changeRequested'?`<button class="btn btn-sm btn-success" onclick="updateApt('${a.id}','confirmed')">تأكيد</button>`:''}
          ${a.status==='confirmed'?`<button class="btn btn-sm btn-success" onclick="updateApt('${a.id}','completed')">إكمال</button>`:''}
        </div>
      </div>`;
    }).join('')}`;
}

function showAptDetail(id) {
  const a = MockData.appointments.find(a=>a.id===id); if(!a) return;
  const report = MockData.reports.find(r=>r.id===a.reportId);
  const user = MockData.users.find(u=>u.id===a.userId);
  const el = document.getElementById('page-content');

  const mapsUrl = a.locationLat ? `https://www.google.com/maps?q=${a.locationLat},${a.locationLng}` : null;
  const wazeUrl = a.locationLat ? `https://waze.com/ul?ll=${a.locationLat},${a.locationLng}&navigate=yes` : null;

  el.innerHTML = `
    <button class="btn btn-outline btn-sm mb-16" onclick="navigate('appointments')">${ic('arrow-right')} العودة للمواعيد</button>
    <div class="detail-panel">
      <div class="detail-header">
        <div class="list-icon" style="background:var(--${AptStatusBadge[a.status]}-light,var(--primary-surface));color:var(--${AptStatusBadge[a.status]},var(--primary));width:56px;height:56px">${ic('calendar', 28)}</div>
        <div style="flex:1">
          <h2 style="margin-bottom:2px">موعد صيانة — ${a.id}</h2>
          <div class="text-secondary">${esc(a.userName)}</div>
        </div>
        ${badge(AptStatusBadge[a.status], AptStatusLabels[a.status])}
        <div class="list-actions">
          ${a.status==='scheduled'||a.status==='changeRequested'?`<button class="btn btn-success" onclick="updateApt('${a.id}','confirmed');showAptDetail('${a.id}')">${ic('check')} تأكيد</button>`:''}
          ${a.status==='confirmed'?`<button class="btn btn-success" onclick="updateApt('${a.id}','completed');showAptDetail('${a.id}')">${ic('check')} إكمال</button>`:''}
          ${a.status!=='completed'&&a.status!=='cancelled'?`<button class="btn btn-outline-error" onclick="updateApt('${a.id}','cancelled');showAptDetail('${a.id}')">إلغاء</button>`:''}
        </div>
      </div>

      <div class="two-col">
        <div>
          <div class="detail-section">
            <div class="detail-section-title">${ic('calendar')} تفاصيل الموعد</div>
            <div class="detail-row"><div class="detail-label">التاريخ</div><div class="detail-value">${fmtDate(a.scheduledDate)}</div></div>
            <div class="detail-row"><div class="detail-label">الوقت</div><div class="detail-value">${a.timeSlot}</div></div>
            <div class="detail-row"><div class="detail-label">الفرع</div><div class="detail-value">${a.branchName||'لم يُحدد'}</div></div>
            <div class="detail-row"><div class="detail-label">تاريخ الإنشاء</div><div class="detail-value">${fmtDate(a.createdAt)}</div></div>
          </div>

          ${a.branchName&&a.locationLat?`<div class="detail-section">
            <div class="detail-section-title">${ic('map-pin')} موقع الفرع — ${a.branchName}</div>
            <div class="map-placeholder" style="flex-direction:column;gap:8px">
              <div>الإحداثيات: ${a.locationLat}, ${a.locationLng}</div>
              <div class="flex gap-8">
                <a href="${mapsUrl}" target="_blank" class="btn btn-sm btn-primary">${ic('map')} خرائط جوجل</a>
                <a href="${wazeUrl}" target="_blank" class="btn btn-sm btn-warning">${ic('navigation')} Waze</a>
              </div>
              <div class="fs-11 text-hint">هذا الرابط يظهر للمستخدم في التطبيق ليتمكن من الوصول للفرع</div>
            </div>
          </div>`:''}

          ${a.maintenanceNote?`<div class="detail-section">
            <div class="detail-section-title">${ic('file-text')} ملاحظة للمستخدم</div>
            <div class="card" style="background:var(--bg)">${esc(a.maintenanceNote)}</div>
          </div>`:''}

          ${a.userNote?`<div class="detail-section">
            <div class="detail-section-title">${ic('message-circle')} ملاحظة المستخدم</div>
            <div class="card" style="background:var(--warning-light);color:var(--warning)">${esc(a.userNote)}</div>
          </div>`:''}
        </div>

        <div>
          ${report?`<div class="detail-section">
            <div class="detail-section-title">${ic('siren')} البلاغ المرتبط</div>
            <div class="card">
              <div class="list-title">${report.carDesc}</div>
              <div class="list-sub">${report.location} · ${fmtDate(report.accidentDate)}</div>
              <p class="fs-12 mt-16" style="color:var(--text)">${report.description}</p>
              ${report.photoUrls.length?`<div class="photo-grid mt-16">${report.photoUrls.map(u=>`<img src="${esc(u)}" class="photo-thumb" onclick="openLightbox('${esc(u)}')">`).join('')}</div>`:''}
              <button class="btn btn-sm btn-outline mt-16" onclick="showReportDetail('${report.id}')">عرض البلاغ كاملاً →</button>
            </div>
          </div>`:''}

          <div class="detail-section">
            <div class="detail-section-title">${ic('user')} المستخدم</div>
            <div class="detail-row"><div class="detail-label">الاسم</div><div class="detail-value">${user?.fullName||'—'}</div></div>
            <div class="detail-row"><div class="detail-label">الهاتف</div><div class="detail-value">${user?.phone||'—'}</div></div>
          </div>
        </div>
      </div>
    </div>`;
  refreshIcons();
}

async function updateApt(id, status) {
  try {
    await API.updateAppointment(id, { status });
    showToast('success', 'تم تحديث الموعد');
  } catch(e) { return; }
  navigate('appointments');
}

// ═════════════════════════════════════════════════════════════════════════════
// PAYMENTS — With proof images, method details, per-car billing
// ═════════════════════════════════════════════════════════════════════════════

function pgPayments(el) {
  const d=MockData.payments;
  const paid=d.filter(p=>p.status==='paid').length, unpaid=d.filter(p=>p.status==='unpaid').length, overdue=d.filter(p=>p.status==='overdue').length;

  el.innerHTML = `<div class="page-header"><h2 class="page-title">المدفوعات</h2></div>
    <div class="stat-cards mb-16">
      <div class="stat-card"><div class="stat-icon" style="background:var(--warning-light);color:var(--warning)">${ic('credit-card')}</div><div><div class="stat-title">غير مسددة</div><div class="stat-value" style="color:var(--warning)">${unpaid}</div></div></div>
      <div class="stat-card"><div class="stat-icon" style="background:var(--error-light);color:var(--error)">${ic('alert-triangle')}</div><div><div class="stat-title">متأخرة</div><div class="stat-value" style="color:var(--error)">${overdue}</div></div></div>
      <div class="stat-card"><div class="stat-icon" style="background:var(--success-light);color:var(--success)">${ic('check')}</div><div><div class="stat-title">مسددة</div><div class="stat-value" style="color:var(--success)">${paid}</div></div></div>
    </div>
    <div class="tabs" id="pay-tabs">
      <div class="tab active" data-f="all" onclick="filterPay('all')">الكل (${d.length})</div>
      <div class="tab" data-f="unpaid" onclick="filterPay('unpaid')">غير مسددة (${unpaid})</div>
      <div class="tab" data-f="overdue" onclick="filterPay('overdue')">متأخرة (${overdue})</div>
      <div class="tab" data-f="paid" onclick="filterPay('paid')">مسددة (${paid})</div>
    </div>
    <div id="payments-list"></div>`;
  filterPay('all');
}

function filterPay(f) {
  document.querySelectorAll('#pay-tabs .tab').forEach(t=>t.classList.toggle('active',t.dataset.f===f));
  const list=f==='all'?MockData.payments:MockData.payments.filter(p=>p.status===f);
  document.getElementById('payments-list').innerHTML = !list.length?'<div class="empty-state">لا توجد مدفوعات</div>':
    list.map(p=>`<div class="list-card" style="cursor:pointer" onclick="showPayDetail('${p.id}')">
      <div class="list-icon" style="background:var(--${PayStatusBadge[p.status]}-light,var(--warning-light));color:var(--${PayStatusBadge[p.status]},var(--warning))">${ic('credit-card')}</div>
      <div class="list-info">
        <div class="list-title">${esc(p.userName)}</div>
        <div class="list-sub">${esc(p.carDesc)} · ${p.month}</div>
        <div class="list-hint">استحقاق: ${fmtDate(p.dueDate)} ${p.paidDate?'· سُدد: '+fmtDate(p.paidDate):''} ${p.method?'· عبر: '+p.method:''}</div>
      </div>
      <div style="text-align:left">
        <div class="fw-700" style="font-size:16px">${fmtIQD(p.amountIQD)}</div>
        ${badge(PayStatusBadge[p.status], PayStatusLabels[p.status])}
      </div>
      <div class="list-actions" onclick="event.stopPropagation()">
        ${p.proofImageUrl?`<button class="icon-btn icon-btn-info" title="عرض إيصال الدفع" onclick="openLightbox('${p.proofImageUrl}')">${ic('image')}</button>`:''}
        ${p.status!=='paid'?`<button class="btn btn-sm btn-success" onclick="verifyPay('${p.id}')">${ic('check')} تأكيد الدفع</button>`:''}
      </div>
    </div>`).join('');
  refreshIcons();
}

function showPayDetail(id) {
  const p = MockData.payments.find(p=>p.id===id); if(!p) return;
  const user = MockData.users.find(u=>u.id===p.userId);
  const car = user?.cars?.find(c => (p.carDesc||'').includes(c.make));
  const el = document.getElementById('page-content');

  el.innerHTML = `
    <button class="btn btn-outline btn-sm mb-16" onclick="navigate('payments')">${ic('arrow-right')} العودة للمدفوعات</button>
    <div class="detail-panel">
      <div class="detail-header">
        <div class="list-icon" style="background:var(--${PayStatusBadge[p.status]}-light,var(--warning-light));color:var(--${PayStatusBadge[p.status]},var(--warning));width:56px;height:56px">${ic('credit-card', 28)}</div>
        <div style="flex:1">
          <h2 style="margin-bottom:2px">دفعة ${p.month}</h2>
          <div class="text-secondary">${esc(p.userName)} · ${esc(p.carDesc)}</div>
        </div>
        ${badge(PayStatusBadge[p.status], PayStatusLabels[p.status])}
        ${p.status!=='paid'?`<button class="btn btn-success" onclick="verifyPay('${p.id}');showPayDetail('${p.id}')">${ic('check')} تأكيد الدفع</button>`:''}
      </div>

      <div class="two-col">
        <div>
          <div class="detail-section">
            <div class="detail-section-title">${ic('credit-card')} تفاصيل الدفعة</div>
            <div class="detail-row"><div class="detail-label">المبلغ</div><div class="detail-value fw-700" style="font-size:18px;color:var(--primary)">${fmtIQD(p.amountIQD)}</div></div>
            <div class="detail-row"><div class="detail-label">الشهر</div><div class="detail-value">${p.month}</div></div>
            <div class="detail-row"><div class="detail-label">تاريخ الاستحقاق</div><div class="detail-value">${fmtDate(p.dueDate)}</div></div>
            <div class="detail-row"><div class="detail-label">تاريخ السداد</div><div class="detail-value">${p.paidDate?fmtDate(p.paidDate):'لم يُسدد بعد'}</div></div>
            <div class="detail-row"><div class="detail-label">طريقة الدفع</div><div class="detail-value">${p.method||'لم تُحدد'}</div></div>
          </div>

          ${p.proofImageUrl?`<div class="detail-section">
            <div class="detail-section-title">${ic('receipt')} إيصال الدفع</div>
            <img src="${esc(p.proofImageUrl)}" class="photo-thumb" style="max-width:300px;width:100%;aspect-ratio:auto" onclick="openLightbox('${esc(p.proofImageUrl)}')">
          </div>`:`<div class="detail-section"><div class="detail-section-title">${ic('receipt')} إيصال الدفع</div><div class="text-hint">لم يرفع المستخدم إيصالاً</div></div>`}
        </div>

        <div>
          <div class="detail-section">
            <div class="detail-section-title">${ic('user')} المستخدم</div>
            <div class="detail-row"><div class="detail-label">الاسم</div><div class="detail-value">${user?.fullName||'—'}</div></div>
            <div class="detail-row"><div class="detail-label">الهاتف</div><div class="detail-value">${user?.phone||'—'}</div></div>
            <div class="detail-row"><div class="detail-label">البريد</div><div class="detail-value">${user?.email||'—'}</div></div>
          </div>

          ${car?`<div class="detail-section">
            <div class="detail-section-title">${ic('car')} السيارة</div>
            ${car.imageUrl?`<img src="${esc(car.imageUrl)}" style="width:100%;max-width:280px;border-radius:10px;margin-bottom:10px;border:1px solid var(--divider)">`:''}
            <div class="detail-row"><div class="detail-label">السيارة</div><div class="detail-value">${esc(car.make)} ${esc(car.model)} ${esc(car.year)}</div></div>
            <div class="detail-row"><div class="detail-label">اللون</div><div class="detail-value">${esc(car.color)}</div></div>
            <div class="detail-row"><div class="detail-label">اللوحة</div><div class="detail-value">${esc(car.plateNumber)}</div></div>
            <div class="detail-row"><div class="detail-label">الاشتراك</div><div class="detail-value">${badge(SubBadge[car.subscription]||'info', SubLabels[car.subscription]||'—')}</div></div>
          </div>`:''}
        </div>
      </div>
    </div>`;
  refreshIcons();
}

async function verifyPay(id) {
  try {
    await API.updatePaymentStatus(id,'paid');
    showToast('success','تم تأكيد الدفعة');
  } catch(e){ return; }
  navigate('payments');
}

// ═════════════════════════════════════════════════════════════════════════════
// SUBSCRIPTIONS
// ═════════════════════════════════════════════════════════════════════════════

function pgSubscriptions(el) {
  const cars = MockData.users.flatMap(u=>(u.cars||[]).filter(c=>c.subscription&&c.subscription!=='none').map(c=>({userName:u.fullName,...c})));
  el.innerHTML = `<div class="page-header"><h2 class="page-title">الاشتراكات النشطة</h2></div>
    <p class="text-secondary mb-16">${cars.length} اشتراك فعّال</p>
    ${!cars.length?'<div class="empty-state">لا توجد اشتراكات</div>':cars.map(c=>{
      const rem=(c.repairsAllowed||0)-(c.repairsUsed||0), tot=c.repairsAllowed||0, pct=tot>0?(rem/tot*100):0;
      const pc=pct>50?'var(--success)':pct>20?'var(--warning)':'var(--error)';
      return `<div class="list-card">
        <div class="list-icon" style="background:var(--${SubBadge[c.subscription]}-light,var(--primary-surface));color:var(--${SubBadge[c.subscription]},var(--primary))">${ic('car')}</div>
        <div class="list-info">
          <div class="list-title">${c.userName}</div>
          <div class="list-sub">${c.make} ${c.model} ${c.year} · ${c.plateNumber}</div>
          <div class="list-hint">${fmtIQD(SubPrices[c.subscription]||0)}/شهرياً · ${c.paymentMonths} ${c.paymentMonths===1?'شهر':'أشهر'}</div>
        </div>
        <div style="text-align:left;min-width:140px">
          ${badge(SubBadge[c.subscription], SubLabels[c.subscription])}
          <div class="fs-11 mt-2" style="color:${pc}">${c.repairsUsed||0}/${tot} تصليح (${rem} متبقي)</div>
          <div style="height:4px;background:var(--bg);border-radius:2px;margin-top:4px"><div style="height:100%;width:${pct}%;background:${pc};border-radius:2px"></div></div>
          ${c.subscriptionExpiry?`<div class="fs-11 text-hint mt-2">ينتهي: ${c.subscriptionExpiry}</div>`:''}
        </div>
      </div>`;
    }).join('')}`;
}

// ═════════════════════════════════════════════════════════════════════════════
// OIL CHANGES — Full scheduling
// ═════════════════════════════════════════════════════════════════════════════

function pgOilChanges(el) {
  el.innerHTML = `<div class="page-header"><h2 class="page-title">طلبات تغيير الزيت</h2></div>
    ${!MockData.oilChanges.length?'<div class="empty-state">لا توجد طلبات</div>':MockData.oilChanges.map(o=>{
      const sc=OilStatusBadge[o.status];
      return `<div class="list-card" style="cursor:pointer" onclick="showOilDetail('${o.id}')">
        <div class="list-icon" style="background:var(--${sc}-light,var(--warning-light));color:var(--${sc},var(--warning))">${ic('wrench')}</div>
        <div class="list-info">
          <div class="list-title">${esc(o.userName)}</div>
          <div class="list-sub">${esc(o.carDesc)}</div>
          ${o.scheduledDate?`<div class="list-hint">${ic('calendar')} ${fmtDate(o.scheduledDate)} · ${o.timeSlot||''}</div>`:''}
          ${o.branchName?`<div class="list-hint">${ic('map-pin')} ${o.branchName}</div>`:''}
          ${o.notes?`<div class="list-hint" style="color:var(--info)">${ic('message-circle')} ${esc(o.notes)}</div>`:''}
        </div>
        <div style="text-align:left">
          ${badge(sc, OilStatusLabels[o.status])}
          <div class="fw-600 fs-12">${fmtIQD(o.priceIQD)}</div>
        </div>
        <div class="list-actions" onclick="event.stopPropagation()">
          ${o.status==='pending'?`<button class="btn btn-sm btn-info" onclick="modalScheduleOil('${o.id}')">${ic('calendar')} جدولة</button>`:''}
          ${o.status==='confirmed'?`<button class="btn btn-sm btn-success" onclick="updateOil('${o.id}','completed')">${ic('check')} إكمال</button>`:''}
        </div>
      </div>`;
    }).join('')}`;
}

function showOilDetail(id) {
  const o = MockData.oilChanges.find(o=>o.id===id); if(!o) return;
  const user = MockData.users.find(u=>u.id===o.userId);
  const car = user?.cars?.find(c=>c.id===o.carId);
  const branch = MockData.branches.find(b=>b.name===o.branchName);
  const mapsUrl = branch ? `https://www.google.com/maps?q=${branch.lat},${branch.lng}` : null;
  const wazeUrl = branch ? `https://waze.com/ul?ll=${branch.lat},${branch.lng}&navigate=yes` : null;
  const el = document.getElementById('page-content');

  el.innerHTML = `
    <button class="btn btn-outline btn-sm mb-16" onclick="navigate('oilChanges')">${ic('arrow-right')} العودة لطلبات تغيير الزيت</button>
    <div class="detail-panel">
      <div class="detail-header">
        <div class="list-icon" style="background:var(--${OilStatusBadge[o.status]}-light,var(--warning-light));color:var(--${OilStatusBadge[o.status]},var(--warning));width:56px;height:56px">${ic('wrench', 28)}</div>
        <div style="flex:1">
          <h2 style="margin-bottom:2px">طلب تغيير زيت — ${o.id}</h2>
          <div class="text-secondary">${esc(o.userName)} · ${esc(o.carDesc)}</div>
        </div>
        ${badge(OilStatusBadge[o.status], OilStatusLabels[o.status])}
        <div class="list-actions">
          ${o.status==='pending'?`<button class="btn btn-primary" onclick="modalScheduleOil('${o.id}')">${ic('calendar')} جدولة</button>`:''}
          ${o.status==='confirmed'?`<button class="btn btn-success" onclick="updateOil('${o.id}','completed');showOilDetail('${o.id}')">${ic('check')} إكمال</button>`:''}
        </div>
      </div>

      <div class="two-col">
        <div>
          <div class="detail-section">
            <div class="detail-section-title">${ic('wrench')} تفاصيل الطلب</div>
            <div class="detail-row"><div class="detail-label">السعر</div><div class="detail-value fw-700" style="color:var(--primary)">${fmtIQD(o.priceIQD)}</div></div>
            <div class="detail-row"><div class="detail-label">تاريخ الطلب</div><div class="detail-value">${fmtDate(o.createdAt)}</div></div>
            <div class="detail-row"><div class="detail-label">التاريخ المجدول</div><div class="detail-value">${o.scheduledDate?fmtDate(o.scheduledDate):'لم يُجدول بعد'}</div></div>
            <div class="detail-row"><div class="detail-label">الوقت</div><div class="detail-value">${o.timeSlot||'—'}</div></div>
            <div class="detail-row"><div class="detail-label">الفرع</div><div class="detail-value">${o.branchName||'لم يُحدد'}</div></div>
            ${o.notes?`<div class="detail-row"><div class="detail-label">ملاحظة المستخدم</div><div class="detail-value" style="color:var(--info)">${esc(o.notes)}</div></div>`:''}
          </div>

          ${branch?`<div class="detail-section">
            <div class="detail-section-title">${ic('map-pin')} موقع الفرع — ${o.branchName}</div>
            <div class="map-placeholder" style="flex-direction:column;gap:8px">
              <div class="flex gap-8">
                <a href="${mapsUrl}" target="_blank" class="btn btn-sm btn-primary">${ic('map')} خرائط جوجل</a>
                <a href="${wazeUrl}" target="_blank" class="btn btn-sm btn-warning">${ic('navigation')} Waze</a>
              </div>
              <div class="fs-11 text-hint">يظهر للمستخدم في التطبيق ليتمكن من الوصول</div>
            </div>
          </div>`:''}
        </div>

        <div>
          ${car?`<div class="detail-section">
            <div class="detail-section-title">${ic('car')} السيارة</div>
            ${car.imageUrl?`<img src="${esc(car.imageUrl)}" style="width:100%;max-width:280px;border-radius:10px;margin-bottom:10px;border:1px solid var(--divider)">`:''}
            <div class="detail-row"><div class="detail-label">السيارة</div><div class="detail-value">${esc(car.make)} ${esc(car.model)} ${esc(car.year)}</div></div>
            <div class="detail-row"><div class="detail-label">اللون</div><div class="detail-value">${esc(car.color)}</div></div>
            <div class="detail-row"><div class="detail-label">اللوحة</div><div class="detail-value">${esc(car.plateNumber)}</div></div>
          </div>`:''}

          <div class="detail-section">
            <div class="detail-section-title">${ic('user')} المستخدم</div>
            <div class="detail-row"><div class="detail-label">الاسم</div><div class="detail-value">${user?.fullName||'—'}</div></div>
            <div class="detail-row"><div class="detail-label">الهاتف</div><div class="detail-value">${user?.phone||'—'}</div></div>
          </div>
        </div>
      </div>
    </div>`;
  refreshIcons();
}

function modalScheduleOil(id) {
  showModal('جدولة تغيير الزيت', `
    <div class="form-group"><label class="form-label">الفرع</label><select class="form-select" id="oil-branch">
      ${MockData.branches.filter(b=>b.isActive!==false).map(b=>`<option>${esc(b.name)}</option>`).join('')}
    </select></div>
    <div class="form-row">
      <div class="form-group"><label class="form-label">التاريخ</label><input class="form-input" type="date" id="oil-date"></div>
      <div class="form-group"><label class="form-label">الوقت</label><select class="form-select" id="oil-time">
        ${MockData.timeSlots.map(t=>`<option>${t}</option>`).join('')}
      </select></div>
    </div>`,
    `<button class="btn btn-outline" onclick="closeModal()">إلغاء</button>
     <button class="btn btn-primary" onclick="scheduleOil('${id}')">تأكيد الجدولة</button>`);
}

async function scheduleOil(id) {
  const date = document.getElementById('oil-date').value;
  if (!date) { showToast('warning','اختر التاريخ'); return; }
  try {
    await API.updateOilChange(id, {
      status:'confirmed',
      scheduledDate: date,
      timeSlot: document.getElementById('oil-time').value,
      branchName: document.getElementById('oil-branch').value,
    });
    showToast('success','تم جدولة الموعد');
  } catch(e){ return; }
  closeModal(); navigate('oilChanges');
}

async function updateOil(id,status) {
  try {
    await API.updateOilChange(id, {status});
    showToast('success','تم تحديث الطلب');
  } catch(e){ return; }
  navigate('oilChanges');
}

// ═════════════════════════════════════════════════════════════════════════════
// REQUESTS — Profile edits, car changes, upgrades with full details
// ═════════════════════════════════════════════════════════════════════════════

function pgRequests(el) {
  const pending=MockData.requests.filter(r=>r.status==='pending'), reviewed=MockData.requests.filter(r=>r.status!=='pending');
  el.innerHTML = `<div class="page-header"><h2 class="page-title">الطلبات</h2></div>
    <div class="tabs" id="req-tabs">
      <div class="tab active" data-f="all" onclick="filterReq('all')">الكل (${MockData.requests.length})</div>
      <div class="tab" data-f="pending" onclick="filterReq('pending')">معلقة (${pending.length})</div>
      <div class="tab" data-f="reviewed" onclick="filterReq('reviewed')">تمت المراجعة (${reviewed.length})</div>
    </div>
    <div id="requests-list"></div>`;
  filterReq('all');
}

function filterReq(f) {
  document.querySelectorAll('#req-tabs .tab').forEach(t=>t.classList.toggle('active',t.dataset.f===f));
  let list; if(f==='pending') list=MockData.requests.filter(r=>r.status==='pending'); else if(f==='reviewed') list=MockData.requests.filter(r=>r.status!=='pending'); else list=MockData.requests;
  document.getElementById('requests-list').innerHTML = !list.length?'<div class="empty-state">لا توجد طلبات</div>':
    list.map(r=>{
      const changes = Object.entries(r.changes||{}).map(([k,v])=>`<div class="detail-row"><div class="detail-label">${esc(k)}</div><div class="detail-value">${esc(v)}</div></div>`).join('');
      return `<div class="card" style="margin-bottom:12px">
        <div class="flex gap-12" style="align-items:center;margin-bottom:12px">
          <div class="list-icon" style="background:var(--administration-light);color:var(--administration)">${ic(RequestTypeIcons[r.type]||'inbox')}</div>
          <div class="list-info">
            <div class="list-title" style="color:var(--administration)">${RequestTypeLabels[r.type]}</div>
            <div class="list-sub">${esc(r.userName)} · ${fmtDate(r.submittedAt)}</div>
            ${r.carDesc?`<div class="list-hint">${ic('car')} ${esc(r.carDesc)}</div>`:''}
          </div>
          ${badge(RequestStatusBadge[r.status], RequestStatusLabels[r.status])}
          ${r.status==='pending'?`<div class="list-actions">
            <button class="btn btn-sm btn-outline-error" onclick="modalRejectReq('${r.id}')">رفض</button>
            <button class="btn btn-sm btn-primary" onclick="approveReq('${r.id}')">قبول</button>
          </div>`:''}
        </div>
        ${changes?`<div style="margin-top:8px">${changes}</div>`:''}
        ${r.type==='upgrade'?`<div style="margin-top:8px;padding:12px;background:var(--bg);border-radius:8px">
          <div class="two-col" style="gap:16px;align-items:start">
            <div>
              <div class="detail-row"><div class="detail-label">الخطة الحالية</div><div class="detail-value">${r.currentPlan}</div></div>
              <div class="detail-row"><div class="detail-label">الخطة المطلوبة</div><div class="detail-value fw-700" style="color:var(--primary)">${r.requestedPlan} (${r.requestedMonths} أشهر)</div></div>
              <div class="detail-row"><div class="detail-label">الرصيد المتبقي</div><div class="detail-value" style="color:var(--success)">${fmtIQD(r.creditIQD||0)}</div></div>
              <div class="detail-row"><div class="detail-label">التكلفة الجديدة</div><div class="detail-value">${fmtIQD(r.newCostIQD||0)}</div></div>
              <div class="detail-row" style="font-weight:700"><div class="detail-label">المبلغ المستحق</div><div class="detail-value" style="color:var(--primary)">${r.amountDueIQD===0?'مغطى بالرصيد':fmtIQD(r.amountDueIQD||0)}</div></div>
            </div>
            <div>
              <div class="fs-11 fw-600 text-secondary" style="margin-bottom:6px;display:flex;align-items:center;gap:6px">
                ${ic('receipt')} إيصال الدفع
              </div>
              ${r.proofImageUrl
                ? `<img src="${esc(r.proofImageUrl)}" class="photo-thumb" style="width:100%;max-width:260px;aspect-ratio:auto;cursor:zoom-in" onclick="openLightbox('${esc(r.proofImageUrl)}')">`
                : (r.amountDueIQD===0
                    ? '<div class="text-hint fs-12" style="padding:12px;background:var(--success-light);color:var(--success);border-radius:8px">مغطى بالرصيد — لا يحتاج إيصالاً</div>'
                    : '<div class="text-hint fs-12" style="padding:12px;background:var(--warning-light);color:var(--warning);border-radius:8px">⚠️ لم يرفق المستخدم إيصال دفع</div>')}
            </div>
          </div>
        </div>`:''}
        ${r.reviewNote?`<div style="margin-top:8px;padding:8px;background:var(--bg);border-radius:8px;font-size:11px;color:var(--text-secondary);font-style:italic;display:flex;align-items:center;gap:6px">${ic('file-text')} ${esc(r.reviewNote)}</div>`:''}
      </div>`;
    }).join('');
  refreshIcons();
}

async function approveReq(id) {
  const r=MockData.requests.find(r=>r.id===id);
  try {
    if(r && r.type==='upgrade') await API.reviewUpgrade(id, {status:'approved', adminNote:'تمت الموافقة'});
    else await API.reviewCarChange(id, {status:'approved', reviewNote:'تمت الموافقة'});
    showToast('success','تمت الموافقة على الطلب');
  } catch(e){ return; }
  navigate('requests');
}

function modalRejectReq(id) {
  showModal('رفض الطلب', `<div class="form-group"><label class="form-label">سبب الرفض (اختياري)</label><textarea class="form-input" id="reject-note" rows="3"></textarea></div>`,
    `<button class="btn btn-outline" onclick="closeModal()">إلغاء</button>
     <button class="btn btn-error" onclick="rejectReq('${id}')">رفض</button>`);
}

async function rejectReq(id) {
  const r=MockData.requests.find(r=>r.id===id);
  const n=document.getElementById('reject-note').value.trim();
  try {
    if(r && r.type==='upgrade') await API.reviewUpgrade(id, {status:'rejected', adminNote:n||'تم الرفض'});
    else await API.reviewCarChange(id, {status:'rejected', reviewNote:n||'تم الرفض'});
    showToast('success','تم رفض الطلب');
  } catch(e){ return; }
  closeModal(); navigate('requests');
}

// ═════════════════════════════════════════════════════════════════════════════
// NOTIFICATIONS — Send to users
// ═════════════════════════════════════════════════════════════════════════════

function pgNotifications(el) {
  el.innerHTML = `<div class="page-header"><h2 class="page-title">الإشعارات</h2></div>
    <div class="two-col">
      <div>
        <div class="card">
          <h3 style="margin-bottom:16px">${ic('send')} إرسال إشعار جديد</h3>
          <div class="form-group"><label class="form-label">المستلم</label><select class="form-select" id="notif-user">
            <option value="all">جميع المستخدمين</option>
            ${MockData.users.filter(u=>u.status==='approved').map(u=>`<option value="${u.id}">${esc(u.fullName)}</option>`).join('')}
          </select></div>
          <div class="form-group"><label class="form-label">النوع</label>
            <div class="notif-type-selector">
              ${['general','payment','appointment','report','subscription'].map((t,i)=>`<button class="notif-type-btn ${i===0?'active':''}" data-type="${t}" onclick="selectNotifType('${t}')">${ic(NotifTypeIcons[t])} ${t==='general'?'عام':t==='payment'?'دفعة':t==='appointment'?'موعد':t==='report'?'بلاغ':'اشتراك'}</button>`).join('')}
            </div>
          </div>
          <div class="form-group"><label class="form-label">العنوان</label><input class="form-input" id="notif-title"></div>
          <div class="form-group"><label class="form-label">المحتوى</label><textarea class="form-input" id="notif-body" rows="3"></textarea></div>
          <button class="btn btn-primary btn-block" onclick="sendNotification()">${ic('send')} إرسال</button>
        </div>
      </div>
      <div>
        <div class="card">
          <h3 style="margin-bottom:16px">${ic('clipboard-list')} الإشعارات المرسلة (${MockData.notifications.length})</h3>
          ${MockData.notifications.map(n=>`<div class="list-card" style="margin-bottom:8px">
            <span style="color:var(--primary)">${ic(NotifTypeIcons[n.type]||'bell')}</span>
            <div class="list-info">
              <div class="list-title fs-12">${esc(n.title)}</div>
              <div class="list-sub">${esc(n.body)}</div>
              <div class="list-hint">${fmtDateTime(n.createdAt)} · ${n.userId==='all'?'جميع المستخدمين':MockData.users.find(u=>u.id===n.userId)?.fullName||n.userId}</div>
            </div>
          </div>`).join('')}
        </div>
      </div>
    </div>`;
}

let selectedNotifType = 'general';
function selectNotifType(t) { selectedNotifType=t; document.querySelectorAll('.notif-type-btn').forEach(b=>b.classList.toggle('active',b.dataset.type===t)); }

async function sendNotification() {
  const title = document.getElementById('notif-title').value.trim();
  const body  = document.getElementById('notif-body').value.trim();
  const userId= document.getElementById('notif-user').value;
  if (!title || !body) { showToast('warning','أكمل العنوان والمحتوى'); return; }
  try {
    await API.sendNotification({userId, title, body, type:selectedNotifType});
    showToast('success','تم إرسال الإشعار');
  } catch(e){ return; }
  navigate('notifications');
}

// ═════════════════════════════════════════════════════════════════════════════
// SETTINGS — Cities + Ad Banners management
// ═════════════════════════════════════════════════════════════════════════════

function pgSettings(el) {
  const s = MockData.supportInfo;
  el.innerHTML = `<div class="page-header"><h2 class="page-title">الإعدادات</h2></div>

    <!-- Support Info -->
    <div class="card" style="margin-bottom:20px">
      <div class="flex gap-12" style="align-items:center;margin-bottom:4px">
        <h3>${ic('phone')} معلومات الدعم والتواصل</h3>
        <button class="btn btn-sm btn-primary" onclick="modalEditSupport()">${ic('pencil')} تعديل</button>
      </div>
      <p class="text-secondary fs-12 mb-16">تظهر للمستخدم في صفحة الدعم داخل التطبيق — يمكن تعديلها في أي وقت</p>
      <hr style="border:none;border-top:1px solid var(--divider);margin-bottom:16px">
      <div class="two-col">
        <div>
          <div class="detail-row"><div class="detail-label">الهاتف</div><div class="detail-value">${esc(s.phone||'—')}</div></div>
          <div class="detail-row"><div class="detail-label">البريد الإلكتروني</div><div class="detail-value">${esc(s.email||'—')}</div></div>
          <div class="detail-row"><div class="detail-label">واتساب</div><div class="detail-value">${esc(s.whatsapp||'—')}</div></div>
          <div class="detail-row"><div class="detail-label">ساعات العمل</div><div class="detail-value">${esc(s.workingHours||'—')}</div></div>
          <div class="detail-row"><div class="detail-label">العنوان</div><div class="detail-value">${esc(s.address||'—')}</div></div>
        </div>
        <div>
          <div class="detail-row"><div class="detail-label">Instagram</div><div class="detail-value">${esc(s.instagram||'—')}</div></div>
          <div class="detail-row"><div class="detail-label">Facebook</div><div class="detail-value">${esc(s.facebook||'—')}</div></div>
          <div class="detail-row"><div class="detail-label">Telegram</div><div class="detail-value">${esc(s.telegram||'—')}</div></div>
          <div class="detail-row"><div class="detail-label">الموقع</div><div class="detail-value">${esc(s.website||'—')}</div></div>
        </div>
      </div>
    </div>

    <div class="two-col">
      <div>
        <!-- Cities -->
        <div class="card" style="margin-bottom:20px">
          <h3 style="margin-bottom:4px">${ic('map-pin')} المدن المتاحة</h3>
          <p class="text-secondary fs-12 mb-16">المدن التي تتوفر فيها الخدمة — تظهر للمستخدم في صفحة الاشتراك</p>
          <hr style="border:none;border-top:1px solid var(--divider);margin-bottom:16px">
          <div class="flex gap-8" style="flex-wrap:wrap;align-items:center">
            ${MockData.cities.map(c=>`<span class="chip" style="background:var(--info-light);color:var(--info)">${c} <span class="chip-close" onclick="rmCity('${c}')">×</span></span>`).join(' ')}
            <button class="btn btn-sm btn-outline" onclick="modalAddCity()">+ إضافة مدينة</button>
          </div>
        </div>

        <!-- System Info -->
        <div class="card">
          <h3 style="margin-bottom:4px">${ic('info')} معلومات النظام</h3>
          <p class="text-secondary fs-12 mb-16">بيانات عامة عن التطبيق</p>
          <hr style="border:none;border-top:1px solid var(--divider);margin-bottom:16px">
          <div class="detail-row"><div class="detail-label">الإصدار</div><div class="detail-value">1.0.0</div></div>
          <div class="detail-row"><div class="detail-label">البيئة</div><div class="detail-value">تطوير (Mock Data)</div></div>
          <div class="detail-row"><div class="detail-label">قاعدة البيانات</div><div class="detail-value">غير متصلة — جاهزة للربط</div></div>
        </div>
      </div>

      <div>
        <!-- Ad Banners -->
        <div class="card">
          <div class="flex gap-12" style="align-items:center;margin-bottom:4px">
            <h3>${ic('palette')} الإعلانات (بانرات التطبيق)</h3>
            <button class="btn btn-sm btn-primary" onclick="modalEditBanner()">${ic('plus')} إضافة بانر</button>
          </div>
          <p class="text-secondary fs-12 mb-16">تظهر في صفحة اختيار السيارة (الكراج) — يراها جميع المستخدمين</p>
          <hr style="border:none;border-top:1px solid var(--divider);margin-bottom:16px">
          ${!MockData.adBanners.length ? '<div class="text-hint fs-12">لا توجد بانرات بعد</div>' : MockData.adBanners.map(b=>`
            <div style="margin-bottom:16px;padding-bottom:12px;border-bottom:1px solid var(--divider)">
              <div class="banner-preview" style="background:${b.bgColor}">
                <span class="banner-preview-icon">${ic(b.icon)}</span>
                <div class="banner-preview-text">
                  <div class="banner-preview-title">${esc(b.title)}</div>
                  <div class="banner-preview-sub">${esc(b.subtitle||'')}</div>
                </div>
              </div>
              <div class="flex gap-8" style="align-items:center;flex-wrap:wrap">
                ${badge(b.isActive?'success':'error', b.isActive?'مفعّل':'معطّل')}
                <button class="btn btn-sm btn-outline" onclick="modalEditBanner('${b.id}')">${ic('pencil')} تعديل</button>
                <button class="btn btn-sm ${b.isActive?'btn-outline-error':'btn-success'}" onclick="toggleBanner('${b.id}')">${b.isActive?'تعطيل':'تفعيل'}</button>
                <button class="btn btn-sm btn-outline-error" onclick="deleteBanner('${b.id}')">${ic('trash-2')}</button>
              </div>
            </div>
          `).join('')}
        </div>
      </div>
    </div>

    <!-- Branches Management -->
    <div class="card" style="margin-top:20px">
      <div class="flex gap-12" style="align-items:center;margin-bottom:4px">
        <h3>${ic('map-pin')} الفروع / مراكز الخدمة</h3>
        <button class="btn btn-sm btn-primary" onclick="modalEditBranch()">${ic('plus')} إضافة فرع</button>
      </div>
      <p class="text-secondary fs-12 mb-16">الفروع التي يختار منها فريق الصيانة عند جدولة المواعيد — تظهر للمستخدم مع روابط الخرائط</p>
      <hr style="border:none;border-top:1px solid var(--divider);margin-bottom:16px">
      <table class="data-table">
        <thead><tr><th>الاسم</th><th>العنوان</th><th>الهاتف</th><th>الإحداثيات</th><th>الحالة</th><th>إجراء</th></tr></thead>
        <tbody>
          ${MockData.branches.map(b=>`<tr>
            <td>${esc(b.name)}</td>
            <td>${esc(b.address||'—')}</td>
            <td style="direction:ltr;text-align:right">${esc(b.phone||'—')}</td>
            <td style="direction:ltr;text-align:right;font-size:11px">${b.lat}, ${b.lng}</td>
            <td>${badge(b.isActive!==false?'success':'error', b.isActive!==false?'نشط':'معطّل')}</td>
            <td class="flex gap-8">
              <button class="btn btn-sm btn-outline" onclick="modalEditBranch('${b.id}')">${ic('pencil')} تعديل</button>
              <button class="btn btn-sm btn-outline-error" onclick="deleteBranch('${b.id}')">${ic('trash-2')}</button>
            </td>
          </tr>`).join('')}
        </tbody>
      </table>
    </div>

    <!-- Subscription Plans Configuration -->
    <div class="card" style="margin-top:20px">
      <div class="flex gap-12" style="align-items:center;margin-bottom:4px">
        <h3>${ic('clipboard-list')} خطط الاشتراك</h3>
      </div>
      <p class="text-secondary fs-12 mb-16">الأسعار وعدد التصليحات لكل خطة — يطّلع عليها المالية والمسؤول. التغييرات تنعكس فوراً على المستخدمين الجدد.</p>
      <hr style="border:none;border-top:1px solid var(--divider);margin-bottom:16px">
      <div class="dash-stats-grid">
        ${MockData.plans.map(p=>`
          <div class="card" style="border:1px solid var(--divider)">
            <div class="flex gap-12" style="align-items:center;margin-bottom:10px">
              ${badge(SubBadge[p.type], p.name)}
              <button class="btn btn-sm btn-outline" style="margin-right:auto" onclick="modalEditPlan('${p.type}')">${ic('pencil')} تعديل</button>
            </div>
            <div class="detail-row"><div class="detail-label">السعر الشهري</div><div class="detail-value fw-700" style="color:var(--primary)">${fmtIQD(p.priceIQD)}</div></div>
            <hr style="border:none;border-top:1px solid var(--divider);margin:10px 0">
            <div class="fs-11 fw-600 text-secondary mb-8">عدد التصليحات حسب مدة الدفع:</div>
            ${p.repairTiers.map(t=>`<div class="detail-row"><div class="detail-label">${t.months===1?'شهري':`${t.months} أشهر مقدماً`}</div><div class="detail-value">${t.repairsPerMonth} تصليح/شهر</div></div>`).join('')}
          </div>
        `).join('')}
      </div>
    </div>

    <!-- Payment Accounts -->
    <div class="card" style="margin-top:20px">
      <div class="flex gap-12" style="align-items:center;margin-bottom:4px">
        <h3>${ic('credit-card')} حسابات الدفع</h3>
        <button class="btn btn-sm btn-primary" onclick="modalEditPaymentAccounts()">${ic('pencil')} تعديل</button>
      </div>
      <p class="text-secondary fs-12 mb-16">أرقام حسابات ZainCash و Super QI التي تظهر للمستخدم في صفحة الدفع</p>
      <hr style="border:none;border-top:1px solid var(--divider);margin-bottom:16px">
      <div class="two-col">
        <div class="detail-row"><div class="detail-label">رقم ZainCash</div><div class="detail-value" style="direction:ltr;text-align:right;font-weight:700">${esc(MockData.paymentAccounts.zainCash)}</div></div>
        <div class="detail-row"><div class="detail-label">رقم Super QI</div><div class="detail-value" style="direction:ltr;text-align:right;font-weight:700">${esc(MockData.paymentAccounts.superQi)}</div></div>
      </div>
    </div>

    <!-- Onboarding Pages -->
    <div class="card" style="margin-top:20px">
      <div class="flex gap-12" style="align-items:center;margin-bottom:4px">
        <h3>${ic('image')} شاشات الترحيب (Onboarding)</h3>
        <button class="btn btn-sm btn-primary" onclick="modalEditOnboarding()">${ic('pencil')} تعديل</button>
      </div>
      <p class="text-secondary fs-12 mb-16">٣ شاشات تظهر لأوّل فتح للتطبيق قبل تسجيل الدخول. يمكنك تعديل العنوان والوصف، واستبدال الأيقونة بصورة من رفعك.</p>
      <hr style="border:none;border-top:1px solid var(--divider);margin-bottom:16px">
      ${(MockData.onboardingPages && MockData.onboardingPages.length)
        ? `<div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(220px,1fr));gap:14px">${MockData.onboardingPages.map((p, i) => `
            <div style="background:var(--bg);padding:14px;border-radius:10px">
              <div class="text-hint fs-11">شاشة ${i + 1}</div>
              ${p.imageUrl ? `<img src="${esc(p.imageUrl)}" style="max-width:100%;max-height:140px;border-radius:8px;margin:8px 0">` : '<div class="text-hint fs-12 my-8">لم تُرفع صورة (يستعمل التطبيق أيقونة افتراضيّة)</div>'}
              <div class="fs-13 fw-700">${esc(p.title || '— عنوان افتراضيّ —')}</div>
              <div class="text-secondary fs-12 mt-6">${esc(p.desc || '— وصف افتراضيّ —')}</div>
            </div>`).join('')}</div>`
        : '<p class="text-hint fs-12">لم يُخصَّص شيء بعد — التطبيق يستعمل النصوص والأيقونات الافتراضيّة المضمَّنة فيه.</p>'}
    </div>

    <!-- Privacy Policy -->
    <div class="card" style="margin-top:20px">
      <div class="flex gap-12" style="align-items:center;margin-bottom:4px">
        <h3>${ic('shield')} سياسة الخصوصية</h3>
        <button class="btn btn-sm btn-primary" onclick="modalEditPrivacyPolicy()">${ic('pencil')} تعديل</button>
      </div>
      <p class="text-secondary fs-12 mb-16">تظهر للمستخدم في شاشة تسجيل الدخول قبل إنشاء الحساب — يجب الموافقة عليها للمتابعة</p>
      <p class="text-hint fs-11 mb-16">آخر تحديث: ${MockData.privacyPolicy.updatedAt}</p>
      <hr style="border:none;border-top:1px solid var(--divider);margin-bottom:16px">
      <div style="background:var(--bg);padding:16px;border-radius:10px;max-height:240px;overflow-y:auto;white-space:pre-wrap;font-size:12px;line-height:1.7;color:var(--text-secondary)">${esc(MockData.privacyPolicy.content)}</div>
    </div>`;
}

async function rmCity(c) {
  const newCities = MockData.cities.filter(x=>x!==c);
  try { await API.updateConfig('available_cities', newCities); MockData.cities = newCities; showToast('success','تم الحذف'); }
  catch(e){ return; }
  navigate('settings');
}

function modalAddCity() {
  showModal('إضافة مدينة', `<div class="form-group"><label class="form-label">اسم المدينة</label><input class="form-input" id="city-name" autofocus></div>`,
    `<button class="btn btn-outline" onclick="closeModal()">إلغاء</button><button class="btn btn-primary" onclick="addCity()">إضافة</button>`);
}

async function addCity() {
  const n = document.getElementById('city-name').value.trim();
  if (!n) { showToast('warning','أدخل اسم المدينة'); return; }
  if (MockData.cities.includes(n)) { showToast('warning','المدينة موجودة أصلاً'); return; }
  const newCities = [...MockData.cities, n];
  try { await API.updateConfig('available_cities', newCities); MockData.cities = newCities; showToast('success','تمت إضافة المدينة'); }
  catch(e){ return; }
  closeModal(); navigate('settings');
}

// ── Banner CRUD ─────────────────────────────────────────────────────────────

async function toggleBanner(id) {
  const b = MockData.adBanners.find(b=>b.id===id);
  if (!b) return;
  try {
    await API.updateBanner(id, {isActive: !b.isActive});
    showToast('success', b.isActive ? 'تم تعطيل البانر' : 'تم تفعيل البانر');
  } catch(e){ return; }
  navigate('settings');
}

const BANNER_COLORS = [
  { bg:'#1A3A8F', label:'أزرق (أساسي)' },
  { bg:'#065F46', label:'أخضر' },
  { bg:'#7C3AED', label:'بنفسجي' },
  { bg:'#D97706', label:'برتقالي' },
  { bg:'#DC2626', label:'أحمر' },
  { bg:'#0F172A', label:'أسود' },
];
const BANNER_ICONS = ['tag','wrench','star','gift','zap','shield','car','percent','flame','bell','award','sparkles'];

function modalEditBanner(id) {
  const b = id ? MockData.adBanners.find(x=>x.id===id) : { title:'', subtitle:'', bgColor:'#1A3A8F', icon:'tag', actionLabel:'', actionRoute:'', mediaUrl:null, mediaType:'none', isActive:true };
  if (!b) return;
  const hasMedia = b.mediaUrl && b.mediaType && b.mediaType !== 'none';
  showModal(id ? 'تعديل بانر' : 'إضافة بانر جديد', `
    <p class="text-secondary fs-12 mb-16">هذا البانر يظهر للمستخدمين في صفحة اختيار السيارة داخل التطبيق</p>
    <div class="form-group"><label class="form-label">العنوان *</label><input class="form-input" id="bn-title" value="${esc(b.title||'')}" placeholder="مثال: خصم 20% على الاشتراك"></div>
    <div class="form-group"><label class="form-label">الوصف</label><input class="form-input" id="bn-subtitle" value="${esc(b.subtitle||'')}" placeholder="مثال: جدّد قبل نهاية الشهر"></div>

    <div class="form-group">
      <label class="form-label">صورة أو فيديو للبانر (اختياري)</label>
      <p class="text-hint fs-11" style="margin:4px 0 8px">عند رفع وسائط، تُستبدل خلفية اللون + الأيقونة بالصورة/الفيديو في تطبيق المستخدم. يبقى العنوان والوصف ظاهرَين فوق الوسائط.</p>
      <div class="upload-area" id="bn-media-area" onclick="document.getElementById('bn-media-input').click()">
        ${ic('image')} اضغط لاختيار صورة أو فيديو<br><span class="fs-11">الحد الأقصى 50 ميجا · JPG, PNG, WEBP, MP4, MOV</span>
      </div>
      <input type="file" id="bn-media-input" accept="image/*,video/*" hidden onchange="onBannerMediaSelected(this)">
      <div id="bn-media-info" class="${hasMedia?'':'hidden'}" style="margin-top:8px;padding:10px;background:var(--success-light);color:var(--success);border-radius:8px;font-size:12px;font-weight:600;display:flex;align-items:center;gap:8px;justify-content:space-between">
        <span id="bn-media-status">${hasMedia ? `${b.mediaType==='video'?'🎬 فيديو حالي':'🖼 صورة حالية'}` : ''}</span>
        <button type="button" class="btn btn-sm btn-outline-error" onclick="clearBannerMedia()">${ic('x')} إزالة</button>
      </div>
      <input type="hidden" id="bn-media-url" value="${esc(b.mediaUrl||'')}">
      <input type="hidden" id="bn-media-type" value="${esc(b.mediaType||'none')}">
    </div>

    <div class="form-group"><label class="form-label">لون الخلفية (يُستخدم عند عدم رفع وسائط)</label>
      <div class="flex gap-8" style="flex-wrap:wrap">
        ${BANNER_COLORS.map(c=>`<button type="button" class="bn-color-swatch ${b.bgColor===c.bg?'active':''}" data-color="${c.bg}" onclick="selectBannerColor('${c.bg}')" style="background:${c.bg};width:36px;height:36px;border-radius:8px;border:3px solid ${b.bgColor===c.bg?'var(--primary)':'transparent'};cursor:pointer" title="${esc(c.label)}"></button>`).join('')}
      </div>
      <input type="hidden" id="bn-bg" value="${esc(b.bgColor||'#1A3A8F')}">
    </div>
    <div class="form-group"><label class="form-label">الأيقونة (تظهر عند عدم رفع وسائط)</label>
      <div class="flex gap-8" style="flex-wrap:wrap">
        ${BANNER_ICONS.map(ic2=>`<button type="button" class="bn-icon-swatch ${b.icon===ic2?'active':''}" data-icon="${ic2}" onclick="selectBannerIcon('${ic2}')" style="width:36px;height:36px;border-radius:8px;border:2px solid ${b.icon===ic2?'var(--primary)':'var(--border)'};background:var(--surface);display:flex;align-items:center;justify-content:center;cursor:pointer">${ic(ic2)}</button>`).join('')}
      </div>
      <input type="hidden" id="bn-icon" value="${esc(b.icon||'tag')}">
    </div>
    <div class="form-group"><label class="form-label">نص زر الإجراء (اختياري)</label><input class="form-input" id="bn-action-label" value="${esc(b.actionLabel||'')}" placeholder="اشترك الآن"></div>
    <div class="form-group"><label class="form-label">رابط الإجراء (اختياري)</label><input class="form-input" id="bn-action-route" dir="ltr" value="${esc(b.actionRoute||'')}" placeholder="/subscription"></div>
    <div class="form-group"><label class="form-label"><input type="checkbox" id="bn-active" ${b.isActive!==false?'checked':''}> البانر مفعّل</label></div>

    <div style="margin-top:12px;padding:12px;border-radius:10px;background:var(--bg)">
      <div class="fs-11 fw-600 text-secondary mb-8">معاينة:</div>
      <div class="banner-preview" id="bn-preview" style="background:${esc(b.bgColor||'#1A3A8F')};position:relative;overflow:hidden">
        <div id="bn-preview-media" class="${hasMedia?'':'hidden'}" style="position:absolute;inset:0;z-index:0">
          ${hasMedia && b.mediaType === 'video'
            ? `<video src="${esc(b.mediaUrl)}" autoplay muted loop playsinline style="width:100%;height:100%;object-fit:cover"></video>`
            : hasMedia
              ? `<img src="${esc(b.mediaUrl)}" style="width:100%;height:100%;object-fit:cover">`
              : ''}
          <div style="position:absolute;inset:0;background:linear-gradient(180deg,rgba(0,0,0,0.1) 0%,rgba(0,0,0,0.45) 100%)"></div>
        </div>
        <span class="banner-preview-icon" id="bn-preview-icon" style="position:relative;z-index:1;${hasMedia?'display:none':''}">${ic(b.icon||'tag')}</span>
        <div class="banner-preview-text" style="position:relative;z-index:1">
          <div class="banner-preview-title" id="bn-preview-title">${esc(b.title||'عنوان البانر')}</div>
          <div class="banner-preview-sub" id="bn-preview-sub">${esc(b.subtitle||'وصف البانر')}</div>
        </div>
      </div>
    </div>`,
    `<button class="btn btn-outline" onclick="closeModal()">إلغاء</button>
     <button class="btn btn-primary" onclick="saveBanner('${esc(id||'')}')">${ic('save')} حفظ</button>`);
  // Live preview wiring
  setTimeout(() => {
    document.getElementById('bn-title').addEventListener('input', e => { document.getElementById('bn-preview-title').textContent = e.target.value || 'عنوان البانر'; });
    document.getElementById('bn-subtitle').addEventListener('input', e => { document.getElementById('bn-preview-sub').textContent = e.target.value || 'وصف البانر'; });
  }, 0);
}

/**
 * Upload the selected file to /admin/upload/banners then stash the remote
 * URL + mediaType in the hidden inputs. The modal also updates its live
 * preview to show the new media.
 */
async function onBannerMediaSelected(input) {
  if (!input.files || !input.files.length) return;
  const file = input.files[0];
  const isVideo = file.type.startsWith('video/');
  const isImage = file.type.startsWith('image/');
  if (!isVideo && !isImage) { showToast('error','نوع الملف غير مدعوم'); return; }

  const area = document.getElementById('bn-media-area');
  const info = document.getElementById('bn-media-info');
  const status = document.getElementById('bn-media-status');
  area.innerHTML = `${ic('loader')} جارٍ رفع الملف...`;
  refreshIcons();

  try {
    const res = await API.uploadFiles([file], 'banners');
    const url = (res.urls && res.urls[0]) || null;
    if (!url) throw new Error('upload failed');
    document.getElementById('bn-media-url').value = url;
    document.getElementById('bn-media-type').value = isVideo ? 'video' : 'image';
    area.innerHTML = `${ic('check-circle')} تم الرفع — اضغط لتغيير`;
    info.classList.remove('hidden');
    status.textContent = isVideo ? '🎬 فيديو مُحدّث' : '🖼 صورة مُحدّثة';
    refreshIcons();
    // Update live preview
    const preview = document.getElementById('bn-preview-media');
    preview.innerHTML = isVideo
      ? `<video src="${esc(url)}" autoplay muted loop playsinline style="width:100%;height:100%;object-fit:cover"></video>
         <div style="position:absolute;inset:0;background:linear-gradient(180deg,rgba(0,0,0,0.1) 0%,rgba(0,0,0,0.45) 100%)"></div>`
      : `<img src="${esc(url)}" style="width:100%;height:100%;object-fit:cover">
         <div style="position:absolute;inset:0;background:linear-gradient(180deg,rgba(0,0,0,0.1) 0%,rgba(0,0,0,0.45) 100%)"></div>`;
    preview.classList.remove('hidden');
    document.getElementById('bn-preview-icon').style.display = 'none';
    showToast('success','تم رفع الوسائط');
  } catch(e) {
    area.innerHTML = `${ic('alert-triangle')} فشل الرفع — اضغط لإعادة المحاولة`;
    refreshIcons();
  }
}

function clearBannerMedia() {
  document.getElementById('bn-media-url').value = '';
  document.getElementById('bn-media-type').value = 'none';
  document.getElementById('bn-media-info').classList.add('hidden');
  document.getElementById('bn-media-area').innerHTML = `${ic('image')} اضغط لاختيار صورة أو فيديو<br><span class="fs-11">الحد الأقصى 50 ميجا · JPG, PNG, WEBP, MP4, MOV</span>`;
  const preview = document.getElementById('bn-preview-media');
  preview.innerHTML = '';
  preview.classList.add('hidden');
  document.getElementById('bn-preview-icon').style.display = '';
  refreshIcons();
}

function selectBannerColor(bg) {
  document.getElementById('bn-bg').value = bg;
  document.getElementById('bn-preview').style.background = bg;
  document.querySelectorAll('.bn-color-swatch').forEach(el => {
    el.style.borderColor = el.dataset.color === bg ? 'var(--primary)' : 'transparent';
  });
}

function selectBannerIcon(iconName) {
  document.getElementById('bn-icon').value = iconName;
  document.getElementById('bn-preview-icon').innerHTML = `<i data-lucide="${iconName}"></i>`;
  document.querySelectorAll('.bn-icon-swatch').forEach(el => {
    el.style.borderColor = el.dataset.icon === iconName ? 'var(--primary)' : 'var(--border)';
  });
  refreshIcons();
}

async function saveBanner(id) {
  const title = document.getElementById('bn-title').value.trim();
  if (!title) { showToast('warning','أدخل عنوان البانر'); return; }
  const mediaUrl = document.getElementById('bn-media-url').value.trim() || null;
  const mediaType = mediaUrl ? (document.getElementById('bn-media-type').value || 'image') : 'none';
  const payload = {
    title,
    subtitle: document.getElementById('bn-subtitle').value.trim() || null,
    bgColor:  document.getElementById('bn-bg').value || '#1A3A8F',
    textColor:'#FFFFFF',
    icon:     document.getElementById('bn-icon').value || 'tag',
    actionLabel: document.getElementById('bn-action-label').value.trim() || null,
    actionRoute: document.getElementById('bn-action-route').value.trim() || null,
    mediaUrl,
    mediaType,
    isActive: document.getElementById('bn-active').checked,
  };
  try {
    if (id) { await API.updateBanner(id, payload); showToast('success','تم حفظ التعديلات'); }
    else    { await API.createBanner(payload); showToast('success','تمت إضافة البانر'); }
  } catch(e){ return; }
  closeModal(); navigate('settings');
}

async function deleteBanner(id) {
  if (!confirm('هل أنت متأكد من حذف هذا البانر؟ لن يظهر للمستخدمين بعد الحذف.')) return;
  try { await API.deleteBanner(id); showToast('success','تم حذف البانر'); }
  catch(e){ return; }
  navigate('settings');
}

function modalEditSupport() {
  const s = MockData.supportInfo;
  showModal('تعديل معلومات الدعم', `
    <p class="text-secondary fs-12 mb-16">التعديلات ستظهر مباشرة للمستخدمين في التطبيق</p>
    <div class="two-col">
      <div>
        <div class="form-group"><label class="form-label">الهاتف</label><input class="form-input" id="sup-phone" dir="ltr" value="${esc(s.phone||'')}"></div>
        <div class="form-group"><label class="form-label">البريد الإلكتروني</label><input class="form-input" id="sup-email" dir="ltr" value="${esc(s.email||'')}"></div>
        <div class="form-group"><label class="form-label">واتساب</label><input class="form-input" id="sup-whatsapp" dir="ltr" value="${esc(s.whatsapp||'')}"></div>
        <div class="form-group"><label class="form-label">ساعات العمل</label><input class="form-input" id="sup-hours" value="${esc(s.workingHours||'')}"></div>
        <div class="form-group"><label class="form-label">العنوان</label><input class="form-input" id="sup-address" value="${esc(s.address||'')}"></div>
      </div>
      <div>
        <div class="form-group"><label class="form-label">Instagram</label><input class="form-input" id="sup-ig" dir="ltr" value="${esc(s.instagram||'')}"></div>
        <div class="form-group"><label class="form-label">Facebook</label><input class="form-input" id="sup-fb" dir="ltr" value="${esc(s.facebook||'')}"></div>
        <div class="form-group"><label class="form-label">Telegram</label><input class="form-input" id="sup-tg" dir="ltr" value="${esc(s.telegram||'')}"></div>
        <div class="form-group"><label class="form-label">الموقع الإلكتروني</label><input class="form-input" id="sup-web" dir="ltr" value="${esc(s.website||'')}"></div>
      </div>
    </div>`,
    `<button class="btn btn-outline" onclick="closeModal()">إلغاء</button>
     <button class="btn btn-primary" onclick="saveSupport()">${ic('save')} حفظ</button>`);
}

async function saveSupport() {
  const val = {
    phone: document.getElementById('sup-phone').value.trim(),
    email: document.getElementById('sup-email').value.trim(),
    whatsapp: document.getElementById('sup-whatsapp').value.trim() || null,
    workingHours: document.getElementById('sup-hours').value.trim() || null,
    address: document.getElementById('sup-address').value.trim() || null,
    instagram: document.getElementById('sup-ig').value.trim() || null,
    facebook: document.getElementById('sup-fb').value.trim() || null,
    telegram: document.getElementById('sup-tg').value.trim() || null,
    website: document.getElementById('sup-web').value.trim() || null,
  };
  try { await API.updateConfig('support_info', val); MockData.supportInfo = val; showToast('success','تم حفظ معلومات الدعم'); }
  catch(e){ return; }
  closeModal(); navigate('settings');
}

// ── Branches ────────────────────────────────────────────────────────────────

function modalEditBranch(id) {
  const b = id ? MockData.branches.find(x=>x.id===id) : { name:'', address:'', phone:'', lat:'', lng:'', isActive:true };
  if (!b) return;
  showModal(id ? 'تعديل فرع' : 'إضافة فرع جديد', `
    <div class="form-group"><label class="form-label">اسم الفرع</label><input class="form-input" id="br-name" value="${esc(b.name||'')}" placeholder="مثال: فرع الكرادة"></div>
    <div class="form-group"><label class="form-label">العنوان</label><input class="form-input" id="br-address" value="${esc(b.address||'')}" placeholder="الكرادة، بغداد"></div>
    <div class="form-group"><label class="form-label">رقم الهاتف</label><input class="form-input" id="br-phone" dir="ltr" value="${esc(b.phone||'')}" placeholder="+964 770 000 0000"></div>
    <div class="form-row">
      <div class="form-group"><label class="form-label">خط العرض (Latitude)</label><input class="form-input" id="br-lat" dir="ltr" value="${b.lat||''}" placeholder="33.3128"></div>
      <div class="form-group"><label class="form-label">خط الطول (Longitude)</label><input class="form-input" id="br-lng" dir="ltr" value="${b.lng||''}" placeholder="44.3615"></div>
    </div>
    <div class="form-group"><label class="form-label"><input type="checkbox" id="br-active" ${b.isActive!==false?'checked':''}> فرع نشط</label></div>
    <p class="text-hint fs-11">يمكنك الحصول على الإحداثيات من خرائط جوجل: انقر بزر الفأرة الأيمن على الموقع → انسخ الإحداثيات</p>`,
    `<button class="btn btn-outline" onclick="closeModal()">إلغاء</button>
     <button class="btn btn-primary" onclick="saveBranch('${id||''}')">${ic('save')} حفظ</button>`);
}

async function saveBranch(id) {
  const name = document.getElementById('br-name').value.trim();
  const address = document.getElementById('br-address').value.trim();
  const phone = document.getElementById('br-phone').value.trim();
  const lat = parseFloat(document.getElementById('br-lat').value);
  const lng = parseFloat(document.getElementById('br-lng').value);
  const isActive = document.getElementById('br-active').checked;
  if (!name || isNaN(lat) || isNaN(lng)) { showToast('warning','أدخل الاسم والإحداثيات بشكل صحيح'); return; }
  try {
    if (id) { await API.updateBranch(id, {name, address, phone, lat, lng, isActive}); showToast('success','تم حفظ تعديلات الفرع'); }
    else { await API.createBranch({name, address, phone, lat, lng}); showToast('success','تمت إضافة الفرع'); }
  } catch(e){ return; }
  closeModal(); navigate('settings');
}

async function deleteBranch(id) {
  if (!confirm('هل أنت متأكد من حذف هذا الفرع؟')) return;
  try { await API.deleteBranch(id); showToast('success','تم حذف الفرع'); }
  catch(e){ return; }
  navigate('settings');
}

// ── Subscription Plans ──────────────────────────────────────────────────────

function modalEditPlan(type) {
  const p = MockData.plans.find(x=>x.type===type);
  if (!p) return;
  showModal(`تعديل خطة ${p.name}`, `
    <div class="form-group"><label class="form-label">السعر الشهري (د.ع)</label><input class="form-input" id="plan-price" type="number" dir="ltr" value="${p.priceIQD}"></div>
    <hr style="border:none;border-top:1px solid var(--divider);margin:16px 0">
    <p class="fs-12 fw-600 mb-16">عدد التصليحات الشهري حسب مدة الدفع المقدّم</p>
    ${p.repairTiers.map((t,i)=>`
      <div class="form-row">
        <div class="form-group"><label class="form-label">${t.months===1?'الدفع الشهري':`${t.months} أشهر مقدماً`}</label><input class="form-input" id="plan-tier-${i}" type="number" dir="ltr" value="${t.repairsPerMonth}"></div>
      </div>
    `).join('')}
    <p class="text-hint fs-11">التغييرات تنطبق على المشتركين الجدد فقط — العقود الحالية تظل كما هي حتى تجديدها.</p>`,
    `<button class="btn btn-outline" onclick="closeModal()">إلغاء</button>
     <button class="btn btn-primary" onclick="savePlan('${type}')">${ic('save')} حفظ</button>`);
}

async function savePlan(type) {
  const p = MockData.plans.find(x=>x.type===type);
  if (!p) return;
  const price = parseInt(document.getElementById('plan-price').value);
  if (isNaN(price) || price <= 0) { showToast('warning','أدخل سعراً صحيحاً'); return; }
  const repairTiers = p.repairTiers.map((t,i) => {
    const v = parseInt(document.getElementById(`plan-tier-${i}`).value);
    return { ...t, repairsPerMonth: (!isNaN(v) && v >= 0) ? v : t.repairsPerMonth };
  });
  try { await API.updatePlan(p.id, {priceIQD: price, repairTiers}); showToast('success','تم حفظ تعديلات الخطة'); }
  catch(e){ return; }
  if (typeof SubPrices !== 'undefined') SubPrices[type] = price;
  closeModal(); navigate('settings');
}

// ── Payment Accounts ────────────────────────────────────────────────────────

function modalEditPaymentAccounts() {
  // Reset any stale "cleared" flags from a previous modal session.
  window._clearedPaymentQr = { zain: false, qi: false };

  const pa = MockData.paymentAccounts || {};
  const qrPreview = (url) => url
    ? `<img src="${esc(url)}" style="max-width:140px;max-height:140px;border-radius:8px;border:1px solid var(--border);margin-top:6px">`
    : '<div class="text-hint fs-11 mt-6">لم تُرفع صورة باركود بعد.</div>';
  showModal('تعديل حسابات الدفع', `
    <p class="text-secondary fs-12 mb-16">لكلّ وسيلة دفع يمكنك إمّا إدخال رقم الحساب أو رفع صورة باركود — وستُعرض الصورة للمستخدم تلقائيّاً إن وُجدت.</p>

    <div class="form-group">
      <label class="form-label">رقم حساب ZainCash</label>
      <input class="form-input" id="pa-zain" dir="ltr" value="${esc(pa.zainCash||'')}" placeholder="+964 770 000 0000">
      <label class="form-label mt-12">صورة باركود ZainCash (اختياريّ — إن وُجدت تظهر بدل الرقم)</label>
      <div id="pa-zain-qr-preview">${qrPreview(pa.zainCashQrUrl)}</div>
      <div id="pa-zain-qr-filename" class="text-hint fs-11 mt-6"></div>
      <input type="file" id="pa-zain-qr" accept="image/*" class="mt-6" style="font-size:12px" onchange="onPaymentQrPicked('zain', this)">
      ${pa.zainCashQrUrl ? `<button type="button" class="btn btn-outline fs-11 mt-6" onclick="clearPaymentQr('zain')">${ic('trash')} حذف صورة ZainCash</button>` : ''}
    </div>

    <div class="form-group">
      <label class="form-label">رقم حساب Super QI</label>
      <input class="form-input" id="pa-qi" dir="ltr" value="${esc(pa.superQi||'')}" placeholder="07XX-XXX-XXXX">
      <label class="form-label mt-12">صورة باركود Super QI (اختياريّ — إن وُجدت تظهر بدل الرقم)</label>
      <div id="pa-qi-qr-preview">${qrPreview(pa.superQiQrUrl)}</div>
      <div id="pa-qi-qr-filename" class="text-hint fs-11 mt-6"></div>
      <input type="file" id="pa-qi-qr" accept="image/*" class="mt-6" style="font-size:12px" onchange="onPaymentQrPicked('qi', this)">
      ${pa.superQiQrUrl ? `<button type="button" class="btn btn-outline fs-11 mt-6" onclick="clearPaymentQr('qi')">${ic('trash')} حذف صورة Super QI</button>` : ''}
    </div>`,
    `<button class="btn btn-outline" onclick="closeModal()">إلغاء</button>
     <button class="btn btn-primary" onclick="savePaymentAccounts()">${ic('save')} حفظ</button>`);
}

// Tracks files the admin picked but hasn't saved yet. When present they
// override any existing saved QR URL in `MockData.paymentAccounts`.
window._clearedPaymentQr = { zain: false, qi: false };

// Called when the admin picks a new QR file via <input type="file">. We
// immediately swap the preview with a local object URL so the admin gets
// visual confirmation that their new file will be used when they click Save.
function onPaymentQrPicked(which, input) {
  const file = input?.files?.[0];
  const previewId = which === 'zain' ? 'pa-zain-qr-preview' : 'pa-qi-qr-preview';
  const nameId = which === 'zain' ? 'pa-zain-qr-filename' : 'pa-qi-qr-filename';
  const previewBox = document.getElementById(previewId);
  const nameBox = document.getElementById(nameId);
  if (!file) { if (nameBox) nameBox.textContent = ''; return; }
  // Cancel any pending delete for this method — a new file wins.
  window._clearedPaymentQr[which] = false;
  const localUrl = URL.createObjectURL(file);
  if (previewBox) {
    previewBox.innerHTML = `<img src="${localUrl}" style="max-width:140px;max-height:140px;border-radius:8px;border:2px solid var(--primary);margin-top:6px"><div class="fs-11 mt-6" style="color:var(--primary);font-weight:600">✓ صورة جديدة جاهزة للحفظ</div>`;
  }
  if (nameBox) nameBox.textContent = 'الملفّ المختار: ' + file.name;
}

function clearPaymentQr(which) {
  window._clearedPaymentQr[which] = true;
  const box = document.getElementById(which === 'zain' ? 'pa-zain-qr-preview' : 'pa-qi-qr-preview');
  if (box) box.innerHTML = '<div class="text-hint fs-11 mt-6" style="color:var(--error)">ستُحذف الصورة عند الحفظ.</div>';
  // Also clear any file the admin had selected for this method.
  const input = document.getElementById(which === 'zain' ? 'pa-zain-qr' : 'pa-qi-qr');
  if (input) input.value = '';
  const nameBox = document.getElementById(which === 'zain' ? 'pa-zain-qr-filename' : 'pa-qi-qr-filename');
  if (nameBox) nameBox.textContent = '';
}

async function savePaymentAccounts() {
  const pa = MockData.paymentAccounts || {};
  // Capture EVERY field value BEFORE any async work (uploads). If we wait
  // for an upload first the user could navigate or the DOM could change,
  // and document.getElementById would return null at line 2341.
  const zainEl = document.getElementById('pa-zain');
  const qiEl = document.getElementById('pa-qi');
  const enteredZain = (zainEl?.value || '').trim();
  const enteredQi = (qiEl?.value || '').trim();
  const zainFile = document.getElementById('pa-zain-qr')?.files?.[0];
  const qiFile = document.getElementById('pa-qi-qr')?.files?.[0];

  let zainCashQrUrl = pa.zainCashQrUrl || '';
  let superQiQrUrl = pa.superQiQrUrl || '';

  if (window._clearedPaymentQr.zain) zainCashQrUrl = '';
  if (window._clearedPaymentQr.qi) superQiQrUrl = '';

  try {
    if (zainFile) {
      showToast('info', 'رفع صورة ZainCash…');
      const up = await API.uploadFiles([zainFile], 'general');
      if (up && up.urls && up.urls[0]) zainCashQrUrl = up.urls[0];
      else throw new Error('الخادم لم يُرجع رابط الصورة');
    }
    if (qiFile) {
      showToast('info', 'رفع صورة Super QI…');
      const up = await API.uploadFiles([qiFile], 'general');
      if (up && up.urls && up.urls[0]) superQiQrUrl = up.urls[0];
      else throw new Error('الخادم لم يُرجع رابط الصورة');
    }
  } catch (e) {
    showToast('error', 'فشل رفع صورة الباركود: ' + (e.message || 'تعذّر الاتّصال'));
    return;
  }

  const val = {
    zainCash: enteredZain || pa.zainCash,
    superQi: enteredQi || pa.superQi,
    zainCashQrUrl,
    superQiQrUrl,
  };

  try {
    await API.updateConfig('payment_accounts', val);
    MockData.paymentAccounts = val;
    // Refetch from server so the settings page shows the authoritative value
    // (and the admin can re-open the modal seeing the newly saved image).
    try {
      const fresh = await API.getConfig('payment_accounts');
      if (fresh && fresh.value) MockData.paymentAccounts = fresh.value;
    } catch (_) { /* stale is fine */ }
    showToast('success','تم حفظ حسابات الدفع');
  }
  catch(e){ return; }
  window._clearedPaymentQr = { zain: false, qi: false };
  closeModal(); navigate('settings');
}

// ── Onboarding Pages ────────────────────────────────────────────────────────

function modalEditOnboarding() {
  const pages = (MockData.onboardingPages && MockData.onboardingPages.length)
    ? MockData.onboardingPages
    : [{ title: '', desc: '', imageUrl: '' }, { title: '', desc: '', imageUrl: '' }, { title: '', desc: '', imageUrl: '' }];
  // Reset any pending file selections from previous open.
  window._onboardFiles = { 0: null, 1: null, 2: null };
  window._onboardClearImage = { 0: false, 1: false, 2: false };

  const slideHtml = (i) => {
    const p = pages[i] || { title: '', desc: '', imageUrl: '' };
    const img = p.imageUrl
      ? `<img src="${esc(p.imageUrl)}" id="onb-${i}-preview" style="max-width:140px;max-height:140px;border-radius:8px;border:1px solid var(--border);margin-top:6px">`
      : `<div id="onb-${i}-preview" class="text-hint fs-11 mt-6">لا توجد صورة (سيستعمل التطبيق أيقونة افتراضيّة)</div>`;
    return `
      <div class="form-group" style="background:var(--bg);padding:14px;border-radius:10px;margin-bottom:14px">
        <h4 style="margin-bottom:8px">شاشة ${i + 1}</h4>
        <label class="form-label">العنوان</label>
        <input class="form-input" id="onb-${i}-title" value="${esc(p.title || '')}" placeholder="عنوان الشاشة">
        <label class="form-label mt-12">الوصف</label>
        <textarea class="form-input" id="onb-${i}-desc" rows="2" style="font-family:inherit">${esc(p.desc || '')}</textarea>
        <label class="form-label mt-12">الصورة (اختياريّ)</label>
        ${img}
        <div id="onb-${i}-filename" class="text-hint fs-11 mt-6"></div>
        <input type="file" accept="image/*" class="mt-6" style="font-size:12px" onchange="onOnboardingImagePicked(${i}, this)">
        ${p.imageUrl ? `<button type="button" class="btn btn-outline fs-11 mt-6" onclick="clearOnboardingImage(${i})">${ic('trash')} حذف الصورة</button>` : ''}
      </div>`;
  };

  showModal('تعديل شاشات الترحيب', `
    <p class="text-secondary fs-12 mb-16">عدّل عناوين ووصف وصور الشاشات الثلاث. الحقول الفارغة تستعمل النصوص الافتراضيّة المضمَّنة في التطبيق.</p>
    ${slideHtml(0)}${slideHtml(1)}${slideHtml(2)}`,
    `<button class="btn btn-outline" onclick="closeModal()">إلغاء</button>
     <button class="btn btn-primary" onclick="saveOnboarding()">${ic('save')} حفظ ونشر</button>`);
}

window._onboardFiles = { 0: null, 1: null, 2: null };
window._onboardClearImage = { 0: false, 1: false, 2: false };

function onOnboardingImagePicked(i, input) {
  const file = input?.files?.[0];
  if (!file) return;
  window._onboardFiles[i] = file;
  window._onboardClearImage[i] = false;
  const localUrl = URL.createObjectURL(file);
  const previewBox = document.getElementById(`onb-${i}-preview`);
  if (previewBox) {
    previewBox.outerHTML = `<img src="${localUrl}" id="onb-${i}-preview" style="max-width:140px;max-height:140px;border-radius:8px;border:2px solid var(--primary);margin-top:6px">`;
  }
  const nameBox = document.getElementById(`onb-${i}-filename`);
  if (nameBox) nameBox.innerHTML = `<span style="color:var(--primary);font-weight:600">✓ صورة جديدة جاهزة:</span> ${esc(file.name)}`;
}

function clearOnboardingImage(i) {
  window._onboardClearImage[i] = true;
  window._onboardFiles[i] = null;
  const previewBox = document.getElementById(`onb-${i}-preview`);
  if (previewBox) {
    previewBox.outerHTML = `<div id="onb-${i}-preview" class="text-hint fs-11 mt-6" style="color:var(--error)">ستُحذف الصورة عند الحفظ.</div>`;
  }
  const nameBox = document.getElementById(`onb-${i}-filename`);
  if (nameBox) nameBox.textContent = '';
}

async function saveOnboarding() {
  const existing = MockData.onboardingPages || [];
  const result = [];
  for (let i = 0; i < 3; i++) {
    const title = document.getElementById(`onb-${i}-title`).value.trim();
    const desc = document.getElementById(`onb-${i}-desc`).value.trim();
    const old = existing[i] || {};
    let imageUrl = old.imageUrl || '';
    if (window._onboardClearImage[i]) imageUrl = '';
    if (window._onboardFiles[i]) {
      try {
        showToast('info', `رفع صورة الشاشة ${i + 1}…`);
        const up = await API.uploadFiles([window._onboardFiles[i]], 'general');
        if (up && up.urls && up.urls[0]) imageUrl = up.urls[0];
      } catch (e) {
        showToast('error', `فشل رفع صورة الشاشة ${i + 1}`);
        return;
      }
    }
    result.push({ title, desc, imageUrl });
  }

  try {
    await API.updateConfig('onboarding_pages', result);
    MockData.onboardingPages = result;
    showToast('success', 'تم حفظ شاشات الترحيب');
  } catch (e) { return; }

  window._onboardFiles = { 0: null, 1: null, 2: null };
  window._onboardClearImage = { 0: false, 1: false, 2: false };
  closeModal(); navigate('settings');
}

// ── Privacy Policy ──────────────────────────────────────────────────────────

function modalEditPrivacyPolicy() {
  const pp = MockData.privacyPolicy;
  showModal('تعديل سياسة الخصوصية', `
    <p class="text-secondary fs-12 mb-16">اكتب نص السياسة كما تريد أن يراه المستخدم. يُحفظ ويظهر في شاشة تسجيل الدخول.</p>
    <div class="form-group">
      <label class="form-label">محتوى السياسة</label>
      <textarea class="form-input" id="pp-content" rows="16" style="font-family:inherit;line-height:1.7">${pp.content}</textarea>
    </div>`,
    `<button class="btn btn-outline" onclick="closeModal()">إلغاء</button>
     <button class="btn btn-primary" onclick="savePrivacyPolicy()">${ic('save')} حفظ ونشر</button>`);
}

async function savePrivacyPolicy() {
  const content = document.getElementById('pp-content').value;
  if (!content.trim()) { showToast('warning','لا يمكن حفظ نص فارغ'); return; }
  const val = { content, updatedAt: new Date().toISOString().slice(0,10) };
  try { await API.updateConfig('privacy_policy', val); MockData.privacyPolicy = val; showToast('success','تم نشر سياسة الخصوصية الجديدة'); }
  catch(e){ return; }
  closeModal(); navigate('settings');
}

// ═════════════════════════════════════════════════════════════════════════════
// ANALYTICS / REPORTS — Department-specific, date-filtered, printable
// ═════════════════════════════════════════════════════════════════════════════

let analyticsFrom = '';
let analyticsTo = '';

function pgAnalytics(el) {
  const d = currentUser.department;
  const today = new Date().toISOString().slice(0,10);
  if (!analyticsFrom) analyticsFrom = new Date(Date.now() - 30*24*60*60*1000).toISOString().slice(0,10);
  if (!analyticsTo) analyticsTo = today;

  el.innerHTML = `
    <div class="page-header" style="flex-wrap:wrap;gap:12px">
      <h2 class="page-title">${ic('bar-chart-3')} التقارير والإحصائيات</h2>
      <div class="flex gap-8" style="align-items:center;flex-wrap:wrap">
        <label class="fs-12 fw-600">من</label>
        <input type="date" class="form-input" id="ana-from" value="${analyticsFrom}" style="width:auto;padding:6px 10px;font-size:13px" onchange="analyticsFrom=this.value;reloadAnalytics()">
        <label class="fs-12 fw-600">إلى</label>
        <input type="date" class="form-input" id="ana-to" value="${analyticsTo}" style="width:auto;padding:6px 10px;font-size:13px" onchange="analyticsTo=this.value;reloadAnalytics()">
        <button class="btn btn-sm btn-outline" onclick="printAnalytics()">${ic('printer')} طباعة</button>
      </div>
    </div>
    <div id="analytics-body"></div>`;
  renderAnalytics();
}

function inRange(dateStr) {
  if (!dateStr) return false;
  const d = dateStr.slice(0,10);
  return d >= analyticsFrom && d <= analyticsTo;
}

async function reloadAnalytics() {
  const el = document.getElementById('analytics-body');
  if (el) el.innerHTML = '<div class="empty-state">جارٍ التحميل...</div>';
  try { await refreshPageData('analytics'); } catch(e){}
  renderAnalytics();
}

function renderAnalytics() {
  const d = currentUser.department;
  const D = MockData;
  const el = document.getElementById('analytics-body');
  if (!el) return;

  // ── Filter data by date range ─────────────────────────────────────────────
  const users = D.users.filter(u => inRange(u.createdAt));
  const allUsers = D.users;
  const reports = D.reports.filter(r => inRange(r.submittedAt || r.accidentDate));
  const allReports = D.reports;
  const payments = D.payments.filter(p => inRange(p.dueDate));
  const allPayments = D.payments;
  const appointments = D.appointments.filter(a => inRange(a.scheduledDate));
  const oilChanges = D.oilChanges.filter(o => inRange(o.createdAt));
  const requests = D.requests.filter(r => inRange(r.submittedAt));

  let html = '';

  // ── Stat helpers ──
  const statRow = (label, value, color) => `<div class="detail-row"><div class="detail-label">${label}</div><div class="detail-value fw-700" style="color:${color||'var(--text)'}">${value}</div></div>`;
  const sectionCard = (title, iconName, body) => `<div class="card" style="margin-bottom:16px"><h3 style="margin-bottom:12px">${ic(iconName)} ${title}</h3><hr style="border:none;border-top:1px solid var(--divider);margin-bottom:12px">${body}</div>`;

  // ══════════════════════════════════════════════════════════════════════════
  // ADMIN — sees everything
  // ══════════════════════════════════════════════════════════════════════════
  if (d === 'admin') {
    // Summary stats
    const totalRevenue = payments.filter(p=>p.status==='paid').reduce((s,p)=>s+p.amountIQD,0);
    const unpaidAmount = payments.filter(p=>p.status!=='paid').reduce((s,p)=>s+p.amountIQD,0);
    const activeSubs = allUsers.flatMap(u=>(u.cars||[])).filter(c=>c.subscription&&c.subscription!=='none').length;

    // ── Charts row ──
    const paymentStatusDonut = drawDonut([
      { label:'مسددة',   value: payments.filter(p=>p.status==='paid').length,    color:'#16A34A' },
      { label:'غير مسددة', value: payments.filter(p=>p.status==='unpaid').length,  color:'#D97706' },
      { label:'متأخرة',  value: payments.filter(p=>p.status==='overdue').length, color:'#DC2626' },
    ]);
    const reportStatusBars = drawBars([
      { label:'جديد',     value: reports.filter(r=>r.status==='pending').length,     color:'#D97706' },
      { label:'مراجعة',   value: reports.filter(r=>r.status==='underReview').length, color:'#0284C7' },
      { label:'معتمد',    value: reports.filter(r=>r.status==='approved').length,    color:'#1A3A8F' },
      { label:'إصلاح',    value: reports.filter(r=>r.status==='inRepair').length,    color:'#7C3AED' },
      { label:'مكتمل',    value: reports.filter(r=>r.status==='completed').length,   color:'#16A34A' },
      { label:'مرفوض',    value: reports.filter(r=>r.status==='rejected').length,    color:'#DC2626' },
    ]);
    const revenueTrend = drawLine(
      sumBucketsBy(payments.filter(p=>p.status==='paid'), 'dueDate', 'amountIQD', analyticsFrom, analyticsTo),
      { color:'#16A34A' }
    );
    const userGrowth = drawLine(
      bucketByDay(users, 'createdAt', analyticsFrom, analyticsTo),
      { color:'#1A3A8F' }
    );

    html += `<div class="two-col">
      ${chartCard('توزيع حالات المدفوعات', 'pie-chart', paymentStatusDonut)}
      ${chartCard('بلاغات الحوادث حسب الحالة', 'bar-chart-3', reportStatusBars)}
    </div>`;
    html += `<div class="two-col">
      ${chartCard('اتجاه الإيرادات اليومية', 'trending-up', revenueTrend)}
      ${chartCard('نمو المستخدمين', 'user-plus', userGrowth)}
    </div>`;

    html += `<div class="dash-stats-grid" style="margin-bottom:20px">
      ${_statBox('المستخدمون الجدد', users.length, 'var(--primary)', 'users')}
      ${_statBox('إجمالي المستخدمين', allUsers.length, 'var(--info)', 'user')}
      ${_statBox('بلاغات الحوادث', reports.length, 'var(--maintenance)', 'siren')}
      ${_statBox('المدفوعات', payments.length, 'var(--finance)', 'credit-card')}
      ${_statBox('الإيرادات المحصّلة', fmtIQD(totalRevenue), 'var(--success)', 'wallet')}
      ${_statBox('مبالغ معلّقة', fmtIQD(unpaidAmount), 'var(--error)', 'alert-triangle')}
      ${_statBox('المواعيد', appointments.length, 'var(--info)', 'calendar')}
      ${_statBox('الاشتراكات النشطة', activeSubs, 'var(--primary)', 'clipboard-list')}
    </div>`;

    // Users breakdown
    html += sectionCard('المستخدمون (في الفترة المحددة)', 'users', `
      ${statRow('تسجيلات جديدة', users.length, 'var(--primary)')}
      ${statRow('بانتظار الموافقة', allUsers.filter(u=>u.status==='pending').length, 'var(--warning)')}
      ${statRow('معتمدون', allUsers.filter(u=>u.status==='approved').length, 'var(--success)')}
      ${statRow('موقوفون', allUsers.filter(u=>u.status==='suspended').length, 'var(--error)')}
      ${statRow('إجمالي السيارات', allUsers.flatMap(u=>u.cars||[]).length)}
    `);

    // Revenue breakdown
    html += sectionCard('المالية (في الفترة المحددة)', 'credit-card', `
      ${statRow('إجمالي المدفوعات', payments.length)}
      ${statRow('مسددة', payments.filter(p=>p.status==='paid').length, 'var(--success)')}
      ${statRow('غير مسددة', payments.filter(p=>p.status==='unpaid').length, 'var(--warning)')}
      ${statRow('متأخرة', payments.filter(p=>p.status==='overdue').length, 'var(--error)')}
      ${statRow('إجمالي الإيرادات', fmtIQD(totalRevenue), 'var(--success)')}
      ${statRow('مبالغ مستحقة', fmtIQD(unpaidAmount), 'var(--error)')}
    `);

    // Accidents
    html += sectionCard('بلاغات الحوادث (في الفترة المحددة)', 'siren', `
      ${statRow('إجمالي البلاغات', reports.length)}
      ${['pending','underReview','approved','inRepair','completed','rejected'].map(s =>
        statRow(ReportStatusLabels[s]||s, reports.filter(r=>r.status===s).length, `var(--${ReportStatusBadge[s]})`)
      ).join('')}
    `);

    // Appointments + Oil
    html += `<div class="two-col">${sectionCard('المواعيد', 'calendar', `
      ${statRow('إجمالي المواعيد', appointments.length)}
      ${['scheduled','confirmed','completed','cancelled'].map(s =>
        statRow(AptStatusLabels[s]||s, appointments.filter(a=>a.status===s).length)
      ).join('')}
    `)}${sectionCard('تغيير الزيت', 'wrench', `
      ${statRow('إجمالي الطلبات', oilChanges.length)}
      ${['pending','confirmed','completed','cancelled'].map(s =>
        statRow(OilStatusLabels[s]||s, oilChanges.filter(o=>o.status===s).length)
      ).join('')}
    `)}</div>`;

    // Requests
    html += sectionCard('الطلبات الإدارية', 'inbox', `
      ${statRow('إجمالي الطلبات', requests.length)}
      ${statRow('معلقة', requests.filter(r=>r.status==='pending').length, 'var(--warning)')}
      ${statRow('مقبولة', requests.filter(r=>r.status==='approved').length, 'var(--success)')}
      ${statRow('مرفوضة', requests.filter(r=>r.status==='rejected').length, 'var(--error)')}
    `);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // FINANCE — payments, revenue, subscriptions
  // ══════════════════════════════════════════════════════════════════════════
  if (d === 'finance') {
    const totalRevenue = payments.filter(p=>p.status==='paid').reduce((s,p)=>s+p.amountIQD,0);
    const unpaidAmount = payments.filter(p=>p.status!=='paid').reduce((s,p)=>s+p.amountIQD,0);
    const activeSubs = allUsers.flatMap(u=>(u.cars||[])).filter(c=>c.subscription&&c.subscription!=='none');

    // Charts
    const statusDonut = drawDonut([
      { label:'مسددة',   value: payments.filter(p=>p.status==='paid').length,    color:'#16A34A' },
      { label:'غير مسددة', value: payments.filter(p=>p.status==='unpaid').length,  color:'#D97706' },
      { label:'متأخرة',  value: payments.filter(p=>p.status==='overdue').length, color:'#DC2626' },
    ]);
    const revenueTrend = drawLine(
      sumBucketsBy(payments.filter(p=>p.status==='paid'), 'dueDate', 'amountIQD', analyticsFrom, analyticsTo),
      { color:'#16A34A' }
    );
    html += `<div class="two-col">
      ${chartCard('توزيع حالات المدفوعات', 'pie-chart', statusDonut)}
      ${chartCard('اتجاه الإيرادات', 'trending-up', revenueTrend)}
    </div>`;

    html += `<div class="dash-stats-grid" style="margin-bottom:20px">
      ${_statBox('المدفوعات', payments.length, 'var(--finance)', 'credit-card')}
      ${_statBox('الإيرادات', fmtIQD(totalRevenue), 'var(--success)', 'wallet')}
      ${_statBox('مبالغ معلّقة', fmtIQD(unpaidAmount), 'var(--error)', 'alert-triangle')}
      ${_statBox('الاشتراكات', activeSubs.length, 'var(--primary)', 'clipboard-list')}
    </div>`;

    html += sectionCard('ملخص المدفوعات', 'credit-card', `
      ${statRow('إجمالي المدفوعات في الفترة', payments.length)}
      ${statRow('مسددة', payments.filter(p=>p.status==='paid').length, 'var(--success)')}
      ${statRow('غير مسددة', payments.filter(p=>p.status==='unpaid').length, 'var(--warning)')}
      ${statRow('متأخرة', payments.filter(p=>p.status==='overdue').length, 'var(--error)')}
      ${statRow('إجمالي المحصّل', fmtIQD(totalRevenue), 'var(--success)')}
      ${statRow('إجمالي المستحق', fmtIQD(unpaidAmount), 'var(--error)')}
    `);

    // Revenue by plan type
    const planRevenue = {};
    payments.filter(p=>p.status==='paid').forEach(p => {
      const desc = p.carDesc || 'غير محدد';
      // Try to find the car's plan from users
      const user = allUsers.find(u=>u.id===p.userId);
      const car = user?.cars?.find(c=> desc.includes(c.make));
      const plan = car?.subscription || 'none';
      planRevenue[plan] = (planRevenue[plan]||0) + p.amountIQD;
    });
    html += sectionCard('الإيرادات حسب الخطة', 'clipboard-list',
      Object.entries(planRevenue).map(([plan, amt]) =>
        statRow(SubLabels[plan]||plan, fmtIQD(amt), `var(--${SubBadge[plan]||'info'})`)
      ).join('') || '<div class="text-hint">لا توجد بيانات</div>'
    );

    // Subscription breakdown
    const subCounts = { standard:0, shared:0, vip:0 };
    activeSubs.forEach(c => { if(subCounts[c.subscription]!==undefined) subCounts[c.subscription]++; });
    html += sectionCard('الاشتراكات النشطة حسب الخطة', 'clipboard-list', `
      ${statRow('ستاندارد', subCounts.standard, 'var(--primary)')}
      ${statRow('المزدوج', subCounts.shared, 'var(--purple,#7C3AED)')}
      ${statRow('VIP', subCounts.vip, 'var(--warning)')}
      ${statRow('الإجمالي', activeSubs.length)}
    `);

    // Payments table
    html += sectionCard('تفصيل المدفوعات', 'list', `
      <table class="data-table"><thead><tr><th>المستخدم</th><th>السيارة</th><th>المبلغ</th><th>الشهر</th><th>الاستحقاق</th><th>الحالة</th></tr></thead><tbody>
      ${payments.map(p=>`<tr><td>${p.userName||'—'}</td><td>${p.carDesc||'—'}</td><td>${fmtIQD(p.amountIQD)}</td><td>${p.month||'—'}</td><td>${fmtDate(p.dueDate)}</td><td>${badge(PayStatusBadge[p.status],PayStatusLabels[p.status])}</td></tr>`).join('')}
      </tbody></table>
    `);

    // Upgrade requests
    const upgReqs = requests.filter(r=>r.type==='upgrade');
    if (upgReqs.length) {
      html += sectionCard('طلبات الاشتراك/الترقية', 'arrow-up', `
        <table class="data-table"><thead><tr><th>المستخدم</th><th>الخطة المطلوبة</th><th>المبلغ</th><th>التاريخ</th><th>الحالة</th></tr></thead><tbody>
        ${upgReqs.map(r=>`<tr><td>${r.userName||'—'}</td><td>${r.requestedPlan||'—'}</td><td>${r.amountDueIQD?fmtIQD(r.amountDueIQD):'—'}</td><td>${fmtDate(r.submittedAt)}</td><td>${badge(RequestStatusBadge[r.status],RequestStatusLabels[r.status])}</td></tr>`).join('')}
        </tbody></table>
      `);
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // MAINTENANCE — accidents, repairs, appointments, oil changes
  // ══════════════════════════════════════════════════════════════════════════
  if (d === 'maintenance') {
    html += `<div class="dash-stats-grid" style="margin-bottom:20px">
      ${_statBox('البلاغات', reports.length, 'var(--maintenance)', 'siren')}
      ${_statBox('المواعيد', appointments.length, 'var(--info)', 'calendar')}
      ${_statBox('تغيير الزيت', oilChanges.length, '#065F46', 'wrench')}
      ${_statBox('مكتملة', reports.filter(r=>r.status==='completed').length, 'var(--success)', 'check-circle')}
    </div>`;

    // Charts
    const reportBars = drawBars([
      { label:'جديد',     value: reports.filter(r=>r.status==='pending').length,     color:'#D97706' },
      { label:'مراجعة',   value: reports.filter(r=>r.status==='underReview').length, color:'#0284C7' },
      { label:'معتمد',    value: reports.filter(r=>r.status==='approved').length,    color:'#1A3A8F' },
      { label:'إصلاح',    value: reports.filter(r=>r.status==='inRepair').length,    color:'#7C3AED' },
      { label:'مكتمل',    value: reports.filter(r=>r.status==='completed').length,   color:'#16A34A' },
      { label:'مرفوض',    value: reports.filter(r=>r.status==='rejected').length,    color:'#DC2626' },
    ]);
    const reportTrend = drawLine(
      bucketByDay(reports, 'submittedAt', analyticsFrom, analyticsTo),
      { color:'#A21CAF' }
    );
    html += `<div class="two-col">
      ${chartCard('البلاغات حسب الحالة', 'bar-chart-3', reportBars)}
      ${chartCard('اتجاه البلاغات اليومية', 'trending-up', reportTrend)}
    </div>`;

    html += sectionCard('بلاغات الحوادث', 'siren', `
      ${statRow('إجمالي البلاغات في الفترة', reports.length)}
      ${['pending','underReview','approved','inRepair','completed','rejected'].map(s =>
        statRow(ReportStatusLabels[s]||s, reports.filter(r=>r.status===s).length, `var(--${ReportStatusBadge[s]})`)
      ).join('')}
    `);

    // Reports table
    html += sectionCard('تفصيل البلاغات', 'list', `
      <table class="data-table"><thead><tr><th>المستخدم</th><th>السيارة</th><th>الموقع</th><th>التاريخ</th><th>الحالة</th></tr></thead><tbody>
      ${reports.map(r=>`<tr><td>${r.userName||'—'}</td><td>${r.carDesc||'—'}</td><td>${r.location||'—'}</td><td>${fmtDate(r.accidentDate)}</td><td>${badge(ReportStatusBadge[r.status],ReportStatusLabels[r.status])}</td></tr>`).join('')}
      </tbody></table>
    `);

    html += `<div class="two-col">${sectionCard('المواعيد', 'calendar', `
      ${statRow('إجمالي المواعيد', appointments.length)}
      ${['scheduled','confirmed','completed','cancelled'].map(s =>
        statRow(AptStatusLabels[s]||s, appointments.filter(a=>a.status===s).length)
      ).join('')}
    `)}${sectionCard('تغيير الزيت', 'wrench', `
      ${statRow('إجمالي الطلبات', oilChanges.length)}
      ${['pending','confirmed','completed','cancelled'].map(s =>
        statRow(OilStatusLabels[s]||s, oilChanges.filter(o=>o.status===s).length)
      ).join('')}
    `)}</div>`;

    // Appointments table
    html += sectionCard('تفصيل المواعيد', 'list', `
      <table class="data-table"><thead><tr><th>المستخدم</th><th>التاريخ</th><th>الوقت</th><th>الفرع</th><th>الحالة</th></tr></thead><tbody>
      ${appointments.map(a=>`<tr><td>${a.userName||'—'}</td><td>${fmtDate(a.scheduledDate)}</td><td>${a.timeSlot||'—'}</td><td>${a.branchName||'—'}</td><td>${badge(AptStatusBadge[a.status],AptStatusLabels[a.status])}</td></tr>`).join('')}
      </tbody></table>
    `);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ADMINISTRATION — users, requests
  // ══════════════════════════════════════════════════════════════════════════
  if (d === 'administration') {
    html += `<div class="dash-stats-grid" style="margin-bottom:20px">
      ${_statBox('مستخدمون جدد', users.length, 'var(--primary)', 'users')}
      ${_statBox('الطلبات', requests.length, 'var(--administration)', 'inbox')}
      ${_statBox('بانتظار الموافقة', allUsers.filter(u=>u.status==='pending').length, 'var(--warning)', 'clock')}
      ${_statBox('معتمدون', allUsers.filter(u=>u.status==='approved').length, 'var(--success)', 'check-circle')}
    </div>`;

    // Charts
    const userStatusDonut = drawDonut([
      { label:'معتمدون',   value: allUsers.filter(u=>u.status==='approved').length,  color:'#16A34A' },
      { label:'بانتظار',   value: allUsers.filter(u=>u.status==='pending').length,   color:'#D97706' },
      { label:'مرفوضون',   value: allUsers.filter(u=>u.status==='rejected').length,  color:'#DC2626' },
      { label:'موقوفون',   value: allUsers.filter(u=>u.status==='suspended').length, color:'#6B7280' },
    ]);
    const userGrowth = drawLine(
      bucketByDay(users, 'createdAt', analyticsFrom, analyticsTo),
      { color:'#1A3A8F' }
    );
    html += `<div class="two-col">
      ${chartCard('توزيع حالات المستخدمين', 'pie-chart', userStatusDonut)}
      ${chartCard('نمو المستخدمين', 'trending-up', userGrowth)}
    </div>`;

    html += sectionCard('المستخدمون (في الفترة المحددة)', 'users', `
      ${statRow('تسجيلات جديدة في الفترة', users.length, 'var(--primary)')}
      ${statRow('إجمالي المستخدمين', allUsers.length)}
      ${statRow('بانتظار الموافقة', allUsers.filter(u=>u.status==='pending').length, 'var(--warning)')}
      ${statRow('معتمدون', allUsers.filter(u=>u.status==='approved').length, 'var(--success)')}
      ${statRow('مرفوضون', allUsers.filter(u=>u.status==='rejected').length, 'var(--error)')}
      ${statRow('موقوفون', allUsers.filter(u=>u.status==='suspended').length, 'var(--error)')}
    `);

    // Users table
    html += sectionCard('المستخدمون المسجلون في الفترة', 'list', `
      <table class="data-table"><thead><tr><th>الاسم</th><th>الهاتف</th><th>تاريخ التسجيل</th><th>الحالة</th><th>السيارات</th></tr></thead><tbody>
      ${users.map(u=>`<tr><td>${esc(u.fullName)}</td><td>${esc(u.phone)}</td><td>${fmtDate(u.createdAt)}</td><td>${badge(UserStatusBadge[u.status],UserStatusLabels[u.status])}</td><td>${(u.cars||[]).length}</td></tr>`).join('')}
      </tbody></table>
    `);

    // Requests
    html += sectionCard('الطلبات الإدارية', 'inbox', `
      ${statRow('إجمالي الطلبات في الفترة', requests.length)}
      ${statRow('معلقة', requests.filter(r=>r.status==='pending').length, 'var(--warning)')}
      ${statRow('مقبولة', requests.filter(r=>r.status==='approved').length, 'var(--success)')}
      ${statRow('مرفوضة', requests.filter(r=>r.status==='rejected').length, 'var(--error)')}
      ${statRow('تعديل ملف', requests.filter(r=>r.type==='profileEdit').length)}
      ${statRow('تعديل سيارة', requests.filter(r=>r.type==='carChange').length)}
      ${statRow('ترقية اشتراك', requests.filter(r=>r.type==='upgrade').length)}
    `);

    // Requests table
    html += sectionCard('تفصيل الطلبات', 'list', `
      <table class="data-table"><thead><tr><th>المستخدم</th><th>النوع</th><th>التاريخ</th><th>الحالة</th></tr></thead><tbody>
      ${requests.map(r=>`<tr><td>${r.userName||'—'}</td><td>${RequestTypeLabels[r.type]||r.type}</td><td>${fmtDate(r.submittedAt)}</td><td>${badge(RequestStatusBadge[r.status],RequestStatusLabels[r.status])}</td></tr>`).join('')}
      </tbody></table>
    `);
  }

  // Period note
  html += `<div class="text-hint fs-11" style="margin-top:20px;text-align:center">التقرير للفترة من ${analyticsFrom} إلى ${analyticsTo} — تم إنشاؤه بواسطة ${currentUser.fullName} (${DeptLabels[d]}) — ${new Date().toLocaleString('ar-IQ')}</div>`;

  el.innerHTML = html;
  refreshIcons();
}

// ── Lightweight SVG charts (no deps) ────────────────────────────────────────

/** Donut chart. data = [{label, value, color}] */
function drawDonut(data, opts) {
  const o = { size: 180, thickness: 32, ...opts };
  const total = data.reduce((s,d)=>s+d.value, 0) || 1;
  const r = o.size/2;
  const cx = r, cy = r;
  const inner = r - o.thickness;
  let cumA = -Math.PI/2; // start at top
  const arcs = data.map(d => {
    if (d.value === 0) return '';
    const frac = d.value/total;
    const a0 = cumA;
    const a1 = cumA + frac*Math.PI*2;
    cumA = a1;
    const large = (a1-a0) > Math.PI ? 1 : 0;
    const x0 = cx + r*Math.cos(a0), y0 = cy + r*Math.sin(a0);
    const x1 = cx + r*Math.cos(a1), y1 = cy + r*Math.sin(a1);
    const xi0 = cx + inner*Math.cos(a1), yi0 = cy + inner*Math.sin(a1);
    const xi1 = cx + inner*Math.cos(a0), yi1 = cy + inner*Math.sin(a0);
    return `<path d="M ${x0} ${y0} A ${r} ${r} 0 ${large} 1 ${x1} ${y1} L ${xi0} ${yi0} A ${inner} ${inner} 0 ${large} 0 ${xi1} ${yi1} Z" fill="${d.color}"/>`;
  }).join('');
  const legend = data.map(d => {
    const pct = total ? Math.round(d.value/total*100) : 0;
    return `<div class="chart-legend-row"><span class="chart-swatch" style="background:${d.color}"></span><span class="chart-legend-label">${d.label}</span><span class="chart-legend-value">${d.value} (${pct}%)</span></div>`;
  }).join('');
  return `<div class="chart-wrap">
    <svg viewBox="0 0 ${o.size} ${o.size}" width="${o.size}" height="${o.size}">
      <circle cx="${cx}" cy="${cy}" r="${r}" fill="#F3F4F6"/>
      ${arcs}
      <circle cx="${cx}" cy="${cy}" r="${inner-1}" fill="#fff"/>
      <text x="${cx}" y="${cy-4}" text-anchor="middle" font-size="22" font-weight="800" fill="#0F1F45">${total}</text>
      <text x="${cx}" y="${cy+14}" text-anchor="middle" font-size="10" fill="#6B7280">المجموع</text>
    </svg>
    <div class="chart-legend">${legend}</div>
  </div>`;
}

/** Vertical bar chart. data = [{label, value, color?}] */
function drawBars(data, opts) {
  const o = { width: 520, height: 220, pad: 28, ...opts };
  if (!data.length) return '<div class="text-hint text-center">لا توجد بيانات</div>';
  const max = Math.max(...data.map(d=>d.value), 1);
  const barW = (o.width - o.pad*2) / data.length - 8;
  const plotH = o.height - o.pad*2;
  const bars = data.map((d, i) => {
    const h = (d.value/max) * plotH;
    const x = o.pad + i*(barW+8);
    const y = o.height - o.pad - h;
    const color = d.color || '#1A3A8F';
    return `<g>
      <rect x="${x}" y="${y}" width="${barW}" height="${h}" fill="${color}" rx="4" />
      <text x="${x+barW/2}" y="${y-4}" text-anchor="middle" font-size="11" fill="#0F1F45" font-weight="700">${d.value}</text>
      <text x="${x+barW/2}" y="${o.height-o.pad+14}" text-anchor="middle" font-size="10" fill="#6B7280">${d.label}</text>
    </g>`;
  }).join('');
  // Y-axis gridlines
  const gridlines = [0.25,0.5,0.75,1].map(f => {
    const y = o.height - o.pad - f*plotH;
    return `<line x1="${o.pad}" y1="${y}" x2="${o.width-o.pad}" y2="${y}" stroke="#E5E7EB" stroke-dasharray="3 3"/>`;
  }).join('');
  return `<svg viewBox="0 0 ${o.width} ${o.height}" class="chart-svg" preserveAspectRatio="xMidYMid meet">
    ${gridlines}
    ${bars}
  </svg>`;
}

/** Sparkline/line chart. series = [{value, label}] */
function drawLine(series, opts) {
  const o = { width: 520, height: 180, pad: 24, color: '#1A3A8F', ...opts };
  if (!series.length) return '<div class="text-hint text-center">لا توجد بيانات</div>';
  const max = Math.max(...series.map(s=>s.value), 1);
  const plotW = o.width - o.pad*2;
  const plotH = o.height - o.pad*2;
  const step = series.length > 1 ? plotW/(series.length-1) : 0;
  const pts = series.map((s, i) => {
    const x = o.pad + i*step;
    const y = o.height - o.pad - (s.value/max)*plotH;
    return [x, y, s];
  });
  const d = pts.map((p,i)=>(i===0?'M':'L')+p[0]+' '+p[1]).join(' ');
  const area = d + ` L ${pts[pts.length-1][0]} ${o.height-o.pad} L ${pts[0][0]} ${o.height-o.pad} Z`;
  const dots = pts.map(p => `<circle cx="${p[0]}" cy="${p[1]}" r="3" fill="${o.color}"/>`).join('');
  const labels = pts.map((p,i) => (i%Math.max(1,Math.floor(series.length/6))===0 ? `<text x="${p[0]}" y="${o.height-o.pad+14}" text-anchor="middle" font-size="9" fill="#6B7280">${p[2].label}</text>` : '')).join('');
  return `<svg viewBox="0 0 ${o.width} ${o.height}" class="chart-svg" preserveAspectRatio="xMidYMid meet">
    <path d="${area}" fill="${o.color}" fill-opacity="0.1"/>
    <path d="${d}" stroke="${o.color}" stroke-width="2.5" fill="none" stroke-linecap="round" stroke-linejoin="round"/>
    ${dots}
    ${labels}
  </svg>`;
}

function chartCard(title, iconName, svgHtml) {
  return `<div class="card" style="margin-bottom:16px">
    <h3 style="margin-bottom:12px">${ic(iconName)} ${title}</h3>
    <hr style="border:none;border-top:1px solid var(--divider);margin-bottom:12px">
    ${svgHtml}
  </div>`;
}

// Build last-N-days buckets from a list of records
function bucketByDay(records, dateField, fromStr, toStr) {
  const from = new Date(fromStr);
  const to   = new Date(toStr);
  const days = Math.min(31, Math.max(1, Math.ceil((to-from)/(24*3600*1000)) + 1));
  const step = Math.max(1, Math.ceil(days/14)); // cap buckets to ~14
  const buckets = [];
  for (let i = 0; i < days; i += step) {
    const b0 = new Date(from); b0.setDate(b0.getDate()+i);
    const b1 = new Date(from); b1.setDate(b1.getDate()+i+step-1);
    if (b1 > to) b1.setTime(to.getTime());
    buckets.push({
      label: `${b0.getMonth()+1}/${b0.getDate()}`,
      from: b0, to: b1, value: 0,
    });
  }
  records.forEach(r => {
    const d = r[dateField];
    if (!d) return;
    const dt = new Date(d);
    const bucket = buckets.find(b => dt >= b.from && dt <= b.to);
    if (bucket) bucket.value += 1;
  });
  return buckets;
}

function sumBucketsBy(records, dateField, valueField, fromStr, toStr) {
  const buckets = bucketByDay(records, dateField, fromStr, toStr);
  buckets.forEach(b => b.value = 0);
  records.forEach(r => {
    const d = r[dateField];
    if (!d) return;
    const dt = new Date(d);
    const bucket = buckets.find(b => dt >= b.from && dt <= b.to);
    if (bucket) bucket.value += (r[valueField] || 0);
  });
  return buckets;
}

function _statBox(title, value, color, iconName) {
  return `<div class="dash-stat" style="cursor:default">
    <div class="dash-stat-icon" style="background:${color}12;color:${color}">${ic(iconName)}</div>
    <div class="dash-stat-body">
      <div class="dash-stat-value" style="color:${color}">${value}</div>
      <div class="dash-stat-title">${title}</div>
    </div>
  </div>`;
}

function printAnalytics() {
  const body = document.getElementById('analytics-body');
  if (!body) return;
  const d = currentUser.department;
  const win = window.open('', '_blank');
  win.document.write(`<!DOCTYPE html><html lang="ar" dir="rtl"><head>
    <meta charset="UTF-8">
    <title>تقرير — ${DeptLabels[d]} — ${analyticsFrom} إلى ${analyticsTo}</title>
    <link href="https://fonts.googleapis.com/css2?family=Cairo:wght@400;600;700;800&display=swap" rel="stylesheet">
    <style>
      * { margin:0; padding:0; box-sizing:border-box; }
      body { font-family:'Cairo',sans-serif; padding:24px; color:#0F1F45; direction:rtl; font-size:13px; }
      h2 { font-size:20px; margin-bottom:4px; color:#1A3A8F; }
      h3 { font-size:15px; margin-bottom:8px; }
      .meta { font-size:11px; color:#6B7280; margin-bottom:20px; }
      .card { background:#fff; border:1px solid #E5E7EB; border-radius:10px; padding:16px; margin-bottom:14px; }
      .detail-row { display:flex; justify-content:space-between; padding:4px 0; border-bottom:1px solid #f3f4f6; }
      .detail-label { color:#6B7280; }
      .detail-value { font-weight:600; }
      .fw-700 { font-weight:700; }
      hr { border:none; border-top:1px solid #E5E7EB; margin:10px 0; }
      table { width:100%; border-collapse:collapse; font-size:12px; }
      th { background:#F5F7FF; padding:8px; text-align:right; font-weight:600; border-bottom:2px solid #E5E7EB; }
      td { padding:6px 8px; border-bottom:1px solid #f3f4f6; }
      .badge { display:inline-block; padding:2px 8px; border-radius:20px; font-size:10px; font-weight:600; }
      .badge-success { background:#DCFCE7; color:#16A34A; } .badge-warning { background:#FEF3C7; color:#D97706; }
      .badge-error { background:#FEE2E2; color:#DC2626; } .badge-info { background:#E0F2FE; color:#0284C7; }
      .badge-primary { background:#E8EDF7; color:#1A3A8F; }
      .dash-stats-grid { display:grid; grid-template-columns:repeat(4,1fr); gap:12px; margin-bottom:16px; }
      .dash-stat { display:flex; align-items:center; gap:10px; padding:12px; border:1px solid #E5E7EB; border-radius:10px; }
      .dash-stat-value { font-size:20px; font-weight:800; } .dash-stat-title { font-size:11px; color:#6B7280; }
      .two-col { display:grid; grid-template-columns:1fr 1fr; gap:14px; }
      .text-hint { font-size:11px; color:#9CA3AF; }
      svg, [data-lucide] { display:none !important; }
      @media print { body { padding:12px; } }
    </style>
  </head><body>
    <h2>تقرير ${DeptLabels[d]}</h2>
    <div class="meta">الفترة: ${analyticsFrom} إلى ${analyticsTo} — أُنشئ بواسطة: ${currentUser.fullName} — ${new Date().toLocaleString('ar-IQ')}</div>
    ${body.innerHTML}
  </body></html>`);
  win.document.close();
  setTimeout(() => win.print(), 500);
}

// ── Init ─────────────────────────────────────────────────────────────────────

document.addEventListener('DOMContentLoaded', () => {
  // Render the static <i data-lucide> icons (login page logo, etc.) on first load.
  refreshIcons();
  document.addEventListener('keydown', e => { if(e.key==='Enter'&&!currentUser) login(); });

  // Auto-login if token exists (dashboard was previously logged in)
  // For now, always show login page — token-based auto-login can be added later
  // by verifying the stored admin token with a /admin/me endpoint.
});
