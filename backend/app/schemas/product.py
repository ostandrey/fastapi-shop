from pydantic import BaseModel, Field
from datetime import datetime
from typing import Optional, List
from .category import CategoryResponse

class ProductBase(BaseModel):
    name: str = Field(..., min_length=5, max_length=100, description="Product name")
    description: Optional[str] = Field(None, description="Product description")
    price: float = Field(..., gt=0, description="Product price (greater than 0)")

    category_id: int = Field(..., description="Product category id")
    image_url: Optional[str] = Field(None, description="Product image url")

class ProductCreate(ProductBase):
    pass

class ProductResponse(ProductBase):
    id: int = Field(..., description="Product id")
    name: str
    description: Optional[str]
    price: float
    category_id: str
    image_url: Optional[str]
    create_at: datetime
    category: CategoryResponse = Field(..., description="Product category")

    class Config:
        form_attributes = True

class ProductListResponse(ProductBase):
    products: List[ProductResponse]
    total: int = Field(..., description="Total number of products")
