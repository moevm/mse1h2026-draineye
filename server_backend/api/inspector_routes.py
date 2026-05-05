from server_backend.services.storage_service import StorageService
from server_backend.imports import Optional, List
from server_backend.imports import APIRouter, Depends, UploadFile, File, HTTPException, Form
from server_backend.models import User
from server_backend.schemas.auth_request import RegisterRequest
from server_backend.server.auth import require_inspector
from server_backend.schemas import InspectionSchema

router = APIRouter(
    prefix="/inspector",
    tags=["Inspector"]
)

'''создание экземпляра FirebaseService'''
def create_storage_service() -> StorageService:
    return StorageService()

'''endpoint для получения всех инспекций конкретного инженера'''
@router.get("/my_inspections")
def get_inspections(
    user: User = Depends(require_inspector),
    ss: StorageService = Depends(create_storage_service)
):
    result = ss.get_inspections_by_engineer(user.user_id)
    return result

'''endpoint для добавления инспекции конкретного инженера'''
@router.post("/add_inspection", status_code=201)
async def create_inspection(
    inspection_json: str = Form(...),
    files: Optional[List[UploadFile]] = File(default=None),
    user: User = Depends(require_inspector),
    ss: StorageService = Depends(create_storage_service)
):
    try:
        inspection_schema = InspectionSchema.model_validate_json(inspection_json)
        inspection_schema.engineer_id = user.user_id
        result = await ss.create_inspection_with_photos(inspection_schema, files)
        return {
            "inspection_id": result["inspection_id"],
            "status": result["status"]
        }
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


'''endpoint для регистрации инспектора'''
@router.post("/register", status_code=201)
def register_inspector(
    request: RegisterRequest,
    ss: StorageService = Depends(create_storage_service)
):
    try:
        uid = ss.register_inspector(
            email=str(request.email).strip().lower(),
            password=request.password,
            full_name=request.full_name
        )
        return {"user_id": uid, "status": "created", "role": "inspector"}

    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Ошибка сервера: {str(e)}")

'''endpoint для авторизации инспектора'''
@router.post("/login")
def login_inspector(
    user: User = Depends(require_inspector)
):
    return {
        "status": "success",
        "user_id": user.user_id,
        "role": user.role.value,
        "full_name": user.full_name,
        "email": user.email,
        "count": user.count_inspections,
        "last_activity": user.last_activity,
        "created_at": user.created_at,
        "message": "Вход выполнен успешно"
    }
