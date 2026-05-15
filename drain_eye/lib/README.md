## Запуск Flutter web для разработки

Из-за того, что бэкенд проброшен через `tuna.am`, а фронт запускается на `localhost`,
браузер блокирует cross-origin запросы к API (CORS). Пока на сервере не настроены
CORS-заголовки, для локальной разработки используется Chrome с отключённой
проверкой Same-Origin Policy.

### 1. Запустить Flutter web

В папке `drain_eye/`:

```powershell
flutter run -d chrome
```

Flutter сам откроет обычный Chrome — это окно нам **не нужно**, в нём CORS заблокирует
запросы к API. Нужен только URL вида `http://localhost:XXXXX`, который Flutter
напечатает в консоли.

### 2. Открыть приложение в специально запущенном Chrome

В отдельном терминале:

```powershell
& "C:\Program Files\Google\Chrome\Application\chrome.exe" `
    --disable-web-security `
    --user-data-dir="C:\tmp\chrome_dev"
```

Откроется отдельное окно Chrome с изолированным профилем. **Вставь в адресную строку
URL из шага 1** (`http://localhost:XXXXX`) — приложение будет работать без ошибок CORS.

**Что делают флаги:**
- `--disable-web-security` — отключает проверку Same-Origin Policy, чтобы фронт
  на `localhost` мог обращаться к API на `https://...tuna.am` без ошибок CORS.
- `--user-data-dir="C:\tmp\chrome_dev"` — запускает Chrome с изолированным
  профилем. Это **обязательно**: иначе флаг `--disable-web-security` игнорируется,
  если параллельно открыт обычный Chrome. Также это изолирует небезопасный режим
  от твоего основного профиля с паролями и расширениями.