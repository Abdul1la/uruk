/* ═══════════════════════════════════════════════════════════════════════════
   URUK MOTORS — Complete Mock Data (mirrors every field from mobile app)
   ═══════════════════════════════════════════════════════════════════════════ */

const MockData = {
  cities: ['بغداد'],

  supportInfo: {
    phone: '+964 770 000 0000',
    email: 'support@urukmotors.iq',
    whatsapp: '+964 770 000 0000',
    address: 'بغداد، الكرادة، شارع أبو نؤاس',
    workingHours: 'السبت - الخميس، 9 صباحاً - 5 مساءً',
    instagram: 'urukmotors',
    facebook: 'urukmotors',
    telegram: 'urukmotors',
    website: 'www.urukmotors.iq',
  },

  // Privacy policy — editable by admin in Settings, shown in app before sign-in.
  privacyPolicy: {
    updatedAt: '2026-04-09',
    content: `سياسة الخصوصية\n\nمرحباً بك في تطبيق Uruk Motors. نهتم بخصوصيتك ونلتزم بحماية بياناتك الشخصية. توضح هذه السياسة كيف نجمع المعلومات ونستخدمها ونحميها.\n\n1. المعلومات التي نجمعها\nنجمع البيانات التي تقدّمها بنفسك عند التسجيل (الاسم، رقم الهاتف، البريد الإلكتروني، الهوية الوطنية، بيانات السيارة).\n\n2. كيف نستخدم بياناتك\nنستخدم بياناتك لتقديم خدمات الصيانة والاشتراكات وإدارة المواعيد والمدفوعات والتواصل معك.\n\n3. مشاركة البيانات\nلا نشارك بياناتك مع أي طرف ثالث إلا بموافقتك أو بموجب القانون.\n\n4. أمان البيانات\nنطبّق إجراءات أمنية لحماية بياناتك من الوصول غير المصرّح به.\n\n5. حقوقك\nيحق لك طلب الاطلاع على بياناتك أو تعديلها أو حذفها في أي وقت بالتواصل معنا.\n\n6. التواصل\nلأي استفسار حول الخصوصية، تواصل معنا عبر معلومات الدعم في التطبيق.`,
  },

  // Branches / service centers — editable in admin Settings, used in scheduling.
  branches: [
    { id:'br_001', name:'فرع الكرادة', lat:33.3128, lng:44.3615, address:'الكرادة، بغداد', phone:'+964 770 111 0001', isActive:true },
    { id:'br_002', name:'فرع المنصور', lat:33.3152, lng:44.3506, address:'المنصور، بغداد', phone:'+964 770 111 0002', isActive:true },
    { id:'br_003', name:'فرع زيونة',   lat:33.33,   lng:44.42,   address:'زيونة، بغداد',  phone:'+964 770 111 0003', isActive:true },
  ],

  // Subscription plan configuration — editable by finance/admin.
  plans: [
    { type:'standard', name:'ستاندارد', priceIQD:35000, repairTiers:[
      { months:1,  repairsPerMonth:1 }, { months:3,  repairsPerMonth:2 },
      { months:6,  repairsPerMonth:3 }, { months:12, repairsPerMonth:4 },
    ]},
    { type:'shared', name:'المزدوج', priceIQD:60000, repairTiers:[
      { months:1,  repairsPerMonth:1 }, { months:3,  repairsPerMonth:2 },
      { months:6,  repairsPerMonth:3 }, { months:12, repairsPerMonth:4 },
    ]},
    { type:'vip', name:'VIP', priceIQD:150000, repairTiers:[
      { months:1,  repairsPerMonth:3 }, { months:3,  repairsPerMonth:5 },
      { months:6,  repairsPerMonth:7 }, { months:12, repairsPerMonth:10 },
    ]},
  ],

  // Payment account numbers shown to users in the app — editable by finance/admin.
  paymentAccounts: {
    zainCash: '+964 770 000 0000',
    superQi:  '07XX-XXX-XXXX',
  },

  // Onboarding slides shown the first time a user opens the app — admin can
  // override the title/desc/image for each slide. Empty array = use the
  // built-in defaults bundled with the Flutter app.
  onboardingPages: [],

  employees: [
    { id:'emp_001', fullName:'علي المدير', email:'admin@uruk.iq', phone:'+964 770 000 0001', department:'admin', isActive:true, createdAt:'2025-06-01' },
    { id:'emp_002', fullName:'سارة المالية', email:'finance@uruk.iq', phone:'+964 770 000 0002', department:'finance', isActive:true, createdAt:'2025-07-01' },
    { id:'emp_003', fullName:'حسن الصيانة', email:'maintenance@uruk.iq', phone:'+964 770 000 0003', department:'maintenance', isActive:true, createdAt:'2025-07-15' },
    { id:'emp_004', fullName:'فاطمة الإدارية', email:'admin-dept@uruk.iq', phone:'+964 770 000 0004', department:'administration', isActive:true, createdAt:'2025-08-01' },
    { id:'emp_005', fullName:'محمد المالي', email:'finance2@uruk.iq', phone:'+964 770 000 0005', department:'finance', isActive:true, createdAt:'2026-01-10' },
  ],

  users: [
    {
      id:'usr_001', fullName:'أحمد الراشدي', phone:'+964 770 123 4567', email:'ahmed@example.com',
      status:'approved', paymentDue:true,
      idFrontUrl:'https://placehold.co/400x250/E8EDF7/1A3A8F?text=هوية+أمامية', idBackUrl:'https://placehold.co/400x250/E8EDF7/1A3A8F?text=هوية+خلفية',
      cars:[
        { id:'car_001', make:'تويوتا', model:'كامري', year:2021, color:'أبيض', plateNumber:'12345 - بغداد', imageUrl:'https://placehold.co/300x200/E8EDF7/1A3A8F?text=كامري+2021', subscription:'shared', subscriptionExpiry:'2026-04-26', paymentMonths:1, repairsAllowed:1, repairsUsed:0 },
        { id:'car_002', make:'هيونداي', model:'سونتا', year:2019, color:'رمادي', plateNumber:'54321 - بغداد', imageUrl:null, subscription:'standard', subscriptionExpiry:'2026-05-23', paymentMonths:3, repairsAllowed:2, repairsUsed:1 },
      ],
      createdAt:'2026-01-15'
    },
    {
      id:'usr_002', fullName:'زينب العلي', phone:'+964 771 555 8899', email:'zainab@example.com',
      status:'pending', paymentDue:false,
      idFrontUrl:'https://placehold.co/400x250/FEF3C7/D97706?text=هوية+أمامية', idBackUrl:'https://placehold.co/400x250/FEF3C7/D97706?text=هوية+خلفية',
      cars:[], createdAt:'2026-04-05'
    },
    {
      id:'usr_003', fullName:'عمر حسين', phone:'+964 772 333 4455', email:null,
      status:'approved', paymentDue:false,
      idFrontUrl:null, idBackUrl:null,
      cars:[
        { id:'car_003', make:'كيا', model:'سبورتاج', year:2023, color:'أسود', plateNumber:'99887 - كربلاء', imageUrl:'https://placehold.co/300x200/E8EDF7/1A3A8F?text=سبورتاج+2023', subscription:'vip', subscriptionExpiry:'2026-07-07', paymentMonths:6, repairsAllowed:7, repairsUsed:2 },
      ],
      createdAt:'2026-02-20'
    },
    {
      id:'usr_004', fullName:'مريم الجبوري', phone:'+964 773 111 2233', email:null,
      status:'pending', paymentDue:false,
      idFrontUrl:'https://placehold.co/400x250/FEF3C7/D97706?text=هوية+أمامية', idBackUrl:null,
      cars:[], createdAt:'2026-04-07'
    },
    {
      id:'usr_005', fullName:'كريم السعدي', phone:'+964 774 999 0011', email:null,
      status:'suspended', paymentDue:false,
      idFrontUrl:null, idBackUrl:null,
      cars:[
        { id:'car_005', make:'نيسان', model:'سنترا', year:2020, color:'فضي', plateNumber:'77661 - بغداد', imageUrl:null, subscription:'none', subscriptionExpiry:null, paymentMonths:1, repairsAllowed:0, repairsUsed:0 },
      ],
      createdAt:'2025-11-10'
    },
  ],

  reports: [
    {
      id:'rpt_001', userId:'usr_001', userName:'أحمد الراشدي', carId:'car_001', carDesc:'تويوتا كامري 2021',
      accidentDate:'2026-03-15', location:'الكرادة، بغداد', lat:33.3128, lng:44.3615,
      description:'اصطدام بسيط عند تقاطع. تضرر المصد الأمامي والغطاء.',
      photoUrls:['https://placehold.co/400x300/FEE2E2/DC2626?text=صورة+حادث+1','https://placehold.co/400x300/FEE2E2/DC2626?text=صورة+حادث+2','https://placehold.co/400x300/FEE2E2/DC2626?text=صورة+حادث+3'],
      otherPartyInvolved:true, status:'completed', submittedAt:'2026-03-15T14:30:00',
      maintenanceNotes:'تم استبدال المصد الأمامي وإعادة طلائه بلون مطابق للأصلي.',
      repairPhotoUrls:['https://placehold.co/400x300/DCFCE7/16A34A?text=صورة+إصلاح+1','https://placehold.co/400x300/DCFCE7/16A34A?text=صورة+إصلاح+2'],
      completedAt:'2026-03-22', appointmentId:'apt_001',
      repairArchive:[
        { date:'2026-03-22', technician:'حسن الصيانة', description:'استبدال المصد الأمامي بالكامل وإعادة الطلاء بلون أبيض مطابق للأصلي. تم فحص الهيكل والتأكد من عدم وجود أضرار داخلية.', partsReplaced:['مصد أمامي','طلاء أبيض لؤلؤي'], cost:0,
          photos:['https://placehold.co/400x300/DCFCE7/16A34A?text=قبل+الإصلاح','https://placehold.co/400x300/DCFCE7/16A34A?text=أثناء+الإصلاح','https://placehold.co/400x300/DCFCE7/16A34A?text=بعد+الإصلاح'] }
      ]
    },
    {
      id:'rpt_002', userId:'usr_001', userName:'أحمد الراشدي', carId:'car_001', carDesc:'تويوتا كامري 2021',
      accidentDate:'2026-03-28', location:'المنصور، بغداد', lat:33.3152, lng:44.3506,
      description:'خدش الباب أثناء وقوف السيارة. الباب الخلفي الأيسر به خدش عميق.',
      photoUrls:['https://placehold.co/400x300/FEE2E2/DC2626?text=صورة+خدش+الباب'],
      otherPartyInvolved:false, status:'inRepair', submittedAt:'2026-03-28T10:00:00',
      maintenanceNotes:null, repairPhotoUrls:[], completedAt:null, appointmentId:'apt_002', repairArchive:[]
    },
    {
      id:'rpt_003', userId:'usr_003', userName:'عمر حسين', carId:'car_003', carDesc:'كيا سبورتاج 2023',
      accidentDate:'2026-04-01', location:'زيونة، بغداد', lat:33.33, lng:44.42,
      description:'تشقق المصد الخلفي بعد الاصطدام بعمود أثناء التراجع.',
      photoUrls:['https://placehold.co/400x300/FEE2E2/DC2626?text=صورة+مصد+خلفي+1','https://placehold.co/400x300/FEE2E2/DC2626?text=صورة+مصد+خلفي+2'],
      otherPartyInvolved:false, status:'underReview', submittedAt:'2026-04-01T16:45:00',
      maintenanceNotes:null, repairPhotoUrls:[], completedAt:null, appointmentId:null, repairArchive:[]
    },
    {
      id:'rpt_004', userId:'usr_001', userName:'أحمد الراشدي', carId:'car_002', carDesc:'هيونداي سونتا 2019',
      accidentDate:'2026-04-06', location:'الجادرية، بغداد', lat:33.27, lng:44.38,
      description:'خدش جانبي في الباب الأمامي الأيمن أثناء المرور بجانب سيارة أخرى.',
      photoUrls:['https://placehold.co/400x300/FEE2E2/DC2626?text=صورة+خدش+جانبي'],
      otherPartyInvolved:true, status:'pending', submittedAt:'2026-04-06T09:15:00',
      maintenanceNotes:null, repairPhotoUrls:[], completedAt:null, appointmentId:null, repairArchive:[]
    },
  ],

  appointments: [
    { id:'apt_001', userId:'usr_001', userName:'أحمد الراشدي', reportId:'rpt_001', scheduledDate:'2026-03-18', timeSlot:'10:00 ص – 11:00 ص', status:'completed', branchName:'فرع الكرادة', locationLat:33.3128, locationLng:44.3615, userNote:null, maintenanceNote:'يرجى الحضور قبل الموعد بـ 10 دقائق.', createdAt:'2026-03-16' },
    { id:'apt_002', userId:'usr_001', userName:'أحمد الراشدي', reportId:'rpt_002', scheduledDate:'2026-04-05', timeSlot:'2:00 م – 3:00 م', status:'confirmed', branchName:'فرع المنصور', locationLat:33.3152, locationLng:44.3506, userNote:null, maintenanceNote:'يرجى الحضور قبل 10 دقائق من موعدك لإتمام إجراءات الاستلام.', createdAt:'2026-03-29' },
  ],

  payments: [
    { id:'pay_001', userId:'usr_001', userName:'أحمد الراشدي', carDesc:'تويوتا كامري 2021', amountIQD:60000, dueDate:'2026-04-01', paidDate:null, status:'unpaid', method:null, month:'نيسان 2026', proofImageUrl:'https://placehold.co/400x600/E0F2FE/0284C7?text=إيصال+ZainCash' },
    { id:'pay_002', userId:'usr_001', userName:'أحمد الراشدي', carDesc:'تويوتا كامري 2021', amountIQD:60000, dueDate:'2026-03-01', paidDate:'2026-03-03', status:'paid', method:'ZainCash', month:'آذار 2026', proofImageUrl:null },
    { id:'pay_003', userId:'usr_003', userName:'عمر حسين', carDesc:'كيا سبورتاج 2023', amountIQD:150000, dueDate:'2026-04-01', paidDate:null, status:'unpaid', method:null, month:'نيسان 2026', proofImageUrl:null },
    { id:'pay_004', userId:'usr_001', userName:'أحمد الراشدي', carDesc:'هيونداي سونتا 2019', amountIQD:35000, dueDate:'2026-03-15', paidDate:null, status:'overdue', method:null, month:'آذار 2026', proofImageUrl:null },
  ],

  oilChanges: [
    { id:'oil_001', userId:'usr_001', userName:'أحمد الراشدي', carId:'car_001', carDesc:'تويوتا كامري 2021', scheduledDate:'2026-03-10', timeSlot:'9:00 ص – 10:00 ص', branchName:'فرع الكرادة', status:'completed', notes:null, priceIQD:15000, createdAt:'2026-03-08' },
    { id:'oil_002', userId:'usr_003', userName:'عمر حسين', carId:'car_003', carDesc:'كيا سبورتاج 2023', scheduledDate:null, timeSlot:null, branchName:null, status:'pending', notes:'زيت 5W-30', priceIQD:15000, createdAt:'2026-04-05' },
  ],

  requests: [
    { id:'req_001', userId:'usr_001', userName:'أحمد الراشدي', type:'profileEdit', status:'pending', changes:{ 'البريد الإلكتروني':'ahmed.new@example.com' }, submittedAt:'2026-04-03', reviewedAt:null, reviewNote:null },
    { id:'req_002', userId:'usr_001', userName:'أحمد الراشدي', type:'carChange', status:'pending', changes:{ 'اللون':'أسود', 'اللوحة':'54321 - بغداد' }, carDesc:'هيونداي سونتا 2019', submittedAt:'2026-03-30', reviewedAt:null, reviewNote:null },
    { id:'req_003', userId:'usr_003', userName:'عمر حسين', type:'upgrade', status:'pending', changes:{}, currentPlan:'VIP', requestedPlan:'VIP', currentPrice:150000, requestedPrice:150000, requestedMonths:12, remainingMonths:3, creditIQD:450000, newCostIQD:1800000, amountDueIQD:1350000, submittedAt:'2026-04-02', reviewedAt:null, reviewNote:null },
    { id:'req_004', userId:'usr_001', userName:'أحمد الراشدي', type:'profileEdit', status:'approved', changes:{ 'الاسم':'أحمد محمد الراشدي' }, submittedAt:'2026-03-20', reviewedAt:'2026-03-21', reviewNote:'تمت الموافقة' },
  ],

  notifications: [
    { id:'notif_001', userId:'usr_001', title:'دفعة مستحقة', body:'دفعة اشتراك نيسان 2026 البالغة 35,000 د.ع مستحقة اليوم.', type:'payment', createdAt:'2026-04-08T10:00:00' },
    { id:'notif_002', userId:'usr_001', title:'تم تأكيد الموعد', body:'تم تأكيد موعد الإصلاح بتاريخ 5 أبريل الساعة 2:00 م.', type:'appointment', createdAt:'2026-04-03T15:00:00' },
    { id:'notif_003', userId:'usr_003', title:'التقرير قيد المراجعة', body:'تقرير الحادث المقدَّم بتاريخ 1 أبريل قيد المراجعة من قِبل فريق الصيانة.', type:'report', createdAt:'2026-04-02T09:00:00' },
  ],

  adBanners: [
    { id:'ban_001', title:'خصم 15% على تجديد الاشتراك', subtitle:'جدّد اشتراكك قبل انتهائه واحصل على خصم حصري', bgColor:'#1A3A8F', icon:'tag', actionLabel:'اشترك الآن', actionRoute:'/subscription', isActive:true },
    { id:'ban_002', title:'خدمة تغيير الزيت متاحة الآن', subtitle:'احجز موعد تغيير الزيت لسيارتك بسعر خاص — 15,000 د.ع فقط', bgColor:'#065F46', icon:'wrench', actionLabel:'احجز الآن', actionRoute:'/oil-change', isActive:true },
    { id:'ban_003', title:'تقييم مجاني لسيارتك', subtitle:'احصل على تقييم شامل لحالة سيارتك مع كل اشتراك جديد', bgColor:'#7C3AED', icon:'star', actionLabel:'اعرف المزيد', actionRoute:null, isActive:false },
  ],

  timeSlots: [
    '8:00 ص – 9:00 ص', '9:00 ص – 10:00 ص', '10:00 ص – 11:00 ص', '11:00 ص – 12:00 م',
    '1:00 م – 2:00 م', '2:00 م – 3:00 م', '3:00 م – 4:00 م', '4:00 م – 5:00 م',
  ],
};

