from app.services import StorageService
from app.imports import Optional, List
from app.imports import FastAPI, Depends, UploadFile, File, HTTPException, Form
from app.models import ModelVerdict, Inspection
from app.imports import datetime

server_app = FastAPI()

'''создание экземпляра FirebaseService'''
def create_storage_service() -> StorageService:
    return StorageService()

'''endpoint для получения всех инспекций конкретного инженера'''
@server_app.get("/inspections_by_user/{id}")
def get_inspections(id: str, ss: StorageService = Depends(create_storage_service)):
    inspections = ss._firebase.inspections_collection.get_inspections_by_eng_id(id)
    result = [inspection.to_dict() for inspection in inspections]
    return result

@server_app.post("/inspection", status_code=201)
def create_inspection(
        engineer_id: str = Form(...),
        timestamp: datetime=Form(...),
        model_verdict_material: str = Form(...),
        model_verdict_state: int = Form(...),
        model_verdict_damage_type: str = Form(...),
        model_verdict_damage_degree: float = Form(...),
        model_verdict_accuracy_model: float = Form(...),
        model_verdict_comments: str = Form(...),
        address: str = Form(...),
        name: str = Form(...),
        files: Optional[List[UploadFile]] = File(default=None),
        ss: StorageService = Depends(create_storage_service)
):
    try:
        model_verdict = ModelVerdict(
            material=model_verdict_material,
            state=model_verdict_state,
            damage_type=model_verdict_damage_type,
            damage_degree=model_verdict_damage_degree,
            accuracy_model=model_verdict_accuracy_model,
            comments=model_verdict_comments
        )
        inspection = Inspection(
            engineer_id=engineer_id,
            timestamp=timestamp,
            model_verdict=model_verdict,
            address=address,
            name=name,
            photos=[],
            status_sync="pending"
        )

        inspection_id = ss.add_inspection(inspection)
        return {
            "inspection_id": inspection_id,
            "status": "created"
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

