// frontend/src/services/api.js
/**
 * API service for interacting with backend.
 * Centralizes all HTTP requests to FastAPI server.
 * Uses axios to perform requests.
 */

import axios from 'axios'

// Base API URL from environment variables or default value
const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || 'http://localhost:8000/api'

// Create axios instance with default settings
const apiClient = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
})

/**
 * API methods for working with products
 */
export const productsAPI = {
  /**
   * Get all products
   */
  getAll() {
    return apiClient.get('/products')
  },

  /**
   * Get product by ID
   */
  getById(id) {
    return apiClient.get(`/products/${id}`)
  },

  /**
   * Get products by category
   */
  getByCategory(categoryId) {
    return apiClient.get(`/products/category/${categoryId}`)
  },
}

/**
 * API methods for working with categories
 */
export const categoriesAPI = {
  /**
   * Get all categories
   */
  getAll() {
    return apiClient.get('/categories')
  },

  /**
   * Get category by ID
   */
  getById(id) {
    return apiClient.get(`/categories/${id}`)
  },
}

/**
 * API methods for working with cart
 */
export const cartAPI = {
  /**
   * Add product to cart
   */
  addItem(item, cartData) {
    return apiClient.post('/cart/add', {
      product_id: item.product_id,
      quantity: item.quantity,
      cart: cartData,
    })
  },

  /**
   * Get cart contents
   */
  getCart(cartData) {
    return apiClient.post('/cart', cartData)
  },

  /**
   * Update product quantity
   */
  updateItem(item, cartData) {
    return apiClient.put('/cart/update', {
      product_id: item.product_id,
      quantity: item.quantity,
      cart: cartData,
    })
  },

  /**
   * Remove product from cart
   */
  removeItem(productId, cartData) {
    return apiClient.delete(`/cart/remove/${productId}`, {
      data: {
        cart: cartData,
      },
    })
  },
}

export default apiClient
