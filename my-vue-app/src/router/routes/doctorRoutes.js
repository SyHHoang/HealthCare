// Định tuyến dành cho bác sĩ với lazy loading
export default [
  {
    path: '/doctor',
    component: () => import('@/layouts/DoctorAppLayout.vue'), // Lazy load
    meta: { requiresAuth: true, requiresDoctor: true },
    children: [
      {
        path: 'dashboard',
        name: 'DoctorDashboard',
        component: () => import('@/views/DoctorViews/Dashboard.vue') // Lazy load
      },
      {
        path: 'chat',
        name: 'DoctorChat',
        component: () => import('@/views/DoctorViews/DoctorChatView.vue') // Lazy load
      },
      {
        path: 'appointments',
        name: 'DoctorAppointments',
        component: () => import('@/views/DoctorViews/Appointments.vue') // Lazy load
      },
      {
        path: 'patients',
        name: 'DoctorPatients',
        component: () => import('@/views/DoctorViews/Patients.vue') // Lazy load
      },
      {
        path: 'patient/:id',
        name: 'PatientMedicalRecord',
        component: () => import('@/views/DoctorViews/PatientMedicalRecord.vue') // Lazy load
      },
      {
        path: 'prescriptions',
        name: 'DoctorPrescriptions',
        component: () => import('@/views/DoctorViews/Prescriptions.vue') // Lazy load
      },
      {
        path: 'schedule',
        name: 'DoctorSchedule',
        component: () => import('@/views/DoctorViews/Schedule.vue') // Lazy load
      },
      {
        path: 'profile',
        name: 'DoctorProfile',
        component: () => import('@/views/DoctorViews/DoctorProfile.vue') // Lazy load
      },
      {
        path: 'change-password',
        name: 'DoctorChangePassword',
        component: () => import('@/views/DoctorViews/DoctorChangePassword.vue') // Lazy load
      },
      {
        path: 'profile/edit',
        name: 'DoctorProfileEdit',
        component: () => import('@/views/DoctorViews/DoctorProfileEdit.vue') // Lazy load
      },
      {
        path: 'consultation-history',
        name: 'doctor-consultation-history',
        component: () => import('@/views/DoctorViews/DoctorConsultationHistoryView.vue'), // Lazy load
      }
    ]
  }
];