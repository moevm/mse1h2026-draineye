from server_backend.imports import  List, BaseModel, datetime, Optional, Field
from server_backend.models.user import UserRole

class UserResponse(BaseModel):
    user_id: str
    email: str
    full_name: str
    role: str
    is_active: bool
    count_inspections: int = 0
    last_activity: Optional[datetime] = None
    created_at: Optional[datetime] = None
    class Config:
        from_attributes = True

class PaginatedUsersResponse(BaseModel):
    users: List[UserResponse]
    next_cursor: Optional[str] = None
    has_more: bool
    total_returned: int

class UserListQueryParams(BaseModel):
    role: UserRole = UserRole.INSPECTOR
    limit: int = Field(50, ge=1, le=50)
    next_cursor: Optional[str] = None
    active_only: bool = True