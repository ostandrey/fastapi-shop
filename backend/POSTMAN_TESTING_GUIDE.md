# Postman API Testing Guide - FastAPI Shop

This guide explains how to use the Postman collection to test the FastAPI Shop API endpoints.

## 📋 Table of Contents

1. [Getting Started](#getting-started)
2. [Importing the Collection](#importing-the-collection)
3. [Setting Up Environment Variables](#setting-up-environment-variables)
4. [Running Tests](#running-tests)
5. [Test Scripts Overview](#test-scripts-overview)
6. [Endpoint Testing Guide](#endpoint-testing-guide)
7. [Running Collection Tests](#running-collection-tests)
8. [Troubleshooting](#troubleshooting)

## 🚀 Getting Started

### Prerequisites

- Postman Desktop App or Postman Web
- FastAPI Shop backend server running (default: `http://localhost:8000`)
- Database initialized with sample data

### Starting the Server

Before testing, ensure your FastAPI server is running:

```bash
cd backend
uvicorn app.main:app --reload
```

The server should be accessible at `http://localhost:8000`

## 📥 Importing the Collection

1. **Open Postman**
2. Click **Import** button (top left)
3. Select **File** tab
4. Choose `fastapi-shop.postman_collection.json`
5. Click **Import**

The collection will appear in your Postman workspace with all endpoints organized in folders.

## ⚙️ Setting Up Environment Variables

The collection uses variables that can be customized:

### Collection Variables

The collection includes these default variables:

- `base_url`: `http://localhost:8000` - API base URL
- `category_id`: `1` - Default category ID for testing
- `product_id`: `1` - Default product ID for testing

### Updating Variables

1. Right-click on the collection name
2. Select **Edit**
3. Go to **Variables** tab
4. Update values as needed
5. Click **Save**

### Using Environment Variables (Optional)

For different environments (dev, staging, production):

1. Click **Environments** in left sidebar
2. Click **+** to create new environment
3. Add variables:
   - `base_url`: Your API URL
   - `category_id`: Test category ID
   - `product_id`: Test product ID
4. Select the environment from dropdown (top right)

## 🧪 Running Tests

### Individual Request Tests

Each request has automated tests that run automatically:

1. **Select a request** from the collection
2. Click **Send**
3. View test results in the **Test Results** tab (bottom panel)

### Test Results

- ✅ Green checkmark = Test passed
- ❌ Red X = Test failed
- View detailed error messages for failed tests

## 📝 Test Scripts Overview

All endpoints include automated tests that validate:

### Common Tests (All Endpoints)

- ✅ **Status Code**: Verifies HTTP status is 200
- ✅ **Response Time**: Ensures response is under 1000ms
- ✅ **Response Structure**: Validates JSON structure

### Specific Tests by Endpoint

#### Root & Health Endpoints

- **Root (`/`)**: Validates welcome message structure
- **Health Check (`/healthcheck`)**: Validates status is "healthy"

#### Categories Endpoints

- **Get All Categories**: 
  - Validates array response
  - Checks required fields (id, name, description, created_at)
  - Auto-saves first category ID to variable
  
- **Get Category by ID**:
  - Validates category matches requested ID
  - Checks all required fields
  - Validates data types

#### Products Endpoints

- **Get All Products**:
  - Validates products array and total count
  - Checks product structure (id, name, price, category, etc.)
  - Validates price is positive number
  - Auto-saves first product ID to variable

- **Get Product by ID**:
  - Validates product matches requested ID
  - Checks category object is included
  - Validates price and other fields

- **Get Products by Category**:
  - Validates all products belong to requested category
  - Checks total count matches array length

#### Cart Endpoints

- **Add to Cart**:
  - Validates cart response structure
  - Verifies added product is in cart
  - Checks quantity matches request

- **Get Cart Details**:
  - Validates items array, total, and items_count
  - Checks each item has required fields
  - Validates total calculation

- **Update Cart Item**:
  - Validates updated quantity in cart
  - Verifies product still exists in cart

- **Remove from Cart**:
  - Validates removed product is not in cart
  - Checks cart structure is maintained

## 🔄 Endpoint Testing Guide

### Testing Workflow

Recommended order for testing:

1. **Health Check** → Verify server is running
2. **Get All Categories** → Get available categories
3. **Get All Products** → Get available products
4. **Get Category by ID** → Test specific category
5. **Get Product by ID** → Test specific product
6. **Get Products by Category** → Test category filtering
7. **Add to Cart** → Add items to cart
8. **Get Cart Details** → View cart contents
9. **Update Cart Item** → Modify quantities
10. **Remove from Cart** → Remove items

### Example: Complete Cart Flow

1. **Get All Products** - Note product IDs
2. **Add to Cart** - Add product with ID 1, quantity 2
   ```json
   {
       "product_id": 1,
       "quantity": 2,
       "cart": {}
   }
   ```
3. **Get Cart Details** - Pass the returned cart:
   ```json
   {
       "1": 2
   }
   ```
4. **Update Cart Item** - Update quantity to 3:
   ```json
   {
       "product_id": 1,
       "quantity": 3,
       "cart": {"1": 2}
   }
   ```
5. **Remove from Cart** - Remove product 1:
   ```json
   {
       "cart": {"1": 3}
   }
   ```

## 🔗 Complete List of Test URLs

### Base URL
```
http://localhost:8000
```

### Root & Health Endpoints

| Method | URL | Description |
|--------|-----|-------------|
| GET | `http://localhost:8000/` | Root endpoint - Welcome message |
| GET | `http://localhost:8000/healthcheck` | Health check endpoint |

**Example Requests:**
```bash
# Root
curl http://localhost:8000/

# Health Check
curl http://localhost:8000/healthcheck
```

### Categories Endpoints

| Method | URL | Description |
|--------|-----|-------------|
| GET | `http://localhost:8000/api/categories` | Get all categories |
| GET | `http://localhost:8000/api/categories/1` | Get category by ID (replace 1 with actual ID) |
| GET | `http://localhost:8000/api/categories/2` | Get category by ID (example with ID 2) |
| GET | `http://localhost:8000/api/categories/999` | Test non-existent category (should return 404) |

**Example Requests:**
```bash
# Get all categories
curl http://localhost:8000/api/categories

# Get category by ID
curl http://localhost:8000/api/categories/1
curl http://localhost:8000/api/categories/2

# Test error case (non-existent)
curl http://localhost:8000/api/categories/999
```

### Products Endpoints

| Method | URL | Description |
|--------|-----|-------------|
| GET | `http://localhost:8000/api/products` | Get all products |
| GET | `http://localhost:8000/api/products/1` | Get product by ID (replace 1 with actual ID) |
| GET | `http://localhost:8000/api/products/2` | Get product by ID (example with ID 2) |
| GET | `http://localhost:8000/api/products/category/1` | Get products by category ID 1 |
| GET | `http://localhost:8000/api/products/category/2` | Get products by category ID 2 |
| GET | `http://localhost:8000/api/products/999` | Test non-existent product (should return 404) |
| GET | `http://localhost:8000/api/products/category/999` | Test non-existent category (should return 404) |

**Example Requests:**
```bash
# Get all products
curl http://localhost:8000/api/products

# Get product by ID
curl http://localhost:8000/api/products/1
curl http://localhost:8000/api/products/2

# Get products by category
curl http://localhost:8000/api/products/category/1
curl http://localhost:8000/api/products/category/2

# Test error cases
curl http://localhost:8000/api/products/999
curl http://localhost:8000/api/products/category/999
```

### Cart Endpoints

| Method | URL | Description | Request Body |
|--------|-----|-------------|--------------|
| POST | `http://localhost:8000/api/cart/add` | Add item to cart | See below |
| POST | `http://localhost:8000/api/cart` | Get cart details | See below |
| PUT | `http://localhost:8000/api/cart/update` | Update cart item | See below |
| DELETE | `http://localhost:8000/api/cart/remove/1` | Remove item from cart | See below |
| DELETE | `http://localhost:8000/api/cart/remove/2` | Remove item from cart (example with ID 2) | See below |

**Example Requests:**

**Add to Cart:**
```bash
curl -X POST http://localhost:8000/api/cart/add \
  -H "Content-Type: application/json" \
  -d '{
    "product_id": 1,
    "quantity": 2,
    "cart": {}
  }'
```

**Get Cart Details:**
```bash
curl -X POST http://localhost:8000/api/cart \
  -H "Content-Type: application/json" \
  -d '{
    "1": 2,
    "2": 1
  }'
```

**Update Cart Item:**
```bash
curl -X PUT http://localhost:8000/api/cart/update \
  -H "Content-Type: application/json" \
  -d '{
    "product_id": 1,
    "quantity": 3,
    "cart": {"1": 2}
  }'
```

**Remove from Cart:**
```bash
curl -X DELETE http://localhost:8000/api/cart/remove/1 \
  -H "Content-Type: application/json" \
  -d '{
    "cart": {"1": 2, "2": 1}
  }'
```

### API Documentation URLs

| URL | Description |
|-----|-------------|
| `http://localhost:8000/api/docs` | Swagger UI - Interactive API documentation |
| `http://localhost:8000/api/redoc` | ReDoc - Alternative API documentation |

### Testing Scenarios

#### Scenario 1: Browse Products Flow
```
1. GET http://localhost:8000/api/categories
2. GET http://localhost:8000/api/products
3. GET http://localhost:8000/api/products/1
4. GET http://localhost:8000/api/products/category/1
```

#### Scenario 2: Shopping Cart Flow
```
1. GET http://localhost:8000/api/products
2. POST http://localhost:8000/api/cart/add (with product_id: 1, quantity: 2)
3. POST http://localhost:8000/api/cart (with cart: {"1": 2})
4. PUT http://localhost:8000/api/cart/update (with product_id: 1, quantity: 3)
5. DELETE http://localhost:8000/api/cart/remove/1 (with cart: {"1": 3})
```

#### Scenario 3: Error Testing
```
1. GET http://localhost:8000/api/categories/999 (404)
2. GET http://localhost:8000/api/products/999 (404)
3. GET http://localhost:8000/api/products/category/999 (404)
4. POST http://localhost:8000/api/cart/add (with invalid product_id: 999)
```

**Note:** The Postman collection includes an "Error Testing" folder with automated tests for 404 scenarios. These tests verify that:
- Status code is 404
- Error response contains a `detail` field
- Error messages are properly formatted

### Quick Test Commands

**Windows PowerShell:**
```powershell
# Health Check
Invoke-WebRequest -Uri http://localhost:8000/healthcheck

# Get All Categories
Invoke-WebRequest -Uri http://localhost:8000/api/categories

# Get All Products
Invoke-WebRequest -Uri http://localhost:8000/api/products
```

**Browser Testing:**
Simply open these URLs in your browser:
- `http://localhost:8000/`
- `http://localhost:8000/healthcheck`
- `http://localhost:8000/api/categories`
- `http://localhost:8000/api/products`
- `http://localhost:8000/api/docs` (Interactive API docs)

### Postman Collection Variables

When using the Postman collection, these variables are available:

- `{{base_url}}` = `http://localhost:8000`
- `{{category_id}}` = `1` (auto-updated from responses)
- `{{product_id}}` = `1` (auto-updated from responses)

**Example URLs using variables:**
- `{{base_url}}/api/products/{{product_id}}`
- `{{base_url}}/api/categories/{{category_id}}`
- `{{base_url}}/api/products/category/{{category_id}}`

## 🎯 Running Collection Tests

### Run Entire Collection

1. Click on collection name (three dots menu)
2. Select **Run collection**
3. Click **Run FastAPI Shop API**
4. View test results for all requests

### Collection Runner Features

- **Iterations**: Run tests multiple times
- **Delay**: Add delay between requests
- **Data File**: Use CSV/JSON for data-driven testing
- **Stop on Error**: Stop if any test fails

### Viewing Results

- **Pass/Fail**: See overall test results
- **Request Details**: View request/response for each endpoint
- **Test Results**: See individual test assertions
- **Export**: Save results as JSON/HTML

## 🐛 Troubleshooting

### Common Issues

#### 1. Connection Refused

**Error**: `Could not get response`

**Solution**:
- Verify server is running: `uvicorn app.main:app --reload`
- Check `base_url` variable is correct
- Verify port 8000 is not in use

#### 2. 404 Not Found

**Error**: `404 Not Found`

**Solution**:
- Check endpoint URL is correct
- Verify router prefix matches (`/api/products`, `/api/categories`, etc.)
- Ensure server routes are registered

#### 3. 422 Validation Error

**Error**: `422 Unprocessable Entity`

**Solution**:
- Check request body format matches schema
- Verify required fields are present
- Check data types (e.g., `product_id` should be integer)

#### 4. Tests Failing

**Error**: Test assertions failing

**Solution**:
- Check response structure matches expected format
- Verify database has test data
- Review test script for correct field names
- Check variable values are set correctly

#### 5. Empty Response Arrays

**Error**: Categories/Products arrays are empty

**Solution**:
- Initialize database with sample data
- Run database migrations
- Check database connection

### Debugging Tips

1. **Check Response**: Always view the response body first
2. **Console Logs**: Use `console.log()` in test scripts for debugging
3. **Variables**: Verify collection variables are set correctly
4. **Request Body**: Double-check JSON format in request body
5. **Headers**: Ensure `Content-Type: application/json` is set for POST/PUT requests

### Test Script Debugging

Add console logs to test scripts:

```javascript
pm.test("Debug test", function () {
    const jsonData = pm.response.json();
    console.log("Response:", jsonData);
    console.log("Variables:", pm.variables.toObject());
});
```

## 📊 Test Coverage

The collection includes tests for:

- ✅ All HTTP methods (GET, POST, PUT, DELETE)
- ✅ Status code validation
- ✅ Response structure validation
- ✅ Data type validation
- ✅ Business logic validation (e.g., cart operations)
- ✅ Response time validation
- ✅ Error handling (implicit through status codes)

## 🔧 Customizing Tests

### Adding New Tests

1. Select a request
2. Go to **Tests** tab
3. Add test script:

```javascript
pm.test("Your test name", function () {
    const jsonData = pm.response.json();
    // Your assertions here
    pm.expect(jsonData.field).to.eql(expectedValue);
});
```

### Common Test Patterns

**Check if field exists:**
```javascript
pm.expect(jsonData).to.have.property('field_name');
```

**Check data type:**
```javascript
pm.expect(jsonData.field).to.be.a('string');
pm.expect(jsonData.field).to.be.a('number');
```

**Check array length:**
```javascript
pm.expect(jsonData.array).to.have.lengthOf(5);
```

**Check value:**
```javascript
pm.expect(jsonData.field).to.eql('expected_value');
```

## 📚 Additional Resources

- [Postman Documentation](https://learning.postman.com/docs/)
- [Postman Test Scripts](https://learning.postman.com/docs/writing-scripts/test-scripts/)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Pydantic Validation](https://docs.pydantic.dev/)

## ✅ Best Practices

1. **Run tests in order**: Some tests depend on previous requests
2. **Update variables**: Use auto-saved IDs from previous requests
3. **Check test results**: Always review test output
4. **Keep data clean**: Reset test data between test runs
5. **Document failures**: Note any failing tests for debugging
6. **Version control**: Export and commit collection to Git

---

**Happy Testing! 🎉**

For issues or questions, check the FastAPI Shop documentation or review the API code.

