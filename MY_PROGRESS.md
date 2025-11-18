# My Progress

This document tracks the development progress of the FastAPI Shop project.

## Setup Phase

### 1. Virtual Environment Setup

Activated the virtual environment in Git Bash (MINGW64):

```bash
source venv/Scripts/activate
```

✅ Successfully activated virtual environment - prompt shows `(venv)`

### 2. Installing Core Dependencies

Installed the main packages for the FastAPI application:

```bash
pip install fastapi uvicorn sqlalchemy pydantic python-dotenv
```

**Installed packages:**
- `fastapi` (0.121.2) - Modern web framework for building APIs
- `uvicorn` (0.33.0) - ASGI server for running FastAPI
- `sqlalchemy` (2.0.44) - SQL toolkit and ORM
- `pydantic` (2.10.6) - Data validation using Python type annotations
- `python-dotenv` (1.0.1) - Load environment variables from .env files

**Dependencies automatically installed:**
- `starlette` (0.44.0)
- `annotated-doc` (0.0.4)
- `typing-extensions` (4.13.2)
- `click` (8.1.8)
- `h11` (0.16.0)
- `greenlet` (3.1.1)
- `annotated-types` (0.7.0)
- `pydantic-core` (2.27.2)
- `anyio` (4.5.2)
- `colorama` (0.4.6)
- `sniffio` (1.3.1)
- `idna` (3.11)
- `exceptiongroup` (1.3.0)

✅ All packages installed successfully

### 3. Creating Requirements File

Generated `requirements.txt` to track all dependencies:

```bash
pip freeze > requirements.txt
```

✅ Requirements file created

### 4. Installing Additional Package

Added `pydantic-settings` for managing application settings:

```bash
pip install pydantic-settings
```

**Installed:**
- `pydantic-settings` (2.8.1) - Settings management using Pydantic models

✅ Package installed and requirements.txt updated

### 5. Project Structure Setup

Created the application directory structure:

```bash
mkdir app
cd app
mkdir -p models schemas repositories services routes
```

**Created directories with detailed explanations:**

- `app/` - Main application directory
  - `models/` - **Database Models (SQLAlchemy)**
    - Define database tables and their structure
    - Similar to Django Models - represent database schema
    - Use SQLAlchemy ORM to map Python classes to database tables
    - Example: User model, Product model, Order model
    
  - `schemas/` - **Pydantic Schemas (Data Validation & Serialization)**
    - Similar to Django Serializers
    - Define the format of data that frontend can receive
    - Handle data validation for incoming requests
    - Transform database models into JSON-serializable format
    - Two types: Request schemas (input validation) and Response schemas (output formatting)
    - Example: UserCreate schema, UserResponse schema
    
  - `repositories/` - **Data Access Layer**
    - Handle all database operations (CRUD - Create, Read, Update, Delete)
    - Abstract database queries away from business logic
    - Work directly with database models
    - Provide clean interface for services to interact with database
    - Example: UserRepository, ProductRepository
    
  - `services/` - **Business Logic Layer (Similar to Django Views)**
    - Similar to Django Views - contain the main application logic
    - Receive data from routes, process it, and return results
    - Coordinate between repositories and schemas
    - Handle business rules and validation
    - Don't directly interact with database (use repositories instead)
    - Example: UserService, ProductService, OrderService
    
  - `routes/` - **API Route Handlers (Similar to Django URLs)**
    - Similar to Django URLs - define API endpoints
    - Map HTTP methods (GET, POST, PUT, DELETE) to functions
    - Define URL paths and HTTP methods
    - Receive HTTP requests and return HTTP responses
    - Thin layer that delegates to services
    - Example: `/api/users`, `/api/products`, `/api/orders`

✅ Project structure created following clean architecture principles

### 6. Core Application Files

Created essential configuration and database setup files:

**Files created:**

- `app/__init__.py` - Makes `app` directory a Python package
- `app/config.py` - **Application Configuration**
  - Uses `pydantic-settings` for settings management
  - Defines application settings with defaults:
    - `app_name`: "FastAPI Shop"
    - `debug`: True (development mode)
    - `database_url`: SQLite database path (`sqlite:///./shop.db`)
    - `cors_origins`: List of allowed frontend origins (localhost ports for development)
    - `static_dir`: Directory for static files
    - `images_dir`: Directory for image uploads
  - Loads environment variables from `.env` file
  - Provides `settings` object for use throughout the application

