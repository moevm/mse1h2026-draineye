from app.imports import uvicorn
from app.config import settings
from app.services import StorageService

'''
запуск сервера и всей программы
'''
if __name__ == "__main__":
    service = StorageService()
    print("Запуск сервера...")
    uvicorn.run(
        "app.server.server:server_app",
        host=settings.SERVER_HOST,
        port=settings.SERVER_PORT,
    )



