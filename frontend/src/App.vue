<!-- frontend/src/App.vue -->
<!--
  Root component of the application.
  Contains the general structure with Header and RouterView.
-->

<template>
  <div id="app" class="min-h-screen bg-gray-50">
    <!-- Site header -->
    <Header />

    <!-- Main content (router) -->
    <RouterView />

    <!-- Footer -->
    <footer class="bg-white border-t-2 border-black mt-16">
      <div class="max-w-7xl mx-auto px-4 py-8">
        <div class="text-center text-gray-600">
          <p class="mb-2">© 2024 FastAPI Shop. All rights reserved.</p>
          <p class="text-sm">Built with FastAPI + Vue.js</p>
        </div>
      </div>
    </footer>
  </div>
</template>

<script setup>
import { onMounted } from 'vue'
import { RouterView } from 'vue-router'
import Header from '@/components/Header.vue'
import { useCartStore } from '@/stores/cart'

const cartStore = useCartStore()

/**
 * Initialize the application
 */
onMounted(() => {
  // Load cart from localStorage on startup
  cartStore.initCart()
})
</script>

<style scoped>
/* Remove all style overrides for #app */
/* Tailwind classes fully control the layout */
</style>
