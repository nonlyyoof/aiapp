@echo off
REM Cleanup script - Removes unused Java services and files
REM This keeps the project clean and focused on Ollama + Python ML Service

echo ========================================
echo AI App Project Cleanup
echo ========================================

REM Remove duplicate src directory
if exist "c:\aiapp\src\" (
    echo [1/5] Removing duplicate src directory...
    rmdir /s /q "c:\aiapp\src"
    echo ✓ Removed c:\aiapp\src\
)

REM Remove tessdata_temp directory (Tesseract can use it dynamically)
if exist "c:\aiapp\tessdata_temp\" (
    echo [2/5] Removing tessdata_temp directory...
    rmdir /s /q "c:\aiapp\tessdata_temp"
    echo ✓ Removed c:\aiapp\tessdata_temp\
)

REM Remove unused Java service files
setlocal enabledelayedexpansion
set services=HuggingFaceService.java MessageService.java QueueService.java ScheduleService.java WordService.java
set count=0
for %%S in (!services!) do (
    set /A count=!count!+1
    set "service=%%S"
    if exist "c:\aiapp\aiapp\src\main\java\com\example\aiapp\service\!service!" (
        echo [3/5] Removing unused service: !service!...
        del /q "c:\aiapp\aiapp\src\main\java\com\example\aiapp\service\!service!"
        echo ✓ Removed !service!
    )
)

echo.
echo ========================================
echo ✓ CLEANUP COMPLETE
echo ========================================
echo.
echo Removed:
echo   - Duplicate src directory
echo   - tessdata_temp directory
echo   - HuggingFaceService.java (replaced by Ollama)
echo   - MessageService.java (use MessageRepository)
echo   - QueueService.java (unused)
echo   - ScheduleService.java (no endpoint)
echo   - WordService.java (experimental)
echo.
echo Keep:
echo   - AIService.java (main AI service)
echo   - OllamaService.java (Ollama integration)
echo   - MLGatewayService.java (Python ML proxy)
echo   - UserService.java (user management)
echo.
pause
