from pydantic import BaseModel, Field
from typing import Optional, List


class CartItemBase(BaseModel):
    product_id: int = Field(..., description="Product ID")
    quantity: int = Field(..., gt=0, description="Quantity (greater than 0)")

class CartItemCreate(CartItemBase):
    pass

class CartItemUpdate(BaseModel):
    product_id: int = Field(..., description="Product ID")
    quantity: int = Field(..., gt=0, description="New Quantity (greater than 0)")

class CartItem(BaseModel):
    product_id: int
    name: str = Field(..., description="Product Name")
    price: float = Field(..., gt=0, description="Price")
    quantity: int = Field(..., gt=0, description="Quantity (greater than 0)")
    subtotal: float = Field(..., gt=0, description="Total price (price * quantity)(greater than 0)")
    image_url: Optional[str] = Field(None, description="Image URL")

class CartResponse(BaseModel):
    items: List[CartItem] = Field(..., description="List of items in the cart")
    total: float = Field(..., description="Total price")
    items_count: int = Field(..., description="Number of items in the cart")
