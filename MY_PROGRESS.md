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
- ⏳ Next: Create routes/API endpoints and main application file

## Notes

- Using Python 3.8.8
- pip version 20.2.3 (consider upgrading to 25.0.1)
- Working in Git Bash (MINGW64) on Windows
- Virtual environment location: `backend/venv/`

