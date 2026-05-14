from imports import uvicorn, logging
from config import settings
from server_backend.services.storage_service import StorageService
from server_backend.server.logger import LOGGING_CONFIG

logger = logging.getLogger(__name__)

'''
запуск сервера и всей программы
'''
if __name__ == "__main__":
    service = StorageService()
    logger.info("Запуск сервера...")
    uvicorn.run(
        "server_backend.server.server:server_app",
        host=settings.SERVER_HOST,
        port=settings.SERVER_PORT,
        log_config=LOGGING_CONFIG,
    )