// ── Label Maps ──────────────────────────────────────────────────────────────

const DeptLabels = { admin:'مسؤول النظام', finance:'المالية', maintenance:'الصيانة', administration:'الإدارة' };
const DeptColors = { admin:'var(--primary)', finance:'var(--finance)', maintenance:'var(--maintenance)', administration:'var(--administration)' };
const DeptBg     = { admin:'var(--primary-surface)', finance:'var(--finance-light)', maintenance:'var(--maintenance-light)', administration:'var(--administration-light)' };

const UserStatusLabels = { pending:'بانتظار الموافقة', approved:'معتمد', rejected:'مرفوض', suspended:'موقوف' };
const UserStatusBadge  = { pending:'warning', approved:'success', rejected:'error', suspended:'info' };

const ReportStatusLabels = { pending:'جديد', underReview:'قيد المراجعة', approved:'معتمد', inRepair:'قيد الإصلاح', completed:'مكتمل', rejected:'مرفوض' };
const ReportStatusBadge  = { pending:'warning', underReview:'info', approved:'primary', inRepair:'warning', completed:'success', rejected:'error' };
const ReportStatusFlow   = { pending:['underReview','rejected'], underReview:['approved','rejected'], approved:['inRepair','rejected'], inRepair:['completed'], completed:[], rejected:[] };
const ReportNextAction   = { pending:'بدء المراجعة', underReview:'اعتماد', approved:'بدء الإصلاح', inRepair:'إكمال الإصلاح' };

