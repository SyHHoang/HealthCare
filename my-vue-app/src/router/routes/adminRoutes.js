// Định tuyến dành cho admin với lazy loading
export default [
  {
    path: '/admin',
    component: () => import('@/layouts/AdminAppLayout.vue'), // Lazy load
    meta: { requiresAuth: true, requiresAdmin: true },
    children: [
      {
        path: '',
        name: 'admin-dashboard',
        component: () => import('@/views/AdminViews/Dashboard.vue') // Lazy load
      },
      {
        path: 'users',
        name: 'AdminUserList',
        component: () => import('@/views/AdminViews/AdminUserList.vue') // Lazy load
      },
      {
        path: 'news',
        name: 'admin-news',
        component: () => import('@/views/AdminViews/AdminNewsList.vue') // Lazy load
      },
      {
        path: 'news/addnews',
        name: 'admin-add-news',
        component: () => import('@/views/AdminViews/AdminAddNews.vue') // Lazy load
      },
      {
        path: 'news/edit/:id',
        name: 'admin-edit-news',
        component: () => import('@/views/AdminViews/AdminEditNews.vue') // Lazy load
      },
      {
        path: 'feedbacks',
        name: 'AdminFeedbackList',
        component: () => import('@/views/AdminViews/AdminFeedbackList.vue') // Lazy load
      },
      {
        path: 'contacts',
        name: 'AdminContactList',
        component: () => import('@/views/AdminViews/AdminContactList.vue') // Lazy load
      },
      {
        path: 'specialties',
        name: 'AdminSpecialtyList',
        component: () => import('@/views/AdminViews/AdminSpecialtyList.vue') // Lazy load
      },
      {
        path: 'doctor-verifications',
        name: 'DoctorVerificationList',
        component: () => import('@/views/AdminViews/DoctorVerificationList.vue') // Lazy load
      },
      {
        path: 'doctors',
        name: 'Doctor',
        component: () => import('@/views/AdminViews/AdminDoctorList.vue') // Lazy load
      },
      {
        path: 'drugs',
        name: 'Drugs',
        component: () => import('@/views/AdminViews/AdminDrugs.vue') // Lazy load
      },
      {
        path: 'transaction',
        name: 'transaction',
        component: () => import('@/views/AdminViews/TransactionManagement.vue') // Lazy load
      },
      
    ]
  }
];