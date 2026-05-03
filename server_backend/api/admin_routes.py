from server_backend.services.storage_service import StorageService
from server_backend.imports import APIRouter, Depends, HTTPException
from server_backend.models import User
from server_backend.schemas.auth_request import RegisterRequest
from server_backend.server.auth import  require_admin

router = APIRouter(
    prefix="/admin",
    tags=["Admin & Auth"]
)

'''создание экземпляра FirebaseService'''
def create_storage_service() -> StorageService:
    return StorageService()

'''endpoint для регистрации администратора'''
@router.post("/register/admin", status_code=201)
def register_admin(
    request: RegisterRequest,
    ss: StorageService = Depends(create_storage_service)
):
    try:
        uid = ss.register_admin(
            email=str(request.email).strip().lower(),
            password=request.password,
            full_name=request.full_name
        )
        return {"user_id": uid, "status": "created", "role": "admin"}

    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Ошибка сервера: {str(e)}")

@router.post("/login/admin")
def login_admin(
    user: User = Depends(require_admin)
):
    return {
        "status": "success",
        "user_id": user.user_id,
        "role": user.role.value,
        "full_name": user.full_name,
        "email": user.email,
        "message": "Вход выполнен успешно"
    }