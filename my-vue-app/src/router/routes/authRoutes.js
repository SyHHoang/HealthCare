// Định tuyến xác thực với lazy loading
export default [
  {
    path: '/auth',
    component: () => import('@/layouts/AuthLayout.vue'), // Lazy load
    children: [
      {
        path: 'login',
        name: 'login',
        component: () => import('@/views/AuthView/CombinedLoginView.vue') // Lazy load
      },
      {
        path: 'register',
        name: 'register',
        component: () => import('@/views/AuthView/CombinedRegisterView.vue') // Lazy load
      },
    ]
  }
];