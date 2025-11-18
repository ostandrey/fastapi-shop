<!-- frontend/src/views/CartPage.vue -->
<!--
  Shopping cart page.
  Displays list of products in cart with ability to manage quantity.
-->

<template>
  <div class="min-h-screen bg-white">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
      <!-- Header -->
      <div class="mb-10">
        <h1 class="text-3xl sm:text-4xl font-extrabold text-black mb-3">Shopping Cart</h1>
        <p class="text-lg text-gray-500">Review your items before checkout</p>
      </div>

      <!-- Loading state -->
      <div v-if="cartStore.loading" class="text-center py-16">
        <div class="inline-block animate-spin rounded-full h-14 w-14 border-b-4 border-black"></div>
        <p class="mt-4 text-lg text-gray-500">Loading cart...</p>
      </div>

      <!-- Empty cart -->
      <div v-else-if="!cartStore.hasItems" class="text-center py-16">
        <svg
          xmlns="http://www.w3.org/2000/svg"
          class="h-28 w-28 mx-auto text-gray-300 mb-6"
          fill="none"
          viewBox="0 0 24 24"
          stroke="currentColor"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            stroke-width="2"
            d="M3 3h2l.4 2M7 13h10l4-8H5.4M7 13L5.4 5M7 13l-2.293 2.293c-.63.63-.184 1.707.707 1.707H17m0 0a2 2 0 100 4 2 2 0 000-4zm-8 2a2 2 0 11-4 0 2 2 0 014 0z"
          />
        </svg>
        <h2 class="text-2xl font-bold text-black mb-3">Your cart is empty</h2>
        <p class="text-lg text-gray-500 mb-8">Add some products to get started!</p>
        <router-link
          to="/"
          class="inline-block bg-black text-white py-3 px-8 text-lg font-semibold rounded-none hover:bg-gray-900 transition-colors"
        >
          Continue Shopping
        </router-link>
      </div>

      <!-- Cart contents -->
      <div v-else class="grid grid-cols-1 lg:grid-cols-3 gap-8">
        <!-- Product list -->
        <div class="lg:col-span-2 space-y-6">
          <CartItem
            v-for="item in cartStore.cartDetails?.items"
            :key="item.product_id"
            :item="item"
          />
        </div>

        <!-- Order summary -->
        <div class="lg:col-span-1">
          <div class="bg-white border-2 border-gray-100 rounded-none p-8 shadow-sm sticky top-24">
            <h2 class="text-2xl font-bold text-black mb-8">Order Summary</h2>

            <!-- Order details -->
            <div class="space-y-6 mb-8">
              <div class="flex justify-between text-lg text-gray-600">
                <span>Items ({{ cartStore.cartDetails?.items_count }})</span>
                <span>${{ cartStore.totalPrice.toFixed(2) }}</span>
              </div>

              <div class="flex justify-between text-lg text-gray-600">
                <span>Shipping</span>
                <span class="text-green-600 font-medium">Free</span>
              </div>

              <div class="border-t-2 border-gray-100 pt-6">
                <div class="flex justify-between text-xl font-bold text-black">
                  <span>Total</span>
                  <span>${{ cartStore.totalPrice.toFixed(2) }}</span>
                </div>
              </div>
            </div>

            <!-- Checkout button -->
            <button
              class="w-full bg-black text-white py-4 px-6 text-lg font-semibold rounded-none hover:bg-gray-900 transition-colors mb-4"
              @click="handleCheckout"
            >
              Proceed to Checkout
            </button>

            <!-- Continue shopping button -->
            <router-link
              to="/"
              class="block w-full bg-gray-100 text-black py-4 px-6 text-lg font-semibold rounded-none hover:bg-gray-200 transition-colors text-center"
            >
              Continue Shopping
            </router-link>

            <!-- Clear cart button -->
            <button
              @click="handleClearCart"
              class="w-full mt-6 text-base text-red-600 hover:text-red-700 transition-colors font-medium"
            >
              Clear Cart
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { useCartStore } from '@/stores/cart'
import CartItem from '@/components/CartItem.vue'

const router = useRouter()
const cartStore = useCartStore()

/**
 * Checkout (placeholder)
 */
function handleCheckout() {
  alert('Checkout functionality will be implemented soon!')
}

/**
 * Clear cart with confirmation
 */
function handleClearCart() {
  if (confirm('Are you sure you want to clear your cart?')) {
    cartStore.clearCart()
  }
}

/**
 * Load cart data on mount
 */
onMounted(async () => {
  await cartStore.fetchCartDetails()
})
</script>
