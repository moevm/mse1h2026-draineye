from app.imports import os, load_dotenv, Path

'''загружаем переменные из .env файла'''
env_path = Path(__file__).parent.parent / '.env'
load_dotenv(dotenv_path=env_path)

'''класс для управления настройками сервера и Firebase'''
class SettingsForServer:
    FIREBASE_CREDENTIALS: str = os.getenv("FIREBASE_CREDENTIALS")
    PROJECT_GOOGLE_ID: str = os.getenv("PROJECT_GOOGLE_ID")
    SERVER_PORT: int = int(os.getenv("SERVER_PORT", 8000))
    SERVER_HOST: str = os.getenv("SERVER_HOST", "0.0.0.0")
    '''формирует полный путь к файлу с credentials Firebase'''
    @property
    def FIREBASE_CREDENTIALS_PATH(self):
        project_root = Path(__file__).parent.parent
        return str(project_root / self.FIREBASE_CREDENTIALS)

'''глобальный экземпляр настроек для использования'''
settings = SettingsForServer()
