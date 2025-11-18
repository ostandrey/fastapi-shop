<!-- frontend/src/components/CategoryFilter.vue -->
<!--
  Product category filter component.
  Displays a list of categories with the ability to select for filtering.
-->

<template>
  <div class="bg-white border-2 border-gray-200 rounded-lg p-6">
    <h2 class="text-2xl font-bold text-black mb-6">Categories</h2>

    <!-- Category list -->
    <ul class="space-y-2">
      <!-- All categories -->
      <li>
        <button
          @click="selectCategory(null)"
          :class="[
            'w-full text-left px-4 py-3 rounded-lg transition-all duration-200',
            !productsStore.selectedCategory
              ? 'bg-black text-white font-semibold'
              : 'bg-gray-50 hover:bg-gray-100 text-gray-700',
          ]"
        >
          All Categories
          <span v-if="!productsStore.selectedCategory" class="float-right">
            ({{ totalProductsCount }})
          </span>
        </button>
      </li>

      <!-- Individual categories -->
      <li v-for="category in productsStore.categories" :key="category.id">
        <button
          @click="selectCategory(category.id)"
          :class="[
            'w-full text-left px-4 py-3 rounded-lg transition-all duration-200',
            productsStore.selectedCategory === category.id
              ? 'bg-black text-white font-semibold'
              : 'bg-gray-50 hover:bg-gray-100 text-gray-700',
          ]"
        >
          {{ category.name }}
          <span v-if="productsStore.selectedCategory === category.id" class="float-right">
            ({{ productsStore.productsCount }})
          </span>
        </button>
      </li>
    </ul>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useProductsStore } from '@/stores/products'

const productsStore = useProductsStore()

/**
 * Total number of products (without filter)
 */
const totalProductsCount = computed(() => {
  return productsStore.products.length
})

/**
 * Select category for filtering
 */
function selectCategory(categoryId) {
  if (categoryId === null) {
    productsStore.clearCategoryFilter()
  } else {
    productsStore.setCategory(categoryId)
  }
}
</script>
