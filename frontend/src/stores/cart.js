// frontend/src/stores/cart.js
/**
 * Pinia store for managing shopping cart.
 * Stores cart state in localStorage and synchronizes with backend.
 * Follows Single Responsibility principle - only handles cart logic.
 */

import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { cartAPI } from '@/services/api'

const CART_STORAGE_KEY = 'shopping_cart'

export const useCartStore = defineStore('cart', () => {
  // State - store cart as object {product_id: quantity}
  const cartItems = ref({})
  const cartDetails = ref(null)
  const loading = ref(false)

  // Getters
  const itemsCount = computed(() => {
    return Object.values(cartItems.value).reduce((sum, qty) => sum + qty, 0)
  })

  const totalPrice = computed(() => {
    return cartDetails.value?.total || 0
  })

  const hasItems = computed(() => {
    return Object.keys(cartItems.value).length > 0
  })

  // Actions
  /**
   * Initialize cart from localStorage
   */
  function initCart() {
    const savedCart = localStorage.getItem(CART_STORAGE_KEY)
    if (savedCart) {
      try {
        cartItems.value = JSON.parse(savedCart)
      } catch (e) {
        console.error('Error parsing cart from localStorage:', e)
        cartItems.value = {}
      }
    }
  }

  /**
   * Save cart to localStorage
   */
  function saveCart() {
    localStorage.setItem(CART_STORAGE_KEY, JSON.stringify(cartItems.value))
  }

  /**
   * Add product to cart
   */
  async function addToCart(productId, quantity = 1) {
    try {
      const item = {
        product_id: productId,
        quantity: quantity,
      }
      const response = await cartAPI.addItem(item, cartItems.value)
      cartItems.value = response.data.cart
      saveCart()
      await fetchCartDetails()
      return true
    } catch (err) {
      console.error('Error adding to cart:', err)
      return false
    }
  }

  /**
   * Get detailed cart information
   */
  async function fetchCartDetails() {
    if (!hasItems.value) {
      cartDetails.value = { items: [], total: 0, items_count: 0 }
      return
    }

    loading.value = true
    try {
      const response = await cartAPI.getCart(cartItems.value)
      cartDetails.value = response.data
    } catch (err) {
      console.error('Error fetching cart details:', err)
    } finally {
      loading.value = false
    }
  }

  /**
   * Update product quantity
   */
  async function updateQuantity(productId, quantity) {
    if (quantity <= 0) {
      return removeFromCart(productId)
    }

    try {
      const item = {
        product_id: productId,
        quantity: quantity,
      }
      const response = await cartAPI.updateItem(item, cartItems.value)
      cartItems.value = response.data.cart
      saveCart()
      await fetchCartDetails()
      return true
    } catch (err) {
      console.error('Error updating cart:', err)
      return false
    }
  }

  /**
   * Remove product from cart
   */
  async function removeFromCart(productId) {
    try {
      const response = await cartAPI.removeItem(productId, cartItems.value)
      cartItems.value = response.data.cart
      saveCart()
      await fetchCartDetails()
      return true
    } catch (err) {
      console.error('Error removing from cart:', err)
      return false
    }
  }

  /**
   * Clear cart
   */
  function clearCart() {
    cartItems.value = {}
    cartDetails.value = null
    localStorage.removeItem(CART_STORAGE_KEY)
  }

  return {
    // State
    cartItems,
    cartDetails,
    loading,
    // Getters
    itemsCount,
    totalPrice,
    hasItems,
    // Actions
    initCart,
    addToCart,
    fetchCartDetails,
    updateQuantity,
    removeFromCart,
    clearCart,
  }
})
