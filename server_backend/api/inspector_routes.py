from server_backend.services.storage_service import StorageService
from server_backend.imports import Optional, List
from server_backend.imports import APIRouter, Depends, UploadFile, File, HTTPException, Form, logging
from server_backend.models import User
from server_backend.schemas.auth_request import RegisterRequest
from server_backend.server.auth import require_inspector
from server_backend.schemas import InspectionSchema

logger = logging.getLogger(__name__)

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
    logger.info(f"Запрос инспекций для инженера ID: {user.user_id}")
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
    logger.info(f"Попытка создания инспекции инженером ID: {user.user_id}")
    try:
        inspection_schema = InspectionSchema.model_validate_json(inspection_json)
        inspection_schema.engineer_id = user.user_id
        result = await ss.create_inspection_with_photos(inspection_schema, files)
        logger.info(f"Инспекция успешно создана. ID: {result['inspection_id']}, Статус: {result['status']}")
        return {
            "inspection_id": result["inspection_id"],
            "status": result["status"]
        }
    except ValueError as e:
        logger.warning(f"Ошибка валидации данных от пользователя {user.user_id}: {str(e)}")
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error(f"Критическая ошибка при создании инспекции для {user.user_id}: {str(e)}", exc_info=True)
        raise HTTPException(status_code=500, detail=str(e))


'''endpoint для регистрации инспектора'''
@router.post("/register", status_code=201)
def register_inspector(
    request: RegisterRequest,
    ss: StorageService = Depends(create_storage_service)
):
    email_safe = str(request.email).strip()
    logger.info(f"Запрос на регистрацию нового инспектора: {email_safe}")
    try:
        uid = ss.register_inspector(
            email=str(request.email).strip().lower(),
            password=request.password,
            full_name=request.full_name
        )
        logger.info(f"Инспектор успешно зарегистрирован. UID: {uid}")
        return {"user_id": uid, "status": "created", "role": "inspector"}

    except ValueError as e:
        logger.warning(f"Ошибка регистрации для {email_safe}: {str(e)}")
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.error(f"Ошибка сервера при регистрации {email_safe}: {str(e)}", exc_info=True)
        raise HTTPException(status_code=500, detail=f"Ошибка сервера: {str(e)}")

@router.post("/login")
def login_inspector(
    user: User = Depends(require_inspector)
):
    logger.info(f"Успешный вход инспектора: {user.email} (ID: {user.user_id})")
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