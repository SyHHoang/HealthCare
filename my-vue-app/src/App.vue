<template>
  <div id="app">
    <NotificationHandler />
    <router-view/>
    <PrimeToast />
  </div>
</template>

<script>
import PrimeToast from 'primevue/toast';
import NotificationHandler from './components/NotificationHandler.vue';

export default {
  name: 'App',
  components: {
    PrimeToast,
    NotificationHandler
  }
};
</script>

<style>
html, body {
  margin: 0;
  padding: 0;
  width: 100%;
  overflow-x: hidden;
}

#app {
  display: flex;
  flex-direction: column;
  min-height: 100vh;
  width: 100%;
  max-width: 100%;
  margin: 0;
  padding: 0;
}

* {
  box-sizing: border-box;
}
</style>