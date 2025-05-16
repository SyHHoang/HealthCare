import { createApp } from 'vue'
import { createPinia } from 'pinia'
import { Quasar } from "quasar"
import axios from 'axios'

// Import cấu hình axios đã được tạo
import axiosInstance from './services/axiosInstance.js'

// PrimeVue
import PrimeVue from 'primevue/config'
import ToastService from 'primevue/toastservice'
import PrimeToast from 'primevue/toast'
import 'primevue/resources/themes/lara-light-blue/theme.css'
import 'primevue/resources/primevue.min.css'
import 'primeicons/primeicons.css'

// CSS imports
import './assets/main.css'
import 'bootstrap/dist/css/bootstrap.min.css'
import 'bootstrap/dist/js/bootstrap.bundle.min.js'
import '@fortawesome/fontawesome-free/css/all.css'
import "quasar/dist/quasar.css"
import 'bootstrap-icons/font/bootstrap-icons.css'

// Component imports
import App from './App.vue'
import router from './router'
import Toast from 'vue-toastification'
import 'vue-toastification/dist/index.css'

// Sử dụng axiosInstance như axios mặc định toàn cục
window.axios = axiosInstance

const app = createApp(App)
app.use(createPinia())
app.use(router)
app.use(Quasar)
app.use(PrimeVue)
app.use(ToastService)

const toastOptions = {
  position: 'top-right',
  timeout: 3000,
  closeOnClick: true,
  pauseOnFocusLoss: true,
  pauseOnHover: true,
  draggable: true,
  draggablePercent: 0.6,
  showCloseButtonOnHover: false,
  hideProgressBar: false,
  closeButton: 'button',
  icon: true,
  rtl: false
}

app.use(Toast, toastOptions)

// Đăng ký PrimeVue Toast component với tên khác
app.component('PrimeToast', PrimeToast)

// Provide toast service
app.provide('$toast', app.config.globalProperties.$toast)

app.mount('#app')