- `app/database.py` - **Database Connection & Session Management**
  - Creates SQLAlchemy engine with database connection
  - Configures `SessionLocal` for database sessions
  - Defines `Base` class for declarative models (all models will inherit from this)
  - `get_db()`: Dependency function for FastAPI to get database session
    - Uses generator pattern (`yield`) to ensure database connection is properly closed
    - Automatically handles session cleanup
  - `init_db()`: Function to initialize database tables (creates all tables)

- `backend/__init__.py` - Makes `backend` directory a Python package

**Key Concepts:**

- **Configuration Management**: Using Pydantic Settings allows type-safe configuration with automatic environment variable loading
- **Database Sessions**: SQLAlchemy session management ensures proper connection handling and cleanup
- **Dependency Injection**: `get_db()` function will be used as a FastAPI dependency to inject database sessions into route handlers

✅ Core application infrastructure files created

### 7. Database Models Created

Created SQLAlchemy models for the e-commerce shop:

**Files created:**

- `app/models/__init__.py` - Exports all models for easy importing
  - Exports: `Category`, `Product`

- `app/models/category.py` - **Category Model**
  - Table name: `categories`
  - Fields:
    - `id` (Integer, Primary Key, Indexed)
    - `name` (String, Unique, Not Null, Indexed) - Category name
    - `slug` (String, Unique, Not Null, Indexed) - URL-friendly identifier
  - Relationships:
    - `products` - One-to-Many relationship with Product model
  - Includes `__repr__` method for debugging

- `app/models/product.py` - **Product Model**
  - Table name: `product`
  - Fields:
    - `id` (Integer, Primary Key, Indexed)
    - `name` (String, Not Null, Indexed) - Product name
    - `description` (Text) - Product description
    - `price` (Float, Not Null) - Product price
    - `category_id` (Integer, Foreign Key) - Reference to Category
    - `image_url` (String) - URL to product image
    - `created_at` (DateTime) - Timestamp of creation (defaults to UTC now)
  - Relationships:
    - `category` - Many-to-One relationship with Category model
  - Includes `__repr__` method for debugging

**Key Features:**

- **Database Relationships**: 
  - Category has many Products (One-to-Many)
  - Product belongs to one Category (Many-to-One)
  - Bidirectional relationship using `back_populates`

- **Data Integrity**:
  - Foreign key constraint ensures products must belong to a valid category
  - Unique constraints on category name and slug prevent duplicates
  - Indexed fields for better query performance

- **Model Structure**:
  - All models inherit from `Base` (declarative base from `database.py`)
  - Proper use of SQLAlchemy Column types
  - Relationship definitions for easy navigation between related models

✅ Database models created for Category and Product entities

### 8. Pydantic Schemas Created

Created Pydantic schemas for data validation and serialization:

**Files created:**

- `app/schemas/__init__.py` - Package initialization file

- `app/schemas/category.py` - **Category Schemas**
  - `CategoryBase`: Base schema with common fields
    - `name`: String (5-100 characters)
    - `slug`: String (5-100 characters, URL-friendly)
  - `CategoryCreate`: Schema for creating categories (inherits from CategoryBase)
  - `CategoryResponse`: Schema for API responses
    - Includes `id` field
    - Uses `form_attributes = True` for ORM compatibility

- `app/schemas/product.py` - **Product Schemas**
  - `ProductBase`: Base schema with common fields
    - `name`: String (5-100 characters)
    - `description`: Optional text
    - `price`: Float (must be greater than 0)
    - `category_id`: Integer (foreign key to category)
    - `image_url`: Optional string
  - `ProductCreate`: Schema for creating products (inherits from ProductBase)
  - `ProductResponse`: Schema for API responses
    - Includes `id`, `created_at` timestamp
    - Includes nested `category` (CategoryResponse) for related data
  - `ProductListResponse`: Schema for paginated product lists
    - `products`: List of ProductResponse
    - `total`: Total count of products

- `app/schemas/cart.py` - **Shopping Cart Schemas**
  - `CartItemBase`: Base schema for cart items
    - `product_id`: Integer
    - `quantity`: Integer (must be greater than 0)
  - `CartItemCreate`: Schema for adding items to cart
  - `CartItemUpdate`: Schema for updating cart item quantities
  - `CartItem`: Schema representing a cart item with product details
    - Includes product name, price, quantity, subtotal, image_url
  - `CartResponse`: Schema for complete cart response
    - `items`: List of CartItem
    - `total`: Total price of all items
    - `items_count`: Total number of items

