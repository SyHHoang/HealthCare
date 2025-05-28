// Định tuyến công khai với lazy loading
export default [
  {
    path: '/',
    component: () => import('@/layouts/GuestLayout.vue'),
    children: [
      {
        path: '',
    name: 'Home',
    component: () => import('@/views/PublicView/Hero.vue') // Lazy load
  },
  {
        path: 'contact',
    name: 'Contact',
    component: () => import('@/views/PublicView/Contact.vue') // Lazy load
  },
  {
        path: 'about',
    name: 'About',
    component: () => import('@/views/PublicView/About.vue') // Lazy load
  },
  {
        path: 'feedback',
    name: 'Feedback',
    component: () => import('@/views/PublicView/Feedback.vue') // Lazy load
  },
  {
        path: 'news-events',
    name: 'NewsEvents',
    component: () => import('@/views/PublicView/NewsEventsView.vue') // Lazy load
  },
  {
        path: 'news/:id',
    name: 'ArticleDetail',
    component: () => import('@/views/PublicView/ArticleDetailView.vue') // Lazy load
  },
  {
        path: 'consultationlist',
    name: 'consultation-list',
    component: () => import('@/views/UserView/ConsultationListView.vue') // Lazy load
  },
  {
        path: 'consultation-history',
    name: 'consultation-history',
    component: () => import('@/views/UserView/ConsultationHistoryView.vue') // Lazy load
  },
  {
        path: 'medical-record',
    name: 'MedicalRecord',
    component: () => import('@/components/MedicalRecord.vue') // Lazy load
  },
  {
        path: 'drugs',
    name: 'drugs',
    component: () => import('@/views/PublicView/DrugSearchView.vue') // Lazy load
  },
  {
        path: 'doctors&specialties',
    name: 'doctors&specialties',
    component: () => import('@/views/PublicView/SpecialtyAndDoctorView.vue') // Lazy load
  },
  {
        path: 'chat/:chatId?',
    name: 'chat',
    component: () => import('@/views/UserView/ChatView.vue') // Lazy load
      },
      // {
      //   path: 'doctors/:doctorId',
      //   name: 'DoctorDetails',
      //   component: () => import('@/views/PublicView/DoctorDetailsView.vue') // Lazy load
      // },
      // {
      //   path: 'specialties/:specialtyId',
      //   name: 'SpecialtyDetails',
      //   component: () => import('@/views/PublicView/SpecialtyDetailsView.vue') // Lazy load
      // }
    ]
  },
  {
    path: '/profile',
    name: 'profile',
    component: () => import('@/views/UserView/ProfileView.vue') // Lazy load
  },
  {
    path: '/video-call/:consultationId',
    name: 'video-call',
    component: () => import('@/components/VideoCall.vue'),
  }
];