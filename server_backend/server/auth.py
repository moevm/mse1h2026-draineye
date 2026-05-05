from server_backend.imports import Depends, HTTPException, status, Header, Optional, auth
from server_backend.services.storage_service import StorageService
from server_backend.models.user import User, UserRole

'''извлекает токен из заголовка Authorization'''
def get_token_from_header(authorization: Optional[str] = Header(default=None)) -> str:
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Отсутствует или неверный токен авторизации"
        )
    return authorization.replace("Bearer ", "")

'''проверяет токен и возвращает объект пользователя'''
def get_current_user(
    token: str = Depends(get_token_from_header),
    ss: StorageService = Depends(lambda: StorageService())
) -> User:
    uid = ss.verify_token(token)
    if not uid:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Неверный или истёкший токен"
        )
    try:
        user_record = auth.get_user(uid)
        if not user_record.email_verified:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Пожалуйста, подтвердите ваш email по ссылке из письма"
            )
    except auth.UserNotFoundError:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Пользователь не найден в системе аутентификации"
        )
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Ошибка проверки статуса пользователя"
        )

    user = ss.get_user(uid)
    if not user or not user.get_is_active():
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Пользователь не найден или заблокирован"
        )

    ss.log_activity(uid)
    return user

'''проверяет, что пользователь является администратором'''
def require_admin(user: User = Depends(get_current_user)) -> User:
    if not user.is_admin():
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Доступ запрещён: требуются права администратора"
        )
    return user

'''проверяет, что пользователь является инспектором'''
def require_inspector(user: User = Depends(get_current_user)) -> User:
    if user.role != UserRole.INSPECTOR:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Доступ запрещён: требуются права инспектора"
        )
    return user