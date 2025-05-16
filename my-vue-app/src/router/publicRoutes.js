import { createRouter, createWebHistory } from 'vue-router';
import DoctorConsultationHistoryView from '@/views/DoctorViews/DoctorConsultationHistoryView.vue';

const routes = [
  {
    path: '/doctor/consultation-history',
    name: 'DoctorConsultationHistory',
    component: DoctorConsultationHistoryView,
    meta: {
      requiresAuth: true,
      role: 'doctor'
    }
  }
];

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes
});

export default router; 