**Key Features:**
- Field validation with Pydantic (min/max length, value constraints)
- Request schemas (Create) for input validation
- Response schemas for output formatting
- Nested schemas for related data (Product includes Category)
- List response schemas for pagination support

✅ Pydantic schemas created for Category, Product, and Cart

### 9. Repository Layer Created

Created repository classes for database operations:

**Files created:**

- `app/repositories/category_repository.py` - **CategoryRepository**
  - `get_all()`: Retrieve all categories
  - `get_by_id(category_id)`: Get category by ID
  - `get_by_slug(slug)`: Get category by slug (for URL routing)
  - `create(category_data)`: Create new category
  - Uses SQLAlchemy Session for database operations
  - Returns Category model instances

- `app/repositories/product_repository.py` - **ProductRepository**
  - `get_all()`: Retrieve all products with category relationship (joinedload)
  - `get_by_id(product_id)`: Get product by ID with category
  - `get_by_category(category_id)`: Get all products in a category
  - `create(product_data)`: Create new product
  - `get_multiple_by_ids(product_ids)`: Get multiple products by IDs (for cart)
  - Uses `joinedload` to eagerly load category relationships (prevents N+1 queries)
  - Returns Product model instances with related category data

**Key Features:**
- Clean separation of database operations from business logic
- Efficient querying with relationship loading
- CRUD operations for both entities
- Batch operations support (get_multiple_by_ids for cart functionality)

✅ Repository layer created for Category and Product operations

### 10. Service Layer Created

Created service classes for business logic:

**Files created:**

- `app/services/category_service.py` - **CategoryService**
  - `get_all_categories()`: Get all categories (returns list of CategoryResponse)
  - `get_category_by_id(category_id)`: Get category by ID with 404 error handling
  - `create_category(category_data)`: Create new category
  - Uses CategoryRepository for data access
  - Converts models to response schemas using `model_validate()`
  - Handles HTTP exceptions (404 Not Found)

- `app/services/product_service.py` - **ProductService**
  - `get_all_products()`: Get all products (returns ProductListResponse)
  - `get_product_by_id(product_id)`: Get product by ID with 404 error handling
  - `get_product_by_category(category_id)`: Get products filtered by category
  - `create_product(product_data)`: Create new product with category validation
  - Uses both ProductRepository and CategoryRepository
  - Validates category exists before creating product
  - Returns formatted ProductListResponse with total count

- `app/services/cart_service.py` - **CartService**
  - `add_to_cart(cart_data, item)`: Add item to cart (increments if exists)
  - `update_cart_item(cart_data, item)`: Update item quantity in cart
  - `remove_from_cart(cart_data, product_id)`: Remove item from cart
  - `get_cart_details(cart_data)`: Get full cart with product details and totals
  - Uses ProductRepository to fetch product information
  - Calculates subtotals and total price
  - Returns CartResponse with formatted cart items
  - Note: Cart is stored in memory (Dict), not in database

**Key Features:**
- Business logic separated from data access
- Error handling with appropriate HTTP status codes
- Data transformation (models → schemas)
- Validation (e.g., category must exist before creating product)
- Cart functionality with in-memory storage

✅ Service layer created for Category, Product, and Cart operations

### 11. API Routes Created

Created FastAPI route handlers for all endpoints:

**Files created:**

- `app/routes/__init__.py` - Exports all routers for easy importing
  - Exports: `products_router`, `categories_router`, `cart_router`

- `app/routes/categories.py` - **Category Routes**
  - Router prefix: `/api/categories`
  - `GET /api/categories`: Get all categories
    - Returns: List of CategoryResponse
    - Status: 200 OK
  - `GET /api/categories/{category_id}`: Get category by ID
    - Returns: CategoryResponse
    - Status: 200 OK
  - Uses CategoryService for business logic
  - Database session injected via dependency injection

- `app/routes/products.py` - **Product Routes**
  - Router prefix: `/api/products`
  - `GET /api/products`: Get all products
    - Returns: ProductListResponse (with total count)
    - Status: 200 OK
  - `GET /api/products/{product_id}`: Get product by ID
    - Returns: ProductResponse (includes category data)
    - Status: 200 OK
  - `GET /api/products/category/{category_id}`: Get products by category
    - Returns: ProductListResponse
    - Status: 200 OK
  - Uses ProductService for business logic
  - Database session injected via dependency injection

