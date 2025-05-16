import { createRouter, createWebHistory } from 'vue-router';
import publicRoutes from './routes/publicRoutes';
import authRoutes from './routes/authRoutes';
import adminRoutes from './routes/adminRoutes';
import doctorRoutes from './routes/doctorRoutes';
import userRoutes from './routes/userRoutes';
import Settings from '../views/UserView/Settings.vue';

const routes = [
  ...publicRoutes,
  ...authRoutes,
  ...adminRoutes,
  ...doctorRoutes,
  ...userRoutes,
];

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes
});

// Navigation guard
router.beforeEach((to, from, next) => {
  const token = localStorage.getItem('token');
  const role = localStorage.getItem('role');
  
  if (to.matched.some(record => record.meta.requiresAuth)) {
    if (!token) {
      next({
        path: '/auth/login',
        query: { redirect: to.fullPath }
      });
    } else {
      if (to.matched.some(record => record.meta.requiresAdmin) && role === 'admin') {
        next();
      } else if (to.matched.some(record => record.meta.requiresDoctor) && role === 'doctor') {
        next();
      } else if (to.matched.some(record => record.meta.requiresUser) && role === 'user') {
        next();
      } else {
        next('/');
      }
    }
  } else {
    next();
  }
});

export default router;