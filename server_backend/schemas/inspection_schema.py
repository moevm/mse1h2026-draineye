from server_backend.imports import datetime, List, BaseModel, Field, Optional

class ModelVerdictSchema(BaseModel):
    material: str
    state: int
    damage_type: str
    damage_degree: float
    accuracy_model: float
    comments: str

class InspectionSchema(BaseModel):
    engineer_id: str
    timestamp: datetime
    model_verdict: ModelVerdictSchema
    address: str
    name: str
    photos: List[str] = []
    status_sync: str = "pending"

class EngineerBriefResponse(BaseModel):
    user_id: str
    full_name: str
    email: str
    class Config:
        from_attributes = True

class InspectionResponse(InspectionSchema):
    id: str
    engineer: Optional[EngineerBriefResponse] = None
    class Config:
        from_attributes = True


class InspectionListQueryParams(BaseModel):
    limit: int = Field(50, ge=1, le=50)
    next_cursor: Optional[str] = None

class PaginatedInspectionsResponse(BaseModel):
    inspections: List[InspectionResponse]
    next_cursor: Optional[str] = None
    has_more: bool
    total_returned: int