- `app/routes/cart.py` - **Shopping Cart Routes**
  - Router prefix: `/api/cart`
  - `POST /api/cart/add`: Add item to cart
    - Request: AddToCartRequest (product_id, quantity, cart dict)
    - Returns: Updated cart dictionary
    - Status: 200 OK
  - `POST /api/cart`: Get cart details
    - Request: Cart dictionary
    - Returns: CartResponse (with items, total, items_count)
    - Status: 200 OK
  - `PUT /api/cart/update`: Update cart item quantity
    - Request: UpdateCartRequest (product_id, quantity, cart dict)
    - Returns: Updated cart dictionary
    - Status: 200 OK
  - `DELETE /api/cart/remove/{product_id}`: Remove item from cart
    - Request: RemoveFromCartRequest (cart dict)
    - Returns: Updated cart dictionary
    - Status: 200 OK
  - Uses CartService for business logic
  - Cart stored in-memory (passed as request body)

**Key Features:**
- Clean route handlers that delegate to services
- Proper HTTP status codes
- Response models defined for type safety
- Dependency injection for database sessions
- Router prefixes and tags for API organization
- RESTful API design patterns

✅ API routes created for Categories, Products, and Cart

### 12. Main Application File Created

Created the main FastAPI application entry point:

**Files created:**

- `app/main.py` - **FastAPI Application**
  - Creates FastAPI app instance with:
    - Title from settings
    - Debug mode from settings
    - Custom docs URLs (`/api/docs`, `/api/redoc`)
  - **CORS Middleware**: Configured to allow frontend origins
    - Allows credentials
    - Allows all methods and headers
    - Origins from settings (localhost ports)
  - **Static Files**: Mounts static directory for serving images/files
  - **Routers**: Includes all route modules
    - Products router
    - Categories router
    - Cart router
  - **Startup Event**: Initializes database tables on startup
  - **Root Endpoint**: `GET /` - Welcome message with API info
  - **Health Check**: `GET /healthcheck` - Returns health status

- `run.py` - **Application Runner Script**
  - Runs uvicorn ASGI server
  - Configuration:
    - Host: `0.0.0.0` (accessible from all interfaces)
    - Port: `8000`
    - Reload: Enabled in debug mode (auto-reload on code changes)
    - Log level: `info`
  - Entry point: `app.main:app`

**Key Features:**
- Production-ready FastAPI application setup
- CORS configured for frontend integration
- Static file serving for images
- Automatic database initialization
- Development-friendly with auto-reload
- Health check endpoint for monitoring

✅ Main application file and runner script created

### 13. Database Seeding Script Created

Created a script to populate the database with test data:

**Files created:**

- `backend/seed_data.py` - **Database Seeding Script**
  - Purpose: Populate database with sample categories and products for testing
  - Functions:
    - `create_categories(db)`: Creates 4 categories
      - Electronics
      - Clothing
      - Books
      - Home & Garden
    - `create_products(db, categories)`: Creates 13 sample products across categories
      - 5 Electronics products (headphones, smartwatch, laptop stand, USB-C hub, keyboard)
      - 1 Clothing product (running shoes)
      - 3 Books (Python guide, design book, cooking book)
      - 4 Home & Garden products (plant pots, LED lamp, pillows, garden tools)
    - `seed_database()`: Main function that orchestrates the seeding process
  - Features:
    - Checks if database already has data (prevents duplicate seeding)
    - Uses placeholder images from Unsplash
    - Includes detailed product descriptions
    - Proper error handling with rollback on failure
    - Progress messages for each step
  - Usage: Run with `python seed_data.py` from backend directory

**Database Created:**

- `backend/shop.db` - **SQLite Database File**
  - Database file created after running the application or seed script
  - Contains tables: `categories` and `product`
  - Ready to be populated with seed data

**Static Files Directory:**

- `backend/static/images/` - **Static Images Directory**
  - Directory created for serving static image files
  - Currently products use external URLs (Unsplash), but directory is ready for local image storage

**Key Features:**
- Comprehensive test data for development and testing
- Prevents duplicate seeding
- Realistic product data with descriptions and prices
- External image URLs for quick setup
- Easy to extend with more categories/products

✅ Database seeding script created with sample data

### 14. Bug Fixes and Schema Corrections

Fixed several validation and schema issues discovered during API testing:

**Files modified:**

- `backend/app/schemas/product.py` - **Product Schema Fixes**
  - Fixed `ProductResponse.category_id`: Changed from `str` to `int` to match Product model
  - Fixed field name: Changed `create_at` to `created_at` to match Product model field
  - Fixed `ProductListResponse`: Changed inheritance from `ProductBase` to `BaseModel`
    - ProductListResponse should only have `products` and `total` fields, not product fields

