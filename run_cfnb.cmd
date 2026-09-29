@echo off
setlocal EnableExtensions
cd /d "%~dp0"

set "SRC=main.py"
set "RUNTIME=_main_cfnb_runtime.py"

if not exist "%SRC%" (
    echo ERROR: main.py not found.
    exit /b 1
)

if exist "%RUNTIME%" (
    del /q "%RUNTIME%" >nul 2>&1
)

copy /y "%SRC%" "%RUNTIME%" >nul

if errorlevel 1 (
    echo ERROR: failed to create runtime copy of main.py.
    exit /b 1
)

echo ========================================
echo CFNB - Checking HTTP protocol patch
echo ========================================

python -c "from pathlib import Path; p=Path(r'_main_cfnb_runtime.py'); b=p.read_bytes(); old=b'--http2'; new=b'--http1.1'; n=b.count(old); ok=(n>0 or new in b); p.write_bytes(b.replace(old,new)) if n else None; print(('PATCHED: '+str(n)+' occurrence(s) --http2 -> --http1.1') if n else ('OK: --http1.1 already present' if new in b else 'ERROR: no supported curl protocol flag found')); raise SystemExit(0 if ok else 2)"

if errorlevel 1 (
    del /q "%RUNTIME%" >nul 2>&1
    echo ERROR: HTTP protocol patch check failed.
    exit /b 1
)

echo.
echo ========================================
echo CFNB - Starting test
echo ========================================

python "%RUNTIME%"
set "CFNB_EXIT=%ERRORLEVEL%"

del /q "%RUNTIME%" >nul 2>&1

if not "%CFNB_EXIT%"=="0" (
    echo.
    echo ERROR: cfnb test failed with code %CFNB_EXIT%.
    exit /b %CFNB_EXIT%
)

echo.
echo ========================================
echo CFNB - Test completed
echo Syncing ip.txt to GitHub...
echo ========================================

call "%~dp0git_sync.cmd"

if errorlevel 1 (
    echo.
    echo ERROR: GitHub sync failed.
    exit /b 1
)

echo.
echo ========================================
echo DONE
echo ========================================

endlocal
exit /b 0
