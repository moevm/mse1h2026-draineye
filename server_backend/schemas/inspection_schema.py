from server_backend.imports import datetime, List, BaseModel

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