- `backend/app/repositories/product_repository.py` - **ProductRepository Fix**
  - Fixed `get_by_id()` method:
    - Changed parameter from `category_id` to `product_id`
    - Changed filter from `Product.category_id == category_id` to `Product.id == product_id`
    - Changed `.all()` to `.first()` to return single Product object instead of list
    - This was causing validation errors when trying to get a product by ID

- `backend/app/schemas/cart.py` - **CartResponse Schema Fix**
  - Fixed `CartResponse` inheritance: Changed from `CartItemBase` to `BaseModel`
    - CartResponse should not inherit product_id and quantity fields
    - CartResponse has its own fields: `items`, `total`, `items_count`
  - Removed `gt=0` constraint from `total` and `items_count` to allow empty carts (value 0)

- `backend/app/routes/cart.py` - **Cart Route Fix**
  - Fixed typo: Changed `request.cartm` to `request.cart` in remove_from_cart function
  - Removed unused imports (`urllib.request`, `List`)

**Issues Resolved:**
- ✅ ProductResponse validation errors (category_id type mismatch, missing created_at field)
- ✅ ProductListResponse validation errors (inheriting wrong base class)
- ✅ ProductRepository.get_by_id() returning list instead of single object
- ✅ CartResponse validation errors (inheriting wrong base class with required fields)
- ✅ Cart route typo fixed (request.cartm → request.cart)

**Testing:**
- All endpoints now validate correctly
- Product retrieval by ID works properly
- Cart operations work with empty and populated carts
- All Pydantic validation passes

✅ Schema and repository bugs fixed - API is now fully functional

## Architecture Theory

### Clean Architecture / Layered Architecture

This project follows a **layered architecture** pattern, which separates concerns into distinct layers. Each layer has a specific responsibility and communicates with adjacent layers only.

### Data Flow in the Application

```
HTTP Request → Routes → Services → Repositories → Database
                ↓         ↓          ↓
              Schemas  Schemas    Models
                ↓         ↓          ↓
HTTP Response ← Routes ← Services ← Repositories
```

**Step-by-step flow:**

1. **Routes Layer** (Entry Point)
   - Receives HTTP request from client
   - Validates request using Pydantic schemas
   - Calls appropriate service method
   - Returns HTTP response with data formatted by schemas

2. **Services Layer** (Business Logic)
   - Contains application business rules
   - Validates business logic (e.g., "user must be 18+", "product must be in stock")
   - Coordinates between repositories and schemas
   - Transforms data between database models and API schemas
   - Handles complex operations that might involve multiple repositories

3. **Repositories Layer** (Data Access)
   - Performs CRUD operations on database
   - Abstracts SQL queries
   - Returns database models
   - Handles database-specific logic

4. **Models Layer** (Database Schema)
   - Represents database tables
   - Defines relationships between tables
   - Managed by SQLAlchemy ORM

5. **Schemas Layer** (Data Validation & Formatting)
   - Validates incoming data (Request schemas)
   - Formats outgoing data (Response schemas)
   - Ensures type safety and data integrity
   - Converts between database models and API-friendly formats

### Key Concepts

#### Separation of Concerns
Each layer has a single, well-defined responsibility:
- **Routes**: HTTP handling
- **Services**: Business logic
- **Repositories**: Database operations
- **Models**: Data structure
- **Schemas**: Data validation and formatting

#### Dependency Direction
Dependencies flow inward:
- Routes depend on Services
- Services depend on Repositories
- Repositories depend on Models
- Schemas are used by Routes and Services

This means:
- ✅ Services don't know about HTTP (routes)
- ✅ Repositories don't know about business logic (services)
- ✅ Models don't know about repositories

#### Benefits of This Architecture

1. **Testability**: Each layer can be tested independently
2. **Maintainability**: Changes in one layer don't affect others
3. **Scalability**: Easy to add new features or modify existing ones
4. **Reusability**: Services can be reused by different routes
5. **Flexibility**: Can swap database or change API structure without major refactoring

### Comparison with Django

| FastAPI Component | Django Equivalent | Purpose |
|-------------------|-------------------|---------|
| `routes/` | `urls.py` | Define API endpoints |
| `services/` | `views.py` | Business logic |
| `repositories/` | Model Managers / Querysets | Database operations |
| `models/` | `models.py` | Database schema |
| `schemas/` | `serializers.py` | Data validation & formatting |

