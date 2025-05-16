// Định tuyến xác thực với lazy loading
export default [
  {
    path: '/auth',
    component: () => import('@/layouts/AuthLayout.vue'), // Lazy load
    children: [
      {
        path: 'login',
        name: 'login',
        component: () => import('@/views/AuthView/LoginView.vue') // Lazy load
      },
      {
        path: 'register',
        name: 'register',
        component: () => import('@/views/AuthView/RegisterView.vue') // Lazy load
      },
      {
        path: 'doctor/login',
        name: 'doctor-login',
        component: () => import('@/views/AuthView/DoctorLoginView.vue') // Lazy load
      },
      {
        path: 'doctor/register',
        name: 'doctor-register',
        component: () => import('@/views/AuthView/DoctorRegisterView.vue') // Lazy load
      }
    ]
  }
];