const PayStatusLabels = { paid:'مسددة', unpaid:'غير مسددة', overdue:'متأخرة' };
const PayStatusBadge  = { paid:'success', unpaid:'warning', overdue:'error' };
const PayMethodLabels = { ZainCash:'ZainCash', SuperQi:'Super QI', Other:'أخرى' };

const OilStatusLabels = { pending:'بانتظار الجدولة', confirmed:'مؤكد', completed:'مكتمل', cancelled:'ملغي' };
const OilStatusBadge  = { pending:'warning', confirmed:'info', completed:'success', cancelled:'error' };

const AptStatusLabels = { scheduled:'مجدول', changeRequested:'طلب تغيير', confirmed:'مؤكد', completed:'مكتمل', cancelled:'ملغي' };
const AptStatusBadge  = { scheduled:'primary', changeRequested:'warning', confirmed:'success', completed:'success', cancelled:'error' };

const RequestTypeLabels = { profileEdit:'تعديل الملف الشخصي', carChange:'تعديل بيانات السيارة', upgrade:'ترقية الاشتراك' };
const RequestTypeIcons  = { profileEdit:'user', carChange:'car', upgrade:'arrow-up' };
const RequestStatusLabels = { pending:'معلق', approved:'مقبول', rejected:'مرفوض' };
const RequestStatusBadge  = { pending:'warning', approved:'success', rejected:'error' };

const SubLabels = { standard:'ستاندارد', shared:'المزدوج', vip:'VIP', none:'بدون اشتراك' };
const SubBadge  = { standard:'primary', shared:'purple', vip:'warning', none:'info' };
const SubPrices = { standard:35000, shared:60000, vip:150000 };

const NotifTypeIcons = { payment:'credit-card', appointment:'calendar', report:'siren', subscription:'clipboard-list', general:'bell' };

function formatIQD(n) { return n.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ',') + ' د.ع'; }
function formatDate(d) { if(!d) return '—'; const dt=new Date(d); return `${dt.getFullYear()}/${String(dt.getMonth()+1).padLeft(2,'0')}/${String(dt.getDate()).padLeft(2,'0')}`; }
function formatDateTime(d) { if(!d) return '—'; const dt=new Date(d); return `${dt.getFullYear()}/${String(dt.getMonth()+1).padLeft(2,'0')}/${String(dt.getDate()).padLeft(2,'0')} ${String(dt.getHours()).padLeft(2,'0')}:${String(dt.getMinutes()).padLeft(2,'0')}`; }

// Polyfill
if (!String.prototype.padLeft) String.prototype.padLeft = function(n,c) { return (c||'0').repeat(Math.max(0,n-this.length)) + this; };