**Key Differences:**
- FastAPI is more explicit about separating data access (repositories) from business logic (services)
- Django combines views and business logic, while FastAPI separates them
- FastAPI uses Pydantic for validation (built-in), Django uses serializers (DRF)

### Best Practices

1. **Keep Routes Thin**: Routes should only handle HTTP concerns, delegate to services
2. **Business Logic in Services**: All business rules belong in services, not routes or repositories
3. **Repository Pattern**: Always access database through repositories, never directly in services
4. **Schema Validation**: Always validate input/output with Pydantic schemas
5. **Error Handling**: Handle errors at appropriate layers (validation errors in routes, business errors in services)

### Example: Creating a User

```python
# 1. Route receives POST /api/users
@router.post("/users")
def create_user(user_data: UserCreate):  # Schema validates input
    return user_service.create_user(user_data)

# 2. Service processes business logic
def create_user(user_data: UserCreate):
    # Business rule: check if email exists
    if user_repository.get_by_email(user_data.email):
        raise ValueError("Email already exists")
    # Create user
    user = user_repository.create(user_data)
    return UserResponse.from_orm(user)  # Schema formats output

# 3. Repository handles database
def create(user_data: UserCreate):
    db_user = User(**user_data.dict())  # Model
    db.session.add(db_user)
    db.session.commit()
    return db_user
```

## Current Status

- ✅ Virtual environment configured
- ✅ Core dependencies installed
- ✅ Requirements file created
- ✅ Project structure initialized
- ✅ Core application files created (`config.py`, `database.py`)
- ✅ Database connection and session management configured
- ✅ Application settings configured with Pydantic Settings
- ✅ Database models created (`Category`, `Product`)
- ✅ Pydantic schemas created (Category, Product, Cart)
- ✅ Repository layer created (CategoryRepository, ProductRepository)
- ✅ Service layer created (CategoryService, ProductService, CartService)
- ✅ API routes created (Categories, Products, Cart)
- ✅ Main application file created (`app/main.py`)
- ✅ Application runner script created (`run.py`)
- ✅ Database seeding script created (`seed_data.py`)
- ✅ Database file created (`shop.db`)
- ✅ Static files directory created (`static/images/`)
- ✅ Schema validation bugs fixed (ProductResponse, ProductListResponse, CartResponse)
- ✅ Repository bug fixed (ProductRepository.get_by_id)
- ✅ **Backend API is complete, tested, and fully functional!**
- ✅ **Frontend is complete with Vue.js 3, Pinia, Vue Router**
- ✅ **Full-stack application is functional!**

## Recent Updates (Code Quality & Bug Fixes)

### Code Internationalization
- ✅ **Frontend comments translated to English**
  - All Vue components (App.vue, CartItem.vue, CategoryFilter.vue, Header.vue, ProductCard.vue)
  - All views (CartPage.vue, HomePage.vue, ProductDetailPage.vue)
  - All stores (cart.js, products.js)
  - All services (api.js)
  - Router configuration (index.js)
  - CSS files (main.css)
  - Total: 15+ files translated

- ✅ **Deployment script translated to English**
  - `deploy.sh` - Complete translation of all Russian comments, messages, and prompts
  - All user-facing text now in English
  - Deployment instructions and error messages translated

### Bug Fixes

- ✅ **Cart quantity update bug fixed**
  - **Backend fix:** Changed `cart_service.py` line 37 from `cart_data[item.product_id] += item.quantity` to `cart_data[item.product_id] = item.quantity`
  - **Issue:** Backend was adding quantity instead of setting it (e.g., clicking "+" on quantity 2 would result in 2+3=5 instead of 3)
  - **Frontend improvements:** Added double-click prevention and proper error handling in `CartItem.vue`
  - **Result:** Cart quantity controls now work correctly (increase/decrease as expected)

### Environment Updates

- ✅ **Python version upgrade**
  - Upgraded from Python 3.8.8 to Python 3.12.10
  - Multiple Python versions available (3.8 and 3.12)
  - Using Python 3.12 for new virtual environments
  - Benefits: Better performance (10-60% faster), latest security patches, full compatibility with modern dependencies

### Code Quality Improvements

- ✅ **Frontend code standardization**
  - All comments in English
  - Consistent code style
  - Better error handling in cart operations
  - Improved user experience with loading states and error prevention

## Notes

- Using Python 3.12.10 (upgraded from 3.8.8)
- pip version 25.3 (upgraded)
- Working in Git Bash (MINGW64) on Windows
- Virtual environment location: `backend/venv/` (recreated with Python 3.12)
- All code comments and documentation now in English

