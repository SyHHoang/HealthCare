import VideoCall from '@/components/VideoCall.vue'

// Định tuyến cho người dùng đã đăng nhập với lazy loading
export default [
  {
    path: '/user',
    component: () => import('@/layouts/UserAppLayout.vue'),
    meta: { requiresAuth: true, requiresUser: true },
    children: [
      {
        path: 'dashboard',
        name: 'UserDashboard',
        component: () => import('@/views/UserView/DashboardView.vue'),
        meta: { requiresAuth: true, requiresUser: true }
      },
      {
        path: 'consultation-history',
        name: 'UserConsultationHistory',
        component: () => import('@/views/UserView/ConsultationHistoryView.vue'),
        meta: { requiresAuth: true, requiresUser: true }
      },
      {
        path: 'consultationlist',
        name: 'UserConsultationList',
        component: () => import('@/views/UserView/ConsultationListView.vue'),
        meta: { requiresAuth: true, requiresUser: true }
      },
      {
        path: 'settings',
        name: 'UserSettings',
        component: () => import('@/views/UserView/Settings.vue'),
        meta: { requiresAuth: true, requiresUser: true }
      },
      {
        path: 'profile',
        name: 'UserProfile',
        component: () => import('@/views/UserView/ProfileView.vue'),
        meta: { requiresAuth: true, requiresUser: true }
      },
      {
        path: 'medical-record',
        name: 'UserMedicalRecord',
        component: () => import('@/components/MedicalRecord.vue'),
        meta: { requiresAuth: true, requiresUser: true }
      },
      {
        path: 'doctors',
        name: 'UserDoctors',
        component: () => import('@/views/PublicView/SpecialtyAndDoctorView.vue'),
        meta: { requiresAuth: true, requiresUser: true }
      },
      {
        path: 'drugs',
        name: 'UserDrugs',
        component: () => import('@/views/PublicView/DrugSearchView.vue'),
        meta: { requiresAuth: true, requiresUser: true }
      },
      {
        path: 'news',
        name: 'UserNews',
        component: () => import('@/views/PublicView/NewsEventsView.vue'),
        meta: { requiresAuth: true, requiresUser: true }
      },
      {
        path: 'feedback',
        name: 'UserFeedback',
        component: () => import('@/views/PublicView/Feedback.vue'),
        meta: { requiresAuth: true, requiresUser: true }
      },
      {
        path: 'contact',
        name: 'UserContact',
        component: () => import('@/views/PublicView/Contact.vue'),
        meta: { requiresAuth: true, requiresUser: true }
      },
      {
        path: 'chat/:chatId?',
        name: 'UserChat',
        component: () => import('@/views/UserView/ChatView.vue'),
        meta: { requiresAuth: true, requiresUser: true }
      },
      {
        path: 'notifications',
        name: 'UserNotifications',
        component: () => import('@/views/UserView/Notifications.vue'),
        meta: { requiresAuth: true, requiresUser: true }
      }
    ]
  },
  {
    path: '/video-call',
    name: 'video-call',
    component: () => import('@/components/VideoCall.vue'),
    meta: {
      requiresAuth: true,
      requiresUser: true
    },
    props: (route) => ({
      consultationId: route.query.consultationId,
      isDoctor: route.query.isDoctor === 'true'
    })
  }
]; 