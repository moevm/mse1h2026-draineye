from app.services import StorageService
from app.imports import Optional, List
from app.imports import FastAPI, Depends, UploadFile, File, HTTPException, Form
from app.models import ModelVerdict, Inspection
from app.schemas import InspectionSchema, ModelVerdictSchema

server_app = FastAPI()

'''создание экземпляра FirebaseService'''
def create_storage_service() -> StorageService:
    return StorageService()

'''endpoint для получения всех инспекций конкретного инженера'''
@server_app.get("/inspections_by_user/{id}")
def get_inspections(id: str, ss: StorageService = Depends(create_storage_service)):
    result  = ss.get_inspections_by_engineer(id)
    return result

'''endpoint для добавления инспекции конкретного инженера'''
@server_app.post("/add_inspection", status_code=201)
def create_inspection(
        inspection_json: str = Form(...),
        files: Optional[List[UploadFile]] = File(default=None),
        ss: StorageService = Depends(create_storage_service)
):
    try:
        inspection_schema = InspectionSchema.model_validate_json(inspection_json)
        inspection = Inspection.from_schema(inspection_schema)
        inspection_id = ss.add_inspection(inspection)
        return {
            "inspection_id": inspection_id,
            "status": "created"
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
