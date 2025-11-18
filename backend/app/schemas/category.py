from pydantic import BaseModel, Field


class CategoryBase(BaseModel):
    name: str = Field(..., min_length=5, max_length=100, description = "Category name")
    slug: str = Field(..., min_length=5, max_length=100, description = "Category url")

class CategoryCreate(CategoryBase):
    pass

class CategoryResponse(CategoryBase):
    id: int = Field(..., description="Unique Category id")

    class Config:
        from_attributes = True
