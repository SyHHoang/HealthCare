<template>
  <div id="guest-layout">
    <AppHeader />
    <main class="main-content">
      <router-view/>
    </main>
    <AppFooter v-if="showFooter" id="footer"/>
    <TooltipButton />
    <NotificationBell />
  </div>
</template>

<script>
import AppHeader from '../views/GuestViews/Header.vue';
import AppFooter from '../views/GuestViews/Footer.vue';
import TooltipButton from '../components/TooltipButton.vue';
import NotificationBell from '../components/NotificationBell.vue';

export default {
  name: 'GuestLayout',
  components: {
    AppHeader,
    AppFooter,
    TooltipButton,
    NotificationBell,
  },
  computed: {
    showFooter() {
      return this.$route.path === '/' || this.$route.path === '/news-events';
    }
  }
};
</script>

<style scoped>
#guest-layout {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
  width: 100%;
  max-width: 100%;
  margin: 0;
  padding: 0;
}

.main-content {
  flex: 1;
  margin-top: 80px; /* Chiều cao của header */
  padding: 20px;
  background-color: #f8f9fa;
}
